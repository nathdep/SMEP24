#! /bin/bash
#$ -pe smp 4
#$ -N CLEAN_UP
#$ -q CASMA
#$ -e /dev/null
#$ -o /dev/null

ERR="/Users/depy/SMEP24/e/CLEAN_UP_STDERR_${JOB_ID}_${SGE_TASK_ID}.txt"
OUT="/Users/depy/SMEP24/o/CLEAN_UP_STDOUT_${JOB_ID}_${SGE_TASK_ID}.txt"

exec 1> $OUT
exec 2> $ERR

cd /Users/depy/SMEP24

apptainer run --bind /Users/depy/SMEP24:/root /Users/depy/containers/R.sif Rscript --vanilla cleanup.R $JOB_ID $SGE_TASK_ID
