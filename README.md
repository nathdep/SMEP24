# Function Index

- Click [**here**](https://github.com/nathdep/SMEP24/wiki/INDEX) to view an online index of the package's functions.
***
# Simulation Files

- [**2PL .R syntax**](https://github.com/nathdep/SMEP24/blob/main/R/twopl.R)

- [**Bifactor .R syntax**](https://github.com/nathdep/SMEP24/blob/main/R/bifactor.R)

***

# Stan Files for Label-Switching Methods

## Bifactor Model

- [**Base**](https://github.com/nathdep/SMEP24/blob/main/Stan/bifactor_base.stan)
- [**ADVI**](https://github.com/nathdep/SMEP24/blob/main/Stan/bifactor_advi.stan)
- [**Empirical TruncNorm (α)**](https://github.com/nathdep/SMEP24/blob/main/Stan/bifactor_empiricalAlpha.stan)
- [**Empirical Positively Bounded μ<sub>λ</sub>**](https://github.com/nathdep/SMEP24/blob/main/Stan/bifactor_empiricalPos.stan)

## 2PL Model
- [**Base**](https://github.com/nathdep/SMEP24/blob/main/Stan/twopl_base.stan)
- [**ADVI**](https://github.com/nathdep/SMEP24/blob/main/Stan/twopl_advi.stan)
- [**Empirical TruncNorm (α)**](https://github.com/nathdep/SMEP24/blob/main/Stan/twopl_empiricalAlpha.stan)
- [**Empirical Positively Bounded μ<sub>λ</sub>**](https://github.com/nathdep/SMEP24/blob/main/Stan/twopl_empiricalPos.stan)

# Example Replication
Click [**here**](https://github.com/nathdep/SMEP24/blob/main/example.R) to access the example `.R` file displayed below.
```r
library(SMEP24)

# EMPIRICAL METHODS
# "base" (all inits randomly drawn)
# "empiricalPos" (μ_λ > 0)
# "empiricalAlpha" (λ_i > α)

# STARTING VALUES
# "advi" (item inits from EAP conditioned on StdSumScore -> NUTS)
# "allRand" (all parameters initialized on U(-6,6))
# "stdSumScore" (latent traits initialized on standardized sum scores, all other parameters initialized on U(-6,6))

# MODELS
# "twopl" (2-parameter logistic item response model)
# "bifactor (item response model with 1 General factor and 2 sub-factors)

starting_methods <- c("advi", "allRand", "stdSumScore")
empirical_methods <- c("base","empiricalPos", "empiricalAlpha")
models <- c("twopl", "bifactor")

methods_matrix <- expand.grid(starting_methods=starting_methods, empirical_methods=empirical_methods, models=models)

if(!interactive()){
  args <- commandArgs(trailingOnly=TRUE) # Grab JOB_ID and SGE_TASK_ID from .job file in Argon
  # empiricalMethod =
  # startingMethod =
  # model =
  seed <- as.numeric(paste(args, collapse="")) # Generate integer for seed
}

if(interactive()){
  seed <- sample(x=c(1:1e6), size=1) # Randomly draw integer for seed
  startingMethod="allRand"
  empiricalMethod="empiricalAlpha" # Debugging
  model="bifactor"
}

set.seed(seed) # set seed (for reproducibility)

P=500 # Number of examinees
I=75 # Number of items
rHatThreshold=1.05 # Threshold for deteriming chain convergence

coefHyper=5 # Hyperparameter for unbounded/continuous/normal parameters
sdHyper=.1 # Hyperparameter for positive bounded/gamma parameters

if(model == "bifactor"){
  env <- bifactor() # create bifactor simulation environment/list
}

if(model == "twopl"){
  env <- twopl() # create 2PL simulation environment/list
}

list2env(env, envir=.GlobalEnv) # load objects in bifactor simulation into global environment

modrun <- modstan$sample(
  iter_warmup=2000,
  iter_sampling=2000,
  seed=seed,
  data=ModelData,
  chains=4,
  parallel_chains=4,
  init=function()inits
)

modsum <- modrun$summary()

nBadRhats <- countRhat(modsum, rHatThreshold = rHatThreshold) # Indicator for Rhats > 1.05

if(nBadRhats > 0 && !interactive()){

    badRhatModsum <- modsum[which(modsum$rhat > rHatThreshold),] # filter for posterior descriptives that exceed Rhat threshold (non-converging)
    write.csv(badRhatModsum, paste0("BadRhatModsum_", seed, ".csv")) # write non-convergent parameter posterior descriptives to .csv file
    rHatNames <- badRhatModsum$variable # extract bad Rhat names
    dropind_rHat <- sub("\\[.*\\]", "", rHatNames) # drop indices ([,])
    unique_rHatNames <- unique(dropind_rHat) # eliminate repeats in names
    unique_rHatNames <- unique_rHatNames[-which(unique_rHatNames == "lp__")] # drop lp__ (log posterior)

    sink(paste0(getwd(), "/", model,"_", method,"_", "badCount.txt"), append=TRUE) # begin appending <model>_<method>_badCount.csv file
    cat(paste0(nBadRhats,",")) # write result
    sink() # close connection

    sink(paste0(getwd(), "/", model,"_", method,"_", "badNames.txt"), append=TRUE) # begin appending <model>_<method>_badNames.csv file
    for(i in 1:length(unique_rHatNames)){
      cat(paste0(unique_rHatNames[i], ",", "\n"))
    }
    sink() # close connection

  }
}

```
