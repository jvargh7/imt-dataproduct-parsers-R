controller_information <- read_csv(paste0(path_fusion_data,"/output/controller_information.csv"))
source("functions/nct05386849.R")
source("functions/ctime_issues.R")

# PENDING: Different encounters for each patient - need to assign unique patient ID, unique encounter ID
# Need to change ~/functions/* also
unique_ids <- controller_information %>% 
  distinct(data_session,subject_id)

controller_summary <- map_dfr(1:nrow(unique_ids),
                              function(r){
                                ds_id = unique_ids[r,]$data_session;
                                s_id = unique_ids[r,]$subject_id;
                                
                                s <- controller_information %>% 
                                  dplyr::filter(data_session == ds_id,subject_id == s_id) %>% 
                                  dplyr::select(glucose) %>% 
                                  pull() %>% 
                                  nct05386849(dexcom_glucose = .);
                                
                                
                                data.frame(data_session = ds_id,
                                           subject_id = s_id) %>% 
                                  bind_cols(s) %>% 
                                  return(.)
                                
                                
                              }) %>% 
  dplyr::select(subject_id,data_session,everything())



ctime_summary <- map_dfr(1:nrow(unique_ids),
                         function(r) {
                           ds_id = unique_ids[r,]$data_session;
                           s_id = unique_ids[r,]$subject_id;
                           
                           c_df <- controller_information %>% 
                             dplyr::filter(data_session == ds_id,
                                           subject_id == s_id) %>% 
                             ctime_issues(.)
                           
                         }
                           
                           ) %>% 
  dplyr::select(subject_id,data_session,folder_name,controller_time,system_time,everything())

write_csv(controller_summary,paste0(path_fusion_data,"/summary/controller_summary.csv"))
write_csv(ctime_summary,paste0(path_fusion_data,"/summary/ctime_summary.csv"))
