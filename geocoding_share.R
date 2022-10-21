# ykim8771@gmail.com Google API setting
library(ggmap)
library(tidyverse)
library(mapview)
library(openxlsx)

register_google(key = "XXX", write = TRUE)

data <- read.csv("ner_place_freq_n5.csv")

# test
data_20 <- data[1:20,]
data_20 <- data_20 %>% mutate_geocode(location = unique_values, output = "latlona")

data_20 <- data_20 %>% mutate(unique_values_usa = paste0(unique_values, ", USA"))
data_20 <- data_20 %>% mutate_geocode(location = unique_values, output = "latlona")

geocode("the United States", output = "latlona")

# all data
data <- data %>% mutate_geocode(location = unique_values, output = "latlona")

data_done <- data %>% filter(is.na(address)==FALSE)
data_re <- data %>% filter(is.na(address)==TRUE)

data_re <- data_re %>% mutate_geocode(location = unique_values, output = "latlona")
data_re <- data_re %>% mutate(lon = `lon...7`, lat = `lat...8`, address = `address...9`)
data_re <- data_re %>% select(-contains("..."))

data_merge <- rbind(data_done, data_re)
data_merge <- data_merge %>% arrange(-desc(X))

data_merge <- read.xlsx('data_merge.xlsx')
data_merge_true <- data_merge %>% filter(is.na(address)==FALSE)
#write.xlsx(data_merge, "data_merge.xlsx")


# view
data_merge_true %>% 
  mapview(cex = "counts", xcol = "lon", ycol = "lat", crs = 4269, grid = FALSE)

