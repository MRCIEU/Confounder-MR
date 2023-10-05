#Import the Home varible from bash
HOME=Sys.getenv("HOME")
LIB=Sys.getenv("LIB")

#Put filepath in variable
OUTPUT=paste(HOME, "/scratch/Confounder-MR/output/", sep="")
DATA=paste(HOME, "/scratch/Confounder-MR/data/", sep="")

#Load packages
library(TwoSampleMR, lib=LIB)
library(ieugwasr, lib=LIB)
library(genetics.binaRies, lib=LIB)

#Create clump function
clump <- function(GWAS){

  #Read
  data<-read.table(paste(GWAS, ".txt", sep=""), header=TRUE)
  
  #Headers
  names(data)[c(1,14)]<-c("rsid", "pval")
  print(names(data))

  #Clump
  data_clumped<-ld_clump(data, plink_bin = genetics.binaRies::get_plink_binary(), bfile = paste(DATA, "eur", sep=""))
  
  #Headers
  names(data_clumped)[c(1)]<-c("SNP")
  data_clumped<-format_data(data_clumped, type = "exposure", beta_col="BETA", se_col="SE", eaf_col="A1FREQ", effect_allele_col="ALLELE1", other_allele_col="ALLELE0", pval_col="pval", info_col="INFO", chr_col="CHR", pos_col="pos")

  #Save
  write.table(data_clumped, paste(GWAS, "-clumped.txt", sep=""), row.names=FALSE, sep = "\t", quote=FALSE)
}

#Run
setwd(OUTPUT)
clump("cycling-A-relaxed")
clump("cycling-B-relaxed")
clump("processed-meat-A-relaxed")
clump("processed-meat-B-relaxed")
clump("BMI-A-GWAS")
clump("BMI-B-GWAS")
