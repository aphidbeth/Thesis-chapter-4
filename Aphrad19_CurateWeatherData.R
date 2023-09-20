# Curating the weather data for chapter four thesis

# Data source: 
# Montlhly weather data for 2018 was downloaded from HADUK-grid climate dataset 
# downloaded from CEDA: https://archive.ceda.ac.uk/

# Field polygons drawn in ARCGIS and 500m buffer zones around the outside calculated

# MEAN values for each field buffer extracted for each month for the following
# variables:

#-Humidity
#-Precipitation
#-Sunshine hours
#-Temp mean
#-Temp min
#-Temp max
#-Wind
#-Groundfrost days

# This is the data being imported here for further curation and selection of 
# relevant variables for RDA

#==============================================================================
# Housekeeping: 

#Clear enviroment
rm(list=ls())

# Set working directory
setwd("C:/Users/beth-/OneDrive - University of Aberdeen/Data/AphRad19/Field stuff/hadukmeans")

# Load libraries
library(dplyr)
library(ggplot2)
library(tidyr)
library(purrr)

#====================
# Import data

wind <- read.csv("wind1000.csv")
rain<- read.csv("rain1000.csv")
sun <- read.csv("sun1000.csv")
temp <- read.csv("temp1000.csv")
tempmin <- read.csv("tempmin1000.csv")
tempmax <- read.csv("tempmax1000.csv")
frost <- read.csv("frost1000.csv")
humidity <- read.csv("humidity1000.csv")

# Look at the data

ggplot(tempmax, aes(x=StdTime, y=MEAN, color=FieldName)) + geom_point() + facet_wrap(~FieldName)
ggplot(rain, aes(x=StdTime, y=MEAN, color=FieldName)) + geom_point() + facet_wrap(~FieldName)
ggplot(sun, aes(x=StdTime, y=MEAN, color=FieldName)) + geom_point() + facet_wrap(~FieldName)
ggplot(frost, aes(x=StdTime, y=MEAN, color=FieldName)) + geom_point() + facet_wrap(~FieldName)

# To look at correlations across the year for each variable
# need to rearrange the dataframe into wide format, then plot

# Import the panel cor function to look at the numbers
panel.cor <- function(x, y, digits = 2, prefix = "", cex.cor, ...)
{
  par(usr = c(0, 1, 0, 1))
  r <- abs(cor(x, y))
  txt <- format(c(r, 0.123456789), digits = digits)[1]
  txt <- paste0(prefix, txt)
  if(missing(cex.cor)) cex.cor <- 0.8/strwidth(txt)
  text(0.5, 0.5, txt, cex = cex.cor * r)
}

# Plots the correlations from our climate dataframes
plotcorrs <- function(climate.df) {
  df<- dplyr::select(climate.df, FieldName, StdTime, MEAN) %>%
    pivot_wider(., names_from=StdTime, values_from = MEAN) %>%
    mutate_at(., 2:13, as.numeric)
  colnames(df)[2:13] <-month.name
 pairs(df[2:13], gap=1/10, upper.panel=panel.cor)
}

# Look at correlations within each dataframe
plotcorrs(temp)
plotcorrs(tempmin)
plotcorrs(tempmax)
plotcorrs(rain)
plotcorrs(sun)
plotcorrs(wind)
plotcorrs(frost)
plotcorrs(humidity)  

# Temperature highly correlated across months
# wind/rain/sun/frost less correlated


# Select a subset based on what I assume might be critical times for aphid survival
# and crop growth
pivotdf <- function(climate.df) {
  df<- dplyr::select(climate.df, FieldName, StdTime, MEAN) %>%
    pivot_wider(., names_from=StdTime, values_from = MEAN) %>%
    mutate_at(., 2:13, as.numeric)
  colnames(df)[2:13] <-paste(month.name,unique(climate.df$Variable), sep=".")
  return(df)
}

# Select which of the months are important & not too correlated
rain_vars <- pivotdf(rain) %>% dplyr::select(., "FieldName","May.rainfall")
sun_vars <- pivotdf(sun) %>% dplyr::select(., "FieldName", "May.sun")
temp_vars <- pivotdf(temp) %>% dplyr::select(., "FieldName", "June.tas")
frost_vars <- pivotdf(frost) %>% dplyr::select(., "FieldName", "February.groundfrost")

# Merge together the selected variables 
dfList<- list(rain_vars, sun_vars, temp_vars, frost_vars)
climatevars <- dfList %>% purrr::reduce(full_join, by='FieldName')

# Run correlation plot again
pairs(climatevars[2:5], gap=1/10, upper.panel = panel.cor)


# save as csv 
write.csv(climatevars, "../../Data/climatevars.csv")

