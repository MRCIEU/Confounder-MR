#Import the Home varible from bash
HOME=Sys.getenv("HOME")

#Put filepaths in variables
DATA=paste(HOME, "/scratch/Confounder-MR/data/", sep="")

#Load packages
library(data.table)
library(tidyverse)

###########################
# MAKE JOBS FILE FOR GWAS #
###########################

#Make jobs file
jobs <- data.frame(name=c("GWASofCyclingToWork", "GWASofCyclingToWork_A", "GWASofCyclingToWork_B", "GWASofCVD", "GWASofCVD_A", "GWASofCVD_B", "GWASofProcessedMeat", "GWASofProcessedMeat_A", "GWASofProcessedMeat_B", "GWASofAlzheimers", "GWASofAlzheimers_A", "GWASofAlzheimers_B"), 
		application_id = c("80112", "80112", "80112",  "80112", "80112", "80112", "80112", "80112", "80112", "80112", "80112", "80112"), 
		pheno_file = c("GWAS.txt", "GWAS-A-cycling.txt", "GWAS-B-cycling.txt", "GWAS.txt", "GWAS-A-cycling.txt", "GWAS-B-cycling.txt", "GWAS.txt", "GWAS-A-procmeat.txt", "GWAS-B-procmeat.txt", "GWAS.txt", "GWAS-A-procmeat.txt", "GWAS-B-procmeat.txt"), 
		pheno_col = c("Cycling", "Cycling", "Cycling", "CVD", "CVD", "CVD", "Processed_Meat_Cats", "Processed_Meat_Cats", "Processed_Meat_Cats", "Alzheimers", "Alzheimers", "Alzheimers"), 
		covar_file = c("data.covariates.bolt.txt", "data.covariates.bolt.txt", "data.covariates.bolt.txt", "data.covariates.bolt.txt", "data.covariates.bolt.txt", "data.covariates.bolt.txt", "data.covariates.bolt.txt", "data.covariates.bolt.txt", "data.covariates.bolt.txt", "data.covariates.bolt.txt", "data.covariates.bolt.txt", "data.covariates.bolt.txt"), 
		covar_col = c("sex;chip", "sex;chip", "sex;chip", "sex;chip", "sex;chip", "sex;chip", "sex;chip", "sex;chip", "sex;chip", "sex;chip", "sex;chip", "sex;chip"), 
		qcovar_col = c("age", "age", "age", "age", "age", "age", "age", "age", "age", "age", "age", "age"), 
		method = c("bolt", "bolt", "bolt", "bolt", "bolt", "bolt", "bolt", "bolt", "bolt", "bolt", "bolt", "bolt"))

#Save
setwd(DATA)
write.table(jobs, "jobs.csv", row.names=FALSE, sep = ",", quote=FALSE)

#################################
# TRANSFORM GWAS OUTCOME TRAITS #
#################################

transform <- function(name, saveas){

	#Read
	data<-fread(name, header=TRUE, data.table=F)

	#ID columns
	data$f.eid <- data$app
	names(data)[c(1,2)] <- c("FID", "IID")
	
	#Convert to 2 vs 1 instead of 1 vs 0
	data<-mutate(data, Cycling=Cycling+1, CVD=CVD+1, Alzheimers=Alzheimers+1)
	
	#Save
	write.table(data, saveas, row.names=FALSE, quote=FALSE)
}

transform("data-GWAS.txt", "GWAS.txt")
transform("data-A-GWAS-procmeat.txt", "GWAS-A-procmeat.txt")
transform("data-B-GWAS-procmeat.txt", "GWAS-B-procmeat.txt")
transform("data-A-GWAS-cycling.txt", "GWAS-A-cycling.txt")
transform("data-B-GWAS-cycling.txt", "GWAS-B-cycling.txt")

