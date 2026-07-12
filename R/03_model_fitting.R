# ============================================================
# 03_model_fitting.R
# Fit logistic regression and GLMM models
# 
# This script fits:
#   - M1: Distance-only logistic regression
#   - M2: Distance + goal-opening angle
#   - M3: Full logistic model
#   - M4: GLMM with shooter random intercept
# 
# It also performs grouped 10-fold cross-validation.
# ============================================================

# Load required libraries
library(dplyr)
library(lme4)
library(pROC)
library(performance)
library(rsample)
library(broom)

# Load processed data
shots_model <- readRDS("data/shots_model.rds")

# ============================================================
# STEP 1: Fit models
# ============================================================

# Model 1: Distance only
m1 <- glm(
  goal ~ distance,
  family = binomial,
  data = shots_model
)

# Model 2: Distance + goal-opening angle
m2 <- glm(
  goal ~ distance + angle_deg,
  family = binomial,
  data = shots_model
)

# Model 3: Full logistic model
m3 <- glm(
  goal ~ distance + angle_deg + body_part + technique + first_time + under_pressure,
  family = binomial,
  data = shots_model
)

# Model 4: GLMM with shooter random intercept
glmm <- glmer(
  goal ~ distance + angle_deg + body_part + technique + first_time + under_pressure +
    (1 | player_id),
  family = binomial,
  data = shots_model,
  control = glmerControl(
    optimizer = "bobyqa",
    optCtrl = list(maxfun = 200000)
  )
)

# ============================================================
# STEP 2: Odds ratios and confidence intervals
# ============================================================

OR <- exp(coef(m3))
CI <- exp(confint(m3))
P <- coef(summary(m3))[, 4]

OR_table <- data.frame(
  Variable = names(OR),
  Odds_Ratio = OR,
  Lower95CI = CI[, 1],
  Upper95CI = CI[, 2],
  P_value = P,
  row.names = NULL
)

print(OR_table)

# ============================================================
# STEP 3: Cross-validation
# ============================================================

set.seed(12345)

folds <- group_vfold_cv(shots_model, group = match_id, v = 10)

formula_m3 <- goal ~ distance + angle_deg + body_part + technique + first_time + under_pressure

cv_predictions <- map_dfr(folds$splits, function(split) {
  train <- analysis(split)
  test <- assessment(split)
  model <- glm(formula_m3, family = binomial, data = train)
  test$pred <- predict(model, newdata = test, type = "response")
  test
})

# ============================================================
# STEP 4: Cross-validated metrics
# ============================================================

# Cross-validated Brier score
cv_brier <- mean((cv_predictions$goal - cv_predictions$pred)^2)

# Cross-validated log loss
eps <- 1e-15
p <- pmin(pmax(cv_predictions$pred, eps), 1 - eps)
cv_logloss <- -mean(cv_predictions$goal * log(p) + (1 - cv_predictions$goal) * log(1 - p))

cat("Cross-validated Brier score:", cv_brier, "\n")
cat("Cross-validated log loss:", cv_logloss, "\n")

# ============================================================
# STEP 5: Save models and predictions
# ============================================================

saveRDS(m1, "output/m1.rds")
saveRDS(m2, "output/m2.rds")
saveRDS(m3, "output/m3.rds")
saveRDS(glmm, "output/glmm.rds")
saveRDS(cv_predictions, "output/cv_predictions.rds")
saveRDS(OR_table, "output/OR_table.rds")

cat("All models saved to output/\n")
