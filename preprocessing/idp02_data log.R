header1 <- c("subject_id","weight","control_range","insulin","dextrose","imt_controller","software_git")

header2 <- c("controller_time","system_time","glucose",
             paste0(rep(c("insulin_pump","dextrose_pump","controller_insulin","controller_dextrose"),each=3),
                    rep(c(25,50,75),times=4),"th"),
             "controller_private","sensor_algorithm","notes")

data_logs_list <- list.files(paste0(path_fusion_data,"/extract"),pattern="data_log",full.names = TRUE,recursive = TRUE)

data_logs_extract <- map(data_logs_list,
    function(f){
      f_name <- str_extract(f,"IMT_[a-z0-9_]+");
      f_id <- str_replace(f_name,"IMT_data_log_","");
      
      df1 <- read_csv(f,col_names = header1,n_max = 1,skip = 1)
      df2 <- read_csv(f,col_names = header2,skip = 3)
      
      list(df1,df2) %>% 
        return()

    })


patient_information <- map_dfr(data_logs_extract,
                               function(dl){
                                 dl[[1]] %>% 
                                   return(.)
                                 
                               })

controller_information <- map_dfr(data_logs_extract,
                               function(dl){
                                 dl[[2]] %>% 
                                   bind_cols(dl[[1]] %>% 
                                               dplyr::select(subject_id,imt_controller)) %>% 
                                   return(.)
                                 
                               })


write_csv(patient_information,paste0(path_fusion_data,"/patient_information.csv"))
write_csv(controller_information,paste0(path_fusion_data,"/controller_information.csv"))


