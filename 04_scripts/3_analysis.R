#------------------------------------------------------------------------------#
# Title: Analysis Script
# Date: 28/07/2025
# Description: Preliminary analysis prior to making the rmd file report
#------------------------------------------------------------------------------#

# clear everything
# rm(list = ls())

# packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(
  dplyr, readxl, here, tidyverse, ggtext, ggplot2, scales, stringr, install = T)



clean_merge <- here("02_cleaneddata/", "cleaned_merge.xlsx")

analysis_data <- read_excel(clean_merge) %>%
  filter(merge == "Merged") %>%
  filter(country_name != "Kosovo (UNSCR 1244)") %>%
  mutate(ontrack = if_else(status == "Acceleration Needed", "Off-track", "On-track"),
         value = as.numeric(value),
         wghts = as.numeric(wghts))

# relabelling the values to something shorter
analysis_data <-analysis_data %>%
  mutate(indicator = case_when(
    str_detect(indicator, regex("^Antenatal care.*4\\+.*visits", ignore_case = TRUE)) ~ "Percentage of women who attended at least four ANC checks during pregnancy",
    str_detect(indicator, regex("^Skilled birth attendant", ignore_case = TRUE)) ~ "Percentage of deliveries attended by skilled health personnel",
    TRUE ~ indicator
  ))

# table of means by group / indicator / year
mean_df <- analysis_data %>%
  group_by(year, indicator, ontrack) %>%
  summarise(weighted_mean_value = weighted.mean(value, wghts, na.rm = TRUE), .groups = "drop") %>%
  mutate(weighted_mean_value = weighted_mean_value / 100)

# make a factor with labels for the graph
mean_df <- mean_df %>%
  mutate(ontrack = factor(ontrack,
                          levels = c("On-track", "Off-track")))

my_theme <- function(base_size = 14, base_family = "sans") {
  ggthemes::theme_excel_new(base_size = base_size, base_family = base_family) %+replace%
    theme(
      plot.title = element_text(face = "bold",
                                size = base_size + 2,
                                hjust = 0,
                                margin = margin(b = 15)),
      legend.position = "bottom",
      legend.title = element_blank(),
      legend.text = element_text(size = base_size * 0.7),
      axis.text.x = element_text(angle = 0, hjust = 0.5),
      panel.grid.major.x = element_blank(),
      panel.grid.minor.x = element_blank(),
      strip.text = element_text(face = "bold", size = base_size, hjust = 0,
                                margin = margin(t = 10, b = 5)),
      panel.grid.major.y = element_line(color = "#e4e1e1"),
      panel.grid.minor = element_blank(),
      panel.background = element_rect(fill = "white", color = NA),
      plot.background = element_rect(fill = "white", color = NA),
      plot.margin = margin(10, 10, 40, 10),
      plot.caption = element_markdown(
        size = base_size * 0.6,
        hjust = 0,
        vjust = 1,
        margin = margin(t = 15, r = 0, b = 0, l = 5),
        color = "gray30",
        family = base_family
      )
    )
}



mean_df$indicator <- str_wrap(mean_df$indicator, width = 95)

blue_fill <- c(
  "On-track"  = scales::alpha("#0071bc", 0.75),
  "Off-track" = scales::alpha("#00a3e0", 0.75)
)

blue_outline <- c(
  "On-track"  = "#0071bc",
  "Off-track" = "#00a3e0"
)

ggplot(mean_df, aes(x = factor(year),
                    y = weighted_mean_value,
                    fill = ontrack)) +
  geom_bar(stat = "identity",
           position = position_dodge(width = 0.9),
           size = 0.7,
           aes(color = ontrack)) +
  geom_text(aes(label = scales::percent(weighted_mean_value, accuracy = 1)),
            position = position_dodge(width = 0.99),
            vjust = 1.2,
            color = "white",
            fontface = "bold",
            size = 3,
            check_overlap = TRUE,
            show.legend = FALSE) +
  scale_fill_manual(values = unicef_blue_fill) +
  scale_color_manual(values = unicef_blue_outline) +
  guides(color = "none") +
  facet_wrap(~ indicator,
             scales = "fixed",
             ncol = 1) +
  scale_y_continuous(
    limits = c(0, 1),
    breaks = seq(0, 1, by = 0.2),
    labels = scales::percent_format(accuracy = 1)
  ) +
  labs(
    title = "Weighted Mean by Year, Indicator,\nand On-Track Status",
    x = "Year",
    y = "Weighted Mean Value (%)",
    fill = "On-Track Status",
    caption = "**Source:** These charts are based on an unbalanced group of countries spanning years 2018-2022. The data used in this chart are available for download from the UNICEF Data Warehouse."
  ) +
  my_theme() +
  geom_hline(yintercept = 0, color = "black")


# Part 2: closing gap between on track/off track countries
# using just two years for this one
skilled_birth_df <- mean_df %>%
  filter(str_detect(indicator, regex("deliveries", ignore_case = TRUE))) %>%
  filter(year %in% c(2018, 2022))


ggplot(skilled_birth_df, aes(x = factor(year),
                             y = weighted_mean_value,
                             fill = ontrack)) +
  geom_bar(stat = "identity",
           position = position_dodge(width = 0.9),
           size = 0.7,
           aes(color = ontrack)) +
  geom_text(aes(label = scales::percent(weighted_mean_value, accuracy = 1)),
            position = position_dodge(width = 0.99),
            vjust = 1.2,
            color = "white",
            fontface = "bold",
            size = 3,
            check_overlap = TRUE,
            show.legend = FALSE) +
  scale_fill_manual(values = unicef_blue_fill) +
  scale_color_manual(values = unicef_blue_outline) +
  guides(color = "none") +
  facet_wrap(~ indicator,
             scales = "fixed",
             ncol = 1, ) +
  scale_y_continuous(
    limits = c(0, 1),
    breaks = seq(0, 1, by = 0.2),
    labels = scales::percent_format(accuracy = 1)
  ) +
  labs(
    title = "Closing the Gap:\nIn 2018, the gap between Off-track and On-track countries was 30 percentage points. By 2022,\nthis gap reduced to 1 percentage point",
    x = "Year",
    y = "Weighted Mean Value (%)",
    fill = "On-Track Status",
    caption = "**Source:** These charts are based on an unbalanced group of countries spanning years 2018-2022. The data used in this chart are available for download from the UNICEF Data Warehouse."
  ) +
  my_theme() +
  geom_hline(yintercept = 0, color = "black") +
  theme(strip.text = element_blank())
