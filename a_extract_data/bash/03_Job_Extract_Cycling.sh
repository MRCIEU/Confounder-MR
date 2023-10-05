#!/bin/bash
#SBATCH --account=psyc010162
#SBATCH --job-name=extract_cycling
#SBATCH --output=extract_cycling_slurm.txt
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=22
#SBATCH --time=20:00:00
#SBATCH --mem=10000M

###################
# EXTRACT CYCLING #
###################

#Put data filepath in variable
DATA="$HOME/scratch/Confounder-MR/data"
CODE="$HOME/scratch/Confounder-MR/code/a_extract_data/R/"

#Get column numbers for commuting
head -n1 $DATA/data.50982.tab | sed 's/\t/\n/g' | nl | grep -n "f.6143.0."

#Put columns in file
cut -f5894-5897 $DATA/data.50982.tab > $DATA/cycling.txt
head -1 $DATA/cycling.txt

#Delete headers
sed -i 1d $DATA/cycling.txt

#Get indexes of vehicle
grep -n '1\|3' $DATA/cycling.txt | grep -v -e -3 | cut -d : -f 1 > $DATA/vehicle_rows.txt

#Get indexes of Walk
grep -n 2 $DATA/cycling.txt | cut -d : -f 1 > $DATA/walk_rows.txt

#Get indexes of Cycle
grep -n 4 $DATA/cycling.txt | cut -d : -f 1 > $DATA/cycling_rows.txt

#Run R code
module add languages/r/4.0.3
cd $CODE
R CMD BATCH --no-save --no-restore process_cycling.R process_cycling_r_log.txt

sed -i "1i Cycling" $DATA/cycling.txt 

#Count missing data
echo "count missing data"
echo "NA"
grep -c NA $DATA/cycling.txt
echo "-7: None of the above"
grep -c -e -7 $DATA/cycling.txt
echo "-3: Prefer not to answer"
grep -c -e -3 $DATA/cycling.txt

#Count cases
echo "count non-active and cycling commuters"
grep -c 0 $DATA/cycling.txt
grep -c 1 $DATA/cycling.txt

#Remove temp files
rm $DATA/vehicle_rows.txt
rm $DATA/walk_rows.txt
rm $DATA/cycling_rows.txt
