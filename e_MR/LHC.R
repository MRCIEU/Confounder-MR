#Import HOME variable from Bash
HOME=Sys.getenv("HOME")
LIB=Sys.getenv("LIB")

#Put path in variable
OUTPUT=paste(HOME, "/scratch/Confounder-MR/output/", sep="")
DATA=paste(HOME, "/scratch/Confounder-MR/data/", sep="")
LD.filepath = paste(DATA, "LDscores_filtered.csv", sep="")
rho.filepath = paste(DATA, "LD_GM2_2prm.csv", sep="")
ld = paste(DATA, "eur_w_ld_chr/", sep="")
hm3 = paste(DATA, "w_hm3.snplist", sep="")
args <- commandArgs(trailingOnly = TRUE)

#Load package
library(data.table)
library(lhcMR, lib=LIB)
library(GenomicSEM, lib=LIB)

#############
# READ DATA #
#############

#Read
setwd(OUTPUT)
exposure<-fread(args[1], header=TRUE, data.table=F)
outcome<-fread(args[2], header=TRUE, data.table=F)
setwd(DATA)
N<-read.table(args[3])[1,1]-1

#######
# LHC #
#######

#Format
colnames(exposure)[c(12,14)]<-c("STD_ERR", "P")
colnames(outcome)[c(12,14)]<-c("STD_ERR", "P")
exposure$N<-N
outcome$N<-N
trait.names=c("Exp","Out")
input.files = list(exposure,outcome)

#Merge
df = merge_sumstats(input.files=input.files,trait.names=trait.names,LD.file=LD.filepath,rho.file=rho.filepath)

#SP
SP_list = calculate_SP(input.df=df,trait.names=trait.names,run_ldsc=TRUE,run_MR=FALSE,hm3=hm3,ld=ld,nStep = 2,SP_single=3,SP_pair=50,SNP_filter=1000)

#LHC
res = lhc_mr(SP_list=SP_list, trait.names=trait.names, paral_method="lapply", nBlock=200)

#Print Results
print(summary(res))

#Save
setwd(OUTPUT)
write.table(res, args[4], row.names=FALSE, quote=FALSE)
