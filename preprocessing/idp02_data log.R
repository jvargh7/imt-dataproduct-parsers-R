header1 <- c("subject_id","weight","control_range","insulin","dextrose","imt_controller","software_git")

header2 <- c("controller_time","system_time","glucose",
             paste0(rep(c("insulin_pump","dextrose_pump","controller_insulin","controller_dextrose"),each=3),
                    rep(c(25,50,75),times=4),"th"),
             "controller_private","sensor_algorithm","notes")

data_logs_list <- list.files(paste0(path_fusion_data),pattern="data_log",full.names = TRUE,recursive = TRUE)

data_logs_extract <- map(data_logs_list,
    function(s){
      s_name <- str_extract(s,"IMT_[a-z0-9_]+");
      data_session <- str_replace(s_name,"IMT_data_log_","") %>% ymd_hm(.);
      folder_name = str_extract(s,pattern = "/[0-9_]+/extract") %>% 
        str_replace_all(.,"extract","") %>% 
        str_replace_all(.,"/","");
      
      print(session_time);
      
      df1 <- if(str_detect(s,"csv")){
        read_csv(s,col_names = header1,n_max = 1,skip = 1)
      }else if(str_detect(s,".xlsx")){
        readxl::read_excel(s,col_names = header1,n_max = 1,skip=1)
      }

                    
      
      df1 <- df1 %>% 
        mutate(data_session = data_session,
               folder_name = folder_name,
               subject_id = paste0("'",subject_id,"'")) %>% 
        mutate_at(vars(weight,insulin,dextrose),~as.numeric(.))
      
      df2 <- if(str_detect(s,".csv")){
        read_csv(s,col_names = header2,skip = 3)
      }else if(str_detect(s,".xlsx")){
        readxl::read_excel(s,col_names = header2,skip = 3)
      }
      
      
      
      df2 <- df2  %>% 
        mutate(data_session = data_session,
               folder_name = folder_name,
               system_time = ymd_hms(system_time))
      
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


write_csv(patient_information,paste0(path_fusion_data,"/output/patient_information.csv"))
write_csv(controller_information,paste0(path_fusion_data,"/output/controller_information.csv"))


