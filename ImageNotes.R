# Some notes for images
#

# Map size:
#' Width: 31.6cm
#' Height: 57.8cm



# Results column:
#' Width: 19cm
#' Height - not specific size


#' Colour pallette
#'
#'
cPalette <- c(rgb(200/256, 200/256, 200/256, 1),
              rgb(230/256, 75/256, 60/256, 1),
              rgb(230/256, 75/256, 60/256, 0.5))


# Fonts:

# install.packages('showtext', dependencies = TRUE)
library(showtext)
require(ggplot2)
require(tidyverse)
# https://fonts.google.com/featured/Superfamilies
font_add_google("Quattrocento Sans", "Quattrocento Sans")

## automatically use showtext for new devices
showtext_auto()


# As an example create figure 1 (figure 1 is actually created in the PPT)
# Requires curly braces package:
# remotes::install_github("Solatar/ggbrace")
require(ggbrace)

theData = tibble('Episodes' = c(769, 97, 62),
                 'Doses' =as.factor(c(">14", "2-14", "1")))

theData |>
    mutate(LabelPos = Episodes/sum(Episodes)) |>
    mutate(LabelPos2 = cumsum(LabelPos) - 0.5* LabelPos) -> theData

ggplot(theData, aes(x=1, y=Episodes/sum(Episodes))) +
    geom_col(aes(fill=fct_inorder(Doses)), width = 0.2,  position = position_stack(reverse = TRUE) )+
    geom_text(aes(y = LabelPos2, label = Episodes), vjust = 0.5, colour = "black", size=8, family="Quattrocento Sans")+
    theme_minimal(base_family="Quattrocento Sans", base_size = 24) +
    xlab(label="Dispensing\nepisodes") +
    ylab(label="")+
    theme(axis.text.y = element_blank(),
          axis.ticks.x = element_blank(),
          panel.grid.major.y = element_blank(),
          panel.grid.minor = element_blank(),
          axis.title.y = element_text(angle = 0, vjust = 0.5, hjust=0.5)) +

    theme(legend.position="bottom") +
    theme(legend.title=element_blank()) +
    scale_y_continuous(labels=scales::percent) +
    scale_fill_manual(values=cPalette, labels = c("> 14 doses", "2 - 14 doses", "1 dose")) +
    geom_brace (aes(x=c(1.11,1.16), y=c(theData$LabelPos[1],1.0), colour=rgb(230/256, 75/256, 60/256, 1)), inherit.data=FALSE, rotate=90) +
    geom_text(aes(y = 0.5*(LabelPos[1] + 1.0), x = 1.2, label = "Emergency\nSupply?"), vjust = 0, colour = rgb(230/256, 75/256, 60/256, 1), size=6, family="Quattrocento Sans") +
    coord_flip(clip = "off", ylim=c(0,1), xlim=c(0.6,1.4)) -> p

ggsave(file="Outputs/Fig1.svg", plot=p, width=19, height=13, units="cm")
