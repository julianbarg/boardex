#!/usr/bin/env Rscript

library(arrow)
library(tidyverse)

#  Clean the preprocessed file--mostly removing 
temp <- read_feather("data/na_summary_preprocessed.feather")

# See data_validation for justification
temp<- filter(temp,isin != "US30224P2002")
temp <- temp %>%
    mutate(year = lubridate::year(annualreportdate)) %>%
    group_by(companyid, year) %>%
    mutate(n = n_distinct(annualreportdate)) %>%
    filter(n == 1) %>%
    ungroup() %>%
    select(-year, - n)

write_feather(temp, "data/na_summary_cleaned.feather")
