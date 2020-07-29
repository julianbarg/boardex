#!/usr/bin/env Rscript

library(arrow)
library(tidyverse)
library(openxlsx)

df <- read_feather("data/preliminary.feather")

naming <- c("number_board_members" = "numberdirectors", 
            "number_board_members_fm" = "number_female", 
            "age_diversity" = "stdevage", 
            "age_diversity_check" = "stdevage_check", 
            "compustat_date" = "apdedate", 
            "total_assets" = "at", 
            "employees" = "emp", 
            "lt_debt" = "dltt", 
            "mv_common_equity" = "ceq",
            "current_assets" = "act", 
            "current_liabilities" = "lct",
            "common_shares_outstanding" = "csho", 
            "gender_ratio" = "genderratio",
            "nationality_mix" = "nationalitymix", 
            "avg_age" = "average_age", 
            "avg_age_na_rm" = "average_age_na_rm", 
            "ethnic_diversity" = "nationalitymix", 
            "ceo_chair" = "ned", 
            "year_end_date" = "annualreportdate", 
            "book_value_share" = "bkvlps", 
            "number_compensating_fm" = "number_compensating_female", 
            "number_audit_fm" = "number_audit_female", 
            "number_nominating_fm" = "number_nominating_female")

df <- rename(df, all_of(naming))

# Reordering variables.
df <- select(# Identifiers
             df, name, year, boardid, isin, cusip, gvkey, cik, 
             # BoardEx variables
             number_board_members, number_board_members_fm, 
             number_nominating, number_audit, number_compensating, number_nominating_fm, 
             number_audit_fm,  number_compensating_fm, gender_ratio, avg_tenure, 
             avg_compensation, avg_compensation_fm, equity_compensation, 
             equity_compensation_fm, avg_age, ethnic_diversity, age_diversity, ceo_chair, 
             year_end_date, 
             # Compustat
             total_assets, employees, lt_debt, mv_common_equity, current_assets,
             current_liabilities, book_value_share, common_shares_outstanding, 
             sic, naics, gsubind, gind, gsector, 
             # Alternative ways to create variables & sources
             avg_compensation_na_rm, avg_compensation_fm_na_rm,  equity_compensation_na_rm, 
             equity_compensation_fm_na_rm, avg_age_na_rm,  
             members_check, age_diversity_check, compustat_date
             )

write_feather(df, "data/output.feather")
write_csv(df, "data/output.csv")
openxlsx::write.xlsx(df, "data/output.xlsx")
