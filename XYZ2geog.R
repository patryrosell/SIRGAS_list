XYZ2geog<- function(path,nombre_file){
  
  # El documento debe estar formado por ID;X;Y;Z;WEEK- No importa el nombre, respetar el orden
  # Las columnas deben estar separadas por ";" y los decimales deben ser puntos
  
  print("---- Running coordinate transformation (from XYZ to Lat,Long,H.)")
  
  data_raw = read.csv(paste0(path,"/",nombre_file,".txt"),
                      header=TRUE,
                      sep=";",
                      dec=".",
                      stringsAsFactors = FALSE)
  
	# WGS84 parameters  
  aa = 6378137
  bb = 6356752.3
  e2 = 0.006694379990
  ff = 1/298.257223  
  
  # Tolerance value
  tol = 1e-11
  
  # Max number of iterations
  it_max = 40
  
   data  =  data_raw %>% mutate(LONG = atan(data_raw$Y/data_raw$X)*(180/pi))
   
   # Valores iniciales 
   data  =  data %>% mutate(theta = aa*data$Z/(bb*sqrt(data$X^2+data$Y^2)))
   
   data  =  data %>% mutate(LAT = (atan((data$Z+(e2*bb*(sin(data$theta)^3)))/(sqrt(data$X^2+data$Y^2)-e2*aa*(cos(data$theta)^3)))))
   
   # Duplicate of Lat column to always have the latest value computed
   data = data %>% mutate(LAT_2 = LAT)
   
   FLAG = 1
   
   IT = 0
   
   OUT = NULL
   
   while (FLAG == 1){ # Iteraciones
     
     data  =  data %>% mutate(N = aa/sqrt(1-e2*(sin(data$LAT_2)^2)))
     
     data  =  data %>% mutate(h = (sqrt(data$X^2+data$Y^2)/cos(data$LAT_2))-data$N)
   
     data  =  data %>% mutate(tera = data$Z/(sqrt(data$X^2+data$Y^2)))
     
     data  =  data %>% mutate(terb = (1-((e2*data$N)/(data$N+data$h)))^(-1))
     
     data  =  data %>% mutate(LAT_2 = atan(data$tera*data$terb))
     
     data  =  data %>% mutate(TOL = abs(LAT - LAT_2))
     
     IT = IT +1
     
     #print(IT)
     
     # Separate data that converged 
     data_tol = dplyr::filter(data, TOL <= tol)
     
     # Separate data that doesnt converged yes
     data_no_tol = dplyr::filter(data, TOL > tol)
     
     if (nrow(data_no_tol) != 0) {
       # If data doesnt converge yet, replace initial data with new values
       data = data_no_tol
       data = data %>% mutate(LAT = LAT_2)
       # Put apart data that already converge
       OUT = rbind(OUT, data_tol)
       IT = IT + 1
     } else {
       # Once all data converged, leave the loop
       OUT = rbind(OUT, data_tol)
       FLAG = 2
     }
     
     # If data still doesn't converge...
     if (IT == it_max) {
       OUT = rbind(data, data_tol)
       FLAG = 2
     }
     
  
   } # End while
   
   print(paste0("Amount of iterations: ",IT))
   
   # Plotting tolerances for control
   
   tol_plot = ggplot(OUT) + 
              geom_point(aes(x=STAT, y=TOL)) +
              labs(y = "Residuals [m]", x = "Stations") +
              theme(axis.text.x=element_blank(),
                   axis.ticks.x=element_blank()) +
              ggtitle(paste0("Max res: ",max(OUT$TOL)," // Min res: ",min(OUT$TOL)))
   
   ggsave(paste0(path,"/residuals.jpeg"),
          plot = tol_plot,
          dpi = 300, 
          width = 30, 
          height = 15,
          units = "cm")
   
   # End plot
  
  OUT  =  OUT %>% mutate(LAT = OUT$LAT_2*(180/pi))
  
  data_select  =  OUT %>% select("STAT","LAT","LONG","h") %>% arrange(STAT)
  
  nombre_salida = paste0(nombre_file,"_ellip.txt")
  
  write.table(data_select,
              file  =  paste0(path,"/",nombre_salida),
              sep=";",
              row.names  =  FALSE,
              col.names  =  TRUE,
              quote  =  FALSE)
  

  
  print(">>>> Transformation has ended")
  
}
