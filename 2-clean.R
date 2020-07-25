#!/usr/bin/env Rscript

library(arrow)
library(tidyverse)

# Clean the na_summary_preprocessed file--mostly removing.
df <- read_feather("data/na_summary_preprocessed.feather")

# See data_validation for justification.
df <- filter(df,isin != "US30224P2002")

# There are some duplicates. we retain only unique observations
df <- unique(df)

# In some cases, there are multiple diverging observations for the same person.
# We address that by first filling NAs and then removing remaining offending observations.
df$nas <- rowSums(is.na(df))
df <- df %>%
    group_by(isin, annualreportdate, directorid) %>%
    arrange(nas) %>%
    fill(totalcompensation, eqlinkremratio) %>%
    select(-nas) %>%
    unique()

inconsistencies <- df %>%
    group_by(isin, annualreportdate, directorid) %>%
    distinct() %>%
    summarize(n = n()) %>%
    filter(n>1) %>%
    select(-directorid)
inconsistencies$inconsistent <- TRUE

df <- df %>%
    left_join(inconsistencies, by = c("isin", "annualreportdate")) %>%
    filter(!inconsistent %in% c(TRUE)) %>%
    select(-inconsistent)

write_feather(df, "data/na_summary_cleaned.feather")
