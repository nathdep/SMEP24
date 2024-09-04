bifactor <- function(...){
  env <- new.env(parent=.GlobalEnv)
  with(env, {

    if(is.null(seed)){
      seed <- sample(x=c(1:1e6), size=1)
    }

    method=method
    model="bifactor"

    set.seed(seed)
    P=P
    I=I
    coefHyper=coefHyper
    sdHyper=sdHyper
    # SIMULATION OF ITEM INTERCEPTS
    tau <- runif(n=I, min=-3, max=3)
    # SIMULATION OF DISCRIMINATION PARAMETERS
    lambda_G <- runif(n=I, min=0, max=3) # loadings on general factor
    lambda_g12 <- cbind(runif(n=I, min=0, max=3)) # loadings on dimensions/sub-factors

    if(method != "base"){
      lambda_g12 <- makeNeg(lambda_g12, numNeg=2) # if selected model is not "base", negate given number of sub-factor lambdas at random
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
    QmatLong <- sample(x=c(1:3), size=I, replace=TRUE) # Indices of dimension loading by item
    Qmat <- model.matrix(data=data.frame(x=as.factor(QmatLong)), ~x) # Q matrix of item loadings (first column is general factor)
    lambdaQ <- Qmat*lambdaMat
    # GENERATING DICHOTOMIZED ITEM RESPONSE DATA
    Y <- matrix(data=NA, nrow=P, ncol=I) # storing dichotomized item responses
    logits <- matrix(data=NA, nrow=P, ncol=I)
    for(i in 1:I){
      logits[,i] <- theta%*%lambdaQ[i,] + tau[i]
      for(p in 1:P){
        Y[p,i] <- rbinom(n=1, size=1, prob=plogis(logits[p,i]))
      }
    }
    modstan <- cmdstan_model(stan_file=paste0(getwd(), "/Stan/bifactor_", method, ".stan"))

    ModelData <- list(
      P=nrow(Y),
      I=ncol(Y),
      Y=Y,
      nDim=3,
      Qmat=Qmat,
      coefHyper=5,
      sdHyper=.1
    )

    if(method == "advi"){
      basemod <- cmdstan_model(stan_file=paste0(getwd(), "/Stan/bifactor_base.stan"))
      StdSumScore <- array(data=NA, dim=c(P,3))
      for(i in 1:ncol(Qmat)){
        StdSumScore[,i] <- getStdSumScore(Y[,which(Qmat[,i] == 1)])
      }
      ModelData$StdSumScore = StdSumScore
    }

    if(method == "empiricalAlpha"){
      ModelData$alpha = min(lambda_g12) - 1 # assigning α using min(lambda_g12) - 1
      ModelData$QmatInd = rowSums(Qmat[,2:3]) + 1
    }

  })
  return(as.list(env))
}
