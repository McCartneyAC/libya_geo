###########################
# REACH & ACLED Libya Data Analysis Project
# CAUSAL INFERENCE
# Author: Andrew McCartney 
# Editor: Matt Kruszewski
# Last Updated: 4/20/2018
###########################


# Libraries
library(psych)
library(ggmap)
library(readxl)
library(ggthemes)
library(broom)
library(AER)
library(geosphere)
library(ggrepel)
library(lubridate)
library(scales)
library(gridExtra)
library(ggpubr)
library(tidyverse)


# Read Data

setwd("V:\\reach_libya") # or your wd
reach<-read_xlsx("reach_lby_nationalschoolsassessment_complete_db_reliable__not_reliable_18oct2012.xlsx") 
acled<-read_csv("2011-01-31-2012-03-01-Libya.csv")
reach
reach$Q1_1LevelofSchoolPrimary<-  as.numeric(reach$Q1_1LevelofSchoolPrimary)
reach$Q1_1LevelofSchoolPrep<-     as.numeric(reach$Q1_1LevelofSchoolPrep)
reach<-reach %>% 
  filter(Q1_1LevelofSchoolPrimary+Q1_1LevelofSchoolPrep != 0)




# initial exploration
reach$change<-reach$Q2_1NumberofStudentsTotalBefore - reach$Q2_1NumberofStudentsTotalNow
hist(reach$change)
reach$student_changes <- as.factor(ifelse((reach$change > 0), "lost students", "gained students"))




# initial Map Visual
# map_tripoli <- get_map(location = "Tripoli", zoom = 8, color="bw")
map_libya   <- get_map(location = "Sirte, Libya", zoom = 6, color="bw" )


mapschools_changes<-ggmap(map_libya)+
  geom_point(aes(x = latitude, y = longitude, colour=student_changes, alpha = 0.3), 
             data = reach) + 
  scale_color_manual(values = c("navy", "red")) + 
  guides(alpha=FALSE) + 
  labs(
    title="School locations and change in students",
    x = "Latitude",
    y = "Longitude",
    subtitle = "Changes in student population by location within Libya",
    color = "Student Changes"
  ) + 
  theme_few()
mapschools_changes


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

# year over year change with this factor
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

# is this the result of NAs? (probably not! NA count was low, yes?)
# See Buckland (2015) for an explanation




##########################################################################
# War Timeline Chart
##########################################################################
cbbPalette <- c("#000000", "#009E73", "#e79f00", "#9ad0f3", "#F0E442", "#D55E00", 
                "#CC79A7","#BBBBBB", "#0072B2")

# fatalities count. Don't use
# acled %>% 
#  ggplot(aes(as.factor(as.yearmon(event_date)), fatalities, fill = event_type)) + 
#  stat_summary(fun.y = sum, geom = "bar") + 
#  scale_fill_manual(values = cbbPalette) + 
#  labs(
#    title = "Violent Events in the Libyan Civil War, 2011-2012",
#    x = "Month", 
#    y = "Fatalities",
#    fill = "ACLED Event Type",
#    caption = "Data Via Armed Conflict Location & Event Data Project (ACLED)"
#  ) + 
#  scale_y_continuous() + 
#  theme_pander()

# events count. use me. 
p_events<- acled %>% 
  group_by(as.yearmon(event_date)) %>% 
  count(event_type) %>% 
  ggplot(aes(as.factor(`as.yearmon(event_date)`),n,fill = event_type)) + 
  geom_col()+
  scale_fill_manual(values = cbbPalette) + 
  labs(
    title = "Violent Events in the Libyan Civil War, 2011-2012",
    x = "", 
    y = "Count of Events",
    fill = "ACLED Event Type"
  ) + 
  scale_y_continuous() + 
  theme_pander()

# fatalities count over same X. Use me. 
p_fatalities <- acled %>% 
  group_by(as.yearmon(event_date)) %>% 
  tally(fatalities) %>% 
  ggplot(aes(as.factor(`as.yearmon(event_date)`),n, group = 1)) + 
  geom_point(stat = "identity",color = "#D55E00") +
  geom_line(color = "#D55E00", size = 1.5) +
  theme_pander() + 
  labs (
    title = "Fatalities",
    x = "", y = "",
    caption = "Data Via Armed Conflict Location & Event Data Project (ACLED)"
  )

events_over_time<-ggarrange(p_events,
          ggarrange(p_fatalities,NULL, ncol = 2, nrow = 1, widths = c(3.6,1)), 
          ncol = 1,
          nrow = 2,
          heights = c(2, 1)) 
events_over_time

