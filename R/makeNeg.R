makeNeg <- function(lambda, numNeg=2){
  newLambda <- lambda
  if(!all(lambda > 0)){
    stop("Ensure that all lambda values are > 0.")
  }
  negInd <- sample(x=c(1:length(lambda)), size=2)
  newLambda[negInd] <- -lambda[negInd]
  return(newLambda)
}
