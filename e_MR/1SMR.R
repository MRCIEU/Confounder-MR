#Import HOME variable from Bash
HOME=Sys.getenv("HOME")
LIB=Sys.getenv("LIB")

#Put path in variable
DATA=paste(HOME, "/scratch/Confounder-MR/data/", sep="")
OUTPUT=paste(HOME, "/scratch/Confounder-MR/output/", sep="")

#Load packages
library(data.table)
library(meta)
library(ivreg, lib=LIB)
library(DescTools, lib=LIB)

#############
# READ DATA #
#############

#Read
setwd(DATA)
cycA<-fread("cyc-A-GRS.txt", header=TRUE, data.table=F)
cycB<-fread("cyc-B-GRS.txt", header=TRUE, data.table=F)
procA<-fread("proc-A-GRS.txt", header=TRUE, data.table=F)
procB<-fread("proc-B-GRS.txt", header=TRUE, data.table=F)
risk<-fread("risk-GRS.txt", header=TRUE, data.table=F)
education<-fread("education-GRS.txt", header=TRUE, data.table=F)
bmi<-fread("bmi-GRS.txt", header=TRUE, data.table=F)
PC<-fread("PC.txt", header=TRUE, data.table=F)
chip<-fread("chip.txt", header=TRUE, select=c(1,3), data.table=F)

#Name
names(PC)[1]<-"IID"
for (i in 1:10){
	names(PC)[i+1]<-paste("PC", i, sep="")
}
names(chip)<-c("IID", "Chip")

#Merge
cov<-merge(PC, chip)
names(cov)[1]<-"app"
confounders <- merge(risk, education)
confounders <- merge(confounders, bmi)
confounders <- merge(confounders, cov)
cycA<-merge(cycA, cov)
cycB<-merge(cycB, cov)
procA<-merge(procA, cov)
procB<-merge(procB, cov)

#N
print(nrow(confounders))
print(nrow(cycA))
print(nrow(cycB))
print(nrow(procA))
print(nrow(procB))

#######################
# PROCESS CONFOUNDERS #
#######################

#Standardise GRSs
confounders$bmi_GRS <- as.vector(scale(confounders$bmi_GRS))
confounders$risk_GRS <- as.vector(scale(confounders$risk_GRS))
confounders$education_GRS <- as.vector(scale(confounders$education_GRS))

#Combine phenotype
confounders$Overall_Confounder <- as.vector(scale(as.vector(scale(confounders$BMI)) + as.vector(scale(confounders$Risk_Taking)) + as.vector(scale(confounders$Education))))

#Combine GRSs
confounders$Overall_GRS <- confounders$bmi_GRS + confounders$risk_GRS + confounders$education_GRS

#Check
print(head(confounders))

########
# 1SMR #
########

