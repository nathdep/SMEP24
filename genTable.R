library(SMEP24)

dirs <- as.list(paste0("D:\\SMEP_0\\", c("Reduc_Control", "Reduc_Tested"), "\\"))

files <- lapply(dirs, function(x) {
  setwd(x)
  list.files(pattern="\\.csv")
})

dfs <- vector(mode="list", length=2)

for(i in 1:2){
  setwd(dirs[[i]])
  dfs[[i]] <- bind_rows(lapply(files[[i]], function(x) fread(x, data.table=FALSE)))
}

dfFile <- lapply(dfs, function(x) strsplit(x$File, split="_"))
extraCols <- as.data.frame(t(do.call(cbind, dfFile[[1]])))
extraCols <- extraCols[,3:ncol(extraCols)]
colnames(extraCols) <- c("model","empir", "start", "sample", "seed", "taskNo")

compiled <- as.data.frame(cbind(bind_rows(dfs), bind_rows(extraCols)))

compiled[which(compiled$empir == "NA"),14] <- NA

tmp <- tempFile(fileext = ".parquet")
write_parquet(compiled, tmp)
