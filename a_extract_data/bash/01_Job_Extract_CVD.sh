#!/bin/bash
#SBATCH --job-name=extract_CVD
#SBATCH --output=extract_CVD_slurm.txt
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=22
#SBATCH --time=20:00:00
#SBATCH --mem=10000M
#SBATCH --partition=mrcieu

###############
# EXTRACT CVD #
###############

#Put data filepath in variable
DATA="$HOME/scratch/Confounder-MR/data"

#Get column numbers for ICD10 diagnosis
head -n1 $DATA/data.50982.tab | sed 's/\t/\n/g' | nl | grep -n "f.41270.0."

#Put columns in file
cut -f15741-15983 $DATA/data.50982.tab > $DATA/icd10.txt
head -n1 $DATA/icd10.txt

#Delete headers
sed -i 1d $DATA/icd10.txt

#Get indexes of cases
grep -n 'I21\|I60\|I61\|I63\|I64' $DATA/icd10.txt | cut -d : -f 1 > $DATA/CVD_rows.txt

#Take first column of diagnosis
cut -f1 $DATA/icd10.txt > $DATA/CVD.txt

#Split characters into different columns
sed -e 's/\(.\)/\1 /g' $DATA/CVD.txt > $DATA/CVD-temp.txt

#Take first column so file of single characters
awk '{ print$1 }' $DATA/CVD-temp.txt > $DATA/CVD.txt

#Change everything to 0s
sed 's/./0/g' $DATA/CVD.txt > $DATA/CVD-temp.txt

#Change CVD to 1
sed 's/$/c\\\n1/' $DATA/CVD_rows.txt | sed -f - $DATA/CVD-temp.txt > $DATA/CVD.txt

#Replace header
sed  -i '1i CVD' $DATA/CVD.txt

#Count cases
echo "count cases"
grep -c 1 $DATA/CVD.txt
grep -c 0 $DATA/CVD.txt

#Remove extra files
rm $DATA/CVD_rows.txt
rm $DATA/CVD-temp.txt
