#------------------------------------------------------------------------------#
# Title: Merging Script
# Date: 28/07/2025
# Description: Merges the population, indicator and status datasets together
#------------------------------------------------------------------------------#

# need to install pacman - easy tio load packages then
if (!require(pacman)) {

  install.packages("pacman")

  library(pacman)

} else {

  library(pacman)
}

# clear the environment - risky, but we dont really need anything. This stays commented for now
# rm(list=ls())


# Packages----
p_load("tidyverse",
       "readxl",
       "writexl",
       "here",
       "janitor",
       "purrr",
       install = T)

# merge function that I like to use - I find it more helpful with diagnostics
stata_merge <- function(x, y, by = intersect(names(x), names(y))) {
  x[is.na(x)] <- Inf
  y[is.na(y)] <- Inf

  matched <- merge(x, y, by.x = by, by.y = by, all = TRUE)
  matched <- matched[complete.cases(matched),]
  matched$merge <- "Merged"

  master <- merge(x, y, by.x = by, by.y = by, all.x = TRUE)
  master <- master[!complete.cases(master),]
  master$merge <- "Master Only"

  using <- merge(x, y, by.x = by, by.y = by, all.y = TRUE)
  using <- using[!complete.cases(using),]
  using$merge <- "Secondary Only"

  df <- rbind(matched, master, using)
  df[sapply(df, is.infinite)] <- NA
  df
}



# Paths ----

## Paths
cleaned_pop_path    <- here("02_cleaneddata/", "cleaned_population.xlsx")
cleaned_track_path  <- here("02_cleaneddata/", "cleaned_ontrack_data.xlsx")
cleaned_health_path <- here("02_cleaneddata/", "cleaned_health_data.xlsx")
clean_merge         <- here("02_cleaneddata/", "cleaned_merge.xlsx")


# Importing cleaned data ----

## Pop data comes from the projects, so need to specify the sheet - others arefine
clean_population_data <- read_excel(cleaned_pop_path)
clean_track_data      <- read_excel(cleaned_track_path)
clean_health_data     <- read_excel(cleaned_health_path)



# Step 1: Merge the datasets----
# First, merge population to status data by iso3
pop_status   <- stata_merge(clean_population_data, clean_track_data, by = "iso3")


# Step 2: Merge previous output to the health data ----
# we merge pop + status to the indicator dataset
full_data    <- stata_merge(pop_status, clean_health_data, by = "country_name")



# Step 3: Some quick summary stats----
# some summary stats overall - I am handrolling the same estimate in the excel data just to see - ideally this number should match

# means by year, and merge status
full_data |>
  mutate(value = as.numeric(value)) |>
  group_by(year, indicator, merge) |>
  summarise(mean_value = mean(value, na.rm = TRUE)) |>
  pivot_wider(
    names_from = year,
    values_from = mean_value,
    values_fill = 0
  )


#  unique countries by year
    full_data |>
      filter(!is.na(iso3)) |>
      group_by(year, merge) |>
      summarise(unique_countries = n_distinct(iso3)) |>
      pivot_wider(
        names_from = year,
        values_from = unique_countries,
        values_fill = 0)

# how recent is the data?
    full_data |>
      mutate(year = as.numeric(year)) |>                 # Ensure year is numeric
      filter(!is.na(year), !is.na(value), merge=="Merged") |>             # Keep only valid rows
      group_by(indicator) |>
      summarise(
        sample_size = n(),                                # Count of non-missing rows
        min_year    = min(year, na.rm = TRUE),
        max_year    = max(year, na.rm = TRUE),
        mean_year   = mean(year, na.rm = TRUE),
        .groups     = "drop"
      )


# tbh, I am ok with this dataset given the time constraint - can always re-visit this stage later!

# Step 4: Saving Final Dataset ----
write_xlsx(full_data,             path = clean_merge)

