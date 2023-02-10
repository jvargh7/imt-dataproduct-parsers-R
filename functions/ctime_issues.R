# PENDING: Different encounters for each patient - need to assign unique patient ID, unique encounter ID

# Where is controller time different from system time?
ctime_issues <- function(df,ctime_cutoff=3){
  
  df %>% 
    group_by(data_session) %>% 
    mutate(ctime_diff = controller_time - dplyr::lag(controller_time,1), 
           stime_diff = system_time - dplyr::lag(system_time,1)) %>% 
    dplyr::filter(abs(ctime_diff - as.numeric((stime_diff))) > ctime_cutoff) %>% 
    ungroup() %>% 
    return(.)
  
}
