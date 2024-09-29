library(SMEP24)

CONTROL=FALSE
args <- as.numeric(commandArgs(trailingOnly=TRUE))

Reduc_Modsum <- readRDS("Reduc_Modsum.RDS")[[1]]

models <- c("twopl", "bifactor")
examineeSizes <- c(500, 2000)
paramNames <- c("theta", "lambda", "tau")

if(CONTROL){
  control_starting_methods=c("ALLPOS", "CONTROL")
  control_empirical_methods="NA"
  combo_matrix <- expand.grid(model=models, empiricalMethod=control_empirical_methods, startingMethod=control_starting_methods, sampleSize=examineeSizes)
}

if(!CONTROL){
  tested_empirical_methods <-  c("empiricalPos", "empiricalAlpha")
  tested_starting_methods <- c("advi", "allRand", "StdSumScore")
  combo_matrix <- expand.grid(model=models, empiricalMethod=tested_empirical_methods, startingMethod=tested_starting_methods, sampleSize=examineeSizes)
}

selRow <-as.vector(as.matrix(methodSelect(base10=args[2], methodsMatrix=combo_matrix)))

filteredInds <- which(sapply(Reduc_Modsum$Infos, function(x) all(selRow %in% x)))
filteredModsumsFull <- lapply(Reduc_Modsum$Modsums[filteredInds], function(x)x$df)

paramInds <- vector(length=length(paramNames), mode="list")
names(paramInds) <- paramNames

filteredModsums <- vector(length=length(paramNames), mode="list")
names(filteredModsums) <- paramNames

for(j in 1:length(paramNames)){
  for(i in 1:length(filteredInds)){
    if(Reduc_Modsum$Modsums[[filteredInds[i]]]$reduc == paramNames[j]){
      paramInds[[paramNames[j]]] <- c(paramInds[[paramNames[j]]], i)
    }
  }
}

for(j in 1:length(paramNames)){
  filteredModsums[[paramNames[j]]] <- filteredModsumsFull[paramInds[[paramNames[j]]]]
  write.csv(bind_rows(filteredModsums[[paramNames[j]]])[,2:ncol(bind_rows(filteredModsums[[paramNames[j]]]))], paste0(paste0(selRow, collapse="_"), "_",paramNames[j],".csv"), row.names=FALSE)
}

paramLengths <- lapply(filteredModsums, length)

saveRDS(filteredModsumsFull, file=paste0(paste0(selRow, collapse="_"), "_", "filteredModsumsFull.RDS"))

