search_stations<-function(pathout,trasform) {
  
  # Search for the weekly solutions (XYZ coordinates) of SIRGAS stations
  packages <-
    c("RCurl",
      "dplyr",
      "stringr")
  
  source("search_and_load.R")
  
  search_and_load(packages)
  
  options(RCurlOptions = list(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl")))
  
  URL_name = 'ftp://ftp.sirgas.org/pub/gps/SIRGAS/'
  
  result = getURL(URL_name,
                  dirlistonly = TRUE,
                  verbose = TRUE
                  )
  
  # If the list already exists, we need to upload data with the newest coordinates and sites available
  
  file_name = paste0(pathout,"/SIRGAS_list.txt")
  
  if (file.exists(file_name) == TRUE){
    
    # Latest week read
    OUT = read.csv2(file_name,
                    header=TRUE,
                    dec=".",
                    stringsAsFactors = FALSE)
    week = max (OUT$WEEK) + 1
    print(paste0("Latest week consulted: ",max (OUT$WEEK),". Starting from: ",max (OUT$WEEK)+1))
    
  } else {
    
    # First week of SIRGAS 
    week = 1043
    # Empty data frame with data types
    OUT = data.frame(STAT=character(0),
                     X=numeric(0),
                     Y=numeric(0),
                     Z=numeric(0),
                     WEEK=numeric(0))
    
    print("Starting from the very begining (Week 1043)")
    
  }
  
  # Latest GPS week
  semanas=as.numeric(strsplit(result,"\r\n")[[1]])
  
  n = max(semanas, na.rm = TRUE)
  
  # Loop through every weekly solution
  for (j in week:n) {

    print(paste0('Week ',j))
    
    # URL name  REPRO1
    # url_raw=paste0(URL_name,j,'/')
    
    if (j < 2191) { # solucion temporal
      # URL name REPRO2
      url_raw=paste0(URL_name,j,'/REPRO2/') # Solo hasta semana 2190.
    } else {
      # URL name REPRO2
      url_raw=paste0(URL_name,j,'/') # Solo hasta semana 2190.
    }
    
    # Find the coordinates file
    # text_data <- getURL(url_raw,dirlistonly=TRUE) - Listado de cosas dentro de la carpeta
    text_data = getURL(url_raw,
                       customrequest="NLST s*.crd", 
                       ssl.verifypeer = FALSE)

    file_interes = strsplit(text_data,"\r\n")[[1]]
    
    if (length(file_interes) != 0) {
      
      # Read the coordinates file, if exists
      XYZ <- read.csv(text = getURL(paste0(url_raw,file_interes)),
                      header=FALSE,
                      skip=5,
                      sep="",
                      dec=".",
                      stringsAsFactors = FALSE,
                      col.names=c("NUM","STAT","ID","X","Y","Z","FLAG"))
      
      # Keep specific columns and merge them with the existing
      list = XYZ %>% select("STAT","X","Y","Z") %>% 
        mutate("WEEK" = j)
      
      OUT = OUT %>% full_join(list, by = c("STAT", "X", "Y", "Z", "WEEK"))
      
      # Remove oldest coordinates and sort by STAT name
      OUT_filt = OUT %>% 
        group_by(STAT) %>%
        top_n(1, WEEK) %>%
        arrange(STAT)
      
      # Save file
      write.table(OUT_filt,
                  file = paste0(pathout,"/SIRGAS_list.txt"),
                  quote=FALSE,
                  sep=";",
                  na="NA",
                  dec=".",
                  row.names=FALSE,
                  col.names=TRUE)
      
    } else {
      
      print(" ")
      print("    WARNING !!!!")
      print(paste0("No coordinate file for week ",j, ". Week ",j-1," is assumed to be the latest with data"))
      break
      
    }
    
    # We need to wait a while and not send many queries to the server in a short time
    Sys.sleep(180)
    
  }  # end loop
  
  # If we want, we can transform coordinates to lat, long, h
  if (trasform == "Y"){
    search_and_load("ggplot2")
    source("XYZ2geog.R")
    XYZ2geog(pathout,"SIRGAS_list")
  }
  
}
