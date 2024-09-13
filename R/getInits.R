#' Get Parameter Values for Initializing NUTS
#' @param modsum  object generated from `$summary()` method on a `cmdstanr` model environment
#' @returns a named list object containing \emph{expected a prior} from ADVI-approximated posterior draws
getInits <- function(modsum){
  vars <- modsum$variable
  dropind <- sub("\\[.*\\]", "", vars)
  inits <- list()
  for(i in 1:length(dropind)){
    inits[[dropind[i]]] <- c(inits[[dropind[i]]], modsum$mean[i])
  }
  return(inits)
}
