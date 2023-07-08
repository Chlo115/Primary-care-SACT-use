# Required packages
library(tidyverse)
library(jsonlite)

# Set API endpoint and parameters
api_endpoint <- "https://openprescribing.net/api/1.0/"
api_path <- "spending/?code="
bnf_code <- "0407020AD"
#api_key <- "YOUR_API_KEY"  # Replace with your actual API key

# Function to fetch data from API
fetch_data <- function(endpoint) {
  url <- paste0(api_endpoint, endpoint, "&format=json") #&api_key=", api_key)
  result <- httr::GET(url)
  stop_for_status(result)
  content(result, as="text", encoding="UTF-8") %>%
      fromJSON( flatten=TRUE) -> data
  return(data)
}

# Fetch tramadol data
tramadol_data <- fetch_data(paste0(api_path, bnf_code))

# Convert data to tibble
tramadol_tibble <- as_tibble(tramadol_data)

# Extract relevant columns
tramadol_use <- tramadol_tibble %>%
  select(date, items) %>%
  rename(Date = date, Items = items)

tramadol_expenditure <- tramadol_tibble %>%
  select(date, actual_cost) %>%
  rename(Date = date, ActualCost = actual_cost)

# Summary statistics
total_use <- sum(tramadol_use$Items)
total_expenditure <- sum(tramadol_expenditure$ActualCost)

# Print summary
cat("Total Tramadol Use:", total_use, "items\n")
cat("Total Tramadol Expenditure:", total_expenditure, "GBP\n")
