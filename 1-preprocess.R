#!/usr/bin/env Rscript

library(arrow)
library(tidyverse)

##  Preprocess na_summary
df <- read_feather("data/na_summary.feather")

df <- filter(df, !is.na(annualreportdate))
df <- filter(df, !is.na(isin))
# I noticed by chance that these are not board members!
df <- filter(df, rowtype != "Disclosed Earner")
df$cusip <- stringr::str_sub(df$isin, 3, 11)
df$annualreportdate <- lubridate::as_date(df$annualreportdate)
df <- df %>%
    select(boardname, gender, boardid, directorid, timebrd, annualreportdate, totalcompensation, 
           eqlinkremratio, directorid, isin, genderratio, nationalitymix, numberdirectors, cusip)
df <- unique(df)
write_feather(df, "data/na_summary_preprocessed.feather")



## Grab gender for directors (we validated column in data_validation)
gender <- df %>%
    select(directorid, gender) %>%
    group_by(directorid) %>%
    summarize(gender = first(gender))
write_feather(gender, "data/gender.feather")



## Extract relevant columns & companies from compa
compa <- read_feather("data/compa.feather")
compa <- select(compa, gvkey, fyear, cusip, apdedate, at, emp, dltt, ceq, act, lct, bkvlps, csho)
write_feather(compa, "data/compa_preprocessed.feather")



## Extract relevant columns for board dataset and retain only unique entries
boards <- read_feather("data/na_boards.feather")
boards <- select(boards, -c(functionalexperience, ned, boardrole, brdposition))
boards <- unique(boards)
write_feather(boards, "data/na_boards_preprocessed.feather")



# Grab date of birth
age <- read_feather("data/age.feather")
age$age <- as.integer(age$age)
age <- select(age, directorid, age)
age <- rename(age, "age_2020" = "age")
write_feather(age, "data/age_preprocessed.feather")
