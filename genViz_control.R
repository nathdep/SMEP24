library(SMEP24)
library(Cairo)

Palette <- c("black", "#FFCD00")
sampleSize=500
model <- "twopl"
custLabsControl <- c(ALLPOS="All Positive True/Inits", CONTROL = "Random True/Inits")
PDF=FALSE
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

if(model == "bifactor"){
  whichModel = "Bifactor"
}

if(model == "twopl"){
  whichModel = "2PL"
}

if(model=="bifactor" & whichParam=="lambda"){
  whichParam="lambdag"
}

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
  xlab(bquote(hat(R)[.(as.name(whichSymbol))])) +
  ylab("Count")+
  labs(title = paste0(whichModel, " ", whichSymbol, " Convergence Counts: ", sampleSize, " Examinees (No Emp. Methods)"))+
  theme_apa(legend.pos="bottom")

p.point <- ggplot(data=control, aes(x=true, y=mean))+
  geom_point(alpha=.25)+
  stat_function(fun=function(x)x, aes(color="EAP / True = 1"), linewidth=1.05)+
  stat_function(fun=function(x)-x, aes(color="EAP / True = -1"), linewidth=1.05)+
  facet_wrap(~start, labeller=as_labeller(custLabsControl))+
  xlab(bquote(True[.(as.name(whichSymbol))]))+
  ylab(bquote(EAP[.(as.name(whichSymbol))]))+
  scale_color_manual(values=c("#FFCD00", "#e234fd"))+
  theme_apa(legend.pos="bottom")

if(whichParam == "lambdag"){

  p.count <- p.count +
    xlab(bquote(R[.(as.name(whichSymbol))][g]))+
    labs(title = bquote(
      bold(.(whichModel)) ~
        bold(.(as.name(whichSymbol))[g]) ~
        bold("Convergence Counts:") ~
        bold(.(as.character(sampleSize))) ~
        bold("Examinees")
    ))


  p.point <- p.point +
    xlim(-3,3)+
    ylim(-6,6)+
    xlab(bquote(True[.(as.name(whichSymbol))][g]))+
    ylab(bquote(EAP[.(as.name(whichSymbol))][g]))+
    labs(title = bquote(bold(.(whichModel) ~ "Recovery: EAP" ~
                               .(as.name(whichSymbol))[italic(g)] ~ "vs. True" ~
                               .(as.name(whichSymbol))[italic(g)] * "," ~
                               bold(.(as.character(sampleSize))) ~
                               "Examinees (No Emp. Methods)")))

}

if(whichParam == "lambda"){

  p.point <- p.point +
    xlim(-3,3)+
    ylim(-6,6)+
    xlab(bquote(True[.(as.name(whichSymbol))]))+
    ylab(bquote(EAP[.(as.name(whichSymbol))]))+
    labs(title=paste0(whichModel, " Recovery: EAP ", whichSymbol, " vs. True ", whichSymbol, ", ", sampleSize, " Examinees (No Emp. Methods)"))


  p.count <- p.count +
    xlab(bquote(hat(R)[.(as.name(whichSymbol))]))+
    labs(title = paste0(whichModel, " ",whichSymbol, " Convergence Counts: ", sampleSize, " Examinees"))

}

if(whichParam == "theta" | whichParam == "tau"){
  p.point <- p.point +
  xlim(-6,6)+
  ylim(-6,6)
}

if(PDF){
  CairoPDF(file=paste0("C:\\Users\\nathd\\Downloads\\SMEP24\\Visualizations\\",model, "_", whichParam, "_", sampleSize, "_count_CONTROL.pdf"), height=8, width=11)
  print(p.count)
  print(p.point)
  dev.off()
}

if(PNG){
  ggsave(filename=paste0("C:\\Users\\nathd\\Downloads\\SMEP24\\Visualizations\\",model, "_", whichParam, "_", sampleSize, "_count_CONTROL.png"), plot=p.count, height=8, width=8)
  ggsave(filename=paste0("C:\\Users\\nathd\\Downloads\\SMEP24\\Visualizations\\",model, "_", whichParam, "_", sampleSize, "_point_CONTROL.png"), plot=p.point, height=8, width=8)
}
