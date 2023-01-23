# SIRGAS_list

This project is part of the [Geodesy and Georeferencing Research Group](https://ingenieria.uncuyo.edu.ar/grupo-de-investigacion-aplicado-a-la-geodesia-y-georreferenciacion) of the SIRGAS Analysis Centre for the Neutral Atmosphere (CIMA) and the Remote Sensing Division of [Instituto de Capacitación Especial y Desarrollo de Ingeniería Asistida por Computadora (CEDIAC)](https://cediac.ingenieria.uncuyo.edu.ar/isat.html)

## Status

Active

## Objetive

This project aims to generate a GNSS station list of the [Geodetic Reference System for the Americas (SIRGAS)](https://sirgas.ipgh.org/). It searches within every weekly solution of coordinates and generates a list up to the latest geocentric XYZ coordinates available. It reads the files of the [REPRO2 solutions](https://www.sirgas.org/en/weekly-solutions/). Due to server restrictions, there is an automatic waiting of 3' between each search. Once finished, you can transform the geocentric coordinates to ellipsoidal positions (WGS 84).

## Institutions involved

- Facultad de Ingeniería ([FING](https://ingenieria.uncuyo.edu.ar/)) - Univesidad Nacional de Cuyo (Mendoza, Argentina)
- Facultad de Ingeniería y Enología ([INE](https://www.umaza.edu.ar/facultad-de-INE)) - Universidad Juan Agustín Maza (Mendoza, Argentina)
- Consejo Nacional de Investigaciones Científicas y técnicas ([CONICET](https://www.conicet.gov.ar/))

## Requirements

Download and Install [R](https://cran.r-project.org/)

## Getting started

1. Clone this repo
2. Within an R terminal, set the working directory to the location of step 1.: setwd(path)
3. Load the "seach_station.R": source("search_stations.R")
4. Run the function "seach_station" with the following arguments: search_stations(output_path,opt_T)
	- output_path: Absolute path (between quotation marks) to the output folder (the list/s will be stored there)
	- opt_T: set "Y" if you want to transform from geocentric to ellipsoidal. "N" for not transformation.
5. Wait. The file "SIRGAS_list.txt" will be generated and updated after every weekly search. This file is separated with semicolons (";") and presents a header with the following information: 
	- STAT: 4-letter name of each station
	- X: X coordinate in meters
	- Y: Y coordinate in meters
	- Z: Z coordinate in meters
	- WEEK: Number of the latest GPS week with a solution
6. Any rerun of the function will start from the latest week informed in the output file (if exists in the path indicated in step 3.)
7. If you set "Y" in step 4. the function "XYZ2geog" will be loaded in order to transform the coordinates into ellipsoidal positions. The output file will be called "SIRGAS_list_ellip.txt" and it is separated with semicolons (";"). It will be stored in the same path as step 4. and presents a header with the following information: 
	- STAT: 4-letter name of each station
	- LAT: Latitude
	- LONG: Longitude
	- h: Ellipsoidal height
 Additionally, a plot with the residuals of the transformation will be stored as "plot_tol.jpeg"
8. The function of step 7. can be reused for any file with the same format of "SIRGAS_list.txt". It requires two arguments:
	- Location path of the file to be transformed
	- Name of the file to be read, without its extension.

## Last update: 

01-23-2013

## Author

Patricia A. Rosell, Ph.D.

## Contact info

For any doubts or more information, please contact me at:\
​​patricia.rosell[at]ingenieria.uncuyo.edu.ar\
prosell[at]profesores.umaza.edu.ar\
(to both emails to ensure you an answer)
