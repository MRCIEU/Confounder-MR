#Imports the HOME filepath varible from bash
HOME=Sys.getenv("HOME")

#Make data filepath variable
DATA=paste(HOME, "/scratch/Confounder-MR/data/", sep="")

#Load packages
library(data.table)

#Load data
setwd(DATA)
cycling_cases<-fread("cycling.txt", select=1, header=FALSE, data.table=F)
cycling<-fread("cycling_rows.txt", header=FALSE, data.table=F)
walking<-fread("walk_rows.txt", header=FALSE, data.table=F)
vehicle<-fread("vehicle_rows.txt", header=FALSE, data.table=F)

###################
# PROCESS CYCLING #
###################

#Get exclusive index
cycling_no_vehicle<-cycling[-which(cycling[,1] %in% vehicle[,1]),]
vehicle_no_cycling<-vehicle[-which(vehicle[,1] %in% cycling[,1]),]
vehicle_no_cycling_or_walking<-vehicle_no_cycling[-which(vehicle_no_cycling %in% walking[,1])]

#Bind and unique all indexes
all<-rbind(cycling, walking, vehicle)
all<-unique(all)

#Turn to NAs then change just cases and controls
cycling_cases[all[,1],]<-NA
cycling_cases[cycling_no_vehicle,]<-1
cycling_cases[vehicle_no_cycling_or_walking,]<-0

########
# SAVE #
########

write.table(cycling_cases, "cycling.txt", col.names=FALSE, row.names=FALSE, sep = "\t", quote=FALSE)
