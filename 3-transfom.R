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
# df$female_compensation <- df$totalcompensation * df$female
# df$female_equity_compensation <- df$valtoteqheld * df$female
# df$male_compensation <- df$totalcompensation * !df$female

# Board characteristics
boards <- df %>%
    group_by(isin, annualreportdate) %>%
    summarize(boardid = first(boardid),
              name = first(boardname),
              ned = first(ned),
              genderratio = first(genderratio),
              avg_tenure = mean(timebrd),
              avg_compensation = mean(totalcompensation),
              avg_compensation_na_rm = mean(totalcompensation, na.rm = T),
              equity_compensation = mean(valeqaward),
              equity_compensation_na_rm = mean(valeqaward, na.rm = T),
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

gender <- df %>%
    mutate(gender = recode(gender, "F" = "fm", "M" = "m")) %>%
    group_by(isin, annualreportdate, gender) %>%
    summarize(avg_compensation = mean(totalcompensation),
              equity_compensation = mean(valeqaward)) %>%
    pivot_longer(c(avg_compensation, equity_compensation)) %>%
    pivot_wider(c(isin, annualreportdate), names_from = c(name, gender))

df <- boards %>%
    left_join(gender, by = c("isin", "annualreportdate"))

# Add gender_share_income
df$total_over_female <- (df$avg_compensation / df$avg_compensation_fm)
df$total_over_male <- (df$avg_compensation / df$avg_compensation_m)

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
