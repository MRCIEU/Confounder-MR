#Import HOME variable from Bash
HOME=Sys.getenv("HOME")
LIB=Sys.getenv("LIB")

#Put path in variable
OUTPUT=paste(HOME, "/scratch/Confounder-MR/output/", sep="")

#Load packages
library(data.table)
library(msm, lib=LIB)

########
# READ #
########

setwd(OUTPUT)
data <- fread("overall_confounder.txt", header=TRUE, data.table=F)
mr_res <- fread("ConfounderMR.txt", header=TRUE, data.table=F)
reg_res <- fread("regressions.txt", header=TRUE, data.table=F) 

#Remove NAs for confouder
data <- subset(data, !is.na(data$Overall_Confounder))

#############
# FUNCTIONS #
#############

#Create 95% confidence intervals
confidence <- function(beta, se){
        lower <- beta - (1.96*se)
        upper <- beta + (1.96*se)
	res <- cbind(beta, lower, upper)
	return(res)
}

#Create 95%CI, convert from standardised exposure and convert from beta (linear regression) to Odds ratio (logistic)
convert <- function(beta, se, exposure, outcome){
	
	#95%CI
	res<-confidence(beta, se)	

	#Get outcome prevelance
        mu <- length(outcome[outcome==1]) / (length(outcome[outcome==0]) + length(outcome[outcome==1]))

	#If exposure standardised, unstandardise by dividing by standard deviation of exposure
	if (length(exposure)>1){
		std <- sd(exposure, na.rm=TRUE)
		res <- res/std
	#If outcome standardised, unstandardise by multipyling by standard deviations of outcome
	} else {
		std <- sd(outcome, na.rm=TRUE)
                res <- res*std
	}

        #Convert to OR
        ORs <- exp(res/(mu*(1-mu)))
        return(ORs)
}

#Perform Confounder-MR
analyse <- function(mr_est_exp, mr_est_out, mr_se_exp, mr_se_out, reg_est, reg_se, exposure, outcome){

	#Confidence for original regression estimate
        print("reg")
        print(confidence(reg_est, reg_se))
        print(convert(reg_est, reg_se, exposure, outcome))

        #Confidence for con-expMR
        print("con-exp")
        print(confidence(mr_est_exp, mr_se_exp))
        print(convert(mr_est_exp, mr_se_exp, exposure=NA, outcome=exposure))

        #Confidence for con-outMR
        print("con-out")
        print(confidence(mr_est_out, mr_se_out))
        print(convert(mr_est_out, mr_se_out, exposure=NA, outcome=outcome))

	#Confounding Beta
	mr_est <- mr_est_exp * mr_est_out 

	#Confounding SE
	mr_se <- deltamethod(~ x1 * x2, c(mr_est_exp, mr_est_out), matrix(nrow=2, ncol=2,c(mr_se_exp^2,0,0,mr_se_out^2)))

	#Confidence for proportion due to confoudning
	print("con")
	print(confidence(mr_est, mr_se))

	#Confounder-MR Beta
	est <- reg_est - mr_est
	
	#Confounder-MR SE
	se <- deltamethod(~ x1 - x2, c(reg_est, mr_est), matrix(nrow=2, ncol=2,c(reg_se^2,0,0,mr_se^2)))

	#Confidence for Confounder-MR estimate
	print("confounder-MR")
	print(confidence(est, se))

	#Convert estimates
	ORs <- convert(est, se, exposure, outcome)
	return(ORs)
}

##################################
# CONFOUNDER-MR ANALYSIS CYC-CVD #
##################################

analyse(mr_res$BETA[mr_res$Variables == "Confounders-Cycling"], mr_res$BETA[mr_res$Variables == "Confounders-CVD"], 
		mr_res$SE[mr_res$Variables == "Confounders-Cycling"], mr_res$SE[mr_res$Variables == "Confounders-CVD"], 
		reg_res$BETA[reg_res$Analysis == "Cyc_CVD_Lin"], reg_res$SE[reg_res$Analysis == "Cyc_CVD_Lin"], 
		data$Cycling, data$CVD)

####################################
# CONFOUNDER-MR ANALYSIS PROC-ALZH #
####################################

analyse(mr_res$BETA[mr_res$Variables == "Confounders-ProcMeat"], mr_res$BETA[mr_res$Variables == "Confounders-Alzheimers"], 
		mr_res$SE[mr_res$Variables == "Confounders-ProcMeat"], mr_res$SE[mr_res$Variables == "Confounders-Alzheimers"], 
		reg_res$BETA[reg_res$Analysis == "Proc_Alzh_Lin"], reg_res$SE[reg_res$Analysis == "Proc_Alzh_Lin"],
		data$Processed_Meat_Cats, data$Alzheimers)

#############
# 95%CI BMI #
#############

exp(confidence(mr_res$BETA[mr_res$Variables == "BMI-Cycling"], mr_res$SE[mr_res$Variables == "BMI-Cycling"]))
exp(confidence(mr_res$BETA[mr_res$Variables == "BMI-CVD"], mr_res$SE[mr_res$Variables == "BMI-CVD"]))
confidence(mr_res$BETA[mr_res$Variables == "BMI-ProcMeat"], mr_res$SE[mr_res$Variables == "BMI-ProcMeat"])
exp(confidence(mr_res$BETA[mr_res$Variables == "BMI-Alzheimers"], mr_res$SE[mr_res$Variables == "BMI-Alzheimers"]))

###################
# 95%CI Education #
###################

exp(confidence(mr_res$BETA[mr_res$Variables == "Education-Cycling"], mr_res$SE[mr_res$Variables == "Education-Cycling"]))
exp(confidence(mr_res$BETA[mr_res$Variables == "Education-CVD"], mr_res$SE[mr_res$Variables == "Education-CVD"]))
confidence(mr_res$BETA[mr_res$Variables == "Education-ProcMeat"], mr_res$SE[mr_res$Variables  == "Education-ProcMeat"])
exp(confidence(mr_res$BETA[mr_res$Variables == "Education-Alzheimers"], mr_res$SE[mr_res$Variables == "Education-Alzheimers"]))

##############
# 95%CI RISK #
##############

exp(confidence(mr_res$BETA[mr_res$Variables == "Risk-Cycling"], mr_res$SE[mr_res$Variables == "Risk-Cycling"]))
exp(confidence(mr_res$BETA[mr_res$Variables == "Risk-CVD"], mr_res$SE[mr_res$Variables == "Risk-CVD"]))
confidence(mr_res$BETA[mr_res$Variables == "Risk-ProcMeat"], mr_res$SE[mr_res$Variables == "Risk-ProcMeat"])
exp(confidence(mr_res$BETA[mr_res$Variables == "Risk-Alzheimers"], mr_res$SE[mr_res$Variables == "Risk-Alzheimers"]))


