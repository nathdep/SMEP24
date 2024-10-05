library(SMEP24)

Palette <- c("#FF8200", "#8134DF", "#bd472a", "#00664f", "#63666a", "#00558c")
sampleSize=500
model <- "twopl"
PDF=TRUE
PNG=TRUE
whichParam="lambda"

if(whichParam == "lambda"){
  whichSymbol <- "\u03bb"
}

if(whichParam == "theta"){
  whichSymbol <- "\u03b8"
}

if(whichParam == "tau"){
  whichSymbol <- "\u03c4"
}

custLabsTested <- c(advi_empiricalAlpha="ADVI / \u03b1",
                    advi_empiricalPos="ADVI / +\u03bc",
                    allRand_empiricalAlpha="Random / \u03b1",
                    allRand_empiricalPos="Random / +\u03bc",
                    StdSumScore_empiricalAlpha="Std. Sum Score / \u03b1",
                    StdSumScore_empiricalPos="Std. Sum Score / +\u03bc"
)

if(model == "bifactor"){
  whichModel = "Bifactor"
}

if(model == "twopl"){
  whichModel = "2PL"
}

if(model=="bifactor" & whichParam == "lambda"){
  whichParam="lambdag"
}

if(!("df" %in% ls(envir=.GlobalEnv))){
  df <- read_parquet("C:\\Users\\nathd\\Downloads\\SMEP24\\fullComp.parquet")
}

selected <- df[grepl(paste0("^",whichParam), df$variable),]
selected <- selected[which(selected$sample == sampleSize),]
selected <- selected[grepl(model, selected$model),]
tested <- selected[which(!is.na(selected$empir)),]

starting <- tested$start
emp <- tested$empir
combo <- paste0(starting, "_", emp)
tested$combo <- combo

diff <- selected$mean - selected$true
bias <- tapply(diff, selected$combo, mean)
rmse <- tapply(diff, selected$combo, function(x) sqrt(mean(x^2)))
rhat <- tapply(selected, selected$combo, function(x) countRhat(x))
dfPostProc <- cbind(bias, rmse, rhat)

for(i in 1:nrow(dfPostProc)){
  for(j in 1:length(custLabsTested)){
    if(row.names(dfPostProc)[i] == names(custLabsTested)[j]){
      row.names(dfPostProc)[i] <- custLabsTested[[j]]
    }
  }
}

colnames(dfPostProc) <- c("bias", "RMSE", "rhat")

write.csv(round(dfPostProc, digits=3), file=paste0("C:\\Users\\nathd\\Downloads\\SMEP24\\PostProcDFs\\", model, "_", whichParam, "_", sampleSize, "_PostProcDF.csv"), row.names=TRUE)

p.count <- ggplot(data=tested, aes(x=isThresh))+
  geom_bar(aes(fill=combo),color="black", position="dodge")+
  scale_fill_manual(values=Palette, labels=custLabsTested)+
  xlab(expression(hat(R)[lambda]))+
  ylab("Count")+
  labs(title = paste0(whichModel, " ",whichSymbol, " Convergence Counts: ", sampleSize, " Examinees"))+
  guides(fill=guide_legend(title="Init./Emp."))+
  theme_apa(legend.pos="right", legend.use.title = TRUE)


p.point <- ggplot(data=tested, aes(x=true, y=mean))+
  geom_point(alpha=.25)+
  stat_function(fun=function(x)x, aes(color="EAP / True = 1"))+
  stat_function(fun=function(x)-x, aes(color="EAP / True = -1"))+
  facet_wrap(~combo, labeller=as_labeller(custLabsTested))+
  xlab(expression(True[lambda]))+
  ylab(expression(EAP[lambda]))+
  labs(title=paste0(whichModel, " Recovery: EAP \u03bb vs. True \u03bb, ", sampleSize, " Examinees (Init./Emp.)"))+
  scale_color_manual(values=c("#FFCD00", "#e234fd"))+
  theme_apa(legend.pos="bottom")

if(whichParam == "theta" | whichParam == "tau"){
  p.point <- p.point +
    xlim(-6,6)+
    ylim(-6,6)
}

if(whichParam == "lambda" | whichParam == "lambdag"){
  p.point <- p.point +
    xlim(-3,3)+
    ylim(-6,6)
}

if(PDF){
  CairoPDF(file=paste0("C:\\Users\\nathd\\Downloads\\SMEP24\\Visualizations\\",model, "_", whichParam, "_", sampleSize, "_count_TESTED.pdf"), height=8, width=11)
  print(p.count)
  print(p.point)
  dev.off()
}

if(PNG){
  ggsave(filename=paste0("C:\\Users\\nathd\\Downloads\\SMEP24\\Visualizations\\",model, "_", whichParam, "_", sampleSize, "_count_TESTED.png"), plot=p.count, height=8, width=8)
  ggsave(filename=paste0("C:\\Users\\nathd\\Downloads\\SMEP24\\Visualizations\\",model, "_", whichParam, "_", sampleSize, "_point_TESTED.png"), plot=p.point, height=8, width=8)
}
