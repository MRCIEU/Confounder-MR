#!/bin/bash
#SBATCH --account=psyc010162
#SBATCH --job-name=process_GWAS_results
#SBATCH --output=process_GWAS_results_slurm.txt
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=22
#SBATCH --time=10:00:00
#SBATCH --mem=50000M
#SBATCH --array=01-20

#Put filepath in variable
CODE="${HOME}/scratch/Confounder-MR/code/c_process_GWAS_results/"

#Load R
module add languages/r/4.0.3

#Run R code
cd $CODE
if [ "$SLURM_ARRAY_TASK_ID" == 1 ]
then
	Rscript process_GWAS_results.R GWAS-A-cycling.txt GWASofCyclingToWork_A_imputed.txt Binary Cycling 5e-8 cycling-A-GWAS.txt > logs/process_cycling_A_GWAS_r_log.txt
elif [ "$SLURM_ARRAY_TASK_ID" == 2 ]
then
	Rscript process_GWAS_results.R GWAS-A-cycling.txt GWASofCyclingToWork_A_imputed.txt Binary Cycling 1e-6 cycling-A-relaxed.txt > logs/process_cycling_A_relaxed_r_log.txt
elif [ "$SLURM_ARRAY_TASK_ID" == 3 ]
then
	Rscript process_GWAS_results.R GWAS-A-cycling.txt GWASofCyclingToWork_A_imputed.txt Binary Cycling NA cycling-A-GWAS-all.txt > logs/process_cycling_A_all_r_log.txt
elif [ "$SLURM_ARRAY_TASK_ID" == 4 ]
then
	Rscript process_GWAS_results.R GWAS-B-cycling.txt GWASofCyclingToWork_B_imputed.txt Binary Cycling 5e-8 cycling-B-GWAS.txt > logs/process_cycling_B_GWAS_r_log.txt
elif [ "$SLURM_ARRAY_TASK_ID" == 5 ]
then
	Rscript process_GWAS_results.R GWAS-B-cycling.txt GWASofCyclingToWork_B_imputed.txt Binary Cycling 1e-6 cycling-B-relaxed.txt > logs/process_cycling_B_relaxed_r_log.txt
elif [ "$SLURM_ARRAY_TASK_ID" == 6 ]
then
	Rscript process_GWAS_results.R GWAS-B-cycling.txt GWASofCyclingToWork_B_imputed.txt Binary Cycling NA cycling-B-all.txt > logs/process_cycling_B_all_r_log.txt
elif [ "$SLURM_ARRAY_TASK_ID" == 7 ]
then
        Rscript process_GWAS_results.R GWAS.txt GWASofCyclingToWork_imputed.txt Binary Cycling NA cycling-all.txt > logs/process_cycling_all_r_log.txt
elif [ "$SLURM_ARRAY_TASK_ID" == 8 ]
then
        Rscript process_GWAS_results.R GWAS-A-procmeat.txt GWASofProcessedMeat_A_imputed.txt Linear Processed_Meat_Cats 5e-8 processed-meat-A-GWAS.txt > logs/process_procmeat_A_GWAS_r_log.txt
elif [ "$SLURM_ARRAY_TASK_ID" == 9 ]
then
        Rscript process_GWAS_results.R GWAS-A-procmeat.txt GWASofProcessedMeat_A_imputed.txt Linear Processed_Meat_Cats 1e-6 processed-meat-A-relaxed.txt > logs/process_procmeat_A_relaxed_r_log.txt
elif [ "$SLURM_ARRAY_TASK_ID" == 10 ]
then
        Rscript process_GWAS_results.R GWAS-A-procmeat.txt GWASofProcessedMeat_A_imputed.txt Linear Processed_Meat_Cats NA processed-meat-A-all.txt > logs/process_procmeat_A_all_r_log.txt
elif [ "$SLURM_ARRAY_TASK_ID" == 11 ]
then
        Rscript process_GWAS_results.R GWAS-B-procmeat.txt GWASofProcessedMeat_B_imputed.txt Linear Processed_Meat_Cats 5e-8 processed-meat-B-GWAS.txt > logs/process_procmeat_B_GWAS_r_log.txt
elif [ "$SLURM_ARRAY_TASK_ID" == 12 ]
then
        Rscript process_GWAS_results.R GWAS-B-procmeat.txt GWASofProcessedMeat_B_imputed.txt Linear Processed_Meat_Cats 1e-6 processed-meat-B-relaxed.txt > logs/process_procmeat_B_relaxed_r_log.txt
elif [ "$SLURM_ARRAY_TASK_ID" == 13 ]
then
        Rscript process_GWAS_results.R GWAS-B-procmeat.txt GWASofProcessedMeat_B_imputed.txt Linear Processed_Meat_Cats NA processed-meat-B-all.txt > logs/process_procmeat_B_all_r_log.txt
elif [ "$SLURM_ARRAY_TASK_ID" == 14 ]
then
        Rscript process_GWAS_results.R GWAS.txt GWASofProcessedMeat_imputed.txt Linear Processed_Meat_Cats NA processed-meat-all.txt > logs/process_procmeat_all_r_log.txt
elif [ "$SLURM_ARRAY_TASK_ID" == 15 ]
then
        Rscript process_GWAS_results.R GWAS-A-cycling.txt GWASofCVD_A_imputed.txt Binary CVD NA CVD-A-all.txt > logs/process_CVD_A_all_r_log.txt
elif [ "$SLURM_ARRAY_TASK_ID" == 16 ]
then
        Rscript process_GWAS_results.R GWAS-B-cycling.txt GWASofCVD_B_imputed.txt Binary CVD NA CVD-B-all.txt > logs/process_CVD_B_all_r_log.txt
elif [ "$SLURM_ARRAY_TASK_ID" == 17 ]
then
        Rscript process_GWAS_results.R GWAS.txt GWASofCVD_imputed.txt Binary CVD NA CVD-all.txt > logs/process_CVD_all_r_log.txt
elif [ "$SLURM_ARRAY_TASK_ID" == 18 ]
then
        Rscript process_GWAS_results.R GWAS-A-procmeat.txt GWASofAlzheimers_A_imputed.txt Binary Alzheimers NA alzheimers-A-all.txt > logs/process_alzheimers_A_all_r_log.txt
elif [ "$SLURM_ARRAY_TASK_ID" == 19 ]
then
        Rscript process_GWAS_results.R GWAS-B-procmeat.txt GWASofAlzheimers_B_imputed.txt Binary Alzheimers NA alzheimers-B-all.txt > logs/process_alzheimers_B_all_r_log.txt
else
        Rscript process_GWAS_results.R GWAS.txt GWASofAlzheimers_imputed.txt Binary Alzheimers NA alzheimers-all.txt > logs/process_alzheimers_all_r_log.txt
fi
