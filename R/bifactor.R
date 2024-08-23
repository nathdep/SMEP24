bifactor <- function(..., P, I, method, nDim=3, seed=NULL, coefHyper=5, sdHyper=.1){
  env <- new.env()
  with(env, {

    if(is.null(seed)){
      seed <- sample(x=c(1:1e6), size=1)
    }

    if("Alpha" %in% method){
      alpha=alpha
    }

    set.seed(seed)
    method=method
    P=P
    I=I
    nDim=nDim
    coefHyper=coefHyper
    sdHyper=sdHyper
    # SIMULATION OF ITEM INTERCEPTS
    tau <- runif(n=I, min=-3, max=3)
    # SIMULATION OF DISCRIMINATION PARAMETERS
    lambda_G <- runif(n=I, min=-3, max=3) # loadings on general factor
    lambda_g12 <- cbind(runif(n=I, min=-3, max=3)) # loadings on dimensions/sub-factors
    lambdaMat <- matrix(data=NA, nrow=I, ncol=nDim)
    lambdaMat[,1] <- lambda_G
    for(dim in 1:(nDim-1)){
      lambdaMat[,dim+1] <- lambda_g12
    }
    # SIMULATION OF LATENT TRAIT MEASUREMENTS
    theta_G <- rnorm(n=P, mean=0, sd=1) # Latent trait measurements of general factor
    theta_g1 <- rnorm(n=P, mean=0, sd=1) # Latent trait measurements of g1
    theta_g2 <- rnorm(n=P, mean=0, sd=1) # Latent trait measurements of g2
    thetaMat <- cbind(theta_G, theta_g1, theta_g2)
    # GENERATING Q MATRIX
    QmatLong <- sample(x=c(1:2), size=I, replace=TRUE) # Indices of dimension loading by item
    Qmat <- cbind(rep(1, I), model.matrix(data=data.frame(x=as.factor(QmatLong)), ~-1+x)) # Q matrix of item loadings (first column is general factor)
    lambdaQ <- Qmat*lambdaMat
    # GENERATING DICHOTOMIZED ITEM RESPONSE DATA
    Y <- matrix(data=NA, nrow=P, ncol=I) # storing dichotomized item responses
    logits <- matrix(data=NA, nrow=P, ncol=I)
    for(i in 1:I){
      logits[,i] <- thetaMat%*%lambdaQ[i,] + tau[i]
      for(p in 1:P){
        Y[p,i] <- rbinom(n=1, size=1, prob=plogis(logits[p,i]))
      }
    }
    ModelData <- mget(x=ls(envir=env))
    modstan <- cmdstan_model(stan_file=paste0(getwd(), "/Stan/bifactor_", method, ".stan"))
  })
  return(as.list(env))
}
