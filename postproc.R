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

typeLong <- unlist(lapply(catList, function(x) x$Info[1]))
type <- unique(typeLong)

for(i in 1:length(type)){
  assign(type[i], list(), envir=.GlobalEnv)
}

for(i in 1:length(typeLong)){
  addedObj <- catList[[i]]$Info[-1]
  assign(x=typeLong[i], rbind(get(typeLong[i], envir=.GlobalEnv), addedObj), envir=.GlobalEnv)
}

for(i in 1:length(type)){
  write.csv(get(type[i], envir=.GlobalEnv), paste0(type[i], ".csv"))
}

