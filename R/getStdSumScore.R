#' Calculate Standardized Sum Scores
#' @param resps matrix of dichotomized (0/1) item response data
#' @returns a vector of standardized sum scores of the measured latent trait
#' @export
getStdSumScore <- function(resps){
  num <- rowSums(resps, na.rm=TRUE) - mean(rowSums(resps, na.rm=TRUE))
  denom <- sd(rowSums(resps, na.rm=TRUE))
  return(num/denom)
}
