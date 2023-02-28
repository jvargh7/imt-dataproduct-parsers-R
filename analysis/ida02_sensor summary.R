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
  arrange(subject_id,log_timestamp)  %>% 
  
  group_by(subject_id,data_session,substance,units,units_per_kg) %>% 
  mutate(rate1_imp = case_when(is.na(rate1) ~ 0,
                               TRUE ~ rate1),
         rate1_per_kg_imp = case_when(is.na(rate1_per_kg) ~ 0,
                                      TRUE ~ rate1_per_kg),
         diff_timestamp = (log_timestamp - dplyr::lag(log_timestamp,1)) %>% as.numeric(.,units="mins")) %>% 
  mutate(diff_timestamp = case_when(substance == "Insulin" ~ diff_timestamp/60,
                                    substance == "Dextrose" ~ diff_timestamp,
                                    TRUE ~ NA_real_)) %>% 
  
  # This would assume that the rates for the first and second observations are the same for each pair of
  # subject_id x data_session x substance (and units, units per kg)
  dplyr::summarize(time_elapsed = sum(diff_timestamp,na.rm=TRUE),
            volume_rate1 = sum(diff_timestamp*rate1_imp,na.rm=TRUE),
            
            volume_rate1_per_kg = sum(diff_timestamp*rate1_per_kg_imp,na.rm=TRUE),
            average_rate1 = sum(diff_timestamp*rate1_imp,na.rm=TRUE)/sum(diff_timestamp,na.rm=TRUE),
            average_rate1_per_kg = sum(diff_timestamp*rate1_per_kg_imp,na.rm=TRUE)/sum(diff_timestamp,na.rm=TRUE),
            n_nonna = sum(!is.na(diff_timestamp*rate1_imp))) %>% 
  ungroup() %>% 
  mutate(units_time = str_extract(units,"(min|hr)"),
         units_volume = str_replace(units,"(/min|/hr)",""),
         units_volume_per_kg = str_replace(units_per_kg,"(/min|/hr)","")) %>% 
  rename(units_rate1 = units,
         units_rate1_per_kg = units_per_kg) %>% 
  dplyr::select(subject_id,data_session,substance,time_elapsed,units_time,volume_rate1,units_volume,average_rate1,units_rate1,
                volume_rate1_per_kg,units_volume_per_kg,average_rate1_per_kg,units_rate1_per_kg,n_nonna)


write_csv(glucose_summary,paste0(path_fusion_data,"/summary/glucose_summary.csv"))
write_csv(pump_rate_summary,paste0(path_fusion_data,"/summary/pump_rate_summary.csv"))
