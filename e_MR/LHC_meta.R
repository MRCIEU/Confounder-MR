#Import HOME variable from Bash
HOME=Sys.getenv("HOME")

#Put path in variable
OUTPUT=paste(HOME, "/scratch/Confounder-MR/output/", sep="")

#Load package
library(data.table)
library(meta)

#############
# READ DATA #
#############

#Read
setwd(OUTPUT)
cycAB<-fread("LHC_cyclingAB.txt", header=TRUE, data.table=F)
cycBA<-fread("LHC_cyclingBA.txt", header=TRUE, data.table=F)
procAB<-fread("LHC_procmeatAB.txt", header=TRUE, data.table=F)
procBA<-fread("LHC_procmeatBA.txt", header=TRUE, data.table=F)


################
# EXTRACT DATA #
################

#Make results table
results<-data.frame(matrix(nrow=4, ncol=3))
names(results)<-c("Analysis", "Beta", "SE")
results$Analysis<-c("CycCVDAB", "CycCVDBA", "ProcAlzhmrsAB", "ProcAlzhmrsBA")

#For each LHC analysis, extract and put in results table
data<-c("cycAB", "cycBA", "procAB", "procBA")
for(i in 1:length(data)){
	d<-get(data[i])
	results$Beta[i]<-d$axy[1]
	results$SE[i]<-d$axy[2]
}

################
# META-ANALYSE #
################

#Cyc-CVD
meta<-metagen(TE=c(results$Beta[1], results$Beta[2]), seTE=c(results$SE[1], results$SE[2]), sm = "OR", comb.fixed = TRUE, comb.random = FALSE, method.ci = "z")
print(summary(meta))

#Procmeat-Alzh
meta<-metagen(TE=c(results$Beta[3], results$Beta[4]), seTE=c(results$SE[3], results$SE[4]), sm = "OR", comb.fixed = TRUE, comb.random = FALSE, method.ci = "z")
print(summary(meta))

