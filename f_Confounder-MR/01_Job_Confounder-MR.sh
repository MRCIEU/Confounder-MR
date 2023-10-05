#!/bin/bash
#SBATCH --account=psyc010162
#SBATCH --job-name=confounderMR
#SBATCH --output=confounderMR_slurm.txt
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=22
#SBATCH --time=1:00:00
#SBATCH --mem=1000M

#Put path in variable
CODE="${HOME}/scratch/Confounder-MR/code/f_Confounder-MR"

#Load R
module add languages/r/4.0.3
#Loads R

#Run R script
cd $CODE
R CMD BATCH --no-save --no-restore confounder-MR.R confounder-MR_r_log.txt

