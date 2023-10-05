#Import HOME variable from bash
HOME=Sys.getenv("HOME")

#Put filepaths in variables
DATA=paste(HOME, "/scratch/Confounder-MR/data/", sep="")
OUTPUT=paste(HOME, "/scratch/Confounder-MR/output/", sep="")

#Load packages
library(data.table)
library(ggplot2)

################
# PREPARE DATA #
################

#Read
setwd(DATA)
cycling<-fread("data-cycling.txt", header=TRUE, data.table=F)
processed_meat<-fread("data-processed-meat.txt", header=TRUE, data.table=F)

###############
# REGRESSIONS #
###############

#Create table for results
regression<-data.frame(matrix(nrow=4, ncol=6))
names(regression)<-c("Analysis", "BETA", "SE", "OR", "LOWER", "UPPER")
regression$Analysis<-c("Cyc_CVD_Full", "Cyc_CVD_Lin", "Proc_Alzh_Full", "Proc_Alzh_Lin")

#Create function to extract regression results and place in table
extract <- function(fit, row, exposure, linear=FALSE){

	#Extract beta and se
	regression$BETA[row] <<- coef(fit)[exposure]
	regression$SE[row] <<- summary(fit)$coefficients[exposure, 2]

	#if logistic convert to ORs
	if(linear==FALSE){
		regression$OR[row] <<- exp(regression$BETA[row])
		regression$LOWER[row] <<- exp(confint(fit, exposure, level=0.95)["2.5 %"])
		regression$UPPER[row] <<- exp(confint(fit, exposure, level=0.95)["97.5 %"])
	}
}

#Cycling-CVD (standard)
fit <- glm(CVD ~ Cycling + Age + Sex + BMI + Risk_Taking + Education, data=cycling, family = "binomial")
extract(fit, 1, "Cycling")

#Cycling-CVD (linear)
fit <- glm(CVD ~ scale(Cycling), data=cycling, family = "gaussian")
regression$SD[2] <- sd(cycling$Cycling)
extract(fit, 2, "scale(Cycling)", linear=TRUE)

#Processed Meat-Alzheimers (standard)
fit <- glm(Alzheimers ~ Processed_Meat_Cats + Age + Sex + BMI + Risk_Taking + Education, data=processed_meat, family = "binomial")
extract(fit, 3, "Processed_Meat_Cats")

#Processed Meat-Alzheimers (linear)
fit <- glm(Alzheimers ~ scale(Processed_Meat_Cats), data=processed_meat, family = "gaussian")
regression$SD[4] <- sd(processed_meat$Processed_Meat_Cats)
extract(fit, 4, "scale(Processed_Meat_Cats)", linear=TRUE)

#############
# Save Data #
#############

setwd(OUTPUT)
write.table(regression, "regressions.txt", row.names=FALSE, sep = "\t", quote=FALSE)
