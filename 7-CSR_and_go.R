#!/usr/bin/env Rscript

library(arrow)
library(tidyverse)
library(openxlsx)

# CSR_hand_matched was created on the basis of CSR_auto_merged, in an iterative
# appraoch to fill in missing values.
matching <- read.xlsx("data/CSR_hand_matched.xlsx")
CSR <- read.xlsx("data/CSR Master Database_Final Oct. 30.xlsx", check.names = T)
compustat <- read_feather("data/compustat.feather")

compustat <- filter(compustat, !is.na(gvkey))

CSR_compustat <- CSR %>%
  left_join(matching, by = "Company.name") %>%
  select(-name_clean) %>%
  left_join(compustat, by = "gvkey")

write.xlsx(CSR_compustat, "data/CSR_compustat.xlsx")
write_feather(CSR_compustat, "data/CSR_compustat.feather")
write_csv(CSR_compustat, "data/CSR_compustat.csv")
