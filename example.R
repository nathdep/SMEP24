library(SMEP24)

seed <- sample(x=c(1:1e6),size=1)

# METHODS (available for 2PL and bifactor models):
# "base" (all inits randomly drawn)
# "empiricalPos" (μ_λ > 0)
# "empiricalAlpha" (λ_i > α)
# "advi" (item inits from EAP conditioned on StdSumScore -> NUTS)

env <- bifactor(seed=seed, I=75, P=500, method="base")

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
