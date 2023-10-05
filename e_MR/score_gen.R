#Import HOME variable from Bash
HOME=Sys.getenv("HOME")

#Put path in variable
DATA=paste(HOME, "/scratch/Confounder-MR/data/", sep="")
OUTPUT=paste(HOME, "/scratch/Confounder-MR/output/", sep="")
INPUT=paste(HOME, "/scratch/Confounder-MR/code/inputs/", sep="")

#Load packages
library(data.table)
library(stringr)
library(dplyr)

#############
# READ DATA #
#############

#------------------#
# Participant Data #
#------------------#

setwd(DATA)
data <- fread("data-MR.txt", header=TRUE, select=c("app","CVD","Cycling","Alzheimers","Processed_Meat_Cats","BMI","Education","Risk_Taking","Age","Sex"), data.table=F)
data_A_proc <- fread("data-A-MR-procmeat.txt", header=TRUE, select=c("app","Alzheimers","Processed_Meat_Cats","Age","Sex"), data.table=F)
data_B_proc <- fread("data-B-MR-procmeat.txt", header=TRUE, select=c("app","Alzheimers","Processed_Meat_Cats","Age","Sex"), data.table=F)
data_A_cyc <- fread("data-A-MR-cycling.txt", header=TRUE, select=c("app","CVD","Cycling","Age","Sex"), data.table=F)
data_B_cyc <- fread("data-B-MR-cycling.txt", header=TRUE, select=c("app","CVD","Cycling","Age","Sex"), data.table=F)

#--------------#
# Genetic Data #
#--------------#

data_gen<-fread("data-IDs.txt", header=TRUE, data.table=F)

UKB<-fread("snps-dosage.txt", select=c(3, 5, 6), header=FALSE, data.table=F)
names(UKB)=c("SNP", "Other_Allele", "Effect_Allele")

EAF<-fread("snp_stats/EAF.txt", header=FALSE, data.table=F)
names(EAF)=c("SNP", "EAF")

UKB<-merge(UKB, EAF, by = "SNP")

#-----------#
# GWAS Data #
#-----------#

setwd(OUTPUT)
cycling_A <- fread("cycling-A-relaxed-clumped.txt", header=TRUE, data.table=F)
names(cycling_A)[which(names(cycling_A)=="beta.exposure")]<-"Beta"
cycling_B <- fread("cycling-B-relaxed-clumped.txt", header=TRUE, data.table=F)
names(cycling_B)[which(names(cycling_B)=="beta.exposure")]<-"Beta"
procmeat_A <- fread("processed-meat-A-relaxed-clumped.txt", header=TRUE, data.table=F)
names(procmeat_A)[which(names(procmeat_A)=="beta.exposure")]<-"Beta"
procmeat_B <- fread("processed-meat-B-relaxed-clumped.txt", header=TRUE, data.table=F)
names(procmeat_B)[which(names(procmeat_B)=="beta.exposure")]<-"Beta"

setwd(INPUT)
risk <- fread("risk.txt", header=TRUE, data.table=F)
education <- fread("education.txt", header=TRUE, data.table=F)
bmi <- fread("bmi.txt", header=TRUE, data.table=F)

#######################
# REMOVE MISSING SNPS #
#######################

missing <- function(GWAS){
	for (i in 1:nrow(GWAS)){
		if (!(GWAS$SNP[i] %in% UKB$SNP)){
			GWAS$exclude[i] <- 1
		} else {
			GWAS$exclude[i] <- 0
		}
	}

	print(subset(GWAS, exclude==1))
	return(subset(GWAS, exclude==0))
}

bmi_in <- missing(bmi)
print(nrow(bmi_in))

risk_in <- missing(risk)
print(nrow(risk_in))

education_in <- missing(education)
print(nrow(education_in))

#########################
# ALIGN STRAND WITH UKB #
#########################

strand <- function(GWAS){
	n<-0
	for (i in 1:nrow(GWAS)){
		
		index<-which(UKB$SNP==GWAS$SNP[i])
		
		if ((GWAS$Effect_Allele[i]!=UKB$Effect_Allele[index]) & (GWAS$Effect_Allele[i]!=UKB$Other_Allele[index])){
			
			if (GWAS$Effect_Allele[i]=="A") {
                              GWAS$Effect_Allele[i]<-"T"
                        } else if (GWAS$Effect_Allele[i]=="T") {
                                GWAS$Effect_Allele[i]<-"A"
                        } else if (GWAS$Effect_Allele[i]=="C") {
                                GWAS$Effect_Allele[i]<-"G"
                        } else if (GWAS$Effect_Allele[i]=="G") {
                                GWAS$Effect_Allele[i]<-"C"
                        }
		
			n<-n+1	
		}
	}
	print(n)
	return(GWAS)
}

bmi_strand <- strand(bmi_in)
risk_strand <- strand(risk_in)
education_strand <- strand(education_in)

