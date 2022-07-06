
glucose_parsed <- read_csv(paste0(path_fusion_data,"/glucose_parsed.csv"))
pump_rate_parsed <- read_csv(paste0(path_fusion_data,"/pump_rate_parsed.csv"))

unique_ids <- glucose_parsed$folder_id %>% unique(.)

glucose_summary <- map_dfr(unique_ids,
                         function(id){
                           sensor1_out <- glucose_parsed %>% 
                             dplyr::filter(sensor_id == 1,folder_id == id) %>% 
                             dplyr::select(glucose) %>% 
                             pull() %>% 
                             nct05386849(dexcom_glucose = .) %>% 
                             mutate(sensor_id = 1);
                           
                           sensor0_out <- glucose_parsed %>% 
                             dplyr::filter(sensor_id == 0,folder_id == id) %>% 
                             dplyr::select(glucose) %>% 
                             pull() %>% 
                             nct05386849(dexcom_glucose = .) %>% 
                             mutate(sensor_id = 0);
                           
                           s_id = glucose_parsed %>% 
                             dplyr::filter(folder_id == id) %>% 
                             dplyr::select(subject_id) %>% 
                             pull() %>% 
                             unique() %>% 
                             .[[1]];
                           
                           data.frame(folder_id = id,
                                      subject_id = s_id) %>% 
                             bind_cols(bind_rows(sensor1_out,
                                                 sensor0_out)) %>% 
                             return(.)
                           
                         }) %>% 
  dplyr::select(folder_id,subject_id,sensor_id,everything())


pump_rate_summary <- pump_rate_parsed %>% 
  group_by(folder_id,subject_id,substance) %>% 
  summarize(average_rate1 = mean(rate1,na.rm=TRUE),
            average_rate1_per_kg = mean(rate1_per_kg,na.rm=TRUE)) %>% 
  dplyr::select(folder_id,subject_id,everything())


write_csv(glucose_summary,paste0(path_fusion_safety,"/working/glucose_summary.csv"))
write_csv(pump_rate_summary,paste0(path_fusion_safety,"/working/pump_rate_summary.csv"))
