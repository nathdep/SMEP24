library(SMEP24)

list2env(twopl(I=75, P=500, method="empiricalAlpha"), envir=.GlobalEnv)

modrun <- modstan$sample(
  iter_warmup=2000,
  iter_sampling=2000,
  seed=seed,
  data=bifactorModelData,
  chains=4,
  parallel_chains=4
)

modsum <- modrun$summary()
