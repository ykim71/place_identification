# ykim8771@gmail.com Google API setting
library(ggmap)
library(tidyverse)
library(mapview)
library(readxl)

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
data_merge_false <- data_merge %>% filter(is.na(address)==TRUE)

##
data <- data %>% mutate_geocode(location = unique_values, output = "more")
saveRDS(data, "places_original.RDS")

data_merge2 <- data %>% mutate(unique_values_pa = paste0(unique_values, ", PA, USA")) %>% select(X, unique_values_pa)
data_merge2 <- data_merge2 %>% mutate_geocode(location = unique_values_pa, output = "more")
saveRDS(data_merge2, "places_pa.RDS")

colnames(data_merge2) <- paste(colnames(data_merge2), "pa", sep = "_")

data_merge3 <- data %>% mutate(unique_values_usa = paste0(unique_values, ", USA")) %>% select(X, unique_values_usa)
data_merge3 <- data_merge3 %>% mutate_geocode(location = unique_values_usa, output = "more")
saveRDS(data_merge3, "places_usa.RDS")

colnames(data_merge3) <- paste(colnames(data_merge3), "usa", sep = "_")


data_merge_all <- cbind(data, data_merge2, data_merge3)

data_merge_all_50 <- data_merge_all %>% sample_n(50)
write.xlsx(data_merge_all_50, "google_api_places_50.xlsx")
# view
data_merge_true %>% 
  mapview(cex = "counts", xcol = "lon", ycol = "lat", crs = 4269, grid = FALSE)


place_org <- readRDS("places_original.RDS")
place_pa <- readRDS("places_pa.RDS")
place_usa <- readRDS("places_usa.RDS")

place_org_true <- place_org %>% filter(is.na(address)==FALSE)
place_org_true <- place_org_true %>% mutate(unique_values_pa = paste0(unique_values, ", PA, USA")) 

colnames(place_pa) <- paste(colnames(place_pa), "pa", sep = "_")
place_pa <- place_pa %>% mutate(unique_values_pa = unique_values_pa_pa) %>% select(-unique_values_pa_pa)

place_org_true_merge <- list(place_org_true, place_pa) %>% reduce(left_join, by="unique_values_pa")
place_org_true_merge <- place_org_true_merge %>% mutate(agree = ifelse(address==address_pa,1,0))
table(place_org_true_merge$agree) # not agree = 2143

write_csv(place_org_true_merge, "place_org_true_merge.csv")
