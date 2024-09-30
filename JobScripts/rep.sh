# SCRIPT FOR SUBMITTING JOBS BOOTED FROM HPC QUEUE WHERE NO simData.RDS FILE WAS CREATED
# FOR TESTED MODELS

#! /bin/bash

apptainer run --bind /Users/depy/SMEP24:/root Rscript --vanilla getNums.R

FILES=($(cat task.txt))

for i in "${FILES[@]}"; do
	qsub -t $i -q CASMA smep.job
done
