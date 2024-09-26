library(SMEP24)

setwd("~/Findings")

f <- list.files(pattern=".csv$")
gatheredInfo <- strsplit(x=f, split="_")

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

catList <- list()

for(i in 1:length(catNamesLong)){
  catList[[catNamesLong[i]]] <- c(catList[[catNamesLong[i]]], read_csv(f[i]))
}

saveRDS(catList, file="catList.RDS")
