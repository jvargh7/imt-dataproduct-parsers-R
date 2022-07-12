source("functions/nct05386849.R")
glucose_parsed <- read_csv(paste0(path_fusion_data,"/output/glucose_parsed.csv"))
pump_rate_parsed <- read_csv(paste0(path_fusion_data,"/output/pump_rate_parsed.csv"))

unique_ids <- glucose_parsed %>% 
  distinct(data_session,subject_id)

glucose_summary <- map_dfr(1:nrow(unique_ids),
                         function(r){
                           
                           ds_id = unique_ids[r,]$data_session;
                           s_id = unique_ids[r,]$subject_id;
                           
                           sensor1_out <- glucose_parsed %>% 
                             dplyr::filter(sensor_id == 1,data_session == ds_id,subject_id == s_id) %>% 
                             dplyr::select(glucose) %>% 
                             pull() %>% 
                             nct05386849(dexcom_glucose = .) %>% 
                             mutate(sensor_id = 1);
                           
                           sensor0_out <- glucose_parsed %>% 
                             dplyr::filter(sensor_id == 0,data_session == ds_id,subject_id == s_id) %>% 
                             dplyr::select(glucose) %>% 
                             pull() %>% 
                             nct05386849(dexcom_glucose = .) %>% 
                             mutate(sensor_id = 0);
                           
                           
                           data.frame(data_session = ds_id,
                                      subject_id = s_id) %>% 
                             bind_cols(bind_rows(sensor1_out,
                                                 sensor0_out)) %>% 
                             return(.)
                           
                         }) %>% 
  dplyr::select(subject_id,data_session,sensor_id,everything())


pump_rate_summary <- pump_rate_parsed %>% 
  group_by(subject_id,data_session,substance) %>% 
  summarize(average_rate1 = mean(rate1,na.rm=TRUE),
            average_rate1_per_kg = mean(rate1_per_kg,na.rm=TRUE)) %>% 
  dplyr::select(subject_id,data_session,everything())


write_csv(glucose_summary,paste0(path_fusion_data,"/summary/glucose_summary.csv"))
write_csv(pump_rate_summary,paste0(path_fusion_data,"/summary/pump_rate_summary.csv"))
