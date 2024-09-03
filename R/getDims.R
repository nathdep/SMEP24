getDims <- function(name){
  if(any(grepl(name, ls(envir=.GlobalEnv)))){
    return(dim(get(name, envir = .GlobalEnv)))
  }
}
