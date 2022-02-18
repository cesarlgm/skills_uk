#creates time split density graphs

#######################################################################################################################
#Trying time split
#######################################################################################################################
graphAlpha <- .2
#Original indexes
heatmap <- ggtern(graphData,mapping=aes(x=analyticalIndexOr, y=RIndexOr, z=manualIndexOr,color=young)) +
  stat_density_tern(aes(fill=young),alpha=graphAlpha,bins=3, geom='polygon',weight=graphData$occObs)+
  theme_bw() +
  scale_fill_manual(values=c( "#0859AF", "#F5B041", "#922B21"))+
  scale_color_manual(values=c( "#17379B" ,"#9B6817", "#651F0C"))+
  theme_showarrows() +
  labs(x="", y="", z="", xarrow="Analytical", yarrow="Routine", zarrow="Manual")+
  theme_hidegrid_minor()+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(legend.position="bottom")+
  facet_grid( ~ jobType)

pdfName <- paste("output/densitySep","TimeAgeOr.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=height)


#Dummy routine PC use
heatmap <- ggtern(graphData,mapping=aes(x=analyticalIndexDum, y=routinePCIndexDum, z=newManualIndexDum,color=young)) +
  stat_density_tern(aes(fill=young),alpha=graphAlpha,bins=3, geom='polygon',weight=graphData$occObs)+
  theme_bw() +
  scale_fill_manual(values=c( "#0859AF", "#F5B041", "#922B21"))+
  scale_color_manual(values=c( "#17379B" ,"#9B6817", "#651F0C"))+
  theme_showarrows() +
  labs(x="", y="", z="", xarrow="Analytical", yarrow="Routine", zarrow="Manual")+
  theme_hidegrid_minor()+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(legend.position="bottom")+
  facet_grid( ~ jobType)

pdfName <- paste("output/densitySep","TimeAgeDum.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=height)


#Continuous routine PC use
heatmap <- ggtern(graphData,mapping=aes(x=analyticalIndexCont, y=contRoutinePCIndexCont, z=newManualIndexDum,color=young)) +
  stat_density_tern(aes(fill=young),alpha=graphAlpha,bins=3, geom='polygon',weight=graphData$occObs)+
  theme_bw() +
  scale_fill_manual(values=c( "#0859AF", "#F5B041", "#922B21"))+
  scale_color_manual(values=c( "#17379B" ,"#9B6817", "#651F0C"))+
  theme_showarrows() +
  labs(x="", y="", z="", xarrow="Analytical", yarrow="Routine", zarrow="Manual")+
  theme_hidegrid_minor()+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(legend.position="bottom")+
  facet_grid( ~ jobType)

pdfName <- paste("output/densitySep","TimeAgeCont.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=height)

#Continuous routine PC use
heatmap <- ggtern(graphData,mapping=aes(x=analyticalIndexMod, y=moderatePCIndexMod, z=newManualIndexMod,color=young)) +
  stat_density_tern(aes(fill=young),alpha=graphAlpha,bins=3, geom='polygon',weight=graphData$occObs)+
  theme_bw() +
  scale_fill_manual(values=c( "#0859AF", "#F5B041", "#922B21"))+
  scale_color_manual(values=c( "#17379B" ,"#9B6817", "#651F0C"))+
  theme_showarrows() +
  labs(x="", y="", z="", xarrow="Analytical", yarrow="Routine", zarrow="Manual")+
  theme_hidegrid_minor()+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(legend.position="bottom")+
  facet_grid( ~ jobType)


pdfName <- paste("output/densitySep","TimeAgeMod.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=height)

