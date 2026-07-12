# Interpretable Expected Goals Models in Soccer: A Reproducible Pipeline with StatsBomb Open Data

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.XXXXXXX.svg)](https://doi.org/10.5281/zenodo.XXXXXXX)

This repository contains the complete R code for the manuscript:

**"Interpretable Expected Goals Models in Soccer: A Reproducible Pipeline with StatsBomb Open Data"**  
*Kofi Nyantakyi Appiah, Nathanael Adu, Divyanshu Kumar Singh, Edward Edem Nartey*  
*International Journal of Data Science and Analytics*

---

## 📋 Overview

This repository provides a fully reproducible pipeline for building interpretable expected goals (xG) models from public StatsBomb event data.

### What this pipeline does:
- **Data extraction** from StatsBomb Open Data JSON files
- **Feature engineering** including goal-opening angle calculation
- **Model fitting** (logistic regression and GLMM with shooter random intercepts)
- **Model evaluation** (AUC, Brier score, log loss, calibration plots)
- **Cross-validation** (grouped 10-fold CV by match)

---

## 📊 Data

All event data are from the public **StatsBomb Open Data** repository:

- Repository: [https://github.com/statsbomb/open-data](https://github.com/statsbomb/open-data)
- Competitions used:
  - **La Liga 2015/2016** (competition_id = 11, season_id = 27)
  - **FIFA World Cup 2018** (competition_id = 43, season_id = 3)
- Total matches: 444
- Total non-penalty shots: 10,709

**Citation:**
> StatsBomb. (2023). StatsBomb Open Data. GitHub. https://github.com/statsbomb/open-data

---

## 🔧 Requirements

### R Version
- R (>= 4.5.2)

### Required Packages
| Package | Version | Purpose |
| :--- | :---: | :--- |
| jsonlite | 2.0.0 | JSON parsing |
| dplyr | 1.2.1 | Data manipulation |
| purrr | 1.2.2 | Functional programming |
| tidyr | 1.3.2 | Data tidying |
| readr | 2.2.0 | Data reading |
| ggplot2 | 3.5.1 | Visualisation |
| lme4 | 2.0-1 | Mixed-effects models |
| pROC | 1.19.0.1 | ROC analysis |
| performance | 0.17.1 | Model diagnostics |
| rsample | 1.3.2 | Cross-validation |
| DescTools | 0.99.60 | Utility functions |
| broom | 1.0.13 | Model tidying |

### Install Packages
```r
install.packages(c(
  "jsonlite", "dplyr", "purrr", "tidyr", "readr", "tibble",
  "ggplot2", "lme4", "pROC", "performance", "rsample",
  "DescTools", "broom", "magrittr"
))
