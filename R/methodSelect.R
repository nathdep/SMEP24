#' Method Selector by Modulo
#' @param base10 number in base-10 (decimal) representation
#' @param methodsMatrix matrix containing all combinations of tested methods conditions
#' @returns A selected row (after converting from base-10/decimal representation) of the methods matrix that describes the tested conditions
#' @export

methodSelect <- function(base10, methodsMatrix){
  nRow <- nrow(methodsMatrix)
  selectedInt <- ((base10 + nRow) %% nRow) + 1
  return(methodsMatrix[selectedInt,])
}
