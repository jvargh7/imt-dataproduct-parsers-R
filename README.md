# IMT Dataproduct Parsers

## Codebook: controller_summary.csv
This is the output from analysis/ida01_controller summary.R and functions/nct05386849.R, consisting of primary and secondary trial outcomes.   


| Variable      | Description |
| ----------- | ----------- |
| subject_id   | Subject ID from Row 2 of Data Log    |
| data_session      | Time of session as per Data Logs |
|  lt70  | Percentage of glucose values < 70 mg/dL  |
|  range70to180  | Percentage of glucose values 70-180 mg/dL  |
|  lt54  | Percentage of glucose values < 54 mg/dL  |
|  gt180  | Percentage of glucose values > 180 mg/dL  |
|  cv  | SD/Mean  |
|  range100to140  | Percentage of glucose values 100-140 mg/dL  |

## Codebook: ctime_summary.csv
This is the list of records where controller time and system time are different by more than 3 minutes.   

## Codebook: glucose_summary.csv
This is the output from analysis/ida02_sensor summary.R, consisting of primary and secondary trial outcomes separately by sensor.   

| Variable      | Description |
| ----------- | ----------- |
| subject_id   | Subject ID from Row 2 of Data Log    |
| data_session      | Time of session as per Data Logs |
| sensor_id   | Sensor ID (0 or 1)   |
|  lt70  | Percentage of glucose values < 70 mg/dL  |
|  range70to180  | Percentage of glucose values 70-180 mg/dL  |
|  lt54  | Percentage of glucose values < 54 mg/dL  |
|  gt180  | Percentage of glucose values > 180 mg/dL  |
|  cv  | SD/Mean  |
|  range100to140  | Percentage of glucose values 100-140 mg/dL  |

## Codebook: pump_rate_summary.csv
This is the output from analysis/ida02_sensor summary.R, consisting of infusion rates.      

| Variable      | Description |
| ----------- | ----------- |
| subject_id   | Subject ID from Row 2 of Data Log    |
| data_session      | Time of session as per Data Logs |
| substance   | Substance (Dextrose or Insulin)   |
| average_rate1   | Rate (Insulin: U/hr or Dextrose: mg/min)   |
| average_rate1_per_kg   | Rate (Insulin: U/kg.hr or Dextrose: mg/kg.min)   |
