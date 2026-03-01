# 01_data_download.R
# Download and assemble StatsBomb Open Data for La Liga 2015/2016 and World Cup 2018

if (!requireNamespace("StatsBombR", quietly = TRUE)) {
  stop("Please install StatsBombR first: remotes::install_github('statsbomb/StatsBombR')")
}

library(StatsBombR)
library(dplyr)

if (!dir.exists("data")) dir.create("data")

comps <- FreeCompetitions()

wc18 <- comps %>%
  filter(competition_name == "FIFA World Cup",
         season_name == "2018")

laliga1516 <- comps %>%
  filter(competition_name == "La Liga",
         season_name == "2015/2016")

wc_matches  <- FreeMatches(wc18)
la_matches  <- FreeMatches(laliga1516)

all_matches <- bind_rows(wc_matches, la_matches)

events <- free_allevents(MatchesDF = all_matches)

saveRDS(events, file = "data/events_statsbomb.rds")
