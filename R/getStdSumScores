getStdSumScore <- function(resps){
  if(length(dim(resps)) == 2){
    res <- (rowSums(resps) - mean(rowSums(resps)))/sd(rowSums(resps))
    return(res)
  }
  if(length(dim(resps)) > 2){
    res <- array(data=NA, dim=c(length(dim(resps)), nrow(resps[,,1])))
    for(dim in 1:length(dim(resps))){
      current <- resps[,,1]
      res[dim,] <- (rowSums(current) - mean(rowSums(current)))/sd(rowSums(current))
    }
    return(res)
  }
}
