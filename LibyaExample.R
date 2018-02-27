library(geosphere)

events <- read.csv("test_data/events.txt", header = TRUE) # lon,lat,count
locs <- read.csv("test_data/locs.txt", header = TRUE)     # lon,lat

# Set your max distance here
MAX_KM <- 100000

# Calculate the distance between from each location to all events
distmatrix <- distm(locs[,1:2], events[,1:2]) # defaults to using haversine distance

# Save the number of events within MAX_KM of each location
locs$num_events <- apply(distmatrix, 
                         1, 
                         function(distvec) length(events[which(distvec < MAX_KM),]$count)
                         )

# Also save the sum of their counts
locs$total_count <- apply(distmatrix, 
                           1, 
                           function(distvec) sum(events[which(distvec < MAX_KM),]$count)
                           )

# That should be it for the calculation.

# The rest is just a visual test.
# function that plots a location and the "nearby" events as a quick visual test
library(ggmap)
library(ggrepel)
libya <- get_map("Libya", zoom=5)

plot_events_for_location <- function(loc_idx) {
  close_events <- events[which(distmatrix[loc_idx,] < MAX_KM),]
  ggmap(libya) + 
    geom_point(data=events[which(distmatrix[loc_idx,] >= MAX_KM),], aes(x=lon, y=lat),size=1, color="red") +
    geom_label_repel(data=close_events, aes(x=lon, y=lat, label=count)) + 
    geom_label_repel(data=locs[loc_idx,], aes(x=lon, y=lat, label=total_count), color="blue", nudge_y=3, nudge_x=3) +
    geom_point(data=close_events, aes(x=lon, y=lat),size=1, color="green") + 
    geom_point(data=locs[loc_idx,], aes(x=lon, y=lat),size=2, color="blue")
}

plot_events_for_location(52)

