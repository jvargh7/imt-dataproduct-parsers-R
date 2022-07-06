# List all files with .zip in file name
file_list <- list.files(path_fusion_data,pattern="\\.zip",full.names = TRUE)

# Create a folder called "extract"
if(!dir.exists(paste0(path_fusion_data,"/extract"))){
  dir.create(paste0(path_fusion_data,"/extract"))
}

map(file_list,
    function(f){
      f_name = str_replace(f,path_fusion_data,"") %>% str_replace(.,"\\.zip","")
      unzip(f,exdir = paste0(path_fusion_data,"/extract"))
      unzip(paste0(path_fusion_data,"/extract/",f_name,"/Data Logs.zip"),exdir = paste0(paste0(path_fusion_data,"/extract/",f_name)))
      unzip(paste0(path_fusion_data,"/extract/",f_name,"/Error Logs.zip"),exdir = paste0(paste0(path_fusion_data,"/extract/",f_name)))
    })