#!/usr/bin/env Rscript

library(arrow)
library(tidyverse)

# Preprocess na_summary
temp <- read_feather("data/na_summary.feather")

temp <- filter(temp, !is.na(annualreportdate))
temp <- filter(temp, !is.na(isin))
temp$annualreportdate <- lubridate::as_date(temp$annualreportdate)

write_feather(temp, "data/na_summary_preprocessed.feather")
