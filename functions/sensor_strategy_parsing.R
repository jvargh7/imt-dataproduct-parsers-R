sensor_strategy_parsing <- function(df,strategy = "WithinFiveMinutesOfLatest"){
  
  ss_parsed <- df %>% 
    dplyr::filter(log_level == "LOG_NOTICE",str_detect(error_message,strategy)) %>% 
    dplyr::select(error_session,log_timestamp,error_message)  %>% 
    mutate_at(vars(log_timestamp),
              function(x) str_replace(x,"[A-Z\\sa-z]\\:","") %>% ymd_hms(.)) %>% 
    mutate(error_message = str_replace_all(error_message,"(Sensor Strategy\\:|\\t|\\n|\\\\n|\\\\t|\\\\|\\{|\\}|Raw Packet\\:|\\`)","") %>% 
             str_replace_all(.,"\\[WithinFiveMinutesOfLatest\\] \\[(0|1)\\/2\\] ","") %>% 
             str_trim(.) %>% 
             str_squish(.)) %>% 
    separate(error_message,into=c("sensor_type","value","time_stamp","glucose",
                                  "system_time","display_time","special_value_type","page","sensor_id"),sep=",") %>% 
    mutate_at(vars(sensor_type:sensor_id),function(x) str_replace_all(x,pattern="^([A-Za-z\\s/\\(\\)])+\\:","") %>% str_trim(.) %>% str_squish(.)) %>% 
    mutate_at(vars(time_stamp,system_time,display_time), function(x) str_replace(x,"[A-Z\\sa-z]\\:","") %>% ymd_hms(.)) %>% 
    mutate_at(vars(value,glucose,special_value_type,page,sensor_id),
              function(x) str_replace_all(x,"[A-Za-z\\s\\:\\/\\(\\)]",""))
  
  return(ss_parsed)
  
}