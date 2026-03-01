# 03_models_and_figures.R
# Fit models and generate figures

library(dplyr)
library(ggplot2)
library(lme4)
library(pROC)
library(broom)
library(purrr)
library(tidyr)

if (!dir.exists("figures")) dir.create("figures")

shots <- readRDS("data/shots_features.rds")

# Models
m_base <- glm(goal ~ shot_dist + shot_angle,
              data = shots, family = binomial)

m_fix <- glm(goal ~ shot_dist + shot_angle + body_part + competition,
             data = shots, family = binomial)

m_mix <- glmer(goal ~ shot_dist + shot_angle + body_part + competition +
                 (1 | player.id),
               data = shots, family = binomial,
               control = glmerControl(optimizer = "bobyqa"))

# Predictions and AUC
shots$pred_base <- predict(m_base, type = "response")
shots$pred_fix  <- predict(m_fix,  type = "response")
shots$pred_mix  <- predict(m_mix,  type = "response")

roc_base <- roc(shots$goal, shots$pred_base)
roc_fix  <- roc(shots$goal, shots$pred_fix)
roc_mix  <- roc(shots$goal, shots$pred_mix)

# Figure 1: distance vs outcome with logistic curve
shots_plot <- shots %>%
  mutate(goal = as.factor(goal))

newdat <- tibble(
  shot_dist  = seq(min(shots$shot_dist, na.rm = TRUE),
                   max(shots$shot_dist, na.rm = TRUE),
                   length.out = 200),
  shot_angle = median(shots$shot_angle, na.rm = TRUE)
)

newdat$pred_prob <- predict(m_base, newdata = newdat, type = "response")

fig1 <- ggplot(shots_plot, aes(x = shot_dist, y = as.numeric(as.character(goal)))) +
  geom_jitter(height = 0.03, width = 0, alpha = 0.15, size = 0.5) +
  geom_line(data = newdat, aes(x = shot_dist, y = pred_prob),
            colour = "red", size = 1) +
  scale_y_continuous("Goal (0 = no, 1 = yes)",
                     limits = c(-0.05, 1.05),
                     breaks = c(0, 1)) +
  scale_x_continuous("Shot distance to goal (StatsBomb units)") +
  theme_minimal()

ggsave("figures/figure1.png", fig1, width = 6, height = 4, dpi = 300)

# Figure 2: mean predicted xG by outcome and model
fig2_dat <- shots %>%
  mutate(goal = factor(goal, levels = c(0, 1),
                       labels = c("Non-goal", "Goal"))) %>%
  summarise(
    mean_xg_base = mean(pred_base, na.rm = TRUE),
    mean_xg_fix  = mean(pred_fix,  na.rm = TRUE),
    mean_xg_mix  = mean(pred_mix,  na.rm = TRUE),
    .by = goal
  ) %>%
  pivot_longer(
    cols = starts_with("mean_xg_"),
    names_to = "model",
    values_to = "mean_xg"
  ) %>%
  mutate(
    model = factor(model,
                   levels = c("mean_xg_base", "mean_xg_fix", "mean_xg_mix"),
                   labels = c("Baseline", "Fixed effects", "Mixed effects"))
  )

fig2 <- ggplot(fig2_dat, aes(x = model, y = mean_xg, fill = goal)) +
  geom_col(position = position_dodge(width = 0.6), width = 0.55) +
  scale_fill_manual(values = c("grey70", "steelblue")) +
  labs(x = "Model", y = "Mean predicted xG", fill = "Outcome") +
  theme_minimal()

ggsave("figures/figure2.png", fig2, width = 6, height = 4, dpi = 300)

# Figure 3: ROC curves
roc_base_df <- data.frame(
  fpr  = 1 - roc_base$specificities,
  tpr  = roc_base$sensitivities,
  model = "Baseline"
)

roc_fix_df <- data.frame(
  fpr  = 1 - roc_fix$specificities,
  tpr  = roc_fix$sensitivities,
  model = "Fixed effects"
)

roc_mix_df <- data.frame(
  fpr  = 1 - roc_mix$specificities,
  tpr  = roc_mix$sensitivities,
  model = "Mixed effects"
)

roc_df <- bind_rows(roc_base_df, roc_fix_df, roc_mix_df)

auc_base <- auc(roc_base)
auc_fix  <- auc(roc_fix)
auc_mix  <- auc(roc_mix)

roc_df <- roc_df %>%
  mutate(
    model = factor(
      model,
      levels = c("Baseline", "Fixed effects", "Mixed effects"),
      labels = c(
        paste0("Baseline (AUC = ", round(auc_base, 3), ")"),
        paste0("Fixed effects (AUC = ", round(auc_fix, 3), ")"),
        paste0("Mixed effects (AUC = ", round(auc_mix, 3), ")")
      )
    )
  )

fig3 <- ggplot(roc_df, aes(x = fpr, y = tpr, colour = model)) +
  geom_line(size = 1) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", colour = "grey60") +
  scale_x_continuous("False positive rate (1 - specificity)", limits = c(0, 1)) +
  scale_y_continuous("True positive rate (sensitivity)", limits = c(0, 1)) +
  scale_colour_manual(values = c("black", "steelblue", "darkred")) +
  theme_minimal() +
  theme(legend.title = element_blank())

ggsave("figures/figure3.png", fig3, width = 6, height = 4, dpi = 300)
