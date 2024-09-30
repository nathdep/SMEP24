# SCRIPT FOR SUBMITTING JOBS BOOTED FROM HPC QUEUE WHERE NO simData.RDS FILE WAS CREATED
# FOR TESTED MODELS

#! /bin/bash

FILES=($(cat task.txt))

for i in "${FILES[@]}"; do
	qsub -t $i -q CASMA smep.job
done
