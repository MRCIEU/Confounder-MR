#!/bin/bash
#SBATCH --account=psyc010162
#SBATCH --job-name=clump
#SBATCH --output=clump_slurm.txt
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=22
#SBATCH --time=10:00:00
#SBATCH --mem=10000M

#Put data filepath in variable
CODE="$HOME/scratch/Confounder-MR/code/c_process_GWAS_results"

#Load R
module add languages/r/4.0.3

#Run R code
cd $CODE
R CMD BATCH --no-save --no-restore clump.R clump_r_log.txt

