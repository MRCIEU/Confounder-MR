#!/bin/bash
#SBATCH --account=psyc010162
#SBATCH --job-name=LHC
#SBATCH --output=LHC_slurm.txt
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=22
#SBATCH --time=20:00:00
#SBATCH --mem=100000M

#Put path in variable
CODE="${HOME}/scratch/Confounder-MR/code/e_MR"
DATA="${HOME}/scratch/Confounder-MR/data"

#Get N
wc -l $DATA/GWAS-A-cycling.txt | awk '{print $1}' > $DATA/NcycA.txt
wc -l $DATA/GWAS-B-cycling.txt | awk '{print $1}' > $DATA/NcycB.txt
wc -l $DATA/GWAS-A-procmeat.txt | awk '{print $1}' > $DATA/NprocA.txt
wc -l $DATA/GWAS-B-procmeat.txt | awk '{print $1}' > $DATA/NprocB.txt

#Load R
module add languages/r/4.0.3

#Run
cd $CODE
Rscript LHC.R cycling-A-all.txt CVD-B-all.txt NcycA.txt LHC_cyclingAB.txt > LHC_cyclingAB_r_log.txt
Rscript LHC.R cycling-B-all.txt CVD-A-all.txt NcycB.txt LHC_cyclingBA.txt > LHC_cyclingBA_r_log.txt
Rscript LHC.R processed-meat-A-all.txt alzheimers-B-all.txt NprocA.txt LHC_procmeatAB.txt > LHC_procmeatAB_r_log.txt
Rscript LHC.R processed-meat-B-all.txt alzheimers-A-all.txt NprocB.txt LHC_procmeatBA.txt > LHC_procmeatBA_r_log.txt
