#' Generate a 2-Parameter Logistic (2PL) IRT Simulation Environment
#' @param ... objects inherited from parent
#' @returns an environment stored to a list object of the 2PL simulation environment
#' @export
twopl <- function(...){

  env <- new.env(parent=.GlobalEnv)

  with(env, {

    set.seed(seed)
    # SIMULATION OF DISCRIMINATION PARAMETERS

    lambda <- runif(n=I, min=0, max=3)

    if(startingMethod != "CONTROL" & startingMethod != "ALLPOS"){
      lambda <- makeNeg(lambda, numNeg=numNeg) # negate lambdas at random
      modstan <- cmdstan_model(stan_file=file.path(paste0(getwd(), "/Stan/twopl_", empiricalMethod, ".stan")))
    }

    if(startingMethod == "CONTROL"){
      lambda <- makeNeg(lambda, numNeg=numNeg) # negate lambdas at random
      modstan <- cmdstan_model(stan_file=file.path(paste0(getwd(), "/Stan/twopl_CONTROL.stan")))
    }

    if(startingMethod == "ALLPOS"){
      modstan <- cmdstan_model(stan_file=file.path(paste0(getwd()), "/Stan/twopl_ALLPOS.stan"))
    }

    tau <- runif(n=I, min=-3, max=3)
    # SIMULATION OF LATENT TRAIT MEASUREMENTS
    theta <- rnorm(n=P, mean=0, sd=1)
    # GENERATING DICHOTOMIZED ITEM RESPONSE DATA
    logits <- matrix(data=NA, nrow=P, ncol=I)
    Y <- matrix(data=NA, nrow=P, ncol=I)
    for(p in 1:P){
      for(i in 1:I){
        logits[p,i] <- theta[p]*lambda[i] + tau[i]
        Y[p,i] <- rbinom(n=1, size=1, prob=plogis(logits[p,i]))
      }
    }

    ModelData <- list(
      P=nrow(Y),
      I=ncol(Y),
      Y=Y,
      coefHyper=coefHyper,
      sdHyper=sdHyper,
      true_theta=theta,
      true_tau=tau,
      true_lambda=lambda
    )

    if(startingMethod == "advi"){
      StdSumScore <- getStdSumScore(Y)
      ModelData$StdSumScore = StdSumScore
      ModelData$alpha = min(lambda) - .25 # assigning α

      advistan <- cmdstan_model(stan_file=paste0(getwd(), "/Stan/twopl_advi.stan"))

      advirun <- advistan$variational(  # Run variational inference via ADVI
        data=ModelData,
        seed=seed
      )

      advisum <- advirun$summary() # Calculate descriptive stats using draws from approximated posteriors

      inits <- getInits(advisum) # Create a list of initial values using EAP extracted from advisum (to pass to NUTS in next step)

      initDims <- lapply(names(inits), function(name)getDims(name,envir=parent.env(environment()))) # get dimensions for parameter matrices from global environment (i.e., theta in bifactor model)

      for(i in 1:length(initDims)){ # reshape initial values to account for matrix dimensions in previous step (if applicable)
        if(!is.null(initDims[[i]])){
          dim(inits[[i]]) <- initDims[[i]]
        }
      }

      inits$theta <- runif(n=P, min=-6, max=6)
    }

    if(startingMethod == "ALLPOS"){
      inits <- list(
        theta = runif(n=P, min=-6, max=6),
        lambdaG = runif(n=I, min=0, max=3),
        lambdag_12=runif(n=I, min=0, max=3),
        tau <- runif(n=I, min=-6, max=6)
      )
    }

    if(startingMethod == "allRand" | startingMethod == "CONTROL"){

      inits <- list(
        theta = runif(n=P, min=-6, max=6),
        lambda = runif(n=I, min=-6, max=6),
        tau = runif(n=I,min=-6, max=6)
      )

    }

    if(startingMethod == "StdSumScore"){

      inits <- list(
        theta = getStdSumScore(Y),
        lambda=runif(n=I, min=-6, max=6),
        tau = runif(n=I, min=-6, max=6)
      )
    }

    if(empiricalMethod == "empiricalAlpha"){
      ModelData$alpha = min(lambda) - .25 # assigning α
      inits$lambda = runif(n=I, min=ModelData$alpha, max=6)
    }

  })
  return(as.list(env))
}
