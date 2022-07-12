
# Run after discussing: If files have not been unzipped ----------
# Not a stable script since it depends on how the current folder structure is setup
# source("preprocessing/idp01_unzip files.R")

# Run preprocessing files ---------
gc();source(".Rprofile")
source("preprocessing/idp02_data log.R")
source("preprocessing/idp03_error log.R")
rm(list=ls())

# Run analysis files ---------
gc();source(".Rprofile")
source("analysis/ida01_controller summary.R")
rm(list=ls())
gc();source(".Rprofile")
source("analysis/ida02_sensor summary.R")
rm(list=ls())

