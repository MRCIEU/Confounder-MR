#!/bin/bash
#SBATCH --account=psyc010162
#SBATCH --job-name=1SMR
#SBATCH --output=1SMR_slurm.txt
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=22
#SBATCH --time=20:00:00
#SBATCH --mem=10000M

#Put path in variable
CODE="${HOME}/scratch/Confounder-MR/code/e_MR"
DATA="${HOME}/scratch/Confounder-MR/data/"
GEN="$UK_B_LATEST/data/derived/"

#Take first 10 Principal Components and genotyping chip
cp $GEN/principal_components/data.pca1-10.qctools.txt $DATA/PC.txt
cp $GEN/standard_covariates/data.covariates.qctools.txt $DATA/chip.txt

#Load R
module add languages/r/4.0.3
#Loads R

#Run R script
cd $CODE
R CMD BATCH --no-save --no-restore 1SMR.R 1SMR_r_log.txt

