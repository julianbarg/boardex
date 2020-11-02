#!/usr/bin/env Rscript

library(arrow)
library(tidyverse)
library(lubridate)

# Add SIC to compa

orgs <- read_feather("data/na_summary_ready.feather")
compa <- read_feather("data/compa_cleaned.feather")
names <- read_feather("data/names.feather")
board <- read_feather("data/board_characteristics.feather")

names <-select(names, gvkey, cik, sic, naics, gsubind, gind)
compa <- compa %>%
    left_join(names, by = "gvkey") %>%
    mutate(gsector = stringr::str_sub(gind, 1, 2)) %>%
    rename(c("year" = "fyear"))
write_feather(compa, "data/compustat_only.feather")

orgs <- orgs %>%
    left_join(board, by = c("boardid", "annualreportdate"))
orgs$cusip <- stringr::str_sub(orgs$isin, 3, 11)
write_feather(orgs, "data/boardex_only.feather")

orgs <- orgs %>%
    mutate(year = year(annualreportdate)) %>%
    group_by(isin, year) %>%
    filter(annualreportdate == min(annualreportdate))



# Match by year
orgs_compa <- left_join(orgs, compa, by=c("year", "cusip"))

orgs_compa <- subset(orgs_compa, year >= 2015 & year <= 2018)

orgs_compa <- ungroup(orgs_compa)

write_feather(orgs_compa, "data/preliminary.feather")
