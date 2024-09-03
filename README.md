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

P=500 # Number of examinees
I=75 # Number of items
alpha=-.25 # lower bound (for empirical bound (α) method)

# METHODS (available for 2PL and bifactor models):
# "base" (all inits randomly drawn)
# "empiricalPos" (μ_λ > 0)
# "empiricalAlpha" (λ_i > α)
# "advi" (item inits from EAP conditioned on StdSumScore -> NUTS)

method="base"

coefHyper=5 # Hyperprior for unbounded/continuous/normal parameters
sdHyper=.1 # Hyperprior for positive bounded/gamma parameters

env <- bifactor()

list2env(env, envir=.GlobalEnv)

modrun <- modstan$sample(
  iter_warmup=2000,
  iter_sampling=2000,
  seed=seed,
  data=ModelData,
  chains=4,
  parallel_chains=4
)

modsum <- modrun$summary()

nBadRhats <- countRhat(modsum)


```
