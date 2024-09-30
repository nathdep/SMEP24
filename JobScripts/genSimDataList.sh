# SCRIPT FOR GENERATING .CSV CONTAINING MODELS BOOTED FROM HPC QUEUE

#!/bin/bash

cd /Users/depy/SMEP24/simData

find . -type f -name "*.RData" -printf "%P,\n" > simDataFileList.csv
