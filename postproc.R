library(SMEP24)
library(tidyverse)

files <- list.files(path="/root/Findings/", pattern=".csv$")

f <- gsub(pattern=".*__(.*)__.*", replacement="\\1", x=files)

gatheredInfo <- lapply(strsplit(x=f, split="_"), function(x)sub(pattern=".csv",replacement="",x=x))
prefix <- lapply(files, function(x)sub(pattern="(.*?)__.*", replacement="\\1",x=x))

catList <- vector(length=length(f), mode="list")

for(i in 1:length(f)){
  catList[[i]]$Info <- as.data.frame(rbind(c(prefix[[i]], gatheredInfo[[i]])))
  if(!any(c("lambda", "tau", "theta") %in% gatheredInfo[[i]][length(gatheredInfo[[i]])])){
    colnames(catList[[i]]$Info) <- c("type","model", "empiricalMethod", "startingMethod", "sampleSize", "seed", "taskNo")
  }
  if(any(c("lambda", "tau", "theta") %in% gatheredInfo[[i]][length(gatheredInfo[[i]])])){
    colnames(catList[[i]]$Info) <-  c("type","model", "empiricalMethod", "startingMethod", "sampleSize", "seed", "taskNo", gatheredInfo[[i]][length(gatheredInfo[[i]])])
  }
  current_csv <- read_csv(paste0("/root/Findings/", files[i]))
  catList[[i]]$Modsum <- current_csv
}

saveRDS(catList, file="catList.RDS")

dfNames <- as.vector(unlist(unique(lapply(catList, function(x)x$Info[1]))))
lapply(dfNames, function(x)assign(x, new.env(), envir=.GlobalEnv))
dfByName <- vector(length=length(dfNames), mode="list")

namesLong <- as.vector(unlist(lapply(catList, function(x)x$Info[1])))
typeInds <- sapply(dfNames, function(x)which(namesLong == x))

for(i in 1:length(dfNames)){
  selCatList <- catList[typeInds[[dfNames[i]]]]
  selInfos <- lapply(selCatList, function(x)x$Info)
  assign("Infos", selInfos, envir=get(dfNames[i], envir=.GlobalEnv))
  selModsums <- lapply(selCatList, function(x)x$Modsum)
  assign("Modsums", selModsums, envir=get(dfNames[i], envir=.GlobalEnv))
}

splitLists <- lapply(mget(dfNames, envir=.GlobalEnv), as.list)

saveRDS(splitLists, file="ResultsByType.RDS")
