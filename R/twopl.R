#' Generate a 2-Parameter Logistic (2PL) IRT Simulation Environment
#' @param ... objects inherited from parent
#' @returns an environment stored to a list object of the 2PL simulation environment
#' @export
twopl <- function(...){

  env <- new.env(parent=.GlobalEnv)

  with(env, {

    method=method
    P=P
    I=I

    model="twopl"

    set.seed(seed)
    # SIMULATION OF DISCRIMINATION PARAMETERS
    lambda <- runif(n=I, min=0, max=3)

    if(method != "base"){
      lambda <- makeNeg(lambda, numNeg=floor(I/4)) # if selected model is not "base", negate I/4 (rounded down) lambdas at random
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
    modstan <- cmdstan_model(stan_file=paste0(getwd(), "/Stan/twopl_", method, ".stan"))

    ModelData <- list(
      P=nrow(Y),
      I=ncol(Y),
      Y=Y,
      coefHyper=coefHyper,
      sdHyper=sdHyper
    )

    if(method == "alpha"){
      ModelData$alpha = min(lambda) - 1 # assigning α using min(lambda) - 1
    }

  })
  return(as.list(env))
}
