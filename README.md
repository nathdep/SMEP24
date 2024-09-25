# Installation

Installation via `devtools`:

```r
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

setwd("/Users/depy/SMEP24/simData")

findings <- "/Users/depy/SMEP24/Findings/" # Location to save model results

args <- as.numeric(commandArgs(trailingOnly=TRUE))

selectedFile <- read.csv("simDataFileList.csv", header=FALSE)[args[2],1]

cat(paste0("SELECTED FILE: ", selectedFile, "\n\n"))

load(selectedFile)

setwd("/Users/depy/SMEP24")

list2env(envList, envir=.GlobalEnv)

rHatThreshold <- 1.05
gatheredInfo <- unlist(strsplit(x=selectedFile, split="_"))
model <- gatheredInfo[2]
empiricalMethod <- gatheredInfo[3]
startingMethod <- gatheredInfo[4]
selectedSampleSize <- as.numeric(gatheredInfo[5])
taskNo <- as.numeric(gsub(".RData", "", gatheredInfo[7]))
seed <- as.numeric(paste0(gatheredInfo[6],taskNo))
set.seed(seed)

fileInfo <- paste0(model, "_", empiricalMethod, "_", startingMethod,"_",selectedSampleSize,"_",gatheredInfo[6], "_", taskNo) # file name info for future saving

if(empiricalMethod == "NA"){
  CONTROL=TRUE
  modstan <- cmdstan_model(stan_file=paste0("/Users/depy/SMEP24/Stan/", model, "_", startingMethod, ".stan"))
}

if(empiricalMethod != "NA"){
  CONTROL=FALSE
  modstan <- cmdstan_model(stan_file=paste0("/Users/depy/SMEP24/Stan/", model, "_", empiricalMethod, ".stan"))
}

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
write.csv(modsum_save_lambda, paste0(findings, "Reduc_Modsum_lambda_", fileInfo, ".csv"))
write.csv(modsum_save_tau, paste0(findings, "Reduc_Modsum_tau_", fileInfo, ".csv"))
write.csv(modsum_save_theta, paste0(findings, "Reduc_Modsum_theta_", fileInfo, ".csv"))
write.csv(modsum_rmsd, paste0(findings, "RMSD_Modsum_", fileInfo, ".csv"))
write.csv(modsum_full, paste0(findings, "Full_Modsum_", fileInfo, ".csv"))

nBadRhats <- countRhat(modsum_full, rHatThreshold = rHatThreshold) # Indicator for Rhats > 1.05

file.rename(from=paste0(getwd(), "/simData/", selectedFile), to=paste0(getwd(),"/DONE/", selectedFile))

if(nBadRhats != 0){

  badRhatModsum <- modsum_full[which(modsum_full$rhat > rHatThreshold),] # filter for posterior descriptives that exceed Rhat threshold (non-converging)
  write.csv(badRhatModsum, paste0(findings, "BadRhat_Modsum_", fileInfo, ".csv")) # write non-convergent parameter posterior descriptives to .csv file

  sink(paste0(findings, "Names_BadRhat_", model, "_", selectedSampleSize, "_", empiricalMethod, "_", startingMethod, ".csv"), append=TRUE) # begin appending <model>_<method>_badCount.csv file
  cat(paste0(nBadRhats,",", model, ",", selectedSampleSize, ",", empiricalMethod, ",", startingMethod, ",", args[1], ",", args[2], "\n")) # write result
  sink() # close connection

}
```
