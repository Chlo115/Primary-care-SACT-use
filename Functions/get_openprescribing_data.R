# This function will GET Open Prescribing Data for a specified drug code
# it will then return that data, formatted in a 'tibble' with the format:
#
# Drug_name [string], BNF_code[string], Items (No of prescriptions issued that month)[numeric],
# Quantity (No of tablets etc issued in total)[numeric], Cost[numeric], Month [date],
# OrgID (Organisation ODS code)[string], Org_name (Organisation name)[string]

# Required packages
require(tidyverse)
require(jsonlite)
require(httr)
require(glue)

# Set API endpoint and parameters
bnf_code <- "0407020AD"


# Function to fetch data from API
get_openprescribing_data <- function(bnf_code,
                                     drug_name = "-", # A drug name if one is provided
                                     api_endpoint = "https://openprescribing.net/api/1.0/", # creates a default if none specified when function called
                                     api_path = "spending_by_sicbl/?code=" #default
                                     ) {

    # Build the url to query the API
    url <- glue("{api_endpoint}{api_path}{bnf_code}&format=json")

    # Submit a web request (get) to the url and save it to 'result'
    result <- GET(url)

    # Wait for the webpage to respond
    stop_for_status(result)

    # extract the text content from the web response
    content(result, as="text", encoding="UTF-8") %>%
        # convert the data from JSON format to an R object
        fromJSON( flatten=TRUE) %>%
        # convert to a tibble (a table format of data in columns)
        as_tibble() -> data  #save to object called data

    # add the drugname and bnfcode as columns and rename columns
    data %>%
        mutate(Drug_name = drug_name, .before="items") %>%
        mutate(BNF_code = bnf_code, .before="items") %>%
        rename(Items = items, Quantity = quantity, Cost = actual_cost, Month = date,
               OrgId = row_id, Org_name = row_name) %>%
        # set the Moth to be a date
        mutate(Month = as.Date(Month))-> data



    # return the tibble as the result of the function
    return(data)
}


## Example:
# get_openprescribing_data("0407020AD", "Tramadol")
