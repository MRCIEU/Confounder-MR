#!/bin/bash
#SBATCH --job-name=extract_alzheimers
#SBATCH --output=extract_alzheimers_slurm.txt
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=22
#SBATCH --time=20:00:00
#SBATCH --mem=10000M
#SBATCH --partition=mrcieu

######################
# EXTRACT ALZHEIMERS #
######################

#Put data filepath in variable
DATA="$HOME/scratch/Confounder-MR/data"

#Get indexes of cases
grep -n 'A810\|F00\|F01\|F02\|F051\|F106\|G30\|G310\|G311\|G318\|I673' $DATA/icd10.txt | cut -d : -f 1 > $DATA/icd10_alzhmrs_rows.txt

#Take first column of diagnosis
cut -f1 $DATA/icd10.txt > $DATA/alzheimers.txt

#Split characters into different columns
sed -e 's/\(.\)/\1 /g' $DATA/alzheimers.txt > $DATA/alzheimers-temp.txt

#Take first column so file of single characters
awk '{ print$1 }' $DATA/alzheimers-temp.txt > $DATA/alzheimers.txt

#Change everything to 0s
sed 's/./0/g' $DATA/alzheimers.txt > $DATA/alzheimers-temp.txt

#Change Alzheimer's to 1
sed 's/$/c\\\n1/' $DATA/icd10_alzhmrs_rows.txt | sed -f - $DATA/alzheimers-temp.txt > $DATA/alzheimers.txt

#Replace header
sed '1i Alzheimers' $DATA/alzheimers-temp.txt > $DATA/alzheimers.txt

#Count cases
echo "count cases"
grep -c 1 $DATA/alzheimers.txt
grep -c 0 $DATA/alzheimers.txt

#Remove extra files
rm $DATA/icd10_alzhmrs_rows.txt
rm $DATA/alzheimers-temp.txt
