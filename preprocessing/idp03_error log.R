header <- c("timestamp","log_level","unused_field","error_message","error_code","error_source","call_chain")


error_logs_list <- list.files(paste0(path_fusion_data,"/extract"),pattern="ERROR_LOG",full.names = TRUE,recursive = TRUE)

error_logs_extract <- map(error_logs_list,
                         function(f){
                           f_name <- str_extract(f,"IMT_[A-Z0-9_]+");
                           f_utc_time <- str_replace(f_name,"IMT_ERROR_LOG_","") %>% ymd_hms(.);

                           df <- read.csv(f,col.names = header,skip = 1,sep=";");
                           
                           df %>% 
                           return()
                           
                         })

