#!/usr/bin/env Rscript

library(arrow)
library(tidyverse)

# Clean the na_summary_preprocessed file--mostly removing.
df <- read_feather("data/na_summary_preprocessed.feather")

# See data_validation for justification.
df <- filter(df,isin != "US30224P2002")

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



# For compa, we also want to fill in data that might be available and then delete duplicates.
# We keep the earliest observation (where there are two), to retain full years where fiscal year end was changed.
# The largest number of duplicate observations is 4, so we repeat the step three times. To see, run:
# df %>%
#     group_by(gvkey, fyear) %>%
#     summarize(n = n()) %>%
#     arrange(desc(n)) %>%
#     head(20)
df <- read_feather("data/compa_preprocessed.feather")
df <- df %>%
    group_by(gvkey, fyear) %>%
    arrange(apdedate) %>%
    fill(at, emp, dltt, ceq, act, lct, bkvlps, csho, .direction = "up") %>%
    fill(at, emp, dltt, ceq, act, lct, bkvlps, csho, .direction = "up") %>%
    fill(at, emp, dltt, ceq, act, lct, bkvlps, csho, .direction = "up") %>%
    slice(1)
write_feather(df, "data/compa_cleaned.feather")
