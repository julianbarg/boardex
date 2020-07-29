#!/usr/bin/env Rscript

library(arrow)
library(tidyverse)

# Clean the na_summary_preprocessed file--mostly removing.
df <- read_feather("data/na_summary_preprocessed.feather")

# See data_validation for justification.
df <- filter(df,isin != "US30224P2002")

# In some cases, there are multiple diverging observations for the same person.
# We address that by first filling NAs and then removing a low number of remaining offending observations.
df$nas <- rowSums(is.na(df))
df <- df %>%
    group_by(isin, annualreportdate, directorid) %>%
    arrange(nas) %>%
    fill(totalcompensation, valtoteqheld) %>%
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



# Compa has a distinct pattern where there are some duplicate, very incomplete observations.
# We retain more complete observations.
df <- read_feather("data/compa_preprocessed.feather")
df$nas <- rowSums(is.na(df))
df <- df %>%
    group_by(gvkey, fyear) %>%
    filter(nas == min(nas)) %>%
    select(-nas)

# The remaining conflicts we can resolve through the use of the fill function
df <- df %>%
    group_by(gvkey, fyear) %>%
    fill(apdedate, at, emp, dltt, ceq, act, lct, bkvlps, csho, .direction = "downup") %>%
    unique()

# Now, this should generate an empty dataframe:
# df %>%
#     group_by(gvkey, fyear) %>%
#     mutate(n = n()) %>%
#     filter(n > 1) %>%
#     arrange(desc(gvkey, fyear))

write_feather(df, "data/compa_cleaned.feather")
