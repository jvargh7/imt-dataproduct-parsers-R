ysi_tracker_output <- read_csv(paste0(path_fusion_data,"/output/ysi_tracker.csv"))

ceg_adds <- function(p) {
  p + theme_bw() +
    geom_segment(aes(y = 84,yend=700,
                     x = 70,xend = 70)) +
    coord_cartesian(ylim = c(0, 400),xlim=c(0,400)) +
    scale_color_manual(values = c("black","black","black")) +
    guides(colour=FALSE)
}

unique_subjects <- unique(ysi_tracker_output$subject_id)

map(unique_subjects,
    function(u){
      
      
      
      fig_A <- ysi_tracker_output %>% 
        dplyr::filter(subject_id == u) %>% 
        dplyr::select(reference_glucose,sensor1_glucose) %>% 
        plotClarkeGrid(referenceVals = .$reference_glucose,testVals = .$sensor1_glucose,zones=NA,
                       title = "Sensor 1",xlab="Reference Glucose (mg/dL)",ylab="Sensor Glucose (mg/dL)");
      
      fig_B <- ysi_tracker_output %>% 
        dplyr::filter(subject_id == u) %>% 
        dplyr::select(reference_glucose,sensor0_glucose) %>% 
        plotClarkeGrid(referenceVals = .$reference_glucose,testVals = .$sensor0_glucose,zones=NA,
                       title = "Sensor 0",xlab="Reference Glucose (mg/dL)",ylab="Sensor Glucose (mg/dL)");
      
      
      fig_C <- ysi_tracker_output %>% 
        dplyr::filter(subject_id == u) %>% 
        dplyr::select(reference_glucose,sensoravg_glucose) %>% 
        plotClarkeGrid(referenceVals = .$reference_glucose,testVals = .$sensoravg_glucose,zones=NA,
                       title = "Sensor Average",xlab="Reference Glucose (mg/dL)",ylab="Sensor Glucose (mg/dL)");

      ggpubr::ggarrange(fig_A %>% ceg_adds(.),
                        fig_B %>% ceg_adds(.),
                        fig_C %>% ceg_adds(.),nrow=1,ncol=3,legend = "bottom") %>% 
        ggsave(.,filename = paste0(path_fusion_data,"/figures/CEG ",u,".png"),width = 15,height=5)
      
    })


