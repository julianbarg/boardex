#!/usr/bin/env Rscript

na_summary <- arrow::read_feather("data/na_summary.feather")
        
output <- na_summary %>% 
    select(companyid, annualreportdate, numberdirectors, nationalitymix,
           genderratio, isin) %>%
    unique()

write.csv(output, file = "data/output.csv")