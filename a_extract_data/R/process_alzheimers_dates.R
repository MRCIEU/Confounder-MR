#Imports the HOME filepath varible from bash
HOME=Sys.getenv("HOME")

#Make data filepath variable
DATA=paste(HOME, "/scratch/Confounder-MR/data/", sep="")

#Load packages
library(data.table)
library(lubridate)

#Load data
setwd(DATA)
icd10dates<-fread("icd10dates.txt", header=TRUE, data.table=F)
baseline<-fread("baseline.txt", header=TRUE, data.table=F)
icd10<-fread("icd10.txt", header=FALSE, data.table=F)

#################
# EXTRACT DATES #
#################

#Make function to prosess dates
extract_dates <- function(icd, codes, icddates, version){
	#Make icd a matrix
	x <- as.matrix(icd)

	#Create vectors
	row<-vector()
	col<-vector()
	date<-vector()

	#Identify coordinates of matches by looping through each codes and grepping all match
	for (i in 1:length(codes)){
		#Grep indexes as if columns where stacked (e.g. row 4 column 3 would be 14 if 5 rows in table)
		j <- grep(codes[i], x)

		#What is the remainder for (index-1) and add 1 to get row number 
		#Have to minus 1 from index and add 1 after otherwise doesn't work for last row (will be 0 not 1)
		rowT <- 1 + (j - 1) %% nrow(x)

		#How many times do number of rows go into (index-1) and add 1 to get column number
		#Have to minus 1 from index and add 1 after otherwise doesn't for last row of data (will be previous column)
		colT <- 1 + (j - 1) %/% nrow(x)
	
		#Append onto one long vector
		row<-append(row, rowT)
		col<-append(col, colT)
  
	}

	#Get matching dates
	for (i in 1:length(row)){
		date[i]<-icddates[row[i], col[i]]
	}

	#Bind
        return(data.frame(row, col, date))

}

#Run for ICD10
codes<-c("A810", "F00", "F01", "F02", "F051", "F106", "G30", "G310", "G311", "G318", "I673")
rowcoldate<-extract_dates(icd10, codes, icd10dates)

#####################
# PROCESS EXCLUSION #
#####################

#Sort so earliest date for partticipant is first and the remove rest
rowcoldate<-rowcoldate[order(rowcoldate$date),]
rowcoldate<-rowcoldate[order(rowcoldate$row),]
rowcoldate<-rowcoldate[!duplicated(rowcoldate$row),]

#Create exclusion vector
exclude<-vector()

#Loop through participants
for (i in 1:nrow(baseline)){
	
	#Get index of current participant in rowcoldate
	j<-which(rowcoldate$row == i)

	#If they are in rowcoldate (i.e., index is not 0/have a diagnosis)
	if (length(j)!=0){

		#If this was before baseline + 1 year exclude
		if (as.Date(rowcoldate$date[j], origin = "1970-01-01")<as.Date(baseline[i,1], origin = "1970-01-01")%m+% years(1)){
			exclude[i]<-1
		} else {
			exclude[i]<-0
		}
	} else {
		#If participant doesn't have diagnosis don't exclude
		exclude[i]<-0
	}
}

#Save
write.table(exclude, "date_alzhmrs_excld.txt", col.names=FALSE, row.names=FALSE, sep = "\t", quote=FALSE)