# fatalities by event type:
acled %>% 
  count(event_type) %>% 
  mutate(event_type = fct_reorder(event_type, n)) %>% 
  ggplot(aes(x = event_type, y = n, fill = event_type)) +
  geom_col() +
  coord_flip()+
  theme_few()+
  scale_fill_manual(values=cbbPalette) + 
  guides(fill=FALSE) +
  labs(
    title= "Fatalities by ACLED Event Type",
    x = "Number of Fatalities",
    y = "Event Type"
  )

##########################################################################
# Geography
##########################################################################

# Set your max distance (meters) here
set_distance<-function(k){
  return(k*1000)
}

MAX_D<-set_distance(15)

acled
events<-acled %>%
  select(longitude, latitude, fatalities, event_date, event_type) %>%
  rename(lon = longitude) %>%
  rename(lat = latitude) %>%
  rename(count = fatalities)

reach
locs<-reach %>%
  select(latitude, longitude, Q2_1NumberofStudentsTotalBefore, Q2_1NumberofStudentsTotalNow, 
         Q2_1NumberofStudentsBoysBefore,Q2_1NumberofStudentsBoysNow, Q2_1NumberofStudentsGirlsBefore, 
         Q2_1NumberofStudentsGirlsNow, Q4_3Damaged, Q5_2_aUsedForBefore4, QII_1Province, 
         Q1_1LevelofSchoolPrimary,  Q1_1LevelofSchoolPrep, Q4_3_bWhen) %>%
  rename(lon = latitude) %>%
  rename(lat = longitude) # Some idiot at REACH hates me. 


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
# locs
# hist(locs$total_count)
# describe(locs$total_count)


# The rest is just a visual test.
# function that plots a location and the "nearby" events as a quick visual test

# map_tripoli <- get_map(location = "Tripoli", zoom = 8, color="bw")
map_libya   <- get_map(location = "Sirte, Libya", zoom = 6, color="bw")

plot_events_for_location <- function(loc_idx) {
  close_events <- events[which(distmatrix[loc_idx,] < MAX_D),]
  ggmap(map_libya) + 
    geom_point(data=events[which(distmatrix[loc_idx,] >= MAX_D),], aes(x=lon, y=lat),size=1, color="#D55E00") +
    geom_label_repel(data=close_events, aes(x=lon, y=lat, label=count)) + 
    geom_label_repel(data=locs[loc_idx,], aes(x=lon, y=lat, label=total_count), color="#0072B2", nudge_y=3, nudge_x=3) +
    geom_point(data=close_events, aes(x=lon, y=lat),size=1, color="#009E73") + 
    geom_point(data=locs[loc_idx,], aes(x=lon, y=lat),size=2, color="#0072B2")
}


# toggle num to view for any of the 2000 locations
plot_events_for_location(500) +
  theme_few()+
  labs(
    title="Violent Events and Fatalities within 15km of a School",
    subtitle = "For school i = 500. Value in blue indicates sum of fatalities. Orange points represent incidents of violence",
    x = "Latitude",
    y = "Longitude",
    caption="Data Via REACH and ACLED")



########################################################################
# DID ESTIMATION                                                       #
########################################################################
locs

locs %>%
  mutate(tx = if_else(total_count == 0, 0, 1)) %>% 
  rename(pre = Q2_1NumberofStudentsTotalBefore) %>% 
  rename(post = Q2_1NumberofStudentsTotalNow) %>% 
  gather(key = time, value = students, pre , post) %>% 
  select(num_events, total_count, tx, time, students) %>% 
  group_by(time, tx) %>% 
  summarize(count_group  = (mean(students))) %>% 
  ggplot(aes(x = fct_relevel(time, "pre", "post"),
             y = count_group,
             color=as.factor(tx),
             shape=as.factor(tx))) +
  geom_line(aes(group=tx))+
  geom_point(size=2) + 
  theme_few()+
  labs(
    title = "Changes in Student Population by Exposure to Violence",
    x = "Time",
    y = "Average Student Population",
    color = "Violence within 
15 km of School"
  ) + 
  guides(shape=FALSE)+
  scale_color_colorblind(labels = c("No", "Yes"))

