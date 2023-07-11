# This script will download data from OpenPrescribing and Merge it into
# a single file and save the output as an R RDS object ready for analysis
#

# Load some essential packages if they are not already loaded into this R session
# If these are not already installed, they will required installation.
require(tidyverse)
require(httr)
require(rvest)
require(jsonlite)
require(glue)
require(NHSDataDictionaRy)

# Load some functions to read the data.  Functions are snippets of code that are
# re-used multiple times. You can pass pre-defined variables to functions
#
# This project is storing Functions in a folder called Functions.  Each function
# has been saved in a file with the same name in that folder and is 'sourced'
# to load it into R, so that it can be called when ready
source ("Functions/get_openprescribing_data.R")

## Example
# get_openprescribing_data("0801030D0", "Capecitabine")
# returns a tibble with data for capecitabine

# We need to repeat that process for each drug we are interested in, and combine them together

## TO-DO - get the actual list we are interested in.
## FOR NOW - here is a quick list
codelist <-  openSafely_listR("user/chloewaterson/oral-sact/")

# Before looping delete any existing object called op_data
if (exists("op_data")) { rm(op_data) }

# Loop through the code list...

for (code in codelist$code) {
    # get the data for this drug and save as drug_result
    drug_result <- get_openprescribing_data(code, unique(codelist$term[codelist$code == code]))

    if (!exists("op_data")) {
        # if op_data doesn't exist, create it from drug_result
        op_data <- drug_result
    } else {
        # if op_data exists, add drug_result to it
        op_data <- rbind(op_data, drug_result)
    }
    Sys.sleep(1)
}

# remove the drug_result (it is a temporary data set)
rm(drug_result)

# Save the Open Precribing Data to an R RDS Object

saveRDS(op_data, file = "Data/OpenPrescribing.RDS")

