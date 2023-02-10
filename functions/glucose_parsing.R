glucose_parsing <- function(df) {
  df_parsed <- df %>% 
    # PENDING
    dplyr::filter(log_level == "LOG_INFO",str_detect(error_message,"Sensor Data")) %>% 
    dplyr::select(error_session,log_timestamp,error_message) %>% 
    mutate(error_message = str_replace_all(error_message,"(Sensor Data\\:\\s|\\t|\\n|\\\\n|\\\\t|\\\\|\\{|\\}|Raw Packet\\:)","") %>% 
             str_trim(.) %>% 
             str_squish(.)) %>% 
    separate(error_message,sep = ",",into=c("sensor_type","value","time_stamp",
                                            "glucose","system_time","display_time","special_value_type","page","sensor_id")) %>% 
    mutate(sensor_type = str_replace(sensor_type,"Sensor Type\\:\\s","")) %>% 
    mutate_at(vars(value,glucose,special_value_type,page,sensor_id),
              function(x) str_replace_all(x,"[A-Za-z\\s\\:\\/\\(\\)]","")) %>% 
    mutate_at(vars(log_timestamp,time_stamp,system_time,display_time),
              function(x) str_replace(x,"[A-Z\\sa-z]\\:","") %>% ymd_hms(.))
    
    return(df_parsed)
  
}

