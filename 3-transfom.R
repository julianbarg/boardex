#!/usr/bin/env Rscript

library(arrow)
library(tidyverse)
library(lubridate)

# For na_summary_cleaned, move to company-year level

df <- read_feather("data/na_summary_cleaned.feather")
age <- read_feather("data/age_preprocessed.feather")
df <- left_join(df, age, by="directorid")
df <- df %>%
    mutate(interval = as.period(interval(start = date_birth, end = annualreportdate))) %>%
    mutate(age = year(interval) + month(interval)/12 + day(interval)/365)
df$female <- df$gender == "F"
df$female_compensation <- df$totalcompensation * df$female
df$equity_compensation <- df$totalcompensation * df$eqlinkremratio
df$female_equity_compensation <- df$equity_compensation * df$female

df <- df %>%
    group_by(isin, annualreportdate) %>%
    summarize(name = first(boardname),
              ned = first(ned), 
              genderratio = first(genderratio),
              avg_tenure = mean(timebrd), 
              avg_compensation = mean(totalcompensation),
              avg_compensation_na_rm = mean(totalcompensation, na.rm = T),
              avg_compensation_fm = mean(female_compensation), 
              avg_compensation_fm_na_rm = mean(female_compensation, na.rm = T),
              equity_compensation_fm = mean(female_equity_compensation), 
              equity_compensation_fm_na_rm = mean(female_equity_compensation, na.rm = T),
              nationalitymix = first(nationalitymix),
              numberdirectors = first(numberdirectors),
              members_check = n(),
              number_female = sum(female), 
              stdevage = first(stdevage),
              average_age = mean(age), 
              average_age_na_rm = mean(age, na.rm = T),
              stdevage_check = sd(age),
              stdevage_check_na_rm = sd(age, na.rm = T)
              )

write_feather(df, "data/na_summary_ready.feather")



# For na_boards, move to company-year level

df <- read_feather("data/na_boards_preprocessed.feather")
gender <- read_feather("data/gender.feather")

df <- left_join(df, gender, by="directorid")

df <- df %>%
    mutate(committee = stringr::str_to_lower(committeename), 
           female = gender == "F") %>%
    mutate(nominating = str_detect(committee, "nominat"), 
           audit = str_detect(committee, "audit"), 
           compensating = str_detect(committee, "compensate")) %>%
    group_by(boardid, annualreportdate) %>%
    summarize(number_nominating = sum(nominating), 
              number_audit = sum(audit), 
              number_compensating = sum(compensating), 
              number_nominating_female = sum(nominating & female), 
              number_audit_female = sum(audit & female), 
              number_compensating_female = sum(compensating & female))
write_feather(df, "data/board_characteristics.feather")
