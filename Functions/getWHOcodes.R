# This is a script to get all antineoplastic drugs from the WHO ATC list (L01)

require(httr)
require(rvest)

base_url = "https://www.whocc.no/atc_ddd_index/"
url_path =  "?code=L01&showdescription=no"
url <- paste0(base_url,url_path)

getLinks <- function(url) {

    web_page <- read_html(url)
    web_page %>%
        html_nodes(xpath= '//*[@id="content"]')|>
        html_nodes('a') |>
        html_attr('href') -> links

    return(links)

}

linkList <- getLinks(url)
allLinkList <- linkList

for (url in linkList[linkList != "./"]) {
    links <- getLinks(paste0(base_url,url))
    allLinkList <- c(allLinkList, links)
}

allLinkList <- unique(allLinkList[allLinkList != "./"])

unlist(str_split( allLinkList, "&"))

allLinkList |>
    as_tibble_col() |>
    separate_wider_delim(value, "&", names = "link", too_many = "drop") |>
    separate_wider_delim(link, "=", names = c("path", "code")) |>
    rowwise() |>
    mutate(code_length = nchar(code)) |>
    filter(code_length >= 5) |>
    select(-code_length) |>
    unite(link, c(path,code), sep="=") -> allLinkList


gettable <- function(url) {

    web_page <- read_html(url)
    web_page %>%
        html_nodes(xpath= '//*[@id="content"]')|>
        html_nodes('table') -> tabl

    return(tabl)

}

for (lnk in allLinkList$link){

    gettable(paste0(base_url, lnk)) |>
        html_table(header = T) ->tabl

    if (exists("ATC_codes")) {
        ATC_codes <- rbind( ATC_codes, tail(tabl, 1)[[1]])
    } else {
        ATC_codes <- tail(tabl, 1)[[1]]
    }

}

saveRDS(ATC_codes, "Data/ATC_codes.RDS")

