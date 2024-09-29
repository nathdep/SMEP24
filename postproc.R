library(SMEP24)

CONTROL=FALSE
args <- as.numeric(commandArgs(trailingOnly=TRUE))

Reduc_Modsum <- readRDS("Reduc_Modsum.RDS")[[1]]

models <- c("twopl", "bifactor")
examineeSizes <- c(500, 2000)
paramNames <- c("theta", "lambda", "tau")

if(CONTROL){
  whichDir = "Reduc_Control/"
  control_starting_methods=c("ALLPOS", "CONTROL")
  control_empirical_methods="NA"
  combo_matrix <- expand.grid(model=models, empiricalMethod=control_empirical_methods, startingMethod=control_starting_methods, sampleSize=examineeSizes)
}

if(!CONTROL){
  whichDir = "Reduc_Tested/"
  tested_empirical_methods <-  c("empiricalPos", "empiricalAlpha")
  tested_starting_methods <- c("advi", "allRand", "StdSumScore")
  combo_matrix <- expand.grid(model=models, empiricalMethod=tested_empirical_methods, startingMethod=tested_starting_methods, sampleSize=examineeSizes)
}

selRow <-as.vector(as.matrix(methodSelect(base10=args[2], methodsMatrix=combo_matrix)))

filteredInds <- which(sapply(Reduc_Modsum$Infos, function(x) all(selRow %in% x)))

filteredModsumsFull <- lapply(Reduc_Modsum$Modsums[filteredInds], function(x)x$df)
filteredInfosFull <- lapply(Reduc_Modsum$Infos[filteredInds], function(x) paste0(x, collapse="_"))

paramInds <- vector(length=length(paramNames), mode="list")
names(paramInds) <- paramNames

filteredModsums <- vector(length=length(paramNames), mode="list")
names(filteredModsums) <- paramNames

filteredInfos <- vector(length=length(paramNames), mode="list")
names(filteredInfos) <- paramNames

bound <- vector(length=length(paramNames), mode="list")
names(bound) <- paramNames

numParams <- vector(length=length(paramNames), mode="list")
names(numParams) <- paramNames

for(j in 1:length(paramNames)){
  for(i in 1:length(filteredInds)){
    if(Reduc_Modsum$Modsums[[filteredInds[i]]]$reduc == paramNames[j]){
      paramInds[[paramNames[j]]] <- c(paramInds[[paramNames[j]]], i)
    }
  }
}

for(j in 1:length(paramNames)){
  filteredModsums[[paramNames[j]]] <- filteredModsumsFull[paramInds[[paramNames[j]]]]
  numParams[[paramNames[j]]] <- nrow(filteredModsums[[paramNames[j]]][[1]])
  filteredInfos[[paramNames[j]]] <- filteredInfosFull[paramInds[[paramNames[j]]]]
  bound[[paramNames[j]]] <- bind_rows(filteredModsums[[paramNames[j]]])
  bound[[paramNames[j]]] <- bound[[paramNames[j]]][,-which(colnames(bound[[paramNames[j]]]) == "V1")]
  bound[[paramNames[j]]]$File <- rep(as.vector(unlist(filteredInfos[[paramNames[j]]])), each=numParams[[paramNames[j]]])
  write.csv(bound[[paramNames[j]]], paste0(whichDir, paste0(selRow, collapse="_"), "_",paramNames[j],".csv"), row.names=FALSE)
}

paramLengths <- lapply(filteredModsums, length)

cat("\nPARAM LENGTHS\n")
print(paramLengths)
cat("\n")

saveRDS(filteredModsums, file=paste0(whichDir, paste0(selRow, collapse="_"), "_", "filteredModsums.RDS"))

