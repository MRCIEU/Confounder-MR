#Import the Home varible from bash
HOME=Sys.getenv("HOME")

#Put filepaths in variables
DATA=paste(HOME, "/scratch/Confounder-MR/data/", sep="")
OUTPUT=paste(HOME, "/scratch/Confounder-MR/output/", sep="")
args <- commandArgs(trailingOnly = TRUE)

#Load packages
library(data.table)
library(dplyr)

#############
# LOAD DATA #
#############

setwd(DATA)
data <- fread(args[1], header=TRUE, data.table=F)

setwd(OUTPUT)
GWAS <- fread(args[2], header=TRUE, data.table=F)

###########
# PROCESS #
###########

#Convert from linear beta to log(OR) using prevelance
if(args[3]=="Binary"){
	mu <- nrow(subset(data, get(args[4])==2)) / nrow(subset(data, get(args[4])==1|get(args[4])==2))
  	print(mu)
  	GWAS<-mutate(GWAS, BETA = BETA/(mu*(1-mu)))
	GWAS<-mutate(GWAS, SE = SE/(mu*(1-mu)))
}
 
#Filter based of significance threshold
if (args[5]!="NA"){
	GWAS<-subset(GWAS, P_BOLT_LMM_INF<as.numeric(args[5]))
}

#Order
GWAS<-GWAS[order(GWAS$P_BOLT_LMM_INF),]

#Remove sex chormosomes
GWAS<-subset(GWAS, CHR<23)

#Save
write.table(GWAS, args[6], row.names=FALSE, sep = "\t", quote=FALSE)

