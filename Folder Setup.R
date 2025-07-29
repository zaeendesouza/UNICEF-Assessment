rm(list=ls())

# Loading packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(fs, usethis)


# !!!! USER NEEDS TO EDIT THIS !!!!

root_dir <- "C:/Users/[USER NAME REMOVED]/OneDrive/Documents/GitHub/UNICEF"

# project creation
if (!dir_exists(root_dir)) {
  dir_create(root_dir)
  usethis::create_project(root_dir, open = FALSE)
} else if (!file.exists(file.path(root_dir, "UNICEF Assessment.Rproj"))) {
  usethis::create_project(root_dir, open = FALSE)

} else {
  message("Project already exists at: ", root_dir)
}

# folders
folders <- c(
  "01_rawdata",
  "02_cleaneddata",
  "03_outputs",
  "04_scripts"
)

# Create all folders; will populate them manually for me - can be done via code too!
for (folder in folders) {
  sub_path <- file.path(root_dir, folder)
  if (!dir_exists(sub_path)) {
    dir_create(sub_path)
    message("Created: ", sub_path)
  } else {
    message("Already exists: ", sub_path)
  }
}

# Create README.md if it doesntr exist
readme_path <- file.path(root_dir, "README.md")

if (!file_exists(readme_path)) {
     writeLines(c("# UNICEF Assessment",
                  "",
                  "Project folder initialized."),
                  readme_path)

  message("Created README.md")
}

message("Open the project with: ")
message(file.path(root_dir, "UNICEF Assessment.Rproj"))