osmr<-function(exposure, outcome, iv, variables, data, stage1, stage2, covariates=TRUE){
	
	#Make R2 variable
	R2<-NA

	#Run Regression
	if (stage2=="logistic"){

		#Get control data for calculation strength
		iv.con<-iv[outcome==0]
		x.con<-exposure[outcome==0]
		data.con<-data[outcome==0,]
		
		#Logistic-logistic
		if(stage1=="logistic"){
			fit <- glm(x.con~iv.con + Age + Sex + Chip + PC1 + PC2 + PC3 + PC4 + PC5 + PC6 + PC7 + PC8 + PC9 + PC10, data=data.con, family="binomial")
			R2<-PseudoR2(fit, which = "McFadden")
			m_iv <- glm(outcome~predict(glm(x.con~iv.con + Age + Sex + Chip + PC1 + PC2 + PC3 + PC4 + PC5 + PC6 + PC7 + PC8 + PC9 + PC10, data=data.con, family="binomial"), newdata=list(iv.con=iv)) + Age + Sex + Chip + PC1 + PC2 + PC3 + PC4 + PC5 + PC6 + PC7 + PC8 + PC9 + PC10, data=data, family="binomial")
			
		#Linear-Logistic			
		} else if(stage1=="linear"){
			fit <- lm(x.con~iv.con + Age + Sex + Chip + PC1 + PC2 + PC3 + PC4 + PC5 + PC6 + PC7 + PC8 + PC9 + PC10, data=data.con)
			R2<-summary(fit)$adj.r.squared
			m_iv <- glm(outcome~predict(lm(x.con~iv.con + Age + Sex + Chip + PC1 + PC2 + PC3 + PC4 + PC5 + PC6 + PC7 + PC8 + PC9 + PC10, data=data.con), newdata=list(iv.con=iv)) + Age + Sex + Chip + PC1 + PC2 + PC3 + PC4 + PC5 + PC6 + PC7 + PC8 + PC9 + PC10, data=data, family="binomial")
		}

	} else if(stage2=="linear"){

		#Logistic-linear
		if(stage1=="logistic"){
			fit <- glm(exposure~iv + Age + Sex + Chip + PC1 + PC2 + PC3 + PC4 + PC5 + PC6 + PC7 + PC8 + PC9 + PC10, data=data, family="binomial")
                        R2<-PseudoR2(fit, which = "McFadden")
                        m_iv <- lm(outcome~predict(glm(exposure ~ iv + Age + Sex + Chip + PC1 + PC2 + PC3 + PC4 + PC5 + PC6 + PC7 + PC8 + PC9 + PC10, data=data, family="binomial"), newdata=list(iv)) + Age + Sex + Chip + PC1 + PC2 + PC3 + PC4 + PC5 + PC6 + PC7 + PC8 + PC9 + PC10, data=data)
		
		#Linear-linear
		}else if(stage1=="linear"){

			#With ovariates
			if(covariates==TRUE){
				fit <- lm(exposure~iv + Age + Sex + Chip + PC1 + PC2 + PC3 + PC4 + PC5 + PC6 + PC7 + PC8 + PC9 + PC10, data=data)
                                m_iv<-ivreg(outcome ~ exposure + Age + Sex + Chip + PC1 + PC2 + PC3 + PC4 + PC5 + PC6 + PC7 + PC8 + PC9 + PC10 | iv + Age + Sex + Chip + PC1 + PC2 + PC3 + PC4 + PC5 + PC6 + PC7 + PC8 + PC9 + PC10, data = data)
			
			#Without covariates
			} else {
				fit <- lm(exposure~iv, data=data)
				m_iv<-ivreg(outcome ~ exposure | iv, data = data)
			}

			R2<-summary(fit)$adj.r.squared
		}
	}	

	#Make results table
	results<-data.frame(matrix(nrow=1, ncol=4))
	names(results)<-c("Variables", "BETA", "SE", "R2")
	results[,"Variables"]<- variables

	#Populate results table
	results$BETA <- coef(summary(m_iv))[2 ,"Estimate"]
	results$SE <- coef(summary(m_iv))[2 ,"Std. Error"]
	results$R2 <- R2
	return(results)
}	
	
#Run standard MRs
cyclingA<-osmr(cycA$Cycling, cycA$CVD, cycA$cyc_GRS, "Cycling-CVD-A", cycA, stage1="logistic", stage2="logistic")
cyclingB<-osmr(cycB$Cycling, cycB$CVD, cycB$cyc_GRS, "Cycling-CVD-B", cycB, stage1="logistic", stage2="logistic")
procmeatA<-osmr(procA$Processed_Meat_Cats, procA$Alzheimers, procA$proc_GRS, "ProcessedMeat-Alzheimers-A", procA, stage1="linear", stage2="logistic")
procmeatB<-osmr(procB$Processed_Meat_Cats, procB$Alzheimers, procB$proc_GRS, "ProcessedMeat-Alzheimers-B", procB, stage1="linear", stage2="logistic")

#Combine
results<-rbind(cyclingA, cyclingB, procmeatA, procmeatB)
print(results)

