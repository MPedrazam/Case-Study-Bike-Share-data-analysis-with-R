# 1. Rideable bike and type of member 

rides_merged %>% count(type_member) 
rides_merged %>% count(type_casual)
# it return the number of register of each of the two types of users, casual: 2546542, member: 3176990

rideable_type <- rides_merged %>% count(rideable_type, member_casual) 
pivot_rideable_type <- pivot_wider(ribeable_type, names_from = member_casual, values_from= n) # it returns a new data frame with the number of ride-able bikes, for each type of user. 

# 2. Stations location and type of member

start_station_data <- rides_merged %>% count(start_station_name, member_casual) 
start_station_pivot <- pivot_wider(start_station_data, names_from = member_casual, values_from= n) 
end_station_data <- rides_merged %>% count(end_station_name, member_casual)
end_station_pivot <- pivot_wider(end_station_data, names_from = member_casual, values_from=n) 
# it counted the number of rides for each type of member, casual or member, in both start and end stations. The information of the type of user was organized vertically in a new dataframe. 

names(end_station_pivot)[names(end_station_pivot) == 'end_station_name'] <- 'station' > names(start_station_pivot)[names(start_station_pivot) == 'start_station_name'] <- 'station' 
all_station <- full_join(start_station_pivot, end_station_pivot, by="station") 
# the name for the column where the station name was registered, was standardized in both data frames, start_station_pivot and end_station_pivot. Then, both data frames were merged taking as a criteria the station name, this allowed summarize all the information and get insights about the most frequently stations from both type of users, regarding if they are for arrival or departure. 

names(all_station)[names(all_station) == 'member.x'] <- 'member_start' 
names(all_station)[names(all_station) == 'casual.x'] <- 'casual_start' 
names(all_station)[names(all_station) == 'member.y'] <- 'member_end' 
names(all_station)[names(all_station) == 'casual.y'] <- 'casual_end' 
# columns for the new data frame merged, all_station, were renamed. 

all_station$station <- all_station$station %>% replace_na("no_reported_station") 
all_station <- all_station %>% replace_na(list(member_start=0, casual_end=0,casual_start=0,member_end=0)) 
# rides values with no assigned station, where renamed as no_reported_station, no rides by any of the kind of members or with departure or arrival where assigned a “0” value, in order to facilitate the calculation. 

all_station <- all_station %>% mutate(total = all_station$casual_start + all_station$casual_end + all_station$member_start + all_station$member_end) 
all_station <- all_station %>% mutate(difference = (all_station$casual_start + all_station$casual_end) - (all_station$member_start + all_station$member_end)) 
# new columns were added to the data frame, one summarizing all the rides for each station, and the second from the difference in the frequency of member and casual member for each station.

# 3 Adding the coordinate information to the station 

data_round <- data %>% mutate(start_lat_round = round(data$start_lat, digits = 2)) > data_round <- data_round %>% mutate(start_lng_round = round(data$start_lng, digits = 2)) 
# to round and standardize the coordinate information to 2 digits 

coordinates <- data_round %>% select(end_station_name, start_lat_round, start_lng_round) > coordinates <- coordinates %>% distinct(end_station_name, .keep_all = TRUE) 
# to create a new table with the station name and its respective coordinates, all repeat station information was removed.

names(coordinates)[names(coordinates) == 'end_station_name'] <- 'station' 
station_coordenates <- full_join(coordinates, all_station, by="station")
# name was standardized and the coordinates table was merged along with station dataframe formally obtained. 

summary (station_coordenates)

# 4. Rides time and type of member

rides_merged$started_at = as.POSIXct(rides_merged$started_at, "%Y-%m-%d %H:%M:%S", tz = “utc” ) 
rides_merged$ended_at = as.POSIXct(rides_merged$ended_at, "%Y-%m-%d %H:%M:%S", tz = “utc”) 
# rides time variable, start_at and ended_at, were converted from character format to calendar dates and times format to develop further calculation.

data_time <- rides_merged %>% select(started_at,ended_at, member_casual) %>% mutate(time = difftime(ended_at, started_at, units = "mins")) 
# a new column, time, was added as the difference between the start and end time for ride, representing the time spent in each ride. 

data_time$day = wday (data_time$started_at, label = TRUE) 
data_day <- data_time %>% count(day, member_casual) 
pivot_data_day <- pivot_wider(day, names_from = member_casual, values_from = n) 
# were extracted the day of the week from the start_at column, and added in a new column, then created a new table data_day, that was used for further analysis. 

data_time %>% count(time <= 0) # 659 TRUE 
time_cleaned <- data_time %>% filter(time >= 0) 
# it was looking for inconsistent values, the negative values represent that the ending ride time was registered before the starting time. And zero values represent the start and the end ride time was the same. 659 negative values were excluded and the ride time was saved in a file along with the member information. 

rides_time_member <- time_cleaned %>% select(time, member_casual) 
summary(rides_time_member) 
aggregate(x = time_cleaned$time, by = list(time_cleaned$member_casual), FUN = mean) 
# mean ride time: 21.55 minutes; mean ride casual user: 31,74404 minutes; mean ride member: 13,37 minutes.