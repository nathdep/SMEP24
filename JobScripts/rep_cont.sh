# SCRIPT FOR SUBMITTING JOBS BOOTED FROM HPC QUEUE WHERE NO simData.RDS FILE WAS CREATED
# FOR CONTROL/ALLPOS MODELS

#! /bin/bash

apptainer run --bind /Users/depy/SMEP24:/root Rscript --vanilla getNums_cont.R

FILES=($(cat task_cont.txt))

for i in "${FILES[@]}"; do
	qsub -t $i -q CASMA smep_control.job
done
