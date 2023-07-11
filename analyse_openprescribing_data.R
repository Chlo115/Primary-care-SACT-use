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
  group_by(Quarter=quarter(Month, type="date_first")) %>% 
  summarise(Items=sum(Items),Cost=sum(Cost)) %>% 
  #mutate(Quarter = as.character(Quarter))  %>%
  ggplot(aes(x=Quarter,y=Cost))+
  geom_line()-> p1

op_data %>% 
  group_by(Quarter=quarter(Month,type="date_first")) %>% 
  summarise(Items=sum(Items),Cost=sum(Cost)) %>% 
  ggplot(aes(x=Quarter,y=Items))+
  geom_col(  )-> p2
  #geom_line(aes(y=Cost))

plot_grid(p1, p2, ncol=1) -> fig1

#find most frequently dispensed drugs
op_data %>%
  group_by(Drug_name) %>% 
  summarise(Items=sum(Items)) %>% 
  ungroup() %>% 
  arrange(-Items)-> frequency_of_drugs

#find most expensive dispensed drugs
op_data %>%
  group_by(Drug_name) %>% 
  summarise(Cost=sum(Cost)) %>% 
  ungroup() %>% 
  arrange(-Cost)-> high_cost_drugs

#find single tablet dispensing
op_data %>% 
  filter(Quantity==1)->single_tablet

