#!/bin/bash
#SBATCH --account=psyc010162
#SBATCH --job-name=make_SNP_list
#SBATCH --output=make_SNP_list_slurm.txt
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=22
#SBATCH --time=10:00:00
#SBATCH --mem=10000M

#Put data filepath in variable
OUTPUT="$HOME/scratch/Confounder-MR/output"
INPUT="$HOME/scratch/Confounder-MR/code/inputs"
CODE="$HOME/scratch/Confounder-MR/code/d_process_genetic_data"

#Make snp list
cd $OUTPUT
for file in *-relaxed-clumped.txt; do
	cat $file | awk '{print $1}' | awk 'NR>1' >> $CODE/SNPlist-combined.txt
done 


#add confounder SNPs (risk, bmi, education)
cd $INPUT
for file in *.txt; do
        cat $file | awk '{print $1}' | awk 'NR>1' >> $CODE/SNPlist-combined.txt
done


#Remove duplicates
uniq $CODE/SNPlist-combined.txt > $CODE/SNPlist.txt
rm $CODE/SNPlist-combined.txt
