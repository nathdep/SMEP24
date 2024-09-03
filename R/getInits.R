getInits <- function(stansum){
  vars <- stansum$variable
  dropind <- sub("\\[.*\\]", "", stansum)
  inits <- list()
  for(i in 1:length(dropind)){
    inits[[dropind[i]]] <- c(inits[[dropind[i]]], stansum$mean[i])
  }
  return(inits)
}
