# SCRIPT FOR MULTIPLE JOB SUBMISSION (100 JOBS BY DEFAULT)
# FOR CONTROL/ALLPOS MODELS

#!/bin/bash

trap "INTERRUPTED, NOW EXITING!" SIGINT

cd /Users/depy/SMEP24

N=100

for (( i=1;i<=N;i++ )); do
	qsub -t 1-8 -q all.q smep_control.job;
	printf "$((i*100/N))%%\n";
done

