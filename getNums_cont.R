library(SMEP24)

setwd("o")

f <- list.files(pattern=".txt")
f <- f[grepl("CONTROL", f)]

readFiles <- lapply(f, readLines)
truthCheck <- vector(mode="logical", length=length(readFiles))

for(i in 1:length(readFiles)){
	truthCheck[i] <- any(sapply(readFiles[[i]], function(x) grepl("^<environment", x)))
}

inds <- which(truthCheck == FALSE)

fileNames <- f[inds]

repTaskNumbers <- sort(as.numeric(sub(".txt", "", sub("_", "", str_extract(fileNames, "_([0-9]{1,2})\\.txt$")))))

con <- file("task.txt", open="wt")

for(i in 1:length(repTaskNumbers)){
	cat(paste0(repTaskNumbers[i], "\n"), file = con)
}

close(con)
