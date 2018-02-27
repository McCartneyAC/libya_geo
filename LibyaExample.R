library(geosphere)

events <- read.csv("test_data/events.txt", header = TRUE) # lon,lat,count
locs <- read.csv("test_data/locs.txt", header = TRUE)     # lon,lat

# Set your max distance (meters) here
MAX_D <- 100000

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

# The rest is just a visual test.
# function that plots a location and the "nearby" events as a quick visual test
library(ggmap)
library(ggrepel)
libya <- get_map("Libya", zoom=5)

plot_events_for_location <- function(loc_idx) {
  close_events <- events[which(distmatrix[loc_idx,] < MAX_D),]
  ggmap(libya) + 
    geom_point(data=events[which(distmatrix[loc_idx,] >= MAX_D),], aes(x=lon, y=lat),size=1, color="red") +
    geom_label_repel(data=close_events, aes(x=lon, y=lat, label=count)) + 
    geom_label_repel(data=locs[loc_idx,], aes(x=lon, y=lat, label=total_count), color="blue", nudge_y=3, nudge_x=3) +
    geom_point(data=close_events, aes(x=lon, y=lat),size=1, color="green") + 
    geom_point(data=locs[loc_idx,], aes(x=lon, y=lat),size=2, color="blue")
}
# toggle num to view for any of the 2000 locations
plot_events_for_location(52)

