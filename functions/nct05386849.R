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
    s8 <- mean(dexcom_glucose %in% c(54:69),na.rm=TRUE)*100
    s9 <- mean(dexcom_glucose %in% c(181:250),na.rm=TRUE)*100
    # Non missing
    n_nonna <- sum(!is.na(dexcom_glucose)) 
    n_total = length(dexcom_glucose)
    sum_of_squares <- var(dexcom_glucose,na.rm=TRUE)*(n_nonna-1)
    
    
    s10 <- round((46.7 + mean(dexcom_glucose, na.rm=TRUE))/28.7, digits = 1)
    s11 <- round(3.31 + (0.02392*mean(dexcom_glucose,na.rm=TRUE)))
    
    median = median(dexcom_glucose,na.rm=TRUE)
    q1 = quantile(dexcom_glucose,probs=0.25,na.rm=TRUE)
    q3 = quantile(dexcom_glucose,probs=0.75,na.rm=TRUE)

  }
  
  # Order based on: Battelino 2019 https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6973648/
  data.frame(
             mean = s6,
             gmi = s11,
             cv = s3,
             
             gt250 = s7,
             range181to250 = s9,
             range70to180 = p2,
             range54to69 = s8,
             lt54 = s1,
             
             range70to140 = s5,
             range100to140 = s4,
             lt70 = p1,
             gt180 = s2,
             
             # estimated a1c was used till 2017
             estimated_a1c = s10,
             n_nonna = n_nonna,
             n_total = n_total,
             sum_of_squares = sum_of_squares,
             
             median = median,
             iqr = paste0("IQR: ",q1," - ",q3)
             ) %>% 
  
  return()
}
