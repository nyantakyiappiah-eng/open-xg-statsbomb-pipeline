# ============================================================
# 04_figures.R
# Generate publication-quality figures
# 
# Figures:
#   - Figure 1: Shot distance vs goal probability
#   - Figure 2: Calibration plot (deciles)
#   - Figure 3: ROC curves
# ============================================================

# Load required libraries
library(dplyr)
library(ggplot2)
library(pROC)

# Load data and models
shots_model <- readRDS("data/shots_model.rds")
m1 <- readRDS("output/m1.rds")
m2 <- readRDS("output/m2.rds")
m3 <- readRDS("output/m3.rds")
cv_predictions <- readRDS("output/cv_predictions.rds")

# ============================================================
# Figure 1: Shot distance vs goal probability
# ============================================================

shots_model$outcome <- factor(shots_model$goal, levels = c(0, 1), labels = c("Non-goal", "Goal"))

fig1 <- ggplot(shots_model, aes(x = distance, y = goal)) +
  geom_point(alpha = 0.3, size = 0.8, color = "gray40") +
  geom_smooth(method = "glm", method.args = list(family = binomial),
              se = TRUE, color = "blue", fill = "lightblue") +
  labs(x = "Distance to goal (StatsBomb units)",
       y = "Probability of goal") +
  theme_minimal(base_size = 11) +
  theme(panel.grid.minor = element_blank(),
        panel.border = element_rect(fill = NA, color = "black", linewidth = 0.5))

tiff("output/Figure1.tiff", width = 90, height = 80, units = "mm", res = 300, compression = "lzw")
print(fig1)
dev.off()
cat("Figure 1 saved to output/Figure1.tiff\n")

# ============================================================
# Figure 2: Calibration plot
# ============================================================

# Generate predictions for M3
shots_model$pred_m3 <- predict(m3, type = "response")

calibration <- shots_model %>%
  mutate(decile = cut(pred_m3, breaks = quantile(pred_m3, probs = seq(0, 1, 0.1)), include.lowest = TRUE)) %>%
  group_by(decile) %>%
  summarise(
    predicted = mean(pred_m3),
    observed = mean(goal),
    n = n(),
    se = sqrt(observed * (1 - observed) / n)
  )

fig2 <- ggplot(calibration, aes(x = predicted, y = observed)) +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed", linewidth = 0.7, color = "black") +
  geom_errorbar(aes(ymin = observed - se, ymax = observed + se),
                width = 0.01, color = "gray50", linewidth = 0.5) +
  geom_point(size = 2.5, color = "#0066CC") +
  labs(x = "Predicted probability", y = "Observed proportion") +
  coord_fixed(xlim = c(0, 0.45), ylim = c(0, 0.45)) +
  theme_classic(base_size = 10) +
  theme(panel.border = element_rect(fill = NA, color = "black", linewidth = 0.5),
        axis.text = element_text(size = 9), axis.title = element_text(size = 10))

tiff("output/Figure2.tiff", width = 90, height = 80, units = "mm", res = 300, compression = "lzw")
print(fig2)
dev.off()
cat("Figure 2 saved to output/Figure2.tiff\n")

# ============================================================
# Figure 3: ROC curves
# ============================================================

shots_model$pred_m1 <- predict(m1, type = "response")
shots_model$pred_m2 <- predict(m2, type = "response")

roc_m1 <- roc(shots_model$goal, shots_model$pred_m1)
roc_m2 <- roc(shots_model$goal, shots_model$pred_m2)
roc_m3 <- roc(shots_model$goal, shots_model$pred_m3)

roc_df <- data.frame(
  fpr = c(1 - roc_m1$specificities, 1 - roc_m2$specificities, 1 - roc_m3$specificities),
  tpr = c(roc_m1$sensitivities, roc_m2$sensitivities, roc_m3$sensitivities),
  model = factor(rep(c("M1 (AUC = 0.74)", "M2 (AUC = 0.75)", "M3 (AUC = 0.797)"),
                     times = c(length(roc_m1$specificities), length(roc_m2$specificities), length(roc_m3$specificities))))
)

fig3 <- ggplot(roc_df, aes(x = fpr, y = tpr, color = model, linetype = model)) +
  geom_line(linewidth = 1) +
  geom_abline(intercept = 0, slope = 1, linetype = "dotted", color = "black", linewidth = 0.5) +
  scale_color_manual(values = c("black", "blue", "red")) +
  labs(x = "1 - Specificity (False positive rate)", y = "Sensitivity (True positive rate)") +
  coord_fixed() +
  theme_minimal(base_size = 11) +
  theme(legend.position = c(0.7, 0.25), legend.title = element_blank(),
        legend.background = element_rect(fill = "white", color = "gray80", linewidth = 0.3),
        panel.grid.minor = element_blank(),
        panel.border = element_rect(fill = NA, color = "black", linewidth = 0.5))

tiff("output/Figure3.tiff", width = 90, height = 80, units = "mm", res = 300, compression = "lzw")
print(fig3)
dev.off()
cat("Figure 3 saved to output/Figure3.tiff\n")

cat("All figures generated successfully!\n")
