header <- c("log_timestamp","log_level","unused_field","error_message","error_code","error_source","call_chain")

source("functions/glucose_parsing.R")
source("functions/pump_rate_parsing.R")

error_logs_list <- list.files(paste0(path_fusion_data,"/extract"),pattern="ERROR_LOG",full.names = TRUE,recursive = TRUE)

error_logs_extract <- map_dfr(error_logs_list,
                         function(f){
                           f_name <- str_extract(f,"IMT_[A-Z0-9_]+");
                           f_utc_time <- str_replace(f_name,"IMT_ERROR_LOG_","") %>% ymd_hms(.);
                           folder_id <- str_extract(string = f,pattern = "extract/[0-9_]+") %>% str_replace(.,"extract/",replacement = "");
                           print(folder_id);

                           df <- read.csv(f,col.names = header,skip = 1,sep=";");
                           
                           df %>%
                             mutate(folder_id = folder_id) %>% 
                           return()
                           
                         })

unique_ids <- error_logs_extract$folder_id %>% unique(.)
patient_information <- read_csv(paste0(path_fusion_data,"/patient_information.csv")) %>% 
  dplyr::select(subject_id,folder_id,insulin,dextrose,weight) %>% 
  pivot_longer(cols=c("insulin","dextrose"),names_to="substance",values_to="concentration") %>% 
  mutate(substance = str_to_sentence(substance))
  


glucose_parsed <- glucose_parsing(error_logs_extract) %>% 
  left_join(patient_information %>% distinct(folder_id,subject_id),by=c("folder_id"))
pump_rate_parsed <- pump_rate_parsing(error_logs_extract) %>% 
  left_join(patient_information,by=c("substance","folder_id")) %>% 
  mutate(rate1 = case_when(substance == "Insulin" ~ rate*concentration,
                                 substance == "Dextrose" ~ (rate/100)*(concentration*1000)*(1/60),
                                 TRUE ~ NA_real_),
         rate1_per_kg = rate1/weight) %>% 
  dplyr::select(-weight,-concentration)





# SAVE ----------
write_csv(glucose_parsed,paste0(path_fusion_data,"/glucose_parsed.csv"))
write_csv(pump_rate_parsed,paste0(path_fusion_data,"/pump_rate_parsed.csv"))
