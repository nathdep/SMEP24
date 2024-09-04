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
