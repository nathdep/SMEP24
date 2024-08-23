# Simulation Files

  - [**2PL .R syntax**](https://github.com/nathdep/SMEP24/blob/main/R/twopl.R)

  - [**Bifactor .R syntax**](https://github.com/nathdep/SMEP24/blob/main/R/bifactor.R)

-----------------

# Stan Files for Label-Switching Approaches

## Bifactor Model

  - [**Base**](https://github.com/nathdep/SMEP24/blob/main/Stan/bifactor_base.stan)
  - [**ADVI**](https://github.com/nathdep/SMEP24/blob/main/Stan/bifactor_advi.stan)
  - [**Empirical TruncNorm (α)**](https://github.com/nathdep/SMEP24/blob/main/Stan/bifactor_empiricalAlpha.stan)
  - [**Empirical Positively Bounded μ_λ**](https://github.com/nathdep/SMEP24/blob/main/Stan/bifactor_empiricalPos.stan)

## 2PL Model
  - [**Base**](https://github.com/nathdep/SMEP24/blob/main/Stan/twopl_base.stan)
  - [**ADVI**](https://github.com/nathdep/SMEP24/blob/main/Stan/twopl_advi.stan)
  - [**Empirical TruncNorm (α)**](https://github.com/nathdep/SMEP24/blob/main/Stan/twopl_empiricalAlpha.stan)
  - [**Empirical Positively Bounded μ_λ**](https://github.com/nathdep/SMEP24/blob/main/Stan/twopl_empiricalPos.stan)

# Example

```r
library(SMEP24)

seed <- sample(x=c(1:1e6),size=1)

# METHODS (available for 2PL and bifactor models):
# "base" (all inits randomly drawn)
# "empiricalPos" (μ_λ > 0)
# "empiricalAlpha" (λ_i > α)
# "advi" (item inits from EAP conditioned on StdSumScore -> NUTS)

env <- twopl(seed=seed, I=75, P=500, method="base")

list2env(env, envir=.GlobalEnv)

ModelData <- list(
  P=nrow(Y),
  I=ncol(Y),
  Y=Y,
  coefHyper=5,
  sdHyper=.1
)

if(grepl("bifactor", model)){
  ModelData$nDim <- ncol(lambdaQ)
  ModelData$Qmat <- Qmat
}

if(grepl("Alpha", method)){
  ModelData$alpha <- -.25
}

if(!grepl("advi", method)){

  modrun <- modstan$sample(
    iter_warmup=2000,
    iter_sampling=2000,
    seed=seed,
    data=ModelData,
    chains=4,
    parallel_chains=4
  )

  modsum <- modrun$summary()

}

if(grepl("advi", method)){

  ModelData$SumScore <- getStdSumScore(resps)

  advirun <- modstan$variational(
    data=ModelData,
    seed=seed
  )

  inits <- getInits(advirun$summary())

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

}
```
