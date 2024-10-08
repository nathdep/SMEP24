#' Generate a Bifactor Simulation Environment
#' @param ... objects inherited from parent
#' @returns an environment stored to a list object of the bifactor simulation environment
#' @export

bifactor <- function(...){

  env <- new.env(parent=.GlobalEnv)
  with(env, {

    seed=seed
    set.seed(seed)
    P=P
    I=I
    coefHyper=coefHyper
    sdHyper=sdHyper
    # SIMULATION OF ITEM INTERCEPTS
    tau <- runif(n=I, min=-3, max=3)
    # SIMULATION OF DISCRIMINATION PARAMETERS
    lambda_G <- runif(n=I, min=0, max=3) # loadings on general factor
    lambda_g12 <- runif(n=I, min=0, max=3) # loadings on specific factors (g1/g2)

    if(startingMethod != "CONTROL" & startingMethod != "ALLPOS"){
      lambda_g12 <- makeNeg(runif(n=I, min=0, max=3), numNeg=numNeg) # negate sub-factor (g) lambdas at random
      modstan <- cmdstan_model(stan_file=file.path(paste0(getwd(),"/Stan/bifactor_", empiricalMethod, ".stan")))
    }

    if(startingMethod == "CONTROL"){
      lambda_g12 <- makeNeg(runif(n=I, min=0, max=3), numNeg=numNeg) # negate sub-factor (g) lambdas at random
      modstan <- cmdstan_model(stan_file=file.path(paste0(getwd(), "/Stan/bifactor_CONTROL.stan")))
    }

    if(startingMethod == "ALLPOS"){
      modstan <- cmdstan_model(stan_file=file.path(paste0(getwd(), "/Stan/bifactor_ALLPOS.stan")))
    }

    lambdaMat <- matrix(data=NA, nrow=I, ncol=3)
    lambdaMat[,1] <- lambda_G
    for(dim in 1:2){
      lambdaMat[,dim+1] <- lambda_g12
    }
    # SIMULATION OF LATENT TRAIT MEASUREMENTS
    theta_G <- rnorm(n=P, mean=0, sd=1) # Latent trait measurements of general factor
    theta_g1 <- rnorm(n=P, mean=0, sd=1) # Latent trait measurements of g1
    theta_g2 <- rnorm(n=P, mean=0, sd=1) # Latent trait measurements of g2
    theta <- cbind(theta_G, theta_g1, theta_g2)
    # GENERATING Q MATRIX
    QmatLong <- sample(x=c(1:2), size=I, replace=TRUE) # Indices of dimension loading by item
    Qmat <- cbind(rep(1,I),model.matrix(data=data.frame(x=as.factor(QmatLong)), ~-1+x)) # Q matrix of item loadings (specific factors only) and adding intercept/general factor column
    lambdaQ <- Qmat*lambdaMat
    # GENERATING DICHOTOMIZED ITEM RESPONSE DATA
    Y <- matrix(data=NA, nrow=P, ncol=I) # storing dichotomized item responses
    logits <- theta%*%t(lambdaQ) + outer(rep(1,P), tau) # outer function replicates tau to be added column-wise (equivalent to adding easiness/intercept for each item)
    for(i in 1:I){
      for(p in 1:P){
        Y[p,i] <- rbinom(n=1, size=1, prob=plogis(logits[p,i]))
      }
    }

    ModelData <- list(
      P=nrow(Y),
      I=ncol(Y),
      Y=Y,
      nDim=3,
      Qmat=Qmat,
      coefHyper=coefHyper,
      lambdaMeanHyper=lambdaMeanHyper,
      tauMeanHyper=tauMeanHyper,
      sdHyper=sdHyper,
      true_theta=theta,
      true_lambda=lambdaMat,
      true_tau=tau
    )

    if(startingMethod == "advi"){
      ModelData$alpha = min(lambda_g12) - .25 # assigning α
      ModelData$QmatInd = max.col(Qmat[,2:3]) # creating integer indices for mean of sub-factor loadings

      StdSumScore <- array(data=NA, dim=c(P,3))

      StdSumScore[,1] <- getStdSumScore(Y)

      for(i in 1:2){
        StdSumScore[,i+1] <- getStdSumScore(Y[,which(QmatLong == i)])
      }

      ModelData$StdSumScore = StdSumScore

      advistan <- cmdstan_model(stan_file=paste0(getwd(), "/Stan/bifactor_advi.stan"))

      advirun <- modstan$variational(  # Run variational inference via ADVI
        data=ModelData,
        seed=seed
      )

      advisum <- advirun$summary() # Calculate descriptive stats using draws from approximated posteriors

      inits <- getInits(advisum) # Create a list of initial values using EAP extracted from advisum (to pass to NUTS in next step)

      initDims <- lapply(names(inits), function(name)getDims(name=name, envir=parent.env(environment()))) # get dimensions for parameter matrices from global environment (i.e., theta in bifactor model)

      for(i in 1:length(initDims)){ # reshape initial values to account for matrix dimensions in previous step (if applicable)
        if(!is.null(initDims[[i]])){
          dim(inits[[i]]) <- initDims[[i]]
        }
      }

      inits$theta <- array(data=runif(n=P*3, min=-6, max=6), dim=c(P,3))
    }

    if(startingMethod == "allRand" | startingMethod == "CONTROL"){
      inits <- list(
        theta = array(data=runif(n=P*3, min=-6, max=6), dim=c(P,3)),
        lambdag_12=runif(n=I, min=.75, max=6),
        lambdaG=runif(n=I, min=.75, max=6),
        tau=runif(n=I, min=-6, max=6)
      )
    }

    if(startingMethod == "ALLPOS"){
      inits <- list(
        theta = array(data=runif(n=P*3, min=-6, max=6), dim=c(P,3)),
        lambdaG = runif(n=I, min=0, max=3),
        lambdag_12=runif(n=I, min=0, max=3),
        tau =runif(n=I, min=-6, max=6)
      )
    }

    if(startingMethod == "StdSumScore"){
      StdSumScore <- array(data=NA, dim=c(P,3))

      StdSumScore[,1] <- getStdSumScore(Y)

      for(i in 1:2){
        StdSumScore[,i+1] <- getStdSumScore(Y[,which(QmatLong == i)])
      }

      inits <- list(
        theta = StdSumScore,
        lambdag_12=runif(n=I, min=-6, max=6),
        lambdaG=runif(n=I, min=.75, max=3),
        tau=runif(n=I, min=-6, max=6)
      )
    }

    if(empiricalMethod == "empiricalPos"){
      ModelData$QmatInd = max.col(Qmat[,2:3]) # creating integer indices for mean of sub-factor loadings
    }

    if(empiricalMethod == "empiricalAlpha"){
      ModelData$alpha = min(lambda_g12) - .25 # assigning α
      inits$lambdag_12 = runif(n=I, min=ModelData$alpha, max=6)
    }

  })
  return(as.list(env))
}
