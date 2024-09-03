getStdSumScore <- function(resps){
  num <- rowSums(resps, na.rm=TRUE) - mean(rowSums(resps, na.rm=TRUE))
  denom <- sd(rowSums(resps, na.rm=TRUE))
  return(num/denom)
}
