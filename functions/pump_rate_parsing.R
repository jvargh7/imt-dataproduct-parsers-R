pump_rate_parsing <- function(df,pause_lag = 3) {
  
  df_pause <- df %>% 
    dplyr::filter(log_level == "LOG_DEBUG",str_detect(error_message,"(controller pausing|controller resuming)")) %>% 
    dplyr::select(error_session,log_timestamp,error_message) %>% 
    mutate(rate = case_when(error_message == "controller pausing" & (log_timestamp - dplyr::lead(log_timestamp,1)) < minutes(pause_lag) ~ NA_real_,
                            error_message == "controller resuming" & (log_timestamp - dplyr::lag(log_timestamp,1)) < minutes(pause_lag) ~ NA_real_,
                            TRUE ~ 0
                            ),
           pause = 1,
           substance = "Dextrose") %>% 
    bind_rows(.,
              {.} %>% 
                mutate(substance = "Insulin")) %>% 
    mutate_at(vars(log_timestamp),
              function(x) str_replace(x,"[A-Z\\sa-z]\\:","") %>% ymd_hms(.))
  
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
  
  bind_rows(df_pause,
            df_parsed) %>% 
    arrange(error_session,log_timestamp,substance) %>% 
  return(.)
  
  
  
}
