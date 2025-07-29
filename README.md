# UNICEF Assessment for Household Survey Data Analyst Consultant

## Overview
This repository is organized as follows:

### Setup File:
The file named `Folder Setup.R` creates the folder structure needed for this - the user will have to edit the main folder path in the file prior to running. Then, open the `UNICEF.Rproj` and run files one at a time. 


1. **`01_rawdata`**  
   Contains all raw data files in `.xlsx` format. These files serve as inputs for the scripts.

2. **`02_cleaneddata`**  
   Contains cleaned data files in `.xlsx` format, which are also used as inputs for the scripts.

3. **`03_outputs`**  
   Stores the final output files in `.docx` format.

4. **`04_scripts`**  
   Includes all R scripts to load, merge, clean, and save data. Also contains the `.Rmd` file used to generate the final report.

---

## How to Use
1. Open the R project file named `UNICEF.Rproj`.  
2. Run the following scripts in order:  
   - `1_import.R`  
   - `2_merging.R`  
   - `3_analysis.R`  
   - `5_Report.R`  
3. Locate the final report in the `03_outputs` folder.
