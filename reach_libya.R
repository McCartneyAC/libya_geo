###########################
# REACH & ACLED Libya Data Analysis Project
# CAUSAL INFERENCE
# Authors: Andrew McCartney & Matt Kruszewski
# Last Updated: 2/27/2018
###########################


# Libraries
library(psych)
library(tidyverse)
library(multcomp)
library(car)
library(ggmap)
library(pscl)
library(readxl)
library(ggthemes)
library(broom)
library(AER)
library(geosphere)
library(ggrepel)

# Read Data

setwd("V:\\reach_libya") # or your wd
reach<-read_xlsx("reach_lby_nationalschoolsassessment_complete_db_reliable__not_reliable_18oct2012.xlsx")
acled<-read_csv("2011-01-31-2012-03-01-Libya.csv")



# initial exploation
reach$change<-libya$Q2_1NumberofStudentsTotalBefore - reach$Q2_1NumberofStudentsTotalNow
hist(reach$change)
reach$change_factor <- as.factor(ifelse((reach$change > 0), "lost students", "gained students"))



# initial Map Visual
map_tripoli <- get_map(location = "Tripoli", zoom = 8, maptype = "toner", source = "stamen")
map_libya   <- get_map(location = "Sirte, Libya", zoom = 6, maptype = "toner", source = "stamen")
# maybe change type/source, because toner/stamen is very intensive. 
# or just learn leaflet already, gosh! 

mapschools_tripoli<-ggmap(map_tripoli)+
  geom_point(aes(x = latitude, y = longitude, colour=change_factor, alpha = 0.3), 
             data = reach) + 
  scale_color_manual(values = c("lightblue", "red")) + 
  guides(alpha=FALSE)

mapschools_libya<-ggmap(map_libya)+
  geom_point(aes(x = latitude, y = longitude, colour=change, alpha = 0.3),  data = reach)+ 
  guides(alpha=FALSE)

mapschools_libya
mapschools_tripoli



# Visualize year-over-year change
ggplot(reach, aes(x=Q2_1NumberofStudentsTotalBefore, y = Q2_1NumberofStudentsTotalNow))+
  geom_point() + geom_smooth(method = "lm") + 
  scale_x_log10()+
  scale_y_log10()+ #beware with this, because schools which closed or opened across the year of the war are now coded as NaN/removed
  labs(
    title = "School population changes, Libya 2011-2012",
    x = "2011 Student Population",
    y = "2012 Student Population"
  )

# need to investigate outliers
# are they universities? (doesn't always seem to be the case)



################


# what can we learn about student experiences?

# Special Education provided?
table(reach$Q2_3_a_ProvisionForCSN)

# School used by armed groups during the war?
table(reach$Q5_2_aUsedForBefore4)
242/4628

# year over year chagne with this factor
ggplot(reach, aes(x=Q2_1NumberofStudentsTotalBefore, y = Q2_1NumberofStudentsTotalNow, color = Q5_2_aUsedForBefore4))+
  geom_point() + geom_smooth(method = "lm") + 
  scale_x_log10()+
  scale_y_log10()+ #beware with this, because schools which closed or opened across the year of the war are now coded as NaN/removed
  labs(
    title = "School population changes, Libya 2011-2012",
    x = "2011 Student Population",
    y = "2012 Student Population"
  )



# school took damage during the war? 
table(reach$Q4_3Damaged) # be sure to xtab this with Q4_3_b!

ggplot(reach, aes(x=Q2_1NumberofStudentsTotalBefore, y = Q2_1NumberofStudentsTotalNow, color = as.factor(Q4_3Damaged)))+
  geom_point() + geom_smooth(method = "lm") + 
  scale_x_log10()+
  scale_y_log10()+ #beware with this, because schools which closed or opened across the year of the war are now coded as NaN/removed
  labs(
    title = "School population changes, Libya 2011-2012",
    x = "2011 Student Population",
    y = "2012 Student Population"
  )
