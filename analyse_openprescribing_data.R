#run some analysis
#assume data already exists in object op_data
require(tidyverse)
require(cowplot)
require(gtsummary)
require(gt)
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
    coord_cartesian(ylim = c(0,100000), expand = T) +
    scale_y_continuous(labels = scales::label_dollar(prefix="£", big.mark = ",")) +
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

#find median, minimum and maximum cost per prescription
median_cost <- median(op_data$Cost) 
max_cost <- max(op_data$Cost)
min_cost <- min(op_data$Cost)

#find single tablet dispensing
op_data %>%
  filter(Quantity==1)->single_tablet

#find 14 or less tablets
op_data %>%
  filter(Quantity<=14)->small_quantity_tablet

#create a comparison table
op_data %>%
  mutate(Year=format(Month,"%Y")) %>% 
  mutate(Year_group=case_when(
    Year=="2019" ~ "2019-2020",
    Year=="2020" ~ "2019-2020",
    Year=="2021" ~ "2021-2022",
    Year=="2022" ~ "2021-2022"
  )) -> Year_data

Year_data %>% 
  group_by(Drug_name, Year_group) %>% 
  summarise(n = sum(Items), Cost = sum(Cost)) %>%
  pivot_wider(id_cols = Drug_name,
              names_from = Year_group,
              values_from = c(n, Cost),
              values_fill = 0) %>%
  ungroup()%>%
  mutate(Total_cost = `Cost_2019-2020` + `Cost_2021-2022`) %>% 
  arrange(-Total_cost) %>% 
  relocate(`n_2021-2022`, .after = `Cost_2019-2020`) %>%
  select(-Total_cost) -> Summary_of_Drugs

Summary_of_Drugs %>%
  slice(1:20) -> Top20_Drugs

Summary_of_Drugs %>%
  slice(21:2000) %>%
  select(-Drug_name) %>%
  summarise(across(everything(), sum, na.rm=TRUE)) %>%
  mutate(Drug_name = "Others", .before = `n_2019-2020`) -> OtherDrugs

rbind(Top20_Drugs,
      OtherDrugs) %>%
  gt::gt(rowname_col = "Drug_name") %>%
  fmt_currency(columns = c(3,5), currency = "GBP", use_subunits=F) %>%
  tab_spanner(label = "2019-2020", columns = 2:3 ) %>% 
  tab_spanner(label = "2021-2022", columns = 4:5 ) %>%
  cols_label(
    `n_2019-2020` = "Prescriptions",
    `n_2021-2022` = "Prescriptions",
    `Cost_2019-2020` = "Cost",
    `Cost_2021-2022` = "Cost",
    ) %>%
  tab_header("Top 20 drugs (by overall expenditure)", "Showing number of prescriptions processed and costs excluding broken bulk for years 2019 and 2020 vs 2021 and 2022") ->t1
