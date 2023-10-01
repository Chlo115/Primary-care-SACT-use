#' This code builds a map of cancer networks and applies a heat map to it
#'
#' It has been heavily commented to make it more readable. Anything on a line begging
#' with a # symbol is a comment and is ignored.
#'
#' The data in this is purely for demonstration purposes and it is simplified to
#' produce a single map. If you wanted our original code
#' check out:  http://dx.doi.org/10.13140/RG.2.2.12924.77446
#'
#' First - load up some required packages
#' If these don't load they need installed in the R instance using: install.packages("packageName")
#'
require(sf)
require(rgdal)    # Some of these may not actually be needed now
require(ggplot2)
require(rgeos)
require(broom)
require(dplyr)
require(grid)
require(gridExtra)
require(ggpubr)
require(httr)
require(tidyr)

#' Get a "MapShape" from:
#' https://geoportal.statistics.gov.uk/datasets/ons::sub-integrated-care-board-locations-july-2022-en-buc/explore?location=51.742731%2C-3.679550%2C5.60
#'
#' Save it in a sub folder called MapShape
#' & Unzip it.

# dir.create("MapShape")
# downloadLink = "https://opendata.arcgis.com/datasets/5b76468104814c4bb5b0297d0d76cba2_0.zip"
# httr::GET(
#   url = downloadLink,
#   httr::write_disk(file.path("MapShape/MapShape.zip"), overwrite = T)
# )
#
# unzip("../MapShape/MapShape.zip", exdir="MapShape")

#' This is a defintion of the geography of the cancer alliances

#' Read the geography into an object called 'shapefile'
shapefile <-
  readOGR(dsn = "MapShape", layer = "ICB_JUL_2022_EN_BUC_V3")

#' The shapefile needs converted to a different format using the following
mapdata_ICB<- #tidy(shapefile, region = "cal19nm")
sf::st_as_sf(shapefile)
#' Create some data to plot on the map (you could read a CSV file here etc)
#'

#assume already have code to create Year_data
Year_data |>
  group_by(Org_name,OrgId)|>
  summarise(Total_spend = sum(Cost))|>
  mutate(Org_name=paste(Org_name,"ICB", "-",OrgId))-> spend_by_subICB

#' Read the geography into an object called 'shapefile'for sub ICBs
shapefile <-  readOGR(dsn = "MapShape", layer = "SICBL_JUL_2022_EN_BUC")

#' The shapefile needs converted to a different format using the following
mapdata_subICB<- sf::st_as_sf(shapefile)

mapdata_subICB |>
  separate_wider_delim(SICBL22NM,delim=" - ", names=c("ICB","subICB"))-> mapdata_subICB

mapdata_subICB |>
  select(ICB,subICB) -> ICBnames

spend_by_subICB|>
  dplyr::left_join(ICBnames, by=c("OrgId"="subICB")) -> spend_by_subICB

spend_by_subICB |>
  group_by(ICB)|>
  summarise(Total_spend = sum(Total_spend))-> spend_by_ICB

#' Join mydata with mapdata to create a single object (dataframe) called df
#' which has -
#'  - each cancer alliance
#'  - its geography
#'  - the heatmap value
mapdata_ICB|>
  mutate(ICB22NM=stringr::str_replace(ICB22NM,"Integrated Care Board","ICB"))->mapdata_ICB

df <- dplyr::left_join(mapdata_ICB, spend_by_ICB, by=c("ICB22NM"="ICB"))

df|>
  mutate(Total_spend=case_when(
    is.na(Total_spend)~0,
    T~Total_spend
  )) -> df

#' Create the left hand side map.  Maps are in fact "graphs" and produced using a package
#' called ggplot - its powerful but a little complex to explain...

# plot1 <- ggplot() + geom_polygon(
#     data = df, aes(
#       x = long,
#       y = lat,
#       #group = group,
#       fill = Value),
#     color = "#004D40",
#     size = 0.5)

plot1 <- df |>
  ggplot()+
  geom_sf(aes(fill=Total_spend))


#' Set the X and Y axes as fixed so the map doesn't get squashed
#plot1 <- plot1 + coord_fixed(1)

#' Remove all the extra bits you'd expect on a graph like X and Y axis
plot1 <- plot1 + theme_void()
plot1 <- plot1 + theme(panel.grid.major = element_blank(),
                       panel.grid.minor = element_blank(),
                       # Put the legend at the bottom
                       legend.position = 'bottom')
plot1 <- plot1 + theme(axis.title.x=element_blank(),
                       axis.text.x = element_blank(),
                       axis.ticks.x = element_blank())
plot1 <- plot1 + theme(axis.title.y=element_blank(),
                       axis.text.y = element_blank(),
                       axis.ticks.y = element_blank())

# Set the legened scale - White to Dark Grey
plot1 <- plot1 + scale_fill_gradient(low="white",high=rgb(45/255,60/255,80/255),
                                     breaks=c(0,20000,40000,60000,80000),
                                     labels=c("£0","£20K","£40K","£60K","£80K"))

# Set a legend label
plot1 <- plot1 + labs(fill="Expenditure by ICB\n")
# in white
plot1 <- plot1 + theme(legend.text=element_text(color="white"),legend.title=element_text(color="white"))

print(plot1)

ggsave("Outputs/Spend_map.svg")

