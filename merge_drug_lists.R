# Quick dirty code to merge lists

#install.packages("stringr") # only run this once
#library(fuzzyjoin)

ATC <- readRDS("Data/ATC_codes.rds")

ATC |>
    mutate(term = stringr::str_to_title(Name)) |>
left_join ( codelist) |>
write_csv( "druglist.csv")
