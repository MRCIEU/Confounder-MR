#!/bin/bash
#SBATCH --account=psyc010162
#SBATCH --job-name=LHC_meta
#SBATCH --output=LHC_meta_slurm.txt
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=22
#SBATCH --time=20:00:00
#SBATCH --mem=100000M

#Put path in variable
CODE="${HOME}/scratch/Confounder-MR/code/e_MR"

#Load R
module add languages/r/4.0.3
#Loads R

#Run R script
cd $CODE
R CMD BATCH --no-save --no-restore  LHC_meta.R LHC_meta_r_log.txt
