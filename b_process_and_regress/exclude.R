#Import the Home varible from bash
HOME=Sys.getenv("HOME")

#Put filepaths in variables
DATA=paste(HOME, "/scratch/Confounder-MR/data/", sep="")

#Load packages
library(data.table)
library(dplyr)

#################
# LOAD AND NAME #
#################

#Load data
setwd(DATA)
data<-read.table("data.txt", header=TRUE)
withdrawals<-fread("withdrawals.csv", sep=",", header=FALSE, data.table=F)
linker<-fread("linker.csv", header=TRUE, data.table=F)
WE<-fread("WE.txt", header=FALSE, data.table=F)
related<-fread("related.txt", header=FALSE, data.table=F)

#Name headers
names(linker)=c("f.eid", "app")
names(withdrawals)=c("f.eid")
names(WE)=c("app")
names(related)=c("app")

###############
# WITHDRAWALS #
###############

#Remove withdrawals
data <- anti_join(data,withdrawals,by="f.eid")
print("Un-withdrawn data")
print(nrow(data))

########################
# CONFORM MISSING DATA #
########################

for (i in 1:length(names(data))){
        index<-which(data[,i]==-1)
        data[index,i]<-NA
        index<-which(data[,i]==-3)
        data[index,i]<-NA
	index<-which(data[,i]==-7)
        data[index,i]<-NA
}

###################################
# EXCLUDE OUTCOME BEFORE BASELINE #
###################################

#CVD
data_cycling<-subset(data, CVD_Before_Baseline==0)
print("No CVD before baseline data")
print(nrow(data_cycling))

#Alzheimers before baseline + 1 year
data_processed_meat<-subset(data, Alzheimers_Before_Baseline==0)
print("No Alzheimers before baseline data")
print(nrow(data_processed_meat))

#Remove un-needed columns
data_cycling<-subset(data_cycling, select=-c(CVD_Before_Baseline, Alzheimers_Before_Baseline))
data_processed_meat<-subset(data_processed_meat, select=-c(CVD_Before_Baseline, Alzheimers_Before_Baseline))

##################
# WHITE-EUROPEAN #
##################

#Merge with linker
data_GWAS <- merge(linker, data, by="f.eid")
data_cycling <- merge(linker, data_cycling, by="f.eid")
data_processed_meat <- merge(linker, data_processed_meat, by="f.eid")

print("linker data")
print(nrow(data_GWAS))
print("linker cycling data")
print(nrow(data_cycling))
print("linker processed meat data")
print(nrow(data_processed_meat))

#Merge with white-European ID (exclude those not in list) list and print new number of rows
data_GWAS <- merge(WE, data_GWAS, by="app")
data_cycling <- merge(WE, data_cycling, by="app")
data_processed_meat <- merge(WE, data_processed_meat, by="app")
print("White-European data")
print(nrow(data_GWAS))
print("White-European cycling data")
print(nrow(data_cycling))
print("White-European processed meat data")
print(nrow(data_processed_meat))

##################
# SPLIT FOR GWAS #
##################

#Split to subsamples A and B
sample_size = floor(0.5*nrow(data_GWAS))
set.seed(801526)
picked = sample(seq_len(nrow(data_GWAS)),size = sample_size)
data_A_GWAS <- data_GWAS[picked,]
data_B_GWAS <- data_GWAS[-picked,]
print("A Rows")
print(nrow(data_A_GWAS))
print("B Rows")
print(nrow(data_B_GWAS))

###########
# RELATED #
###########

#Exclude related individuals and print new number of rows
data_MR <- anti_join(data_GWAS, related, by="app")
data_A_MR <- anti_join(data_A_GWAS, related, by="app")
data_B_MR <- anti_join(data_B_GWAS, related, by="app")
data_cycling <- anti_join(data_cycling, related, by="app")
data_processed_meat <- anti_join(data_processed_meat, related, by="app")
print("Unrelated data")
print(nrow(data_MR))
print("Unrelated data A")
print(nrow(data_A_MR))
print("Unrelated data B")
print(nrow(data_B_MR))
print("Unrelated cycling data")
print(nrow(data_cycling))
print("Unrelated processed meat data")
print(nrow(data_processed_meat))

########################
# PROCESS MISSING DATA #
########################

#Remove NAs in GWAS data
data_A_GWAS_cycling <- subset(data_A_GWAS, !is.na(data_A_GWAS$Cycling))
print(nrow(data_A_GWAS_cycling))
data_B_GWAS_cycling <- subset(data_B_GWAS, !is.na(data_B_GWAS$Cycling))
print(nrow(data_B_GWAS_cycling))
data_A_GWAS_procmeat <- subset(data_A_GWAS, !is.na(data_A_GWAS$Processed_Meat_Cats))
print(nrow(data_A_GWAS_procmeat))
data_B_GWAS_procmeat <- subset(data_B_GWAS, !is.na(data_B_GWAS$Processed_Meat_Cats))
print(nrow(data_B_GWAS_procmeat))

#Remove NAs in MR data
data_A_MR_cycling <- subset(data_A_MR, !is.na(data_A_MR$Cycling))
print(nrow(data_A_MR_cycling))
data_B_MR_cycling <- subset(data_B_MR, !is.na(data_B_MR$Cycling))
print(nrow(data_B_MR_cycling))
data_A_MR_procmeat <- subset(data_A_MR, !is.na(data_A_MR$Processed_Meat_Cats))
print(nrow(data_A_MR_procmeat))
data_B_MR_procmeat <- subset(data_B_MR, !is.na(data_B_MR$Processed_Meat_Cats))
print(nrow(data_B_MR_procmeat))

