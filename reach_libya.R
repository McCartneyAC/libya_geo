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
library(rockchalk)
library(sjstats)
library(sjPlot)
library(edlf8360)
library(ggsci)
library(mccrr)
library(lme4)
library(extrafont); loadfonts()
library(tidyverse)


# Read Data

setwd("V:\\reach_libya") # or your wd
reach<-read_xlsx("reach_lby_nationalschoolsassessment_complete_db_reliable__not_reliable_18oct2012.xlsx") 
acled<-read_csv("2011-01-31-2012-03-01-Libya.csv")
reach
reach$Q1_1LevelofSchoolPrimary<-  as.numeric(reach$Q1_1LevelofSchoolPrimary)
reach$Q1_1LevelofSchoolPrep<-     as.numeric(reach$Q1_1LevelofSchoolPrep)
reach<-reach %>% 
  # mutate(primary_prep = if_else())
  filter((Q1_1LevelofSchoolPrimary + Q1_1LevelofSchoolPrep != 0))


reach <- reach %>% 
  mutate(pct_walking_before = Q2_1_bNumberofStudentsWalkingBefore/Q2_1NumberofStudentsTotalBefore) %>% 
  mutate(pct_walking_now = Q2_1_bNumberofStudentsWalkingNow / Q2_1NumberofStudentsTotalNow) %>% 
  mutate(pct_walking_before = if_else(pct_walking_before > 0, pct_walking_before, NA_real_ )) %>% 
  mutate(pct_walking_now = if_else(pct_walking_now > 0, pct_walking_now, NA_real_))

reach %>% 
  select(pct_walking_before, pct_walking_now) %>% 
  head(10)
hist(reach$pct_walking_before)

reach %>% 
  select(pct_walking_before, pct_walking_now) %>%
  filter(pct_walking_before <= 1) %>% 
  filter(pct_walking_now <= 1) %>% 
  describe()

reach3<-read_xlsx("reach_lby_nationalschoolsassessment_complete_db_reliable__not_reliable_18oct2012 (1).xlsx")
table(reach$RELIABLE)
table(reach$Q1_1LevelofSchoolPrimary)
table(reach$Q1_1LevelofSchoolPrep)

# initial exploration
reach$change<-reach$Q2_1NumberofStudentsTotalBefore - reach$Q2_1NumberofStudentsTotalNow
sum(reach$change)
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
    x = "Longitude",
    y = "Latitude",
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
# Updated but recheck for accuracy
acled %>% 
  group_by(event_type) %>%
  summarize(fatalities = sum(fatalities)) %>%
  mutate(event_type = fct_reorder(event_type, fatalities)) %>% 
  filter(fatalities >0) %>% 
  ggplot(aes(x = event_type, y = fatalities, fill = event_type)) +
  geom_col() +
  coord_flip()+
  theme_few()+
  scale_fill_manual(values=cbbPalette) + 
  guides(fill=FALSE) +
  labs(
    title= "Fatalities by ACLED Event Type",
    y = "Number of Fatalities",
    x = "Event Type"
  )

##########################################################################
# Geography
##########################################################################

# Set your max distance (meters) here
set_distance<-function(k){
  return(k*1000)
}

MAX_D<-set_distance(3)

acled
events<-acled %>%
  select(longitude, latitude, fatalities, event_date, event_type) %>%
  rename(lon = longitude) %>%
  rename(lat = latitude) %>%
  rename(count = fatalities)

names(reach)
locs<-reach %>%
  select(latitude, longitude, id, Q2_1NumberofStudentsTotalBefore, Q2_1NumberofStudentsTotalNow, 
         Q2_1NumberofStudentsBoysBefore,Q2_1NumberofStudentsBoysNow, Q2_1NumberofStudentsGirlsBefore, 
         Q2_1NumberofStudentsGirlsNow, Q4_3Damaged, Q5_2_aUsedForBefore4, QII_1Province, 
         Q1_1LevelofSchoolPrimary,  Q1_1LevelofSchoolPrep, Q4_3_bWhen, pct_walking_before, pct_walking_now) %>%
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
locs
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
    subtitle = "For school i = 500. Value in blue indicates sum of fatalities. 
Orange points represent incidents of violence",
    x = "Longitude",
    y = "Latitude",
    caption="Data Via REACH and ACLED")



########################################################################
# DID ESTIMATION                                                       #
########################################################################

names(reach)
# model specification: 
reach <- reach %>% 
  mutate(pct_change = (Q2_1NumberofStudentsTotalBefore - Q2_1NumberofStudentsTotalNow)/(Q2_1NumberofStudentsTotalBefore+ 0.1))
null_model<-lmer(Q2_1NumberofStudentsTotalNow ~ 1 + (1 | QII_1Province), data = reach)
edlf8360::icc(null_model)


# > edlf8360::icc(null_model)
# [1] 0.005305178
# wut.

#####
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
  mccrr::theme_textbook()+
  labs(
    title = "Changes in Student Population by Exposure to Violence",
    x = "Time",
    y = "Average Student Population",
    color = "Violence within 
3km of School"
  ) + 
  guides(shape=FALSE)+
  scale_color_colorblind(labels = c("No", "Yes"))

