# Example

```r
library(SMEP24)

# METHODS:
# "base" (all inits randomly drawn)
# "empiricalPos (μ_λ > 0)
# "empiricalAlpha" (λ_i > 0)
# "advi" (item inits from EAP conditioned on StdSumScore -> NUTS)

list2env(twopl(I=75, P=500, method="base"), envir=.GlobalEnv)

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
