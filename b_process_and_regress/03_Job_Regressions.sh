#!/bin/bash
#SBATCH --account=psyc010162
#SBATCH --job-name=regressions
#SBATCH --output=regressions_slurm.txt
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=22
#SBATCH --time=10:00:00
#SBATCH --mem=10000M

#Put filepath in variable
CODE="${HOME}/scratch/Confounder-MR/code/b_process_and_regress/"

#Load R
module add languages/r/4.0.3

#Run R code
cd $CODE
R CMD BATCH --no-save --no-restore regressions.R regressions_r_log.txt
