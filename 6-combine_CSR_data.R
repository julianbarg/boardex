#!/usr/bin/env Rscript

library(arrow)
library(tidyverse)
library(openxlsx)
library(stringr)

CSR <- read.xlsx("data/CSR Master Database_Final Oct. 30.xlsx", check.names = T)
names_ <- read_feather("data/names.feather")

CSR <- select(CSR, Company.name)
CSR$name_clean <- DataAnalysisTools::remove_company_suffixes(CSR$Company.name)
CSR$name_clean <- str_to_lower(CSR$name_clean)
CSR$name_clean <- str_remove_all(CSR$name_clean, "[[:punct:]]") # Remove all punctuation
# CSR$name_clean <- str_trim(CSR$name_clean)
CSR$name_clean <- str_remove_all(CSR$name_clean, "\\s") # Remove all whitespace

names_ <- select(names_, conm, gvkey)
names_$name_clean <- DataAnalysisTools::remove_company_suffixes(names_$conm)
names_$name_clean <- str_to_lower(names_$name_clean)
names_$name_clean <- str_remove_all(names_$name_clean, "[[:punct:]]")
# names_$name_clean <- str_trim(names_$name_clean)
names_$name_clean <- str_remove_all(names_$name_clean, "\\s")

CSR <- names_ %>%
  group_by(name_clean) %>%
  mutate(n = n()) %>%
  filter(n == 1) %>% # Keep only unique entries to achieve unambiguous match
  select(-n) %>%
  right_join(CSR) %>%
  select(Company.name, name_clean, gvkey, conm)

write.xlsx(CSR, "data/CSR_auto_merged.xlsx")
