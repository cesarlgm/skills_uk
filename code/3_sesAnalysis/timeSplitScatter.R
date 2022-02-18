#creates time split density scatter plots

#######################################################################################################################
#Time split scatterplots
#######################################################################################################################

graphAlpha <- .4

#Original indexes
heatmap <- ggtern(graphData,mapping=aes(x=analyticalIndexOr, y=RIndexOr, z=manualIndexOr,color=period,shape=period,size=occObs)) +
  geom_point(alpha=graphAlpha)+
  theme_bw() +
  scale_fill_manual(values=c( "#0859AF", "#F5B041", "#922B21"))+
  scale_color_manual(values=c( "#17379B" ,"#9B6817", "#651F0C"))+
  theme_showarrows() +
  labs(x="", y="", z="", xarrow="Analytical", yarrow="Routine", zarrow="Manual")+
  theme_hidegrid_minor()+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(legend.position="bottom")+
  facet_grid( ~ jobType)

pdfName <- paste("output/densitySep","TimeScatterOr.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=height)


#Dummy routine PC use
heatmap <- ggtern(graphData,mapping=aes(x=analyticalIndexDum, y=routinePCIndexDum, z=newManualIndexDum,color=period,shape=period,size=occObs)) +
  geom_point(alpha=graphAlpha)+
  theme_bw() +
  scale_fill_manual(values=c( "#0859AF", "#F5B041", "#922B21"))+
  scale_color_manual(values=c( "#17379B" ,"#9B6817", "#651F0C"))+
  theme_showarrows() +
  labs(x="", y="", z="", xarrow="Analytical", yarrow="Routine", zarrow="Manual")+
  theme_hidegrid_minor()+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(legend.position="bottom")+
  facet_grid( ~ jobType)

pdfName <- paste("output/densitySep","TimeScatterDum.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=height)


#Continuous routine PC use
heatmap <- ggtern(graphData,mapping=aes(x=analyticalIndexCont, y=contRoutinePCIndexCont, z=newManualIndexDum,color=period,shape=period,size=occObs)) +
  geom_point(alpha=graphAlpha)+
  theme_bw() +
  scale_fill_manual(values=c( "#0859AF", "#F5B041", "#922B21"))+
  scale_color_manual(values=c( "#17379B" ,"#9B6817", "#651F0C"))+
  theme_showarrows() +
  labs(x="", y="", z="", xarrow="Analytical", yarrow="Routine", zarrow="Manual")+
  theme_hidegrid_minor()+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(legend.position="bottom")+
  facet_grid( ~ jobType)

pdfName <- paste("output/densitySep","TimeScatterCont.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=height)

#Continuous routine PC use
heatmap <- ggtern(graphData,mapping=aes(x=analyticalIndexMod, y=moderatePCIndexMod, z=newManualIndexMod,color=period,shape=period,size=occObs)) +
  geom_point(alpha=graphAlpha)+
  theme_bw() +
  scale_fill_manual(values=c( "#0859AF", "#F5B041", "#922B21"))+
  scale_color_manual(values=c( "#17379B" ,"#9B6817", "#651F0C"))+
  theme_showarrows() +
  labs(x="", y="", z="", xarrow="Analytical", yarrow="Routine", zarrow="Manual")+
  theme_hidegrid_minor()+
  theme(plot.title = element_text(hjust = 0.5))+
  facet_grid( ~ jobType)


pdfName <- paste("output/densitySep","TimeScatterMod.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=height)
