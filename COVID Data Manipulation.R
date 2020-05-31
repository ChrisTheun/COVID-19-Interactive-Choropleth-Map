rm(list = ls())
setwd("D:/ChrisT/Projects/COVID")

# # ============================ LOAD PACKAGES ============================

library("dplyr")
library("rgdal")

# ============================ DATA FORMATTING ============================

# Import dataset and reformat variable types
# Data retrieved from https://data.overheid.nl/dataset/11508-covid-19-aantallen-gemeente-cumulatief
df <- read.csv("COVID-19_aantallen_gemeente_cumulatief.csv", sep = ";")
df$Date_of_report <- as.POSIXct(df$Date_of_report)
df$Municipality_code <- as.character(df$Municipality_code)
df$Municipality_name <- as.character(df$Municipality_name)
df$Province <- as.character(df$Province)

# Remove the province/country totals and only keep municipality totals
df <- df[df$Municipality_name != "",]

# Add "Municipality" feature by merging both the municipality name and province name
df$Municipality <- paste(df$Municipality_name,", ",df$Province, sep = "")


# Import population per municipality dataset
# Retrieved from: https://opendata.cbs.nl/statline/portal.html?_la=nl&_catalog=CBS&tableId=70072ned&_theme=230
pop <- read.csv("Populatie Gemeenten 2020.csv", sep = ";")
pop <- pop[!is.na(pop$TotaleBevolking_1),]

Municipalities_df <- merge(x=df, y=pop[,c(2,4)], by.x = "Municipality_code", by.y = "RegioS")
names(Municipalities_df)[9] <- "Population"

# ============================ FEATURE ENGINEERING ============================

# Create a date feature from the date-time feature
Municipalities_df$Date <- as.Date(Municipalities_df$Date_of_report)

# Compute weekly & daily growth rates
Municipalities_df <- Municipalities_df %>%
  group_by(Municipality) %>%
  arrange(Municipality, Date) %>%
  mutate(Weekly_casegrowth = round((Total_reported-lag(Total_reported,7))/lag(Total_reported,7)*100,1),
         Daily_casegrowth = round((Total_reported-lag(Total_reported,1))/lag(Total_reported,1)*100,1),
         Weekly_admissiongrowth = round((Hospital_admission-lag(Hospital_admission,7))/lag(Hospital_admission,7)*100,1),
         Daily_admissiongrowth = round((Hospital_admission-lag(Hospital_admission,1))/lag(Hospital_admission,1)*100,1),
         Weekly_deceasedgrowth = round((Deceased-lag(Deceased,7))/lag(Deceased,7)*100,1),
         Daily_deceasedgrowth = round((Deceased-lag(Deceased,1))/lag(Deceased,1)*100,1),
         CasesPer10000 = round(Total_reported/Population * 10000,2),
         DeceasedPer10000 = round(Deceased/Population * 10000,2)
  )

# Create a popup feature consisting of information that will pop up once the user clicks on a municipality on the map
Municipalities_df <- Municipalities_df %>%
  mutate(popup_info=paste("<strong>",Municipality,"</strong>", "<br/>",
                          "Population:", Population, "<br/>",
                          "Reported cases:", Total_reported," (+", Weekly_casegrowth,"%)", "<br/>",
                          "Cases per 10000:", CasesPer10000, "<br/>",
                          "Hospital admissions:", Hospital_admission," (+", Daily_admissiongrowth,"%)", "<br/>",
                          "Deceased:", Deceased," (+", Daily_deceasedgrowth,"%)", "<br/>",
                          "Deceased per 10000:", DeceasedPer10000))
Municipalities_df <- as.data.frame(Municipalities_df)



# ============================ INTERACTIVE MAPS ============================


# choropleth maps
# Shapemap of Dutch municipalities retrieved from: https://hub.arcgis.com/datasets/e1f0dd70abcb4fceabbc43412e43ad4b_0

# Read shapemap of Dutch municipalities
shapefile <- readOGR("Gemeentegrenzen__voorlopig____kustlijn.shp")
shapefile$Gemeentena

# Check whether the municipality names in the shapemap correspond to those in the original dataframe and order them accordingly
is.element(shapefile$Gemeentena, Municipalities_df$Municipality_name)
Municipalities_df <- Municipalities_df[order(match(Municipalities_df$Municipality_name,shapefile$Gemeentena)),]


#write.csv(Municipalities_df, "Municipalities_df.csv")

