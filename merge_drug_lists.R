# Quick dirty code to merge lists

install.packages("fuzzyjoin") # only run this once
library(fuzzyjoin)

ATC <- readRDS("Data/ATC_codes.rds")

ATC |>
fuzzy_left_join ( codelist, by = c("Drug_name" = "Name")) |>
write_csv( "druglist.csv")
