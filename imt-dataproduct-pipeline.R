
# Run after discussing: If files have not been unzipped ----------
# Not a stable script since it depends on how the current folder structure is setup
# source("preprocessing/idp01_unzip files.R")

# Run preprocessing files ---------
gc();source(".Rprofile")

# sink(paste0(path_fusion_data,"/imt-dataproduct-pipeline-R run_",Sys.Date(),".txt"))
# Do not run the unzip files code (idp01_unzip files.R) --> MIGHT READD DUPLICATE LOGS
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

