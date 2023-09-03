# Experimental code to get packsizes for a product

# Load required packages
require(tidyverse)
require(httr)
require(rvest)

# Download the code list in dm+d SNOMED format
download.file("https://www.opencodelists.org/codelist/user/chloewaterson/oral-sact/32ae3ad9/dmd-download.csv", destfile="Data/dmd.csv")

dmd <- read_csv("Data/dmd.csv", col_types = c("cccc"))

# We only want Actual Medicinal Product Codes (AMP not Virtual Products VMP)

dmd |>
    filter(dmd_type == "AMP") -> dmd

# open prescribing have a simple dm+d browser (much simpler than NHS BSA's)
# https://openprescribing.net/dmd/amp/34782411000001102/ gives us the detail on snomed code 34782411000001102 (busulfan)
# including a AMPP table with pack sizes

get_smallest_pack <- function(AMP) {
    url <- "https://openprescribing.net/dmd/amp/"
    # AMP <- "4430611000001102"



    # Download the result table
    html <- read_html(paste0(url, AMP))
    html |>
       html_table() -> result_table

    result_table[[1]] -> result_table

    result_table |>
        filter( X1 == "BNF code") |>
        select( X2) |> as.character() -> BNF_code

    end_row <- as.numeric(length(result_table$X1))
    ampp_row <- as.numeric(which(result_table$X1 == "Actual Medicinal Product Packs") +1)

    if(length(ampp_row != 0)) {

        result_table |>
            slice(ampp_row:end_row) |>
            select(X1) |>
            separate_wider_delim(X1, delim=stringr::regex("\\(.*\\) "), names=c("Drug", "Pack"), too_few = "align_end") |>
            separate_wider_delim(Pack, delim=" ", names=c("Pack", "Form"), too_many = "drop") |>
            mutate(AMP = AMP, BNF_code = BNF_code) |>
            slice_min(order_by = Pack, n=1) -> smallest_pack

    return(smallest_pack)

    } else {
        return(FALSE)
    }



}

# Add some colums to dmd table
dmd$Pack <- ""
dmd$Form <- ""
dmd$BNF_code <- ""

for (AMP in dmd$dmd_id) {
    smallest_pack <- get_smallest_pack(AMP)

    if (length(smallest_pack)>1) {
        smallest_pack |>
            select (dmd_id = AMP, Pack, Form, BNF_code) -> smallest_pack
        dmd |>
            rows_update(by = 'dmd_id', tibble (smallest_pack )) -> dmd
    }
}


# Remove rows with no pack sizes (pack is not available anymore)
dmd |>
    filter (Pack != "") -> dmd

# create a BNF coded list
dmd |>
    group_by(bnf_code) |>
    summarise(Pack = min(Pack),
              Form = first(Form)) -> packsizes

write_csv(packsizes, "Data/packsizes.csv")
