# IMT Dataproduct Parsers

## Pipeline
1. Update .Rprofile with Sys.info()["user"] and paths to the data.   
2. Run imt-dataproduct-pipeline.R by clicking 'Source' at the top-right.     
3. Resolve any dependencies by installing packages using install.packages("<name of package>")    

## Codebook: controller_summary.csv
This is the output from analysis/ida01_controller summary.R and functions/nct05386849.R, consisting of primary and secondary trial outcomes.   


| Variable      | Description |
| ----------- | ----------- |
| subject_id   | Subject ID from Row 2 of Data Log    |
| data_session      | Time of session as per Data Logs |
| mean  | Mean mg/dL  |
|  cv  | SD/Mean  |
|  lt54  | Percentage of glucose values < 54 mg/dL  |
|  lt70  | Percentage of glucose values < 70 mg/dL  |
|  range70to140  | Percentage of glucose values 70-140 mg/dL  |
|  range70to180  | Percentage of glucose values 70-180 mg/dL  |
|  range100to140  | Percentage of glucose values 100-140 mg/dL  |
|  gt180  | Percentage of glucose values > 180 mg/dL  |

## Codebook: ctime_summary.csv
This is the list of records where controller time and system time are different by more than 3 minutes.   

## Codebook: glucose_summary.csv
This is the output from analysis/ida02_sensor summary.R, consisting of primary and secondary trial outcomes separately by sensor.   

| Variable      | Description |
| ----------- | ----------- |
| subject_id   | Subject ID from Row 2 of Data Log    |
| data_session      | Time of session as per Data Logs |
| sensor_id   | Sensor ID (0 or 1)   |
| mean  | Mean mg/dL  |
|  cv  | SD/Mean  |
|  lt54  | Percentage of glucose values < 54 mg/dL  |
|  lt70  | Percentage of glucose values < 70 mg/dL  |
|  range70to140  | Percentage of glucose values 70-140 mg/dL  |
|  range70to180  | Percentage of glucose values 70-180 mg/dL  |
|  range100to140  | Percentage of glucose values 100-140 mg/dL  |
|  gt180  | Percentage of glucose values > 180 mg/dL  |

## Codebook: pump_rate_summary.csv
This is the output from analysis/ida02_sensor summary.R, consisting of infusion rates.      

| Variable      | Description |
| ----------- | ----------- |
| subject_id   | Subject ID from Row 2 of Data Log    |
| data_session      | Time of session as per Data Logs |
| substance   | Substance (Dextrose or Insulin)   |
| time_elapsed   | Sum of lag 1 time difference   |
| units_time   | Units (Insulin: Hours or Dextrose: Minutes)   |
| volume_rate1   | Sum(lag 1 difference $\times$ Rate )   |
| units_volume   | Units (Insulin: U or Dextrose: mg)   |
| average_rate1   | Rate (Insulin: U/hr or Dextrose: mg/min)   |
| units_rate1   | Units (Insulin: U/hr or Dextrose: mg/min)   |
| volume_rate1_per_kg   | Sum(lag 1 difference $\times$ Rate per kg )   |
| units_volume_per_kg   | Volume per kg (Insulin: U/kg or Dextrose: mg/kg)   |
| average_rate1_per_kg   | Rate per kg (Insulin: U/kg.hr or Dextrose: mg/kg.min)   |
| units_rate1_per_kg   | Units for Rate per kg (Insulin: U/kg.hr or Dextrose: mg/kg.min)   |