###########################
# REMOVE PALINDROMIC SNPS #
###########################

pal <- function(GWAS){
	for (i in 1:nrow(GWAS)){

		index<-which(UKB$SNP==GWAS$SNP[i])

		#Identify palindromic SNPs
	        if ((UKB$Effect_Allele[index]=="A" & UKB$Other_Allele[index]=="T") | 
			(UKB$Effect_Allele[index]=="T" & UKB$Other_Allele[index]=="A") | 
			(UKB$Effect_Allele[index]=="G" & UKB$Other_Allele[index]=="C") | 
			(UKB$Effect_Allele[index]=="C" & UKB$Other_Allele[index]=="G")){
			
			#If ambiguous EAF then remove, If make GWAS effect allele match UKB, if opposite then make other allele match effect allele (this highlights SNPs for flipping later).	
			if ((UKB$EAF[index] > 0.45 & UKB$EAF[index] < 0.55) | (GWAS$EAF[i] > 0.45 & GWAS$EAF[i] < 0.55)){
					GWAS$exclude[i]<-1
				} else if ((GWAS$EAF[i] < 0.45 & UKB$EAF[index] > 0.55) | (GWAS$EAF[i] > 0.55 & UKB$EAF[index] < 0.45)){
                        		GWAS$Effect_Allele[i]<-UKB$Other_Allele[index]
	        		}  else if ((GWAS$EAF[i] < 0.45 & UKB$EAF[index] < 0.45) | (GWAS$EAF[i] > 0.55 & UKB$EAF[index] > 0.55)){
                                        GWAS$Effect_Allele[i]<-UKB$Effect_Allele[index]
                                }
		}
	}
	
	print(subset(GWAS, exclude==1))
	return(subset(GWAS, exclude==0))
}

bmi_notpal <- pal(bmi_strand)
print(nrow(bmi_notpal))

risk_notpal <- pal(risk_strand)
print(nrow(risk_notpal))

education_notpal <- pal(education_strand)
print(nrow(education_notpal))

########################################
# FLIP TO ALIGN WITH UKB EFFECT ALLELE #
########################################

flip <- function(GWAS){
        for (i in 1:nrow(GWAS)){

                index<-which(UKB$SNP==GWAS$SNP[i])

                if (UKB$Other_Allele[index]==GWAS$Effect_Allele[i]){
                        GWAS$EAF[i]<- 1 - GWAS$EAF[i]
                        GWAS$Beta[i]<- GWAS$Beta[i]*(-1)
                        GWAS$Effect_Allele[i]<-UKB$Other_Allele[index]
                }
        }

        return(GWAS)
}

bmi_flipped <- flip(bmi_notpal)
risk_flipped <- flip(risk_notpal)
education_flipped <- flip(education_notpal)

####################
# CALCULATE SCORES #
####################

score_gen <- function(GWAS, pps, name){

	#Create scores vector
	scores<-rep(0, nrow(data_gen))
	
	#For each snp in score
	for (i in 1:nrow(GWAS)){

		#Create variables
		dosage<-data_gen[,GWAS$SNP[i]]
		weight<-GWAS$Beta[i]
	
		#Flip if GWAS effect allele has negative association with outcome
		if (weight<0){
			weight<-weight*-1
			dosage<-2-dosage	
		}

		#Add to score	
		scores <- scores + (dosage * weight)	
	}
	
	#Add to data and set names
	scores<-data.frame(data_gen$IID, scores)
	names(scores)<-c("app", paste(name, "_GRS", sep=""))
	return(merge(pps, scores))
}


Cyc_A_GRS <- score_gen(cycling_B, data_A_cyc, "cyc")
Cyc_B_GRS <- score_gen(cycling_A, data_B_cyc, "cyc")
Proc_A_GRS <- score_gen(procmeat_B, data_A_proc, "proc")
Proc_B_GRS <- score_gen(procmeat_A, data_B_proc, "proc")

risk_GRS <- score_gen(risk_flipped, data, "risk")
education_GRS <- score_gen(education_flipped, data, "education")
bmi_GRS <- score_gen(bmi_flipped, data, "bmi")

########
# SAVE #
########

setwd(DATA)
write.table(Cyc_A_GRS, "cyc-A-GRS.txt", row.names=FALSE, quote=FALSE)
write.table(Cyc_B_GRS, "cyc-B-GRS.txt", row.names=FALSE, quote=FALSE)
write.table(Proc_A_GRS, "proc-A-GRS.txt", row.names=FALSE, quote=FALSE)
write.table(Proc_B_GRS, "proc-B-GRS.txt", row.names=FALSE, quote=FALSE)

write.table(risk_GRS, "risk-GRS.txt", row.names=FALSE, quote=FALSE)
write.table(education_GRS, "education-GRS.txt", row.names=FALSE, quote=FALSE)
write.table(bmi_GRS, "bmi-GRS.txt", row.names=FALSE, quote=FALSE)
