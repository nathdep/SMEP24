library(SMEP24)
library(tidyverse)

setwd("Findings")

f <- gsub(".*__(.*)__.*", "\\1", list.files(pattern=".csv$"))

gatheredInfo <- lapply(strsplit(x=f, split="_"), function(x)sub(".csv","",x))

catNamesLong <- unlist(lapply(gatheredInfo, function(x) x[[1]]))
catNames <- unique(catNamesLong)

catCounts <- vector(length=length(catNames), mode="numeric")

for(i in 1:length(catNames)){
  for(j in 1:length(f)){
    catCounts[i] <- catCounts[i] + ifelse(grepl(catNames[i], f[j]), 1, 0)
  }
}

catCounts <- as.list(catCounts)
names(catCounts) <- catNames
saveRDS(catCounts, file="catCounts.RDS")

catList <- vector(length=length(catNamesLong), mode="list")

for(i in 1:length(catNamesLong)){
  catList[[i]]$Info <- as.data.frame(rbind(gatheredInfo[[i]][c(1,3:length(gatheredInfo[[i]]))]))
  colnames(catList[[i]]$Info) <- c("type","model", "empiricalMethod", "startingMethod", "sampleSize", "seed", "taskNo")
  current_csv <- read_csv(f[i])
  catList[[i]]$modsum <- current_csv
}

saveRDS(catList, file="catList.RDS")



