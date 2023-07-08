# Required packages
library(tidyverse)
library(jsonlite)

# Set API endpoint and parameters
api_endpoint <- "https://openprescribing.net/api/1.0/"
api_path <- "drug/BNF_code/"
bnf_code <- "0407020AD"
api_key <- "YOUR_API_KEY"  # Replace with your actual API key

# Function to fetch data from API
fetch_data <- function(endpoint) {
  url <- paste0(api_endpoint, endpoint, "?format=json&api_key=", api_key)
  data <- fromJSON(url)
  return(data)
}

# Fetch tramadol data
tramadol_data <- fetch_data(paste0(api_path, bnf_code))

# Convert data to tibble
tramadol_tibble <- as_tibble(tramadol_data$measures)

# Extract relevant columns
tramadol_use <- tramadol_tibble %>%
  select(date, total_items) %>%
  rename(Date = date, TotalItems = total_items)

tramadol_expenditure <- tramadol_tibble %>%
  select(date, total_cost) %>%
  rename(Date = date, TotalCost = total_cost)

# Summary statistics
total_use <- sum(tramadol_use$TotalItems)
total_expenditure <- sum(tramadol_expenditure$TotalCost)

# Print summary
cat("Total Tramadol Use:", total_use, "items\n")
cat("Total Tramadol Expenditure:", total_expenditure, "GBP\n")
