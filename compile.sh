#!/bin/bash
#$ -e /dev/null
#$ -o /dev/null
#$ -pe smp 4
#$ -q CASMA
#$ -N COMPILE

ERR="/Users/depy/SMEP24/e/COMPILE_STDERR_${JOB_ID}_${SGE_TASK_ID}.txt"
OUT="/Users/depy/SMEP24/o/COMPILE_STDOUT_${JOB_ID}_${SGE_TASK_ID}.txt"

exec 1> $OUT
exec 2> $ERR

cd /Users/depy/SMEP24

apptainer run --bind /Users/depy/SMEP24:/root /Users/depy/containers/R.sif Rscript --vanilla compile.R $JOB_ID $SGE_TASK_ID
