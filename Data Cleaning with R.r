library(tidyverse)

rides_uncleaned <- list.files(path = "C:/...Files _from _202104_202203", pattern = "*.csv", full.names = TRUE) %>% lapply(read_csv) %>% bind_rows
write.csv(rides_uncleaned, file = "C:/...rides_202104_202203.csv", row.names = FALSE)

# 12 csv files, corresponding to monthly ride registers from 04-2021 to 02-2022, listed, read and merged into one csv file compiling the information. After the process it was returned a table: 5,723,532 × 13 - that was locally stored.

rides_uncleaned %>% distinct(ride_id, .keep_all = TRUE)  # checking for duplicates registers based on the ride id, no duplicate registers found. 
rides_merged <- rides_uncleaned %>% drop_na (member_casual) # it wasn’t found blank spaces in target variable member_casual column.
