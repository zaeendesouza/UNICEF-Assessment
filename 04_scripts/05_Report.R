library(rmarkdown)
library(here)

# Path to your Rmd file
rmd_path <- here("04_scripts/4_UNICEF Assessment.Rmd")  # update filename if needed

# Hardcoded output directory (absolute or relative)
output_dir <- here("03_outputs/")  # change this to your desired output folder

# Output filename
output_file <- "UNICEF Assessment (Output).docx"  # change filename if you want

# Render the Rmd file
rmarkdown::render(
  input = rmd_path,
  output_format = "word_document",
  output_file = output_file,
  output_dir = output_dir,
  clean = TRUE,
  quiet = FALSE
)

