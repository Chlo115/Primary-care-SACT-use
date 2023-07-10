#run some analysis
#assume data already exists in object op_data

#restrict date range

op_data %>%
  filter(Month >= as.Date("2019-01-01")) %>%
  filter(Month < as.Date("2023-01-01")) -> op_data

#Calculate number of dispensing episodes
total_items <- sum(op_data$Items, na.rm = TRUE)

#Calculate total expenditure
total_cost <- sum(op_data$Cost, na.rm = TRUE)
