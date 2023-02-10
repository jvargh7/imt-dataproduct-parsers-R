pump_rate_parsing <- function(df,pause_lag = 3,pct_pause_cutoff = 0.5) {
  
  # When has the controller paused and resumed -------
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
  
  # Extracting change in pump rate --------
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
    # This was added to make sure that even if we have duplicate files in error logs, it would remove duplicated rows
    # We need to make sure that this doesn't interfere with anything later.
    # arrange(error_session,log_timestamp,substance) %>% 
    # distinct(error_session,log_timestamp,substance, rate,.keep_all = TRUE)
  
  bind_rows(df_pause,
            df_parsed) %>% 
    arrange(error_session,log_timestamp,substance) %>% 
    group_by(error_session,substance) %>% 
    
    # During a pause, there is no drug delivery
    # If we assume drug keeps getting delivered during the pause, we are overestimating the total volume delivered
    mutate(# Bring last observation down
           last_obs = case_when(is.na(error_message) ~ NA_real_,
                                TRUE ~ zoo::na.locf(rate)),
           # # Bring next observation up
           next_obs = case_when(is.na(error_message) ~ NA_real_,
           #                      # Updated on 9-Feb-2023 because of error when NA values corresponding 
           #                      # to last 'controller pausing' was preventing next_obs from being created
           #                      # zoo::na.locf(rate,fromLast=TRUE) was the original version
                                TRUE ~ zoo::na.locf(rate,fromLast=TRUE,na.rm=FALSE))
           ) %>% 
    mutate(rate_imp = case_when(is.na(error_message) ~ rate,
                            last_obs == 0 & next_obs == 0 ~ rate,
                            abs((last_obs - next_obs)*100/last_obs) > pct_pause_cutoff ~ 0,
                            TRUE ~ rate)) %>%
    dplyr::select(-rate) %>% 
    dplyr::rename(
                  rate = rate_imp) %>% 
    
  return(.)
  
  
  
}
