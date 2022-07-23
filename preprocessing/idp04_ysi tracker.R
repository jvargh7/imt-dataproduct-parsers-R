header <- c("subject_id","sample_number","date","time","ysi_average","nova_average")

ysi_tracker_list <- list.files(paste0(path_fusion_data),pattern="YSI Session Tracker",full.names = TRUE,recursive = TRUE) %>% 
  .[!str_detect(.," - Copy")]

source("functions/merge_timestamp.R")

ysi_tracker_extract <- map_dfr(ysi_tracker_list,
                               function(f){
                                 
                                 s_id = str_extract(f,"/[A-Za-z0-9]+/YSI") %>% 
                                   str_replace_all(.,"(/|YSI)","");
                                 df = tryCatch({readxl::read_excel(f,sheet = paste0("FUSION ",s_id," "))},
                                               error = function(e){readxl::read_excel(f,sheet = paste0("FUSION ",s_id))}) %>% 
                                   dplyr::select(one_of("Subject #",
                                                        "Sample #",
                                                        "Date","Sample Draw Time\r\n(24 hours)",
                                                        "YSI Blood Glucose Average (mg/dL)",
                                                        "Reference Glucose Value (Nova Statstrip mg/dL)")) %>% 
                                   rename_all(~header) %>% 
                                   dplyr::filter(!is.na(subject_id));  
                                 return(df)
                                 
                                 
                               }) %>% 
  mutate(reference_glucose = case_when(is.na(ysi_average) ~ as.numeric(nova_average),
                                       is.na(nova_average) ~ as.numeric(ysi_average),
                                       TRUE ~ as.numeric(ysi_average)),
         blood_draw_time = ymd_hms(paste0(format(date,"%Y/%m/%d"),"_",format(time,"%H:%M:%S")))) %>% 
  dplyr::select(-date,-time)

# # Sensor data from glucose_parsed ------------
# sensor1 <- read_csv(paste0(path_fusion_data,"/output/glucose_parsed.csv")) %>% 
#   dplyr::filter(sensor_id == 1) %>% 
#   dplyr::select(subject_id,log_timestamp,glucose) %>% 
#   rename(timestamp = log_timestamp)
# 
# sensor0 <- read_csv(paste0(path_fusion_data,"/output/glucose_parsed.csv")) %>% 
#   dplyr::filter(sensor_id == 0) %>% 
#   dplyr::select(subject_id,log_timestamp,glucose)  %>% 
#   rename(timestamp = log_timestamp)

# Sensor data from sensor_strategy_parsed ------------

sensor1 <- read_csv(paste0(path_fusion_data,"/output/sensor_strategy_parsed.csv")) %>% 
  dplyr::filter(sensor_id == 1) %>% 
  dplyr::select(subject_id,time_stamp,glucose) %>% 
  rename(timestamp = time_stamp)

sensor0 <- read_csv(paste0(path_fusion_data,"/output/sensor_strategy_parsed.csv")) %>% 
  dplyr::filter(sensor_id == 0) %>% 
  dplyr::select(subject_id,time_stamp,glucose)  %>% 
  rename(timestamp = time_stamp)

# Sensor average from controller_information ------------
sensor_average <- read_csv(paste0(path_fusion_data,"/output/controller_information.csv")) %>% 
  dplyr::select(subject_id,system_time,glucose)  %>% 
  rename(timestamp = system_time)

# Merging with ysi_tracker_extract -------------

ysi_tracker_output <- ysi_tracker_extract %>% 
  left_join(.,
            y = merge_timestamp({.},sensor1) %>% 
              rename(sensor1_timestamp = timestamp,
                     sensor1_glucose = glucose,
                     sensor1_timediff = time_diff) %>% 
              dplyr::select(subject_id,blood_draw_time,sensor1_timestamp,sensor1_glucose,sensor1_timediff),
              by = c("subject_id","blood_draw_time")) %>% 
  left_join(.,
            y = merge_timestamp({.},sensor0) %>% 
              rename(sensor0_timestamp = timestamp,
                     sensor0_glucose = glucose,
                     sensor0_timediff = time_diff) %>% 
              dplyr::select(subject_id,blood_draw_time,sensor0_timestamp,sensor0_glucose,sensor0_timediff),
            by = c("subject_id","blood_draw_time")) %>% 
  left_join(.,
            y = merge_timestamp({.},sensor_average) %>% 
              rename(sensoravg_timestamp = timestamp,
                     sensoravg_glucose = glucose,
                     sensoravg_timediff = time_diff) %>% 
              dplyr::select(subject_id,blood_draw_time,sensoravg_timestamp,sensoravg_glucose,sensoravg_timediff),
            by = c("subject_id","blood_draw_time"))

write_csv(ysi_tracker_output,paste0(path_fusion_data,"/output/ysi_tracker.csv"))
