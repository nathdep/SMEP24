#! /bin/bash
#$ -pe smp 4
#$ -N SMEP
#$ -q CASMA
#$ -e /dev/null
#$ -o /dev/null

ERR="/Users/depy/SMEP24/e/STDERR_${JOB_ID}_${SGE_TASK_ID}.txt"
OUT="/Users/depy/SMEP24/o/STDOUT_${JOB_ID}_${SGE_TASK_ID}.txt"

exec 1> $OUT
exec 2> $ERR

cd /Users/depy/SMEP24

apptainer run --bind /Users/depy/SMEP24:/root /Users/depy/containers/R.sif Rscript --vanilla example.R $JOB_ID $SGE_TASK_ID