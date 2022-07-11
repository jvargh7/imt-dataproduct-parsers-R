pump_rate_parsing <- function(df) {
  
  df_parsed <- df %>% 
    dplyr::filter(log_level == "LOG_DEBUG",str_detect(error_message,"changing pump rate to")) %>% 
    dplyr::select(error_session,log_timestamp,error_message) %>% 
    mutate(rate = str_extract(error_message,"[0-9\\.]+") %>% as.numeric(.),
           substance = case_when(str_detect(error_message,"Dextrose") ~ "Dextrose",
                                 str_detect(error_message,"Insulin") ~ "Insulin",
                                 TRUE ~ NA_character_))  %>% 
    mutate_at(vars(log_timestamp),
              function(x) str_replace(x,"[A-Z\\sa-z]\\:","") %>% ymd_hms(.)) %>% 
    dplyr::select(-error_message)
  
  return(df_parsed)
  
  
  
}
