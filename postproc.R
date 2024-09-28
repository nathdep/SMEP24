library(SMEP24)

CONTROL=FALSE
args <- as.numeric(commandArgs(trailingOnly=TRUE))

files <- list.files(path="/root/Findings/", pattern=".csv$")
csvFiles <- lapply(files, function(x)fread(file=paste0("/root/Findings/", x), data.table=FALSE))

f <- gsub(pattern=".*__(.*)__.*", replacement="\\1", x=files)

gatheredInfo <- lapply(strsplit(x=f, split="_"), function(x)sub(pattern=".csv",replacement="",x=x))
prefix <- lapply(files, function(x)sub(pattern="(.*?)__.*", replacement="\\1",x=x))
suffix <- lapply(files, function(x)sub(pattern=".*__(.*?).csv$", replacement="\\1", x=x))

catList <- vector(length=length(f), mode="list")

for(i in 1:length(f)){
  catList[[i]]$Info <- as.data.frame(rbind(c(prefix[[i]], gatheredInfo[[i]])))
  colnames(catList[[i]]$Info) <- c("type","model", "empiricalMethod", "startingMethod", "sampleSize", "seed", "taskNo")
  if(any(c("lambda", "tau", "theta") %in% suffix[[i]])){
    catList[[i]]$Modsum <- list(reduc=suffix[[i]], df=csvFiles[[i]])
  }
  else{
    catList[[i]]$Modsum <- csvFiles[[i]]
  }
}

saveRDS(catList, file="catList.RDS")

dfNames <- as.vector(unlist(unique(lapply(catList, function(x)x$Info[1]))))
lapply(dfNames, function(x)assign(x, new.env(), envir=.GlobalEnv))

namesLong <- as.vector(unlist(lapply(catList, function(x)x$Info[1])))
typeInds <- sapply(dfNames, function(x)which(namesLong == x))

for(i in 1:length(dfNames)){
  selCatList <- catList[typeInds[[dfNames[i]]]]
  selInfos <- lapply(selCatList, function(x)x$Info)
  selModsums <- lapply(selCatList, function(x)x$Modsum)
  assign("Infos", selInfos, envir=get(dfNames[i], envir=.GlobalEnv))
  assign("Modsums", selModsums, envir=get(dfNames[i], envir=.GlobalEnv))
}

splitLists <- lapply(mget(dfNames, envir=.GlobalEnv), as.list)

saveRDS(splitLists, file="ResultsByTypeFull.RDS")

for(i in 1:length(splitLists)){
  saveRDS(splitLists[i], file=paste0(dfNames[i], ".RDS"))
}

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

saveRDS(filteredModsumsFull, file="filteredModsumsFull.RDS")

