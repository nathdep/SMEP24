library(SMEP24)

Palette <- c("#FF8200", "#8134DF", "#bd472a", "#00664f", "#63666a", "#00558c")
sampleSize=500
model <- "twopl"
PDF=FALSE
PNG=TRUE
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

whichParam <- "lambda"

if(!("df" %in% ls(envir=.GlobalEnv))){
  df <- read_parquet("D:\\SMEP_0\\fullComp.parquet")
}

selected <- df[grepl(paste0("^",whichParam), df$variable),]
selected <- selected[which(selected$sample == sampleSize),]
selected <- selected[grepl(model, selected$model),]
tested <- selected[which(!is.na(selected$empir)),]

starting <- tested$start
emp <- tested$empir
combo <- paste0(starting, "_", emp)
tested$combo <- combo

p.count <- ggplot(data=tested, aes(x=isThresh))+
  geom_bar(aes(fill=combo),color="black", position="dodge")+
  scale_fill_manual(values=Palette, labels=custLabsTested)+
  xlab(expression(hat(R)[lambda]))+
  ylab("Count")+
  labs(title = paste0(whichModel, " \u03bb Convergence Counts: ", sampleSize, " Examinees"))+
  guides(fill=guide_legend(title="Init./Emp."))+
  theme_apa(legend.pos="right", legend.use.title = TRUE)


p.point <- ggplot(data=tested, aes(x=true, y=mean))+
  geom_point(alpha=.25)+
  stat_function(fun=function(x)x, aes(color="EAP / True = 1"))+
  stat_function(fun=function(x)-x, aes(color="EAP / True = -1"))+
  facet_wrap(~combo, labeller=as_labeller(custLabsTested))+
  xlab(expression(True[lambda]))+
  ylab(expression(EAP[lambda]))+
  xlim(-3,3)+
  ylim(-6,6)+
  labs(title=paste0(whichModel, " Recovery: EAP \u03bb vs. True \u03bb, ", sampleSize, " Examinees (Init./Emp.)"))+
  scale_color_manual(values=c("red", "green"))+
  theme_apa(legend.pos="bottom")

if(PDF){
  CairoPDF(file=paste0(model, "_", sampleSize, "_TESTED.pdf"), height=8, width=11)
  print(p.count_control)
  print(p.point_control)
  dev.off()
}

if(PNG){
  ggsave(filename=paste0(model, "_", sampleSize, "_count_TESTED.png"), plot=p.count, height=8, width=8)
  ggsave(filename=paste0(model, "_", sampleSize, "_point_TESTED.png"), plot=p.point, height=8, width=8)
}
