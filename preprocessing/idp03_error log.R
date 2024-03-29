header <- c("log_timestamp","log_level","unused_field","error_message","error_code","error_source","call_chain")

source("functions/glucose_parsing.R")
source("functions/match_logs.R")
source("functions/pump_rate_parsing.R")
source("functions/sensor_strategy_parsing.R")

# If we find duplicates in [subject_id]\IMT Data Export\[folder name]\extract\Error Logs 
# error_logs_list <- list.files(paste0(path_fusion_data),pattern="ERROR_LOG",full.names = TRUE,recursive = TRUE) %>% 
#   .[!str_detect(.," - Copy")]

source("preprocessing/idp_final list of files.R")




# Compiled error logs ---
error_logs_extract <- map_dfr(final_error_logs_list,
                         function(s){
                           
                           s_name <- str_extract(s,"IMT_[A-Z0-9_]+");
                           error_session <- str_replace(s_name,"IMT_ERROR_LOG_","") %>% ymd_hms(.);
                           
                           folder_name = str_extract(s,pattern = "/[0-9_]+/extract") %>% 
                             str_replace_all(.,"extract","") %>% 
                             str_replace_all(.,"/","");

                           df <- read.csv(s,col.names = header,skip = 1,sep=";");
                           if(nrow(df) == 0){
                             df[1,] <- NA
                           }
                           
                           
                           df %>%
                             mutate(error_session = error_session,
                                    folder_name = folder_name) %>% 
                             mutate(log_level = as.character(log_level)) %>% 
                           return()
                           
                         })

unique_ids <- error_logs_extract$error_session %>% unique(.)
patient_information <- read_csv(paste0(path_fusion_data,"/output/patient_information.csv")) %>% 
  dplyr::select(subject_id,data_session,insulin,dextrose,weight) %>% 
  pivot_longer(cols=c("insulin","dextrose"),names_to="substance",values_to="concentration") %>% 
  mutate(substance = str_to_sentence(substance)) 
  

# GLUCOSE --------
# There is an issue here: Controller private data the same as Sensor data?
glucose_parsed <- glucose_parsing(error_logs_extract) %>% 
  match_logs(error_log = .,
             data_log= patient_information %>% 
               distinct(data_session,subject_id),
             )

# PUMP RATE ------------
pump_rate_parsed <- pump_rate_parsing(error_logs_extract) %>% 
  match_logs(data_log= patient_information,
             error_log = .) %>% 
  arrange(log_timestamp) %>% 
  mutate(rate1 = case_when(substance == "Insulin" ~ rate*concentration,
                                 substance == "Dextrose" ~ (rate/100)*(concentration*1000)*(1/60),
                                 TRUE ~ NA_real_),
         units = case_when(substance == "Insulin" ~ "U/hr",
                                 substance == "Dextrose" ~ "mg/min",
                                 TRUE ~ NA_character_),
         rate1_per_kg = rate1/weight,
         units_per_kg = case_when(substance == "Insulin" ~ "U/kg/hr",
                                 substance == "Dextrose" ~ "mg/kg/min",
                                 TRUE ~ NA_character_)) %>% 
  dplyr::select(-weight,-concentration)

unmatched_pump_rate_parsed <- pump_rate_parsing(error_logs_extract) %>% 
  anti_join(pump_rate_parsed,
            by="log_timestamp")

pump_paused <- pump_rate_parsed %>% 
  dplyr::filter(pause == 1) %>% 
  dplyr::select(subject_id,error_session,log_timestamp,substance,error_message)

pump_rate_parsed %>% 
  dplyr::filter(subject_id == "EM08",substance == "Dextrose") %>% 
  ggplot(data=.,aes(x=log_timestamp,y=rate1_per_kg)) + 
  geom_path(col="red") +
  theme_bw() + xlab("Timestamp") +ylab("Dextrose (mg/kg/min)")

# SENSOR STRATEGY -----------

sensor_strategy_parsed <- sensor_strategy_parsing(error_logs_extract,strategy = "WithinFiveMinutesOfLatest") %>% 
  match_logs(data_log= patient_information %>% 
               distinct(data_session,subject_id),
             error_log = .)


# SAVE ----------
write_csv(glucose_parsed,paste0(path_fusion_data,"/output/glucose_parsed.csv"))
write_csv(pump_rate_parsed %>% dplyr::select(-pause,-error_message),paste0(path_fusion_data,"/output/pump_rate_parsed.csv"))
write_csv(pump_paused,paste0(path_fusion_data,"/output/pump_paused.csv"))
write_csv(sensor_strategy_parsed,paste0(path_fusion_data,"/output/sensor_strategy_parsed.csv"))

