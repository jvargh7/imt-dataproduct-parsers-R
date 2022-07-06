controller_information <- read_csv(paste0(path_fusion_data,"/controller_information.csv"))
source("functions/nct05386849.R")
source("functions/ctime_issues.R")

# PENDING: Different encounters for each patient - need to assign unique patient ID, unique encounter ID
# Need to change ~/functions/* also
unique_ids <- controller_information$subject_id %>% unique(.)

controller_summary <- map_dfr(unique_ids,
                              function(id){
                                s <- controller_information %>% 
                                  dplyr::filter(subject_id == id) %>% 
                                  dplyr::select(glucose) %>% 
                                  pull() %>% 
                                  nct05386849(dexcom_glucose = .);
                                
                                data.frame(subject_id = id) %>% 
                                  bind_cols(s) %>% 
                                  return(.)
                                
                                
                              })

write_csv(controller_summary,paste0(path_fusion_safety,"/working/controller_summary.csv"))

ctime_summary <- map_dfr(unique_ids,
                         function(id) {
                           c_df <- controller_information %>% 
                             dplyr::filter(subject_id == id) %>% 
                             ctime_issues(.)
                           
                         }
                           
                           )
write_csv(ctime_summary,paste0(path_fusion_safety,"/working/ctime_summary.csv"))
