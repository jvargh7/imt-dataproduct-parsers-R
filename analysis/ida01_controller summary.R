controller_information <- read_csv(paste0(path_fusion_data,"/controller_information.csv"))
source("functions/nct05386849.R")
source("functions/ctime_issues.R")

# PENDING: Different encounters for each patient - need to assign unique patient ID, unique encounter ID
# Need to change ~/functions/* also
unique_ids <- controller_information$folder_id %>% unique(.)

controller_summary <- map_dfr(unique_ids,
                              function(id){
                                s <- controller_information %>% 
                                  dplyr::filter(folder_id == id) %>% 
                                  dplyr::select(glucose) %>% 
                                  pull() %>% 
                                  nct05386849(dexcom_glucose = .);
                                
                                s_id = controller_information %>% 
                                  dplyr::filter(folder_id == id) %>% 
                                  dplyr::select(subject_id) %>% 
                                  pull() %>% 
                                  unique() %>% 
                                  .[[1]];
                                
                                data.frame(folder_id = id,
                                           subject_id = s_id) %>% 
                                  bind_cols(s) %>% 
                                  return(.)
                                
                                
                              })

write_csv(controller_summary,paste0(path_fusion_safety,"/working/controller_summary.csv"))

ctime_summary <- map_dfr(unique_ids,
                         function(id) {
                           c_df <- controller_information %>% 
                             dplyr::filter(folder_id == id) %>% 
                             ctime_issues(.)
                           
                         }
                           
                           ) %>% 
  dplyr::select(folder_id,subject_id,controller_time,system_time,everything())
write_csv(ctime_summary,paste0(path_fusion_safety,"/working/ctime_summary.csv"))
