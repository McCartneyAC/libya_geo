# Example Geo Analysis with R

Includes randomly generated test data -- "locations" and "events", where each "event" also has a "count". The example R script shows one way to find, for each location, the sum of the counts for all events that are within a certain distance of that location.

Dependencies:

- "geosphere" for an implementation of haversine distance (includes other distance functions as well).
- "ggmap" and "ggrepel" for doing a test visualization of the data on a map.
