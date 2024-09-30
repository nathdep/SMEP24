# SCRIPT FOR MULTIPLE JOB SUBMISSION (100 JOBS BY DEFAULT)
# FOR TESTED MODELS

#!/bin/bash

trap "INTERRUPTED, NOW EXITING!" SIGINT

cd /Users/depy/SMEP24

N=100

for (( i=1;i<=N;i++ )); do
	qsub -t 1-24 -q all.q smep.job;
	printf "$((i*100/N))%%\n";
done

