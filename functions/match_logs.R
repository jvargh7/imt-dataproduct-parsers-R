match_logs <- function(data_log,error_log,delta = 15){
  
  d_session <- unique(data_log$data_session)
  e_session <- unique(error_log$error_session)
  
  delta_m = minutes(delta)
  
  match_variables <- if("substance" %in% colnames(data_log)){
    c("data_session","error_session","substance")} else{
      c("data_session","error_session")
    }

  
  matched_sessions <- which(abs(d_session - e_session) <= delta_m)
  unmatched_sessions <- which(abs(d_session - e_session) > delta_m)
  
  output_file_name <- paste0(path_fusion_data,"/match_logs output.txt")
  if(file.exists(output_file_name)){
    file.remove(output_file_name)
  }
  
  if(!identical(matched_sessions,integer(0))){
    matched_data_log <- map_dfr(matched_sessions,
                                function(x){
                                  d <- data_log %>% 
                                    dplyr::filter(data_session == d_session[x]) %>% 
                                    mutate(error_session = e_session[x]);
                                  
                                  e <- error_log %>% 
                                    dplyr::filter(error_session == e_session[x]) %>% 
                                    mutate(data_session = d_session[x]);
                                  
                                  left_join(d,e,
                                            by=match_variables) %>% 
                                    return(.)
                                  
                                })
      
    
  }
  if(!identical(unmatched_sessions,integer(0))){
    unmatched_data_log <- map_dfr(unmatched_sessions,
                                  function(x){
                                    d <- data_log %>% 
                                      dplyr::filter(data_session == d_session[x]) %>% 
                                      mutate(attempted_match = e_session[x]);
                                    return(d)
                                    })
    
    cat(paste0("Time: ",Sys.time()), file = output_file_name)
    cat("The following patients were not matched: ",file=output_file_name,sep="\n")
    writeLines(unmatched_data_log,file = output_file_name)
    
    
  }
  
  return(matched_data_log)
  
}
