# ============================================================
# 01_data_download.R
# Download and parse StatsBomb Open Data
# 
# This script downloads and processes StatsBomb Open Data
# for La Liga 2015/2016 and the 2018 FIFA World Cup.
#
# To run this script, you need:
#   - R (>= 4.5.2)
#   - Packages: jsonlite, dplyr, purrr, tidyr, readr
#
# Update the path below to point to your local StatsBomb data.
# ============================================================

# Load required libraries
library(jsonlite)
library(dplyr)
library(purrr)
library(tidyr)
library(readr)

# ============================================================
# STEP 1: Set path to StatsBomb data
# ============================================================

# UPDATE THIS PATH BEFORE RUNNING
sb_path <- "E:/open-data-master/open-data-master/data"

# File paths
competitions_file <- file.path(sb_path, "competitions.json")
matches_path <- file.path(sb_path, "matches")
events_path <- file.path(sb_path, "events")

# ============================================================
# STEP 2: Read competitions data
# ============================================================

competitions <- fromJSON(competitions_file)

cat("Total competitions:", nrow(competitions), "\n")

# Identify La Liga 2015/2016 and World Cup 2018
# La Liga: competition_id = 11, season_id = 27
# World Cup: competition_id = 43, season_id = 3

la_liga_id <- 11
la_liga_season <- 27
wc_id <- 43
wc_season <- 3

# ============================================================
# STEP 3: Read match metadata
# ============================================================

la_matches <- fromJSON(
  file.path(matches_path, "11", "27.json"),
  flatten = TRUE
)

wc_matches <- fromJSON(
  file.path(matches_path, "43", "3.json"),
  flatten = TRUE
)

cat("La Liga matches :", nrow(la_matches), "\n")
cat("World Cup matches:", nrow(wc_matches), "\n")
cat("Total matches:", nrow(la_matches) + nrow(wc_matches), "\n")

# Match IDs
la_match_ids <- la_matches$match_id
wc_match_ids <- wc_matches$match_id

# ============================================================
# STEP 4: Read event files
# ============================================================

# Function to read one event file
read_events <- function(match_id) {
  file <- file.path(events_path, paste0(match_id, ".json"))
  x <- fromJSON(file, flatten = TRUE)
  x$match_id <- match_id
  x
}

cat("Reading La Liga events...\n")
la_events <- purrr::map_dfr(la_match_ids, read_events)

cat("Reading World Cup events...\n")
wc_events <- purrr::map_dfr(wc_match_ids, read_events)

# Combine all events
events <- bind_rows(la_events, wc_events)

cat("Total events:", nrow(events), "\n")

# ============================================================
# STEP 5: Extract shots
# ============================================================

shots <- events %>% filter(type.name == "Shot")
cat("Total shots:", nrow(shots), "\n")

# Exclude penalties
shots_np <- shots %>% filter(shot.type.name != "Penalty")
cat("Non-penalty shots:", nrow(shots_np), "\n")

# ============================================================
# STEP 6: Save raw data
# ============================================================

saveRDS(shots_np, "data/shots_np_raw.rds")
cat("Raw shot data saved to data/shots_np_raw.rds\n")
