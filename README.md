# open-xg-statsbomb-pipeline

Reproducible expected-goals (xG) pipeline using StatsBomb Open Data in R.

This repository contains the R code used in the manuscript:

> Building Reproducible Expected-Goals Models from Public Football Event Data: Logistic and Mixed-Effects Analysis Using StatsBomb Open Data

## Data

All event data are from the public **StatsBomb Open Data** repository:

- https://github.com/statsbomb/open-data

The analysis uses:

- La Liga 2015/2016
- FIFA World Cup 2018

Users must comply with StatsBomb’s attribution guidelines when using the data.

## Requirements

- R (>= 4.2)
- Recommended packages:
  - `StatsBombR`
  - `dplyr`, `tidyr`, `purrr`, `ggplot2`
  - `lme4`, `pROC`, `broom`

Install packages (example):

```r
install.packages(c(
  "dplyr", "tidyr", "purrr", "ggplot2",
  "lme4", "pROC", "broom"
))
remotes::install_github("statsbomb/StatsBombR")
## Reproducing the analysis

From an R session opened in a local copy of this repository, run:

```r
source("R/01_data_download.R")
source("R/02_feature_engineering.R")
source("R/03_models_and_figures.R")

