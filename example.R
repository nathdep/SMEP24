library(SMEP24)

seed <- sample(x=c(1:1e6),size=1)

P=500 # Number of examinees
I=75 # Number of items

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

  ModelData$StdSumScore <- getStdSumScore(resps)

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
