# PENDING: Different encounters for each patient - need to assign unique patient ID, unique encounter ID

nct05386849 <- function(dexcom_glucose,fusion_glucose = NULL,arterial_glucose = NULL){
  
  # Duration: 24 hours
  # The primary safety outcome will be the percent of all glucose values that are within the glucose range of less than 70 mg/dL.
  # The primary efficacy outcome will be the percent of all glucose values that are within the glucose range of 70-180 mg/dL.
  
  
  # 1. Measure the percent of all glucose values that are less than 54 mg/dL.
  # 2. Measure the percent of all glucose values that are greater than 180 mg/dL.
  # 3. Measure the degree of glucose dispersion by determining the coefficient of variation.
  # 4. Measure the percent of all glucose values that are within the desired control range of 100-140 mg/dL.
  # 5. The average glucose value used by the FUSION system in mg/dL will be compared with blood glucose in mg/dL from an arterialized hand vein. 
  # The arterialized hand vein measurement will occur every 10-60 minutes throughout the closed loop session.
  # 6. Glucose readings in mg/dL from the Dexcom G6 CGM's will be compared with blood glucose in mg/dL from an arterialized hand vein. 
  # The arterialized hand vein measurement will occur every 10-60 minutes throughout the closed loop session.
 
  missing <- sum(is.na(dexcom_glucose))
  p1 <- p2 <- s1 <- s2 <- s3 <- s4 <- s5 <- s6 <- NA
  if(missing < 0.70*length(dexcom_glucose)){
    p1 <- mean(dexcom_glucose < 70,na.rm=TRUE)*100
    p2 <- mean(dexcom_glucose %in% c(70:180),na.rm=TRUE)*100
    
    s1 <- mean(dexcom_glucose < 54,na.rm=TRUE)*100
    s2 <- mean(dexcom_glucose > 180,na.rm=TRUE)*100
    s3 <- sd(dexcom_glucose,na.rm=TRUE)/mean(dexcom_glucose,na.rm=TRUE)
    s4 <- mean(dexcom_glucose %in% c(100:140),na.rm=TRUE)*100
    s5 <- mean(dexcom_glucose %in% c(70:140),na.rm=TRUE)*100
    s6 <- mean(dexcom_glucose, na.rm=TRUE)
    s7 <- mean(dexcom_glucose > 250,na.rm=TRUE)*100
  }
  
  data.frame(
             mean = s6,
             cv = s3,
             lt54 = s1,
             lt70 = p1,
             range70to140 = s5,
             range70to180 = p2,
             range100to140 = s4,
             gt180 = s2,
             gt250 = s7) %>% 
  
  return()
}
