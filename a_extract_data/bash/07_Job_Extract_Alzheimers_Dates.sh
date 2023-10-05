#!/bin/bash
#SBATCH --job-name=extract_alzheimers_dates
#SBATCH --output=extract_alzheimers_dates_slurm.txt
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=22
#SBATCH --time=20:00:00
#SBATCH --mem=100000M
#SBATCH --partition=mrcieu

############################
# EXTRACT ALZHEIMERS DATES #
############################

#Put data filepath in variable
DATA="$HOME/scratch/Confounder-MR/data"
CODE="$HOME/scratch/Confounder-MR/code/a_extract_data/R/"

#Run R code
module add languages/r/4.0.3
cd $CODE
R CMD BATCH --no-save --no-restore process_alzheimers_dates.R process_alzheimers_dates_r_log.txt

#Replace header
sed '1i Alzheimers_Before_Baseline' $DATA/date_alzhmrs_excld-temp.txt > $DATA/date_alzhmrs_excld.txt

#Count cases
echo "count cases"
grep -c 1 $DATA/date_alzhmrs_excld.txt
grep -c 0 $DATA/date_alzhmrs_excld.txt

#Remove
rm $DATA/date_alzhmrs_excld-temp.txt
