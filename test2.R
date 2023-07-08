library(tidyverse)
library(httr)

# Define API endpoint and parameters
endpoint <- "https://openprescribing.net/api/1.0/spending/"

# Specify your API key here (required for authentication)
##api_key <- "YOUR_API_KEY"

# Define the BNF code for rosuvastatin
bnf_code <- "0212000AA"

# Specify the time period (e.g., last 12 months)
end_date <- Sys.Date()
start_date <- end_date %m-% months(12)

# Construct the API URL
url <- paste0(endpoint,
              "?format=json",
              "&code=", bnf_code,
              "&date=",
              "&date_range=", format(start_date, "%Y-%m-%d"), ",", format(end_date, "%Y-%m-%d")) #,
           #   "&api_key=", api_key)

# Send GET request to the API
response <- GET(url)

# Extract the response content
data <- content(response, "parsed")

# Convert the data to a data frame
df <- as_tibble(data$results)

# Print the monthly spending data
print(df)

