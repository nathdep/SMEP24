#' Negative Lambda Indicator Function
#' @param lambda inputted item discrimination/slope values
#' @param numNeg integer indicating quantity of lambda values to negate
#' @returns a vector of all lambda values (including negated lambdas)
#' @export
makeNeg <- function(lambda, numNeg=2){
  newLambda <- lambda
  if(!all(lambda > 0)){
    stop("Ensure that all lambda values are > 0.")
  }
  negInd <- sample(x=c(1:length(lambda)), size=numNeg)
  newLambda[negInd] <- -lambda[negInd]
  return(newLambda)
}
