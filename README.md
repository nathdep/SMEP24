# Simulation Files

- [**2PL .R syntax**](https://github.com/nathdep/SMEP24/blob/main/R/twopl.R)

- [**Bifactor .R syntax**](https://github.com/nathdep/SMEP24/blob/main/R/bifactor.R)

-----------------

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

# Example
Click [**here**](https://github.com/nathdep/SMEP24/blob/main/example.R) to access the example `.R` file displayed below.
```r
library(SMEP24)

# !TO DO! add other methods

seed <- sample(x=c(1:1e6),size=1) # Generate integer for seed
set.seed(seed) # set seed (for reproducibility)

if(!interactive()){
  methodInd <- as.numeric(commandArgs(trailingOnly=TRUE))
}

# METHODS (available for 2PL and bifactor models):
# "base" (all inits randomly drawn)
# "empiricalPos" (μ_λ > 0)
# "empiricalAlpha" (λ_i > α)
# "advi" (item inits from EAP conditioned on StdSumScore -> NUTS)

methods <- c("empiricalPos", "empiricalAlpha", "advi")
models <- c("twopl", "bifactor")

P=500 # Number of examinees
I=75 # Number of items
alpha=-.25 # lower bound (for empirical bound (α) method)

coefHyper=5 # Hyperprior for unbounded/continuous/normal parameters
sdHyper=.1 # Hyperprior for positive bounded/gamma parameters

env <- bifactor() # create bifactor simulation environment/list

list2env(env, envir=.GlobalEnv) # load objects in bifactor simulation into global environment

if(method == "advi"){

  advirun <- modstan$variational(  # Run variational inference via ADVI
    data=ModelData,
    seed=seed
  )

  advisum <- advirun$summary() # Calculate descriptive stats using draws from approximated posteriors

  inits <- getInits(stansum=advisum) # Create a list of initial values using EAP extracted from advisum (to pass to NUTS in next step)

  initDims <- lapply(names(inits), getDims) # get dimensions for parameter matrices from global environment (i.e., theta in bifactor model)

  for(i in 1:length(initDims)){ # reshape initial values to account for matrix dimensions in previous step (if applicable)
    if(!is.null(initDims[[i]])){
      dim(inits[[i]]) <- initDims[[i]]
    }
  }

  modrun <- basemod$sample( # run NUTS sampler initialized on EAPs from previous step
    iter_warmup=2000,
    iter_sampling=2000,
    seed=seed,
    data=ModelData,
    chains=4,
    parallel_chains=4,
    init=function()inits
  )

}

if(!(method == "advi")){
  modrun <- modstan$sample( # run NUTS sampler (for methods other than )
    iter_warmup=2000,
    iter_sampling=2000,
    seed=seed,
    data=ModelData,
    chains=4,
    parallel_chains=4
  )

  modsum <- modrun$summary()

}

nBadRhats <- countRhat(modsum, rHatThreshold = 1.05) # Indicator for Rhats > 1.05




```
