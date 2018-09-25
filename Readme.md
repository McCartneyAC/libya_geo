# Example Geo Analysis with R

Includes randomly generated test data -- "locations" and "events", where each "event" also has a "count". The example R script shows one way to find, for each location, the sum of the counts for all events that are within a certain distance of that location.

Dependencies:

- "geosphere" for an implementation of haversine distance (includes other distance functions as well).
- "ggmap" and "ggrepel" for doing a test visualization of the data on a map.


next commit: some version of forvalues 1(1)15, generate a dataset via R; import these into stata via a for loop that cleans them for stata (see code) and runs the most relevant model, then outputs the point estimates (DiD) and SEs for those models that can be turned into a data frame and graphed. 

the problem is transferring between stata and R. Can we cluster standard errors at the school-level in R as well? or is that only stata? If R can do it, then this can all be turned into one big loop wherein ... 

well. Wait. Can we add all 15 versions of input variable simultaneously and THEN run this so that they can all be in one set and run together? 

this is why I didn't do this during the paper itself.  

Also-- boxplots or whatever won't work with estimates, so you'll have to use some sort of ggplot statistics thing to do it. they're all ugly so be careful.  


omg omg omg
use WWW data to address the question of "why does the population of students in school increase over the course of the war?"
from B(2005)!!!!!
