#------------------------------------------------------------------------------#
# Title: Cleaning Script
# Date: 28/07/2025
# Description: Imports raw data in xls; cleans it, and saves the cleaned files
#------------------------------------------------------------------------------#

# need to install pacman - easy tio load packages then
if (!require(pacman)) {

  install.packages("pacman")

  library(pacman)

  } else {

  library(pacman)
}

# clear it all
# rm(list=ls())


# Part 1: Import data ----

## Packages----
p_load("tidyverse",
       "readxl",
       "writexl",
       "here",
       "janitor",
       "purrr",
       install = T)


## Paths ----

### Input paths----
population_path     <- here("01_rawdata", "WPP2022_GEN_F01_DEMOGRAPHIC_INDICATORS_COMPACT_REV1.xlsx")
ontrack_path        <- here("01_rawdata", "On-track and off-track countries.xlsx")
health_path         <- here("01_rawdata", "GLOBAL_DATAFLOW_2018-2022.xlsx")

### Output paths----
cleaned_pop_path    <- here("02_cleaneddata", "cleaned_population.xlsx")
cleaned_track_path  <- here("02_cleaneddata", "cleaned_ontrack_data.xlsx")
cleaned_health_path <- here("02_cleaneddata", "cleaned_health_data.xlsx")


## Import the data ----

## Pop data comes from the projects, so need to specify the sheet - others arefine
population_data <- read_excel(population_path, sheet = "Projections", col_names = TRUE)
track_data      <- read_excel(ontrack_path)
health_data     <- read_excel(health_path)


# Part 2: Data Cleaning----

## Population wghts ----

# col names are stored in row 12 - going to extract them, drop all rows from 1..., 12 and relabel the cols eventually
headers <- as.character(population_data[12, ])

population_data <- population_data |>
  slice(-(1:12))    |>
  setNames(headers) |>
  select(Index,
         `Region, subregion, country or area *`,
         `ISO3 Alpha-code`,
         `Births (thousands)`,
         Year) |>
  filter(!is.na(`ISO3 Alpha-code`)) |>
  filter(Year == 2022) |>
  rename(
    country = `Region, subregion, country or area *`,
    iso3 = `ISO3 Alpha-code`,
    wghts = `Births (thousands)`,
    pop_year = Year
  )

## Health data----

health_data <- health_data |>
  select(`Geographic area`, Indicator, OBS_VALUE, TIME_PERIOD) |>
  rename(
    country_name =`Geographic area`, indicator = Indicator, value = OBS_VALUE, year = TIME_PERIOD)

## Status data----

track_data <- track_data |>
  rename(iso3 = ISO3Code, country_name = OfficialName, status = Status.U5MR)

# Part 3: Saving cleaned datasets----
write_xlsx(population_data, cleaned_pop_path)
write_xlsx(track_data, cleaned_track_path)
write_xlsx(health_data, cleaned_health_path)




