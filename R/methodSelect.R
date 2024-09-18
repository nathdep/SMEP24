#' Method Selector by Modulo
#' @param base10 number in base-10 (decimal) representation
#' @param methodsMatrix matrix containing all combinations of tested methods conditions
#' @returns A selected row (after converting from base-10/decimal representation) of the methods matrix that describes the tested conditions
#' @export

methodSelect <- function(base10, methodsMatrix){
  k_wrapped <- ((base10-1) %% (nrow(methodsMatrix)*ncol(methodsMatrix))) + 1
  i <- floor((k_wrapped - 1)/ncol(methodsMatrix)) + 1
  j <- ((k_wrapped-1) %% ncol(methodsMatrix)) + 1
  return(c(i,j))
}
