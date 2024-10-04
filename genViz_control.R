library(SMEP24)
library(Cairo)

Palette <- c("black", "#FFCD00")
sampleSize=500
model <- "twopl"
custLabsControl <- c(ALLPOS="All Positive True/Inits", CONTROL = "Random True/Inits")
PDF=FALSE
PNG=TRUE

if(model == "bifactor"){
  whichModel = "Bifactor"
}

if(model == "twopl"){
  whichModel = "2PL"
}

whichParam <- "lambda"

if(!("df" %in% ls(envir=.GlobalEnv))){
  df <- read_parquet("C:\\Users\\nathd\\Downloads\\SMEP24\\fullComp.parquet")
}

selected <- df[grepl(paste0("^",whichParam), df$variable),]
selected <- selected[which(selected$sample == sampleSize),]
selected <- selected[grepl(model, selected$model),]
control <- selected[which(is.na(selected$empir)),]

p.count <- ggplot(data=control, aes(x=isThresh))+
  geom_bar(aes(fill=start),color="black", position="dodge")+
  scale_fill_manual(values=Palette, labels=custLabsControl)+
  xlab(expression(hat(R)[lambda]))+
  ylab("Count")+
  labs(title = paste0(whichModel, " \u03bb Convergence Counts: ", sampleSize, " Examinees (No Emp. Methods)"))+
  theme_apa(legend.pos="bottom")

p.point <- ggplot(data=control, aes(x=true, y=mean))+
  geom_point(alpha=.25)+
  stat_function(fun=function(x)x, aes(color="Correct Mode"))+
  stat_function(fun=function(x)-x, aes(color="Switched Mode"))+
  facet_wrap(~start, labeller=as_labeller(custLabsControl))+
  xlab(expression(True[lambda]))+
  ylab(expression(EAP[lambda]))+
  xlim(-3,3)+
  ylim(-6,6)+
  labs(title=paste0(whichModel, " Recovery: EAP \u03bb vs. True \u03bb, ", sampleSize, " Examinees (No Emp. Methods)"))+
  scale_color_manual(values=c("green", "red"))+
  theme_apa(legend.pos="bottom")

if(PDF){
  CairoPDF(file=paste0(model, "_", sampleSize, "_CONTROL.pdf"), height=8, width=11)
  print(p.count_control)
  print(p.point_control)
  dev.off()
}

if(PNG){
  ggsave(filename=paste0(model, "_", sampleSize, "_count_CONTROL.png"), plot=p.count, height=8, width=8)
  ggsave(filename=paste0(model, "_", sampleSize, "_point_CONTROL.png"), plot=p.point, height=8, width=8)
}
