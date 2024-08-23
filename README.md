# Simulation Files

[**2PL .R syntax**](https://github.com/nathdep/SMEP24/blob/67105e3d233d0aea5dd0b0050c515af1a78e73b2/R/bifactor.R)

[**Bifactor .R syntax**](https://github.com/nathdep/SMEP24/blob/67105e3d233d0aea5dd0b0050c515af1a78e73b2/R/bifactor.R)

# Stan Files for Label-Switching Approaches

## Bifactor Models
[**Base**](https://github.com/nathdep/SMEP24/blob/67105e3d233d0aea5dd0b0050c515af1a78e73b2/Stan/bifactor_base.stan)
[**ADVI**](https://github.com/nathdep/SMEP24/blob/67105e3d233d0aea5dd0b0050c515af1a78e73b2/Stan/bifactor_advi.stan)
[**Empirical Lower Bound**](https://github.com/nathdep/SMEP24/blob/main/Stan/bifactor_empiricalAlpha.stan)
[**Empirical Bounded μ**](https://github.com/nathdep/SMEP24/blob/67105e3d233d0aea5dd0b0050c515af1a78e73b2/Stan/bifactor_empiricalPos.stan)

## 2PL Models
[**Base**](https://github.com/nathdep/SMEP24/blob/67105e3d233d0aea5dd0b0050c515af1a78e73b2/Stan/twopl_base.stan)
[**ADVI**](https://github.com/nathdep/SMEP24/blob/67105e3d233d0aea5dd0b0050c515af1a78e73b2/Stan/twopl_advi.stan)
[**Empirical Lower Bound**](https://github.com/nathdep/SMEP24/blob/main/Stan/twopl_empiricalAlpha.stan)
[**Empirical Bounded μ**](https://github.com/nathdep/SMEP24/blob/67105e3d233d0aea5dd0b0050c515af1a78e73b2/Stan/twopl_empiricalPos.stan)

# Example

```r
library(SMEP24)

# METHODS (available for twopl and bifactor models):
# "base" (all inits randomly drawn)
# "empiricalPos (μ_λ > 0)
# "empiricalAlpha" (λ_i > 0)
# "advi" (item inits from EAP conditioned on StdSumScore -> NUTS)

env <- twopl(I=75, P=500, method="base")

list2env(env, envir=.GlobalEnv)

modrun <- modstan$sample(
  iter_warmup=2000,
  iter_sampling=2000,
  seed=seed,
  data=bifactorModelData,
  chains=4,
  parallel_chains=4
)

modsum <- modrun$summary()
```
