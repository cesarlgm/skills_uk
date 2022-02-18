#creates time split density graphs

#######################################################################################################################
#Trying time split
#######################################################################################################################
graphAlpha <- .3
binNumber <- 3


#Dummy routine PC use
heatmap <- ggtern(graphData,mapping=aes(x=analyticalIndexDum, y=routinePCIndexDum, z=manualIndexDum,color=period)) +
  stat_density_tern(aes(fill=period),alpha=graphAlpha,bins=binNumber, geom='polygon',weight=graphData$occObs)+
  theme_bw() +
  scale_fill_manual(values=c( "#0859AF", "#F5B041", "#922B21"))+
  scale_color_manual(values=c( "#17379B" ,"#9B6817", "#651F0C"))+
  theme_showarrows() +
  labs(x="", y="", z="", xarrow="Analytical", yarrow="Routine", zarrow="Manual")+
  theme_hidegrid_minor()+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(legend.position="bottom")+
  facet_grid( ~ jobType)

pdfName <- paste("output/densitySep","TimeDum.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=height)


heatmap <- ggtern(graphData,mapping=aes(x=analyticalIndexDum, y=routinePCIndexDum, z=manualIndexDum,color=period)) +
  stat_density_tern(aes(fill=period),alpha=graphAlpha,bins=binNumber, geom='polygon',weight=graphData$obsWeightLFS1)+
  theme_bw() +
  scale_fill_manual(values=c( "#0859AF", "#F5B041", "#922B21"))+
  scale_color_manual(values=c( "#17379B" ,"#9B6817", "#651F0C"))+
  theme_showarrows() +
  labs(x="", y="", z="", xarrow="Analytical", yarrow="Routine", zarrow="Manual")+
  theme_hidegrid_minor()+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(legend.position="bottom")+
  facet_grid( ~ jobType)

pdfName <- paste("output/densitySep","TimeDumLFS1.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=height)


heatmap <- ggtern(graphData,mapping=aes(x=analyticalIndexDum, y=routinePCIndexDum, z=manualIndexDum,color=period)) +
  stat_density_tern(aes(fill=period),alpha=graphAlpha,bins=binNumber, geom='polygon',weight=graphData$obsWeightSES1)+
  theme_bw() +
  scale_fill_manual(values=c( "#0859AF", "#F5B041", "#922B21"))+
  scale_color_manual(values=c( "#17379B" ,"#9B6817", "#651F0C"))+
  theme_showarrows() +
  labs(x="", y="", z="", xarrow="Analytical", yarrow="Routine", zarrow="Manual")+
  theme_hidegrid_minor()+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(legend.position="bottom")+
  facet_grid( ~ jobType)

pdfName <- paste("output/densitySep","TimeDumSES1.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=height)





#Continuous routine PC use
heatmap <- ggtern(graphData,mapping=aes(x=analyticalIndexCont, y=contRoutinePCIndexCont, z=newManualIndexDum,color=period)) +
  stat_density_tern(aes(fill=period),alpha=graphAlpha,bins=binNumber, geom='polygon',weight=graphData$occObs)+
  theme_bw() +
  scale_fill_manual(values=c( "#0859AF", "#F5B041", "#922B21"))+
  scale_color_manual(values=c( "#17379B" ,"#9B6817", "#651F0C"))+
  theme_showarrows() +
  labs(x="", y="", z="", xarrow="Analytical", yarrow="Routine", zarrow="Manual")+
  theme_hidegrid_minor()+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(legend.position="bottom")+
  geom_text(aes(label=period), data=graphData%>%
              filter(toLabel==1))+
  facet_grid( ~ jobType)

pdfName <- paste("output/densitySep","TimeCont.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=height)

#Continuous routine PC use
heatmap <- ggtern(graphData,mapping=aes(x=analyticalIndexMod, y=moderatePCIndexMod, z=newManualIndexMod,color=period)) +
  stat_density_tern(aes(fill=period),alpha=graphAlpha,bins=binNumber, geom='polygon',weight=graphData$occObs)+
  theme_bw() +
  scale_fill_manual(values=c( "#0859AF", "#F5B041", "#922B21"))+
  scale_color_manual(values=c( "#17379B" ,"#9B6817", "#651F0C"))+
  theme_showarrows() +
  labs(x="", y="", z="", xarrow="Analytical", yarrow="Routine", zarrow="Manual")+
  theme_hidegrid_minor()+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(legend.position="bottom")+
  geom_text(aes(label=period), data=graphData%>%
              filter(toLabel==1))+
  facet_grid( ~ jobType)


pdfName <- paste("output/densitySep","TimeMod.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=height)
