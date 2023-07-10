#run some analysis
#assume data already exists in object op_data
require(tidyverse)
require(cowplot)
#restrict date range

op_data %>%
  filter(Month >= as.Date("2019-01-01")) %>%
  filter(Month < as.Date("2023-01-01")) -> op_data

#Calculate number of dispensing episodes
total_items <- sum(op_data$Items, na.rm = TRUE)

#Calculate total expenditure
total_cost <- sum(op_data$Cost, na.rm = TRUE)

op_data %>% 
  group_by(Month) %>% 
  summarise(Items=sum(Items),Cost=sum(Cost)) %>% 
  ggplot(aes(x=Month,y=Cost))+
  #geom_col(  )+
  geom_line(aes(y=Cost))-> p1

op_data %>% 
  group_by(Month) %>% 
  summarise(Items=sum(Items),Cost=sum(Cost)) %>% 
  ggplot(aes(x=Month,y=Items))+
  geom_col(  )-> p2
  #geom_line(aes(y=Cost))

plot_grid(p1, p2, ncol=1) -> fig1
