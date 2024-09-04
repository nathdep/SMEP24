#' Rhat Convergence Indicator Function
#' @param modsum  object generated from `$summary()` method on a `cmdstanr` model environment
#' @param rHatThreshold maximum tolerance for indicated convergence based on Rhat values
#' @returns count of Rhat > threshold
#' @export
countRhat <- function(modsum, rHatThreshold=1.05){
  rHats <- modsum$rhat
  counter <- 0
  for(i in seq_along(rHats)){
    if(rHats[i] >= rHatThreshold){
      counter <- counter+1
    }
  }
  return(counter)
}
