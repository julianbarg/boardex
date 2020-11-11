#!/usr/bin/env Rscript

library(arrow)
library(tidyverse)
library(openxlsx)

CSR <- read_feather("data/CSR_compustat.feather")
compustat <- read_feather("data/compustat.feather")
CSR_orig <- read.xlsx("data/CSR Master Database_Final Oct. 30.xlsx",
                      check.names = T)

CSR_orig$match_ <- as.numeric(NA)
compustat$match_ <- as.numeric(NA)

# Some of the companies have been delisted. Some have duplicate delisted
# entries which are all identical.

CSR_orig[CSR_orig$Company.name == "United Technologies", ]$match_ <- 1
compustat[compustat$isin == "US75513E1010", ]$match_ <- 1

CSR_orig[CSR_orig$Company.name == "USAA", ]$match_ <- 2
compustat[compustat$isin == "US12542R3084", ]$match_ <- 2

CSR_orig[CSR_orig$Company.name == "Twenty-First Century Fox", ]$match_ <- 3
compustat[compustat$isin == "US90130A1016", ]$match_ <- 3

CSR_orig[CSR_orig$Company.name == "Supervalu", ]$match_ <- 4
compustat[compustat$isin == "US8685361037", ]$match_ <- 4

CSR_orig[CSR_orig$Company.name == "BB&T Corp", ]$match_ <- 5
compustat[compustat$isin == "US89832Q1094", ]$match_ <- 5

CSR_orig[CSR_orig$Company.name == "Xerox", ]$match_ <- 6
compustat[compustat$isin == "US98421M1062", ]$match_ <- 6

CSR_orig[CSR_orig$Company.name == "Frontier Communications", ]$match_ <- 7
compustat[compustat$isin == "US35906A1088", ]$match_ <- 7

CSR_orig[CSR_orig$Company.name == "Liberty Media", ]$match_ <- 8
compustat[compustat$isin == "US5312294094", ]$match_ <- 8

CSR_orig[CSR_orig$Company.name == "TravelCenters of America", ]$match_ <- 9
compustat[compustat$isin == "US89421B1098", ]$match_ <- 9

CSR_orig[CSR_orig$Company.name == "Blackstone Group", ]$match_ <- 10
compustat[compustat$isin == "US09260D1072", ]$match_ <- 10

CSR_orig[CSR_orig$Company.name == "Windstream Holdings", ]$match_ <- 11
compustat[compustat$isin == "US97382A2006", ]$match_ <- 11

new_entries <- CSR_orig[!is.na(CSR_orig$match_), ]$Company.name

CSR <- filter(CSR, !(Company.name %in% new_entries))

CSR <- compustat %>%
  filter(!is.na(match_)) %>%
  left_join(CSR_orig, by = "match_") %>%
  bind_rows(CSR)

write_feather(CSR, "data/CSR_manually_finalized.feather")
write.xlsx(CSR, "data/CSR_manually_finalized.xlsx")
write_csv(CSR, "data/CSR_manually_finalized.csv")
