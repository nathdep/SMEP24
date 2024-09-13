#' Find Dimensions of Filtered \code{.GlobalEnv} Object
#' @param name name of target object
#' @param envir name of target environment
#' @returns integer of object's total dimensions
#' @export
getDims <- function(name, envir){
  if(any(grepl(name, ls(envir=envir)))){
    return(dim(get(name, envir = envir)))
  }
}
