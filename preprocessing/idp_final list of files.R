
data_logs_list <- list.files(paste0(path_fusion_data),pattern="data_log",full.names = TRUE,recursive = TRUE)
error_logs_list <- list.files(paste0(path_fusion_data),pattern="ERROR_LOG",full.names = TRUE,recursive = TRUE) %>% 
  .[!str_detect(.," - Copy")]


folder_names_times_data_logs <- str_extract(data_logs_list,"Export/[0-9]{4}_[0-9]{2}.*/extract") %>% 
  str_replace_all("(Export|/extract)","") %>% 
  str_replace("/","") %>% 
  lubridate::ymd_hm()

data_logs_list_times <- str_extract(data_logs_list,"data_log_.*") %>% 
  str_extract("[0-9]+_.*\\.") %>% 
  str_replace("\\.","") %>% 
  lubridate::ymd_hm(.)


folder_names_times_error_logs <- str_extract(error_logs_list,"Export/[0-9]{4}_[0-9]{2}.*/extract") %>% 
  str_replace_all("(Export|/extract)","") %>% 
  str_replace("/","") %>% 
  lubridate::ymd_hm()

error_logs_list_times <- str_extract(error_logs_list,"ERROR_LOG_.*") %>% 
  str_extract("[0-9]+.*\\.") %>% 
  str_replace("\\.","") %>% 
  lubridate::ymd_hms(.)


final_data_logs_list = data_logs_list[(folder_names_times_data_logs - data_logs_list_times)<hours(48)]
final_error_logs_list = error_logs_list[(folder_names_times_error_logs - error_logs_list_times)<hours(48)]
