#' Find Dimensions of Filtered \code{.GlobalEnv} Object
#' @param name name of target object
#' @returns integer of object's total dimensions
#' @export
getDims <- function(name){
  if(any(grepl(name, ls(envir=.GlobalEnv)))){
    return(dim(get(name, envir = .GlobalEnv)))
  }
}
