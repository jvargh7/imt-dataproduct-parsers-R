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

zone_percentages <- map_dfr(unique_subjects,
    function(u){
      
      
      u1_df <- ysi_tracker_output %>% 
        dplyr::filter(subject_id == u) %>% 
        dplyr::filter(!is.na(sensor1_glucose))
      
      sensor1_zones <- getClarkeZones(referenceVals = u1_df$reference_glucose, testVals = u1_df$sensor1_glucose)
      
      fig_A <- u1_df %>% 
        plotClarkeGrid(referenceVals = .$reference_glucose,testVals = .$sensor1_glucose,zones=sensor1_zones,
                       title = "Sensor 1",xlab="Reference Glucose (mg/dL)",ylab="Sensor Glucose (mg/dL)");
      
      u0_df <- ysi_tracker_output %>% 
        dplyr::filter(subject_id == u) %>% 
        dplyr::filter(!is.na(sensor0_glucose))
      
      sensor0_zones <- getClarkeZones (referenceVals = u0_df$reference_glucose, testVals = u0_df$sensor0_glucose)
      
      
      
      fig_B <- u0_df %>% 
        plotClarkeGrid(referenceVals = .$reference_glucose,testVals = .$sensor0_glucose,zones=sensor0_zones,
                       title = "Sensor 0",xlab="Reference Glucose (mg/dL)",ylab="Sensor Glucose (mg/dL)");
      
      
      uavg_df <- ysi_tracker_output %>% 
        dplyr::filter(subject_id == u) %>% 
        dplyr::filter(!is.na(sensoravg_glucose))
      
      sensoravg_zones <- getClarkeZones (referenceVals = uavg_df$reference_glucose, testVals = uavg_df$sensoravg_glucose)
      
      fig_C <- uavg_df %>% 
        plotClarkeGrid(referenceVals = .$reference_glucose,testVals = .$sensoravg_glucose,zones=sensoravg_zones,
                       title = "Sensor Average",xlab="Reference Glucose (mg/dL)",ylab="Sensor Glucose (mg/dL)");

      ggpubr::ggarrange(fig_A %>% ceg_adds(.),
                        fig_B %>% ceg_adds(.),
                        fig_C %>% ceg_adds(.),nrow=1,ncol=3,legend = "bottom") %>% 
        ggsave(.,filename = paste0(path_fusion_data,"/Figures/CEG ",u,".png"),width = 15,height=5)
      
      z_p <- data.frame(zones = c(sensor1_zones,sensor0_zones,sensoravg_zones),
                                     sensor = c(rep("Sensor 1",times=length(sensor1_zones)),
                                                rep("Sensor 0",times=length(sensor0_zones)),
                                                rep("Sensor Average",times=length(sensoravg_zones))
                                                )) %>% 
        group_by(sensor,zones) %>% 
        tally() %>% 
        mutate(percentage = n*100/sum(n)) %>% 
        ungroup() %>% 
        dplyr::select(-n) %>% 
        pivot_wider(names_from=zones,values_from=percentage) %>% 
        mutate(subject_id = u);
      
      return(z_p)
      
      
      
    })

write_csv(zone_percentages,path = paste0(path_fusion_data,"/summary/CEG Zones.csv"))