# how many fewer students in school after the war? 
sum(reach$Q2_1NumberofStudentsTotalBefore, na.rm=T)-sum(reach$Q2_1NumberofStudentsTotalNow, na.rm=T)
# what. 
# is this the result of NAs? (probably not! NA count was low, yes?)









##########################################################################
# Geography
##########################################################################

  #for school in schools:
  #  school.total_count = 0
  #  for event in events:
  #    if haversine_km(school, event) < MAX_DISTANCE:
  #   school.total_count = school.total_count + event.count
     
  
  
  
deg2rad<-function(d){
    return(d * (pi/180))
  }

haversine_km<-function(lat1,lon1,lat2,lon2){
  Rad <- 6371 # Radius of earth in km
  dLat <- deg2rad(lat2-lat1)
  dLon <- deg2rad(lon2-lon1)
  a <- sin(dLat/2)*sin(dLat/2) + cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * sin(dLon/2) * sin(dLon/2)
  c <- 2 * atan2(sqrt(a), sqrt(1-a))
  d <- Rad*c # distance in km
  return(d)
}


k<-5
# currently experiencing problems:
# seems to think I want to operate on the vectors equally and is angry that they are different lengths
# needs an apply() or map() function, probably.
##for (i in seq_along(reach)) {
##  reach$total_count <- 0
##  for (j in seq_along(acled)) {
##    if (haversine_km(reach$latitude, reach$longitude, acled$latitude, acled$longitude) < k) { 
##      reach$total_count <- reach$total_count + acled$fatalities
##    }
##  }
##}




#########################################################
# Matt's addenda
#########################################################


# events <- read.csv("test_data/events.txt", header = TRUE) # lon,lat,count
# locs <- read.csv("test_data/locs.txt", header = TRUE)     # lon,lat

# Set your max distance (meters) here
MAX_D <- 100000

acled
events<-acled %>%
  select(longitude, latitude, fatalities) %>%
  rename(lon = longitude) %>%
  rename(lat = latitude) %>%
  rename(count = fatalities)

reach
locs<-reach %>%
  select(longitude, latitude) %>%
  rename(lon = longitude) %>%
  rename(lat = latitude)


events
locs

# Calculate the distance from each location to all events
distmatrix <- distm(locs[,1:2], events[,1:2]) # defaults to using haversine distance

# Save the number of events within MAX_D of each location
locs$num_events <- apply(distmatrix, 
                         1, 
                         function(distvec) length(events[which(distvec < MAX_D),]$count)
)

# Also save the sum of their counts
locs$total_count <- apply(distmatrix, 
                          1, 
                          function(distvec) sum(events[which(distvec < MAX_D),]$count)
)

# That should be it for the calculation.

# let's see!
locs
hist(locs$total_count)
describe(locs$total_count)


# The rest is just a visual test.
# function that plots a location and the "nearby" events as a quick visual test

libya <- get_map("Libya", zoom=5)


map_tripoli <- get_map(location = "Tripoli", zoom = 8, maptype = "toner", source = "stamen")
map_libya   <- get_map(location = "Sirte, Libya", zoom = 6, maptype = "toner", source = "stamen")


plot_events_for_location <- function(loc_idx) {
  close_events <- events[which(distmatrix[loc_idx,] < MAX_D),]
  ggmap(map_libya) + 
    geom_point(data=events[which(distmatrix[loc_idx,] >= MAX_D),], aes(x=lon, y=lat),size=1, color="red") +
    geom_label_repel(data=close_events, aes(x=lon, y=lat, label=count)) + 
    geom_label_repel(data=locs[loc_idx,], aes(x=lon, y=lat, label=total_count), color="blue", nudge_y=3, nudge_x=3) +
    geom_point(data=close_events, aes(x=lon, y=lat),size=1, color="green") + 
    geom_point(data=locs[loc_idx,], aes(x=lon, y=lat),size=2, color="blue")
}
# toggle num to view for any of the 2000 locations
plot_events_for_location(52)