locs_data<-locs %>%
  mutate(tx = if_else(total_count == 0, 0, 1)) %>% 
  rename(pre = Q2_1NumberofStudentsTotalBefore) %>% 
  rename(post = Q2_1NumberofStudentsTotalNow) %>% 
  gather(key = time, value = students, pre , post) %>% 
  mutate(took_damage= if_else(Q4_3_bWhen==2, 1, 0)) %>% 
  select(num_events, total_count, tx, time, students, took_damage, Q5_2_aUsedForBefore4, 
         QII_1Province, Q1_1LevelofSchoolPrimary, Q1_1LevelofSchoolPrep) %>% 
  unite("group", c("tx", "time"), remove=FALSE) %>%
  filter(students != 0)%>% 
  rename(high_school = Q1_1LevelofSchoolPrep) %>% 
  rename(elementary = Q1_1LevelofSchoolPrimary) %>% 
  mutate(school_levels = high_school+elementary)


table(locs_data$Q1_1LevelofSchoolPrimary)
locs_data


###########################
# genderless models
m1<-lm(students~total_count+time+total_count*time, data=locs_data)
stata_summary(m1)
m1c<-lm(students~total_count+time+total_count*time + high_school, data=locs_data)
stata_summary(m1c)

m2<-lm(students~num_events+time+num_events*time, data=locs_data)
stata_summary(m2)
m2c<-lm(students~num_events+time+num_events*time+ high_school, data=locs_data)
stata_summary(m2c)


m3<-lm(students~took_damage+time+took_damage*time, data=locs_data)
stata_summary(m3)
m3c<-lm(students~took_damage+time+took_damage*time + high_school, data=locs_data)
stata_summary(m3c)




########################
# Boy Models

locs_data_boys<-locs %>%
  mutate(tx = if_else(total_count == 0, 0, 1)) %>% 
  rename(pre = Q2_1NumberofStudentsBoysBefore) %>% 
  rename(post = Q2_1NumberofStudentsBoysNow) %>% 
  gather(key = time, value = students, pre , post) %>% 
  mutate(took_damage= if_else(Q4_3_bWhen==2, 1, 0)) %>% 
  select(num_events, total_count, tx, time, students, took_damage, Q5_2_aUsedForBefore4, 
         QII_1Province, Q1_1LevelofSchoolPrimary, Q1_1LevelofSchoolPrep) %>% 
  unite("group", c("tx", "time"), remove=FALSE) %>%
  filter(students != 0)%>% 
  rename(high_school = Q1_1LevelofSchoolPrep) %>% 
  rename(elementary = Q1_1LevelofSchoolPrimary) %>% 
  mutate(school_levels = high_school+elementary)


m4<-lm(students~total_count+time+total_count*time, data=locs_data_boys)
stata_summary(m4)
m4c<-lm(students~total_count+time+total_count*time + high_school, data=locs_data_boys)
stata_summary(m4c)

m5<-lm(students~num_events+time+num_events*time, data=locs_data_boys)
stata_summary(m5)
m5c<-lm(students~num_events+time+num_events*time+ high_school, data=locs_data_boys)
stata_summary(m5c)


m6<-lm(students~took_damage+time+took_damage*time, data=locs_data_boys)
stata_summary(m6)
m6c<-lm(students~took_damage+time+took_damage*time + high_school, data=locs_data_boys)
stata_summary(m6c)
#######################
# Girl Models


locs_data_girls<-locs %>%
  mutate(tx = if_else(total_count == 0, 0, 1)) %>% 
  rename(pre = Q2_1NumberofStudentsGirlsBefore) %>% 
  rename(post = Q2_1NumberofStudentsGirlsNow) %>% 
  gather(key = time, value = students, pre , post) %>% 
  mutate(took_damage= if_else(Q4_3_bWhen==2, 1, 0)) %>% 
  select(num_events, total_count, tx, time, students, took_damage, Q5_2_aUsedForBefore4, 
         QII_1Province, Q1_1LevelofSchoolPrimary, Q1_1LevelofSchoolPrep) %>% 
  unite("group", c("tx", "time"), remove=FALSE) %>%
  filter(students != 0)%>% 
  rename(high_school = Q1_1LevelofSchoolPrep) %>% 
  rename(elementary = Q1_1LevelofSchoolPrimary) %>% 
  mutate(school_levels = high_school+elementary)

m7<-lm(students~total_count+time+total_count*time, data=locs_data_girls)
stata_summary(m7)
m7c<-lm(students~total_count+time+total_count*time + high_school, data=locs_data_girls)
stata_summary(m7c)

m8<-lm(students~num_events+time+num_events*time, data=locs_data_girls)
stata_summary(m8)
m8c<-lm(students~num_events+time+num_events*time+ high_school, data=locs_data_girls)
stata_summary(m8c)


m9<-lm(students~took_damage+time+took_damage*time, data=locs_data_girls)
stata_summary(m9)
m9c<-lm(students~took_damage+time+took_damage*time + high_school, data=locs_data_girls)
stata_summary(m9c)

