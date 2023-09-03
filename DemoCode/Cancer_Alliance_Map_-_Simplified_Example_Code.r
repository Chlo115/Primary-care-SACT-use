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

require(rgdal)
require(ggplot2)
require(rgeos)
require(broom)
require(dplyr)
require(grid)
require(gridExtra)
require(ggpubr)
require(httr)

#' Get a "MapShape" from:
#' https://geoportal.statistics.gov.uk/datasets/cancer-alliances-july-2019-en-buc/data
#'
#' Save it in a sub folder called MapShape
#' & Unzip it.

dir.create("MapShape")
downloadLink = "https://opendata.arcgis.com/datasets/5b76468104814c4bb5b0297d0d76cba2_0.zip"
httr::GET(
  url = downloadLink,
  httr::write_disk(file.path("MapShape/MapShape.zip"), overwrite = T)
)

unzip("../MapShape/MapShape.zip", exdir="MapShape")

#' This is a defintion of the geography of the cancer alliances

#' Read the geography into an object called 'shapefile'
shapefile <-
  readOGR(dsn = "MapShape", layer = "Cancer_Alliances_July_2019_UGB_EN")

#' The shapefile needs converted to a different format using the following
mapdata <- #tidy(shapefile, region = "cal19nm")
sf::st_as_sf(shapefile)
#' Create some data to plot on the map (you could read a CSV file here etc)
#' 

ExampleData <- "Alliance, Value
West Yorkshire and Harrogate, 18
North Central and North East London, 22
East of England South, 56
Lancashire and South Cumbria, 63
Greater Manchester, 3
Surrey and Sussex, 99
Thames Valley, 74
West Midlands, 65
East of England North, 21
North West and South West London,  33
North East and Cumbria, 44
Cheshire and Merseyside, 77
Kent and Medway, 4
East Midlands, 98
Wessex, 89
Somerset Wiltshire Avon and Gloucester, 34
South East London, 43
Humber Coast and Vale, 13
Peninsula, 14
South Yorkshire and Bassetlaw, 18"  


FullData <- read.table(text=ExampleData, header = TRUE, sep=",")



#' Join mydata with mapdata to create a single object (dataframe) called df
#' which has -
#'  - each cancer alliance
#'  - its geography
#'  - the heatmap value

df <- dplyr::left_join(mapdata, FullData, by=c("cal19nm"="Alliance"))
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
  geom_sf(aes(fill=Value))

#' Set the X and Y axes as fixed so the map doesn't get squashed 
#plot1 <- plot1 + coord_fixed(1)

#' Remove all the extra bits you'd expect on a graph like X and Y axis
plot1 <- plot1 + theme_void()
plot1 <- plot1 + theme(panel.grid.major = element_blank(), 
                       panel.grid.minor = element_blank(), 
                       legend.position = 'bottom')
plot1 <- plot1 + theme(axis.title.x=element_blank(), 
                       axis.text.x = element_blank(), 
                       axis.ticks.x = element_blank())
plot1 <- plot1 + theme(axis.title.y=element_blank(), 
                       axis.text.y = element_blank(), 
                       axis.ticks.y = element_blank())

print(plot1)
