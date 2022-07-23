merge_timestamp <- function(df_x,df_y,lag_seconds_min = 0,lag_seconds_max = 10*60){
  
  df_merge <- df_x %>% 
    full_join(df_y,
              by=c("subject_id")) %>%
    mutate(time_diff = timestamp - blood_draw_time) %>% 
    group_by(subject_id,blood_draw_time) %>% 
    dplyr::filter(time_diff > seconds(lag_seconds_min), time_diff < seconds(lag_seconds_max)) %>% 
    
    # Smallest time difference
    # If we were to get the largest time difference between a (YSI - Sensor) match, we can do time_diff == max(time_diff)
    dplyr::filter(time_diff == min(time_diff)) 
  
  return(df_merge)
  
  
}
