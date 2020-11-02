#!/usr/bin/env Rscript

library(arrow)
library(tidyverse)
library(lubridate)

##  Preprocess na_summary
df <- read_feather("data/na_summary.feather")

df <- filter(df, !is.na(annualreportdate))
df <- filter(df, !is.na(isin))
# I noticed by chance that these are not board members!
df <- filter(df, rowtype != "Disclosed Earner")
df$cusip <- stringr::str_sub(df$isin, 3, 11)
df$annualreportdate <- as_date(df$annualreportdate)
df$ned <- df$ned == "Yes"
df <- df %>%
    select(boardname, ned, gender, boardid, directorid, timebrd, annualreportdate, totalcompensation,
           valtoteqheld, directorid, isin, genderratio, nationalitymix, numberdirectors, stdevage, cusip)
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
compa <- compa %>%
    group_by(gvkey, fyear) %>%
    mutate(has_apdedate = as.logical(max(!is.na(apdedate))),
           n = n())  %>%
    ungroup() %>%
    filter(n == 1 | has_apdedate) %>%
    select(-c(n, has_apdedate))
compa$apdedate <- as_date(compa$apdedate)
compa <- unique(compa)
write_feather(compa, "data/compa_preprocessed.feather")



## Extract relevant columns for board dataset and retain only unique entries
boards <- read_feather("data/na_boards.feather")
boards <- select(boards, -c(functionalexperience, ned, boardrole, brdposition))
boards <- unique(boards)
write_feather(boards, "data/na_boards_preprocessed.feather")



# Grab date of birth
age <- read_feather("data/age.feather")
age$dob <- na_if(age$dob, "n.a.")
age$date_birth <- parse_date_time(age$dob, orders=c("Y", "mY", "dmY"))
age <- select(age, directorid, date_birth)
write_feather(age, "data/age_preprocessed.feather")