#Run for confounders
#Overall 
con_cyc<-osmr(confounders$Overall_Confounder, scale(confounders$Cycling), confounders$Overall_GRS, "Confounders-Cycling", confounders, stage1="linear", stage2="linear", covariates=FALSE)
con_cvd<-osmr(confounders$Overall_Confounder, confounders$CVD, confounders$Overall_GRS, "Confounders-CVD", confounders, stage1="linear", stage2="linear", covariates=FALSE)
con_proc<-osmr(confounders$Overall_Confounder, scale(confounders$Processed_Meat_Cats), confounders$Overall_GRS, "Confounders-ProcMeat", confounders, stage1="linear", stage2="linear", covariates=FALSE)
con_alzhmrs<-osmr(confounders$Overall_Confounder, confounders$Alzheimers, confounders$Overall_GRS, "Confounders-Alzheimers", confounders, stage1="linear", stage2="linear", covariates=FALSE)
#BMI
bmi_cyc<-osmr(confounders$BMI, confounders$Cycling, confounders$bmi_GRS, "BMI-Cycling", confounders, stage1="linear", stage2="logistic")
bmi_cvd<-osmr(confounders$BMI, confounders$CVD, confounders$bmi_GRS, "BMI-CVD", confounders, stage1="linear", stage2="logistic")
bmi_proc<-osmr(confounders$BMI, confounders$Processed_Meat_Cats, confounders$bmi_GRS, "BMI-ProcMeat", confounders, stage1="linear", stage2="linear")
bmi_alzhmrs<-osmr(confounders$BMI, confounders$Alzheimers, confounders$bmi_GRS, "BMI-Alzheimers", confounders, stage1="linear", stage2="logistic")
#Education
education_cyc<-osmr(confounders$Education, confounders$Cycling, confounders$education_GRS, "Education-Cycling", confounders, stage1="linear", stage2="logistic")
education_cvd<-osmr(confounders$Education, confounders$CVD, confounders$education_GRS, "Education-CVD", confounders, stage1="linear", stage2="logistic")
education_proc<-osmr(confounders$Education, confounders$Processed_Meat_Cats, confounders$education_GRS, "Education-ProcMeat", confounders, stage1="linear", stage2="linear")
education_alzhmrs<-osmr(confounders$Education, confounders$Alzheimers, confounders$education_GRS, "Education-Alzheimers", confounders, stage1="linear", stage2="logistic")
#Risk Taking
risk_cyc<-osmr(confounders$Risk_Taking, confounders$Cycling, confounders$risk_GRS, "Risk-Cycling", confounders, stage1="logistic", stage2="logistic")
risk_cvd<-osmr(confounders$Risk_Taking, confounders$CVD, confounders$risk_GRS, "Risk-CVD", confounders, stage1="logistic", stage2="logistic")
risk_proc<-osmr(confounders$Risk_Taking, confounders$Processed_Meat_Cats, confounders$risk_GRS, "Risk-ProcMeat", confounders, stage1="logistic", stage2="linear")
risk_alzhmrs<-osmr(confounders$Risk_Taking, confounders$Alzheimers, confounders$risk_GRS, "Risk-Alzheimers", confounders, stage1="logistic", stage2="logistic")

#Combine
con_results<-rbind(con_cyc, con_cvd, con_proc, con_alzhmrs, bmi_cyc, bmi_cvd, bmi_proc, bmi_alzhmrs, education_cyc, education_cvd, education_proc, education_alzhmrs, risk_cyc, risk_cvd, risk_proc, risk_alzhmrs)
setwd(OUTPUT)

#Save
write.table(con_results, "ConfounderMR.txt", row.names=FALSE, quote=FALSE)
write.table(confounders, "overall_confounder.txt", row.names=FALSE, quote=FALSE)

################
# META-ANALYSE #
################

#Cyc-CVD, fixed effects outputted as ORs with 95%CIs
meta<-metagen(TE=c(results$BETA[1], results$BETA[2]), seTE=c(results$SE[1], results$SE[2]), sm = "OR", comb.fixed = TRUE, comb.random = FALSE, method.ci = "z")
print(summary(meta))

#Procmeat-Alzh, fixed effects outputted as ORs with 95%CIs
meta<-metagen(TE=c(results$BETA[3], results$BETA[4]), seTE=c(results$SE[3], results$SE[4]), sm = "OR", comb.fixed = TRUE, comb.random = FALSE, method.ci = "z")
print(summary(meta))

