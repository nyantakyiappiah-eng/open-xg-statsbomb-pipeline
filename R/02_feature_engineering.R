# 02_feature_engineering.R
# Build shot-level dataset with distance, angle, body part, competition

library(dplyr)
library(purrr)

if (!dir.exists("data")) dir.create("data")

events <- readRDS("data/events_statsbomb.rds")

# Filter non-penalty, non-own-goal shots
shots <- events %>%
  filter(type.name == "Shot",
         shot.type.name != "Penalty",
         is.na(shot.outcome.name) | shot.outcome.name != "Own Goal") %>%
  select(match_id, competition_id, season_id, minute, second,
         team.name, player.id, player.name,
         location, shot.outcome.name, shot.body_part.name)

# Unpack coordinates
shots <- shots %>%
  mutate(
    x = map_dbl(location, 1),
    y = map_dbl(location, 2)
  ) %>%
  select(-location)

goal_x <- 120
goal_y <- 40

# Identify competitions
comps <- FreeCompetitions()
wc18 <- comps %>%
  filter(competition_name == "FIFA World Cup",
         season_name == "2018")
laliga1516 <- comps %>%
  filter(competition_name == "La Liga",
         season_name == "2015/2016")

shots <- shots %>%
  mutate(
    shot_dist  = sqrt((goal_x - x)^2 + (goal_y - y)^2),
    shot_angle = atan2(goal_y - y, goal_x - x),
    goal       = if_else(shot.outcome.name == "Goal", 1L, 0L),
    body_part  = if_else(shot.body_part.name == "Head", "head", "foot"),
    competition = case_when(
      competition_id == wc18$competition_id[1]       ~ "WorldCup2018",
      competition_id == laliga1516$competition_id[1] ~ "LaLiga2015_16",
      TRUE ~ "other"
    )
  )

saveRDS(shots, file = "data/shots_features.rds")
