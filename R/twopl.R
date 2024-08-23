twopl <- function(..., P, I, method, seed=NULL){
  env <- new.env()
  with(env, {

    if(is.null(seed)){
      seed <- sample(x=c(1:1e6), size=1)
    }

    if("alpha" %in% method){
      alpha=alpha
    }

    set.seed(seed)
    # SIMULATION OF DISCRIMINATION PARAMETERS
    lambda <- runif(n=I, min=-3, max=3)
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
    modstan <- cmdstan_model(stan_file=paste0(getwd(), "/Stan/twopl_", method, ".stan"))
    modelData <- mget(x=ls(envir=env))
  })
  return(as.list(env))
}
