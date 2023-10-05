#!/bin/bash
#SBATCH --job-name=extract_education
#SBATCH --output=extract_education_slurm.txt
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=22
#SBATCH --time=20:00:00
#SBATCH --mem=10000M
#SBATCH --partition=mrcieu

#####################
# EXTRACT EDUCATION #
#####################

#Put data filepath in variable
DATA="$HOME/scratch/Confounder-MR/data"

#Get column numbers for education
head -n1 $DATA/data.50982.tab | sed 's/\t/\n/g' | nl | grep -n "f.6138.0."

#Put columns in file
cut -f5798 $DATA/data.50982.tab > $DATA/education.txt
head -n1 $DATA/education.txt

#Delete headers
sed -i 1d $DATA/education.txt

#Recode
sed -i 's/-7/7/g' $DATA/education.txt

#Replace header
sed -i '1i Education' $DATA/education.txt

#Count missing data
echo "count missing data"
echo "NA"
grep -c NA $DATA/education.txt
echo "-3: Prefer not to answer"
grep -c -e -3 $DATA/education.txt

#Count cases
echo "count non-uni and uni"
grep -c 0 $DATA/education.txt
grep -c 1 $DATA/education.txt
