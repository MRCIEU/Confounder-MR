#!/bin/bash
#SBATCH --account=psyc010162
#SBATCH --job-name=compile__eafs
#SBATCH --output=compile_eafs_slurm.txt
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=22
#SBATCH --time=60:00:00
#SBATCH --mem=500M

#Put filepath in variable
INPUT="${HOME}/scratch/Confounder-MR/code/d_process_genetic_data"
DATA="${HOME}/scratch/Confounder-MR/data/snp_stats"

#If the output file already exists delete it
if test -f $DATA/snp-stats-compiled.txt; then
        rm $DATA/snp-stats-compiled.txt
fi

#Re-create outputfile
touch  $DATA/snp-stats-compiled.txt

#Compile the snp data files for each chromosome into 1 file
cat $DATA/*-snp-stats.txt >> $DATA/snp-stats-compiled.txt

#Extract relevant snp columns using grep and snplist
grep -wFf $INPUT/SNPlist.txt $DATA/snp-stats-compiled.txt > $DATA/EAF.txt

#Count rows
wc -l $DATA/EAF.txt