locs_data_3km<-locs %>%
  mutate(tx_fatal = if_else(total_count == 0, 0, 1)) %>% 
  mutate(tx_event = if_else(num_events  == 0, 0, 1)) %>% 
  rename(pre = Q2_1NumberofStudentsTotalBefore) %>% 
  rename(post = Q2_1NumberofStudentsTotalNow) %>% 
  gather(key = time, value = students, pre , post) %>% 
  mutate(took_damage= if_else(Q4_3_bWhen==2, 1, 0)) %>% 
  select(id, num_events, total_count, tx_fatal, tx_event, time, students, took_damage, Q5_2_aUsedForBefore4, 
         QII_1Province, Q1_1LevelofSchoolPrimary, Q1_1LevelofSchoolPrep, pct_walking_before, pct_walking_now) %>% 
  filter(students != 0)%>% 
  rename(high_school = Q1_1LevelofSchoolPrep) %>% 
  rename(elementary = Q1_1LevelofSchoolPrimary) %>% 
  mutate(school_levels = high_school+elementary)

ids<-unique(locs_data$id)
as_tibble(ids)
view(locs_data)
table(locs_data$Q1_1LevelofSchoolPrimary)

locs_data %>% 
  write_csv("reach_libya_dd3km.csv")





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

# with walkers as covariate
names(locs_data)
m_walk1<-lm(students~total_count+time+total_count*time + pct_walking_before , data=locs_data_2km)

# 0.066 marginally significant!

# now for region fixed effects:
m_walk2<-lm(students~total_count+time+total_count*time + pct_walking_before + factor(QII_1Province), data=locs_data_2km)


tab_model(m_walk1, m_walk2)


m_walk_mlm2<-lmer(students~total_count+time+total_count*time + pct_walking_before +  (1 | QII_1Province), data=locs_data_2km)
m_walk_mlm3<-lmer(students~total_count+time+total_count*time + pct_walking_before +  (1 | QII_1Province), data=locs_data_3km)
m_walk_mlm5<-lmer(students~total_count+time+total_count*time + pct_walking_before +  (1 | QII_1Province), data=locs_data_5km)
tab_model(m_walk_mlm2,m_walk_mlm5,m_walk_mlm5)


########################
# Boy Models

locs_data_boys<-locs %>%
  mutate(tx_fatal = if_else(total_count == 0, 0, 1)) %>% 
  mutate(tx_event = if_else(num_events  == 0, 0, 1)) %>% 
  rename(pre = Q2_1NumberofStudentsBoysBefore) %>% 
  rename(post = Q2_1NumberofStudentsBoysNow) %>% 
  gather(key = time, value = students, pre , post) %>% 
  mutate(took_damage= if_else(Q4_3_bWhen==2, 1, 0)) %>% 
  select(id, num_events, total_count, tx_fatal, tx_event, time, students, took_damage, Q5_2_aUsedForBefore4, 
         QII_1Province, Q1_1LevelofSchoolPrimary, Q1_1LevelofSchoolPrep) %>% 
  filter(students != 0)%>% 
  rename(high_school = Q1_1LevelofSchoolPrep) %>% 
  rename(elementary = Q1_1LevelofSchoolPrimary) %>% 
  mutate(school_levels = high_school+elementary)

 


locs_data_boys %>% 
  write_csv("reach_libya_dd5km_boys.csv")

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
  mutate(tx_fatal = if_else(total_count == 0, 0, 1)) %>% 
  mutate(tx_event = if_else(num_events  == 0, 0, 1)) %>% 
  rename(pre = Q2_1NumberofStudentsGirlsBefore) %>% 
  rename(post = Q2_1NumberofStudentsGirlsNow) %>% 
  gather(key = time, value = students, pre , post) %>% 
  mutate(took_damage= if_else(Q4_3_bWhen==2, 1, 0)) %>% 
  select(id, num_events, total_count, tx_fatal, tx_event, time, students, took_damage, Q5_2_aUsedForBefore4, 
         QII_1Province, Q1_1LevelofSchoolPrimary, Q1_1LevelofSchoolPrep) %>% 
  filter(students != 0)%>% 
  rename(high_school = Q1_1LevelofSchoolPrep) %>% 
  rename(elementary = Q1_1LevelofSchoolPrimary) %>% 
  mutate(school_levels = high_school+elementary)

locs_data_girls %>% 
  write_csv("reach_libya_dd5km_girls.csv")

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



#############################
# better data preparation:

MAX_D<-set_distance(7)

# run once
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

locs_data_7km<-locs %>%
  mutate(tx_fatal = if_else(total_count == 0, 0, 1)) %>% 
  mutate(tx_event = if_else(num_events  == 0, 0, 1)) %>% 
  rename(pre = Q2_1NumberofStudentsTotalBefore) %>% 
  rename(post = Q2_1NumberofStudentsTotalNow) %>% 
  gather(key = time, value = students, pre , post) %>% 
  mutate(took_damage= if_else(Q4_3_bWhen==2, 1, 0)) %>% 
  select(id, num_events, total_count, tx_fatal, tx_event, time, students, took_damage, Q5_2_aUsedForBefore4, 
         QII_1Province, Q1_1LevelofSchoolPrimary, Q1_1LevelofSchoolPrep, pct_walking_before, pct_walking_now) %>% 
  filter(students != 0)%>% 
  rename(high_school = Q1_1LevelofSchoolPrep) %>% 
  rename(elementary = Q1_1LevelofSchoolPrimary) %>% 
  mutate(school_levels = high_school+elementary) %>% 
  mutate(fatal_ever = ifelse(tx))

locs_data %>% 
  write_csv("reach_libya_dd7km.csv")
getwd()
