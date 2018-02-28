library(readxl)

reach<-read_xlsx("reach_lby_nationalschoolsassessment_complete_db_reliable__not_reliable_18oct2012.xlsx")
acled<-read_csv("2011-01-31-2012-03-01-Libya.csv")

map_libya   <- get_map(location = "Sirte, Libya", zoom = 4, maptype = "toner", source = "stamen")

map_schools_with_events<-ggmap(map_libya) +
  geom_point(aes(x = latitude, y = longitude, alpha = 0.3),  data = reach, color="blue") + 
  geom_point(aes(x = latitude, y = longitude, alpha = 0.3),  data = acled, color="red") + 
  guides(alpha=FALSE)

map_schools_with_events
