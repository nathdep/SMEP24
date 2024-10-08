library(SMEP24)

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
