# List all files with .zip in file name
file_list <- list.files(path_fusion_data,pattern="\\.zip",full.names = TRUE,recursive = TRUE)

map(file_list,
    function(f){
      f_name = str_extract(f,pattern = "/[0-9_]+/(Data|Error) Logs.zip") %>% 
        str_replace_all(.,"/(Data|Error) Logs.zip","") %>% 
        str_replace(.,"/","");
      f_path = str_extract(f,pattern=paste0(".*/",f_name))
      if(!dir.exists(paste0(f_path,"/extract"))){
        dir.create(paste0(f_path,"/extract"))
      }
      
      
      unzip(f,exdir = paste0(paste0(f_path,"/extract")))
    })
