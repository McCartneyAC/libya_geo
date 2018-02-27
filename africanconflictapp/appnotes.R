library(tidyverse)
data <- read.csv("http://apps.fs.fed.us/fiadb-downloads/CSV/LICHEN_SPECIES_SUMMARY.csv")
base::Sys.Date()
url<-"https://www.acleddata.com/wp-content/uploads/2017/10/ACLED-All-Africa-File_20170101-to-20171014.xlsx"

today<-gsub("-", "", base::Sys.Date())
today<-as.numeric(today)-2
url2<-paste0("https://www.acleddata.com/wp-content/uploads/2017/10/ACLED-All-Africa-File_20170101-to-",today,".xlsx")
url2
data2<-readxl::read_xlsx(url2)
as.tibble(data)
View(data)
?dplyr::failwith