#Remove NAs in regression data
data_processed_meat<-data_processed_meat[!is.na(data_processed_meat$Processed_Meat_Cats),]
print("Processed Meat NAs removed")
print(nrow(data_processed_meat))
data_cycling<-data_cycling[!is.na(data_cycling$Cycling),]
print("Cycling NAs removed")
print(nrow(data_cycling))

################
# DESCRIPTIVES #
################

descriptives <- function(data, exp){

        print("## Total ##")
        print(total <- nrow(data))

        if(exp=="Cyc-CVD"){

                print("## Cycling ##")
                print("#Case")
                print(n <- nrow(subset(data, Cycling==1)))
                print(n/total)
                print("#Control")
                print(n <- nrow(subset(data, Cycling==0)))
                print(n/total)

                print("## CVD ##")
                print("#Case")
                print(n <- nrow(subset(data, CVD==1)))
                print(n/total)
                print("#Control")
                print(n <- nrow(subset(data, CVD==0)))
                print(n/total)

        } else {

	        print("## ProcMeat ##")
                print("#None")
        	print(n <- nrow(subset(data, Processed_Meat_Cats==0)))
        	print(n/total)
        	print("#1")
        	print(n <- nrow(subset(data, Processed_Meat_Cats==1)))
        	print(n/total)
        	print("#2-4")
        	print(n <- nrow(subset(data, Processed_Meat_Cats==2)))
        	print(n/total)
        	print("#5+")
        	print(n <- nrow(subset(data, Processed_Meat_Cats==3)))
        	print(n/total)

                print("## Alzheimers ##")
                print("#Case")
                print(n <- nrow(subset(data, Alzheimers==1)))
                print(n/total)
                print("#Control")
                print(n <- nrow(subset(data, Alzheimers==0)))
                print(n/total)
        }

	print("## Age ##")
	print(mean(data$Age))
        print(sd(data$Age))

	print("## Sex ##")
        print("#Male")
        print(n <- nrow(subset(data, Sex==1)))
        print(n/total)
        print("#Female")
        print(n <- nrow(subset(data, Sex==0)))
        print(n/total)

	print("## BMI ##")
        print(mean(data$BMI, na.rm=TRUE))
        print(sd(data$BMI, na.rm=TRUE))
	print("#NA")
        print(n <- nrow(subset(data, is.na(data$BMI))))
        print(n/total)

	print("## Education ##")
	print("#College")
        print(n <- nrow(subset(data, Education==1)))
        print(n/total)
	print("#Alevel")
	print(n <- nrow(subset(data, Education==2)))
        print(n/total)
	print("#GCSE")
	print(n <- nrow(subset(data, Education==3)))
        print(n/total)
	print("#CSE")
	print(n <- nrow(subset(data, Education==4)))
        print(n/total)
	print("#NVQ")
	print(n <- nrow(subset(data, Education==5)))
        print(n/total)
	print("#Other")
	print(n <- nrow(subset(data, Education==6)))
        print(n/total)
        print("#None")
        print(n <- nrow(subset(data, Education==7)))
        print(n/total)
	print("#NA")
        print(n <- nrow(subset(data, is.na(data$Education))))
        print(n/total)

	print("## Risk ##")
        print("#Case")
        print(n <- nrow(subset(data, Risk_Taking==1)))
        print(n/total)
        print("#Control")
        print(n <- nrow(subset(data, Risk_Taking==0)))
        print(n/total)
	print("#NA")
	print(n <- nrow(subset(data, is.na(data$Risk_Taking))))
        print(n/total)	
}

descriptives(data_cycling, "Cyc-CVD")
descriptives(data_processed_meat, "ProcMeat-Alzh")

########
# SAVE #
########

write.table(data_cycling, "data-cycling.txt", row.names=FALSE, sep = "\t", quote=FALSE)
write.table(data_processed_meat, "data-processed-meat.txt", row.names=FALSE, sep = "\t", quote=FALSE)
write.table(data_GWAS, "data-GWAS.txt", row.names=FALSE, sep = " ", quote=FALSE)
write.table(data_MR, "data-MR.txt", row.names=FALSE, sep = " ", quote=FALSE)
write.table(data_A_MR_cycling, "data-A-MR-cycling.txt", row.names=FALSE, sep = " ", quote=FALSE)
write.table(data_B_MR_cycling, "data-B-MR-cycling.txt", row.names=FALSE, sep = " ", quote=FALSE) 
write.table(data_A_MR_procmeat, "data-A-MR-procmeat.txt", row.names=FALSE, sep = " ", quote=FALSE)
write.table(data_B_MR_procmeat, "data-B-MR-procmeat.txt", row.names=FALSE, sep = " ", quote=FALSE)
write.table(data_A_GWAS_cycling, "data-A-GWAS-cycling.txt", row.names=FALSE, sep = " ", quote=FALSE)
write.table(data_B_GWAS_cycling, "data-B-GWAS-cycling.txt", row.names=FALSE, sep = " ", quote=FALSE)
write.table(data_A_GWAS_procmeat, "data-A-GWAS-procmeat.txt", row.names=FALSE, sep = " ", quote=FALSE)
write.table(data_B_GWAS_procmeat, "data-B-GWAS-procmeat.txt", row.names=FALSE, sep = " ", quote=FALSE)

