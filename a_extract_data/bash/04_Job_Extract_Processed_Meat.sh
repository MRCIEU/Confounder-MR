#!/bin/bash
#SBATCH --job-name=extract_processed_meat
#SBATCH --output=extract_processed_meat_slurm.txt
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=22
#SBATCH --time=20:00:00
#SBATCH --mem=10000M

##########################
# EXTRACT PROCESSED MEAT #
##########################

#Put data filepath in variable
DATA="$HOME/scratch/Confounder-MR/data"

#Get column numbers for processed meat
head -n1 $DATA/data.50982.tab | sed 's/\t/\n/g' | nl | grep -n "f.1349.0."

#Put columns in file
cut -f695 $DATA/data.50982.tab > $DATA/processed_meat.txt
head -1 $DATA/processed_meat.txt

#Delete headers
sed -i 1d $DATA/processed_meat.txt

#Recode
sed -i 's/2/1/g' $DATA/processed_meat.txt
sed -i 's/-3/x/g' $DATA/processed_meat_cats.txt
sed -i 's/3/2/g' $DATA/processed_meat_cats.txt
sed -i 's/x/-3/g' $DATA/processed_meat_cats.txt
sed -i 's/4\|5/3/g' $DATA/processed_meat_cats.txt

#Replace header
sed -i '1i Processed_Meat_Cats' $DATA/processed_meat.txt

#Count missing data
echo "count missing data"
echo "NA"
grep -c NA $DATA/processed_meat.txt
echo "-1: Don't Know"
grep -c -e -1 $DATA/processed_meat.txt
echo "-3: Prefer not to answer"
grep -c -e -3 $DATA/processed_meat.txt

#Count cases
echo "count never, once, 2-4, 5+"
grep -c 0 $DATA/processed_meat.txt
grep -c 1 $DATA/processed_meat.txt
grep -c 2 $DATA/processed_meat.txt
grep -c 3 $DATA/processed_meat.txt
