# Installation

Installation via `devtools`:

```r
# install.packages("devtools")
devtools::install_github("nathdep/SMEP24")
```

***
# Research Article

Click [**here**](https://github.com/nathdep/SMEP24/blob/main/SMEP_2024.pdf) to view the SMEP 2024 research article related to this project.

***
# Function Index

- Click [**here**](https://github.com/nathdep/SMEP24/wiki/INDEX) to view an online index of the package's functions.
***
# Simulation Files

- [**2PL .R syntax**](https://github.com/nathdep/SMEP24/blob/main/R/twopl.R)

- [**Bifactor .R syntax**](https://github.com/nathdep/SMEP24/blob/main/R/bifactor.R)

***
# Stan Files for Label-Switching Methods

## Bifactor Model

- [**All Positive (+λ)**](https://github.com/nathdep/SMEP24/blob/main/Stan/bifactor_ALLPOS.stan)
- [**Control (±λ,Random Initial Values, No Empirical Methods)**](https://github.com/nathdep/SMEP24/blob/main/Stan/bifactor_CONTROL.stan)
- [**ADVI**](https://github.com/nathdep/SMEP24/blob/main/Stan/bifactor_advi.stan)
- [**Empirical TruncNorm (α)**](https://github.com/nathdep/SMEP24/blob/main/Stan/bifactor_empiricalAlpha.stan)
- [**Empirical Positively Bounded μ<sub>λ</sub>**](https://github.com/nathdep/SMEP24/blob/main/Stan/bifactor_empiricalPos.stan)

## 2PL Model
- [**All Positive (+λ)**](https://github.com/nathdep/SMEP24/blob/main/Stan/twopl_ALLPOS.stan)
- [**Control (±λ,Random Initial Values, No Empirical Methods)**](https://github.com/nathdep/SMEP24/blob/main/Stan/twopl_CONTROL.stan)
- [**ADVI**](https://github.com/nathdep/SMEP24/blob/main/Stan/twopl_advi.stan)
- [**Empirical TruncNorm (α)**](https://github.com/nathdep/SMEP24/blob/main/Stan/twopl_empiricalAlpha.stan)
- [**Empirical Positively Bounded μ<sub>λ</sub>**](https://github.com/nathdep/SMEP24/blob/main/Stan/twopl_empiricalPos.stan)

# Example Replication
Click [**here**](https://github.com/nathdep/SMEP24/blob/main/example.R) to access the example `.R` file displayed below.

```r
library(SMEP24)

### CONDITIONS TESTED ###

# EMPIRICAL METHODS
# "empiricalPos" (μ_λ > 0)
# "empiricalAlpha" (λ_i > α)

# STARTING VALUES
# "advi" (item inits from EAP conditioned on StdSumScore -> NUTS)
# "allRand" (all parameters initialized on U(-6,6))
# "stdSumScore" (latent traits initialized on standardized sum scores, all other parameters initialized on U(-6,6))

# MODELS
# "twopl" (2-parameter logistic item response model)
# "bifactor (item response model with 1 General factor and 2 sub-factors)

# SAMPLE SIZE
# Number of examinees = 500 or 2000

### CONTROL MATRIX ###

# --------------------------------------------
#   models    startingMethods   examineeSizes
# ---------- ----------------- ---------------
#   twopl         ALLPOS             500
#
#  bifactor       ALLPOS             500
#
#   twopl         CONTROL            500
#
#  bifactor       CONTROL            500
#
#   twopl         ALLPOS            2000
#
#  bifactor       ALLPOS            2000
#
#   twopl         CONTROL           2000
#
#  bifactor       CONTROL           2000
# --------------------------------------------

### METHODS MATRIX ###

# ----------------------------------------------------------------
#  starting_methods   empiricalMethods    models    examineeSizes
# ------------------ ------------------ ---------- ---------------
#        advi           empiricalPos      twopl          500
#
#      allRand          empiricalPos      twopl          500
#
#    StdSumScore        empiricalPos      twopl          500
#
#        advi          empiricalAlpha     twopl          500
#
#      allRand         empiricalAlpha     twopl          500
#
#    StdSumScore       empiricalAlpha     twopl          500
#
#        advi           empiricalPos     bifactor        500
#
#      allRand          empiricalPos     bifactor        500
#
#    StdSumScore        empiricalPos     bifactor        500
#
#        advi          empiricalAlpha    bifactor        500
#
#      allRand         empiricalAlpha    bifactor        500
#
#    StdSumScore       empiricalAlpha    bifactor        500
#
#        advi           empiricalPos      twopl         2000
#
#      allRand          empiricalPos      twopl         2000
#
#    StdSumScore        empiricalPos      twopl         2000
#
#        advi          empiricalAlpha     twopl         2000
#
#      allRand         empiricalAlpha     twopl         2000
#
#    StdSumScore       empiricalAlpha     twopl         2000
#
#        advi           empiricalPos     bifactor       2000
#
#      allRand          empiricalPos     bifactor       2000
#
#    StdSumScore        empiricalPos     bifactor       2000
#
#        advi          empiricalAlpha    bifactor       2000
#
#      allRand         empiricalAlpha    bifactor       2000
#
#    StdSumScore       empiricalAlpha    bifactor       2000
# ----------------------------------------------------------------

#####################################################################

CONTROL=TRUE # Run control model?
saveEnv <- TRUE # Save simulated environment (twopl()/bifactor() output) as list?
models <- c("twopl", "bifactor") # tested models
examineeSizes <- c(500, 2000) # tested examinee sample sizes
findings <- "/Users/depy/SMEP24/Findings/" # Location to save model results

args <- as.numeric(commandArgs(trailingOnly=TRUE)) # Grab JOB_ID and SGE_TASK_ID from .job file in Argon
taskNumber <- args[2] - 1 # offsetting to be compatible with methodSelect() function

if(!CONTROL){
  starting_methods <- c("advi", "allRand", "StdSumScore") # initial value methods
  empirical_methods <- c("empiricalPos", "empiricalAlpha") # empirical methods

  # forming methods matrix from all combos
  methods_matrix <- expand.grid(starting_methods=starting_methods, empiricalMethods=empirical_methods, models=models,examineeSizes=examineeSizes)

  selRow <- as.vector(as.matrix(methodSelect(base10=taskNumber, methodsMatrix=methods_matrix))) # Select row of methods matrix given SGE_TASK_ID number in Argon

  startingMethod <- selRow[1]
  empiricalMethod <- selRow[2]
  model <- selRow[3]
  selectedSampleSize <- as.numeric(selRow[4])

  cat("\n", startingMethod, " ", empiricalMethod, " ", model," ", selectedSampleSize, "\n\n")
}

if(CONTROL){
  startingMethods=c("ALLPOS", "CONTROL")
  empiricalMethod="NA"

  control_matrix <- expand.grid(models=models,startingMethods=startingMethods, examineeSizes=examineeSizes) # control conditions (model + examinee sample size)

  selRow <- as.vector(as.matrix(methodSelect(base10=taskNumber,methodsMatrix=control_matrix)))

  model <- selRow[1]
  startingMethod <- selRow[2]
  selectedSampleSize <- as.numeric(selRow[3])

  cat(paste0("\nCONTROL/ALLPOS MODEL IS SELECTED\n\n", model," ",startingMethod, " ", selectedSampleSize, "\n\n"))
}

seed <- as.numeric(paste(args, collapse="")) # Generate integer for seed
fileInfo <- paste0("__",model, "_", empiricalMethod, "_", startingMethod,"_",selectedSampleSize,"_",args[1], "_", args[2],"__") # file name info for future saving

set.seed(seed) # set seed (for reproducibility)

P=selectedSampleSize # Number of examinees
I=75 # Number of items
numNeg=3 # Number of lambda values to negate in total
rHatThreshold=1.05 # Threshold for deteriming chain convergence

coefHyper=5 # Hyperparameter for unbounded/continuous/normal parameters
sdHyper=.1 # Hyperparameter for positive bounded/gamma parameters

if(model == "twopl"){
  env <- twopl() # create 2PL simulation environment/list
}

if(model == "bifactor"){
  env <- bifactor() # create bifactor simulation environment/list
}

if(saveEnv){ # save simulated environment?
  envList <- as.list(env) # convert environment to list object
  saveRDS(envList, file=paste0(getwd(), "/simData/simData", fileInfo, ".RDS"))
}

list2env(env, envir=.GlobalEnv) # load objects in bifactor simulation into global environment

# SAMPLE STAN MODEL
modrun <- modstan$sample(
  iter_warmup=2000,
  iter_sampling=2000,
  seed=seed,
  data=ModelData,
  chains=4,
  parallel_chains=4,
  init=function()inits
)

modsum_full <- modrun$summary() # generate full posterior descriptives

# Retrieve sampled RMSD (Est. - True) Samples
modsum_rmsd <- modsum_full[grepl("^rmsd", modsum_full$variable),]

# Split posterior descriptives by parameter (theta/lambda/tau)
modsum_save_lambda <- modsum_full[grepl("^lambda", modsum_full$variable),]
modsum_save_tau <- modsum_full[grepl("^tau", modsum_full$variable),]
modsum_save_theta <- modsum_full[grepl("^theta", modsum_full$variable),]

# Add true value columns for post-processing/comparisons
if(model == "twopl"){
  modsum_save_lambda$true <- lambda
}

if(model == "bifactor"){
  modsum_save_lambda$true <- c(lambda_G, lambda_g12)
}

modsum_save_tau$true <- tau
modsum_save_theta$true <- as.vector(theta)

modsum_save_lambda <- modsum_save_lambda[,c(1, ncol(modsum_save_lambda), 2:(ncol(modsum_save_lambda)-1))]
modsum_save_tau <- modsum_save_tau[,c(1, ncol(modsum_save_tau), 2:(ncol(modsum_save_tau)-1))]
modsum_save_theta <- modsum_save_theta[,c(1, ncol(modsum_save_theta), 2:(ncol(modsum_save_theta)-1))]

# SAVING RESULTS
write.csv(modsum_save_lambda, paste0(findings, "Reduc_Modsum", fileInfo, "lambda.csv"))
write.csv(modsum_save_tau, paste0(findings, "Reduc_Modsum", fileInfo, "tau.csv"))
write.csv(modsum_save_theta, paste0(findings, "Reduc_Modsum", fileInfo, "theta.csv"))
write.csv(modsum_rmsd, paste0(findings, "RMSD_Modsum", fileInfo, ".csv"))
write.csv(modsum_full, paste0(findings, "Full_Modsum", fileInfo, ".csv"))

nBadRhats <- countRhat(modsum_full, rHatThreshold = rHatThreshold) # Indicator for Rhats > 1.05

file.rename(from=paste0(getwd(), "/simData/simData", fileInfo, ".RDS"), to=paste0(getwd(),"/DONE/simData", fileInfo, ".RDS"))

if(nBadRhats != 0){

  badRhatModsum <- modsum_full[which(modsum_full$rhat > rHatThreshold),] # filter for posterior descriptives that exceed Rhat threshold (non-converging)
  write.csv(badRhatModsum, paste0(findings, "BadRhat_Modsum", fileInfo, ".csv")) # write non-convergent parameter posterior descriptives to .csv file

}
```
***
# Clean-Up 
Click [**here**](https://github.com/nathdep/SMEP24/blob/main/cleanup.R) to access the `.R` file needed to re-run simulation environments booted from the HPC queue.

The `simDataFileList.csv` file (a list of all leftover simulation environments booted from the HPC queue/contained in the `simData` directory) may be generated by running `genSimDataList.sh` found [**here**](https://github.com/nathdep/SMEP24/blob/main/genSimDataList.sh). 
***
# Compile
The descriptive statistics for sampled posterior densities may be compiled across replications by running the following `.R` script.

Click[**here**](https://github.com/nathdep/SMEP24/blob/main/compile.R) to view to access the `.R` file displayed below. NOTE: make sure to run this file from *within the directory containing the `simData` directory*.

```r
library(SMEP24)

files <- list.files(path="/root/Findings/", pattern=".csv$")
csvFiles <- lapply(files, function(x)fread(file=paste0("/root/Findings/", x), data.table=FALSE))

f <- gsub(pattern=".*__(.*)__.*", replacement="\\1", x=files)

gatheredInfo <- lapply(strsplit(x=f, split="_"), function(x)sub(pattern=".csv",replacement="",x=x))
prefix <- lapply(files, function(x)sub(pattern="(.*?)__.*", replacement="\\1",x=x))
suffix <- lapply(files, function(x)sub(pattern=".*__(.*?).csv$", replacement="\\1", x=x))

catList <- vector(length=length(f), mode="list")

for(i in 1:length(f)){
  catList[[i]]$Info <- as.data.frame(rbind(c(prefix[[i]], gatheredInfo[[i]])))
  colnames(catList[[i]]$Info) <- c("type","model", "empiricalMethod", "startingMethod", "sampleSize", "seed", "taskNo")
  if(any(c("lambda", "tau", "theta") %in% suffix[[i]])){
    catList[[i]]$Modsum <- list(reduc=suffix[[i]], df=csvFiles[[i]])
  }
  else{
    catList[[i]]$Modsum <- csvFiles[[i]]
  }
}

saveRDS(catList, file="catList.RDS")

dfNames <- as.vector(unlist(unique(lapply(catList, function(x)x$Info[1]))))
lapply(dfNames, function(x)assign(x, new.env(), envir=.GlobalEnv))

namesLong <- as.vector(unlist(lapply(catList, function(x)x$Info[1])))
typeInds <- sapply(dfNames, function(x)which(namesLong == x))

for(i in 1:length(dfNames)){
  selCatList <- catList[typeInds[[dfNames[i]]]]
  selInfos <- lapply(selCatList, function(x)x$Info)
  selModsums <- lapply(selCatList, function(x)x$Modsum)
  assign("Infos", selInfos, envir=get(dfNames[i], envir=.GlobalEnv))
  assign("Modsums", selModsums, envir=get(dfNames[i], envir=.GlobalEnv))
}

splitLists <- lapply(mget(dfNames, envir=.GlobalEnv), as.list)

saveRDS(splitLists, file="ResultsByTypeFull.RDS")

for(i in 1:length(splitLists)){
  saveRDS(splitLists[i], file=paste0(dfNames[i], ".RDS"))
}
```
***
#Post-processing
The following script may be run *after compiling the descriptive statistics of sampled posterior densities* across replications to save results organized according to the methods/control matrices.

Run this code *after* executing the `compile.R` script above.

Click[**here**](https://github.com/nathdep/SMEP24/blob/main/postproc.R) to view to access the `.R` file displayed below. NOTE: make sure to run this file from *within the directory containing the `Findings` directory*.

```r
library(SMEP24)

CONTROL=FALSE
args <- as.numeric(commandArgs(trailingOnly=TRUE))

models <- c("twopl", "bifactor")
examineeSizes <- c(500, 2000)
paramNames <- c("theta", "lambda", "tau")

if(CONTROL){
  control_starting_methods=c("ALLPOS", "CONTROL")
  control_empirical_methods="NA"
  combo_matrix <- expand.grid(model=models, empiricalMethod=control_empirical_methods, startingMethod=control_starting_methods, sampleSize=examineeSizes)
}

if(!CONTROL){
  tested_empirical_methods <-  c("empiricalPos", "empiricalAlpha")
  tested_starting_methods <- c("advi", "allRand", "StdSumScore")
  combo_matrix <- expand.grid(model=models, empiricalMethod=tested_empirical_methods, startingMethod=tested_starting_methods, sampleSize=examineeSizes)
}

selRow <-as.vector(as.matrix(methodSelect(base10=args[2], methodsMatrix=combo_matrix)))

filteredInds <- which(sapply(Reduc_Modsum$Infos, function(x) all(selRow %in% x)))
filteredModsumsFull <- lapply(Reduc_Modsum$Modsums[filteredInds], function(x)x$df)

paramInds <- vector(length=length(paramNames), mode="list")
names(paramInds) <- paramNames

filteredModsums <- vector(length=length(paramNames), mode="list")
names(filteredModsums) <- paramNames

for(j in 1:length(paramNames)){
  for(i in 1:length(filteredInds)){
    if(Reduc_Modsum$Modsums[[filteredInds[i]]]$reduc == paramNames[j]){
      paramInds[[paramNames[j]]] <- c(paramInds[[paramNames[j]]], i)
    }
  }
}

for(j in 1:length(paramNames)){
  filteredModsums[[paramNames[j]]] <- filteredModsumsFull[paramInds[[paramNames[j]]]]
  write.csv(bind_rows(filteredModsums[[paramNames[j]]])[,2:ncol(bind_rows(filteredModsums[[paramNames[j]]]))], paste0(paste0(selRow, collapse="_"), "_",paramNames[j],".csv"), row.names=FALSE)
}

saveRDS(filteredModsumsFull, file="filteredModsumsFull.RDS")
```
***
