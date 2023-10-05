#!/bin/bash
#SBATCH --account=psyc010162
#SBATCH --job-name=combine
#SBATCH --output=combine_slurm.txt
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=22
#SBATCH --time=10:00:00
#SBATCH --mem=5000M

#Put data filepath in variable
DATA="$HOME/scratch/Confounder-MR/data"

#######################
# EXTRACT CONFOUNDERS #
#######################

#Get column numbers for Sex
head -n1 $DATA/data.50982.tab | sed 's/\t/\n/g' | nl | grep -wn "f.31.0.0"
#23

#Get column numbers for risk taking
head -n1 $DATA/data.50982.tab | sed 's/\t/\n/g' | nl | grep -wn "f.2040.0.0"
#916

#Get column numbers for BMI
head -n1 $DATA/data.50982.tab | sed 's/\t/\n/g' | nl | grep -n "f.21001.0."
#9722

#Get column numbers for Age
head -n1 $DATA/data.50982.tab | sed 's/\t/\n/g' | nl | grep -wn "f.21022.0.0"
#9738

#Extract confounder
cut -f23,916,9722,9738 $DATA/data.50982.tab > $DATA/confounders.txt
head -n1 $DATA/confounders.txt

#Change headers
sed -i 1d $DATA/confounders.txt
sed -i '1i Sex\tRisk_Taking\tBMI\tAge' $DATA/confounders.txt

###########
# COMBINE #     
###########

#Get IDs
cut -f1 $DATA/data.50982.tab > $DATA/IDs.txt

#Combine
paste $DATA/IDs.txt $DATA/CVD.txt $DATA/alzheimers.txt $DATA/cycling.txt $DATA/processed_meat.txt $DATA/education.txt $DATA/confounders.txt $DATA/date_CVD_excld.txt $DATA/date_alzhmrs_excld.txt > $DATA/data.txt
