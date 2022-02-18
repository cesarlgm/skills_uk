#creates time split density graphs

#######################################################################################################################
#Trying time split
#######################################################################################################################
graphAlpha <- .2
#Original indexes
heatmap <- ggtern(graphData,mapping=aes(x=analyticalIndexOr, y=RIndexOr, z=manualIndexOr,color=birthGroup)) +
  stat_density_tern(aes(fill=birthGroup),alpha=graphAlpha,bins=3, geom='polygon',weight=graphData$occObs)+
  theme_bw() +
  scale_fill_manual(values=c( "#0859AF", "#F5B041", "#922B21"))+
  scale_color_manual(values=c( "#17379B" ,"#9B6817", "#651F0C"))+
  theme_showarrows() +
  labs(x="", y="", z="", xarrow="Analytical", yarrow="Routine", zarrow="Manual")+
  theme_hidegrid_minor()+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(legend.position="bottom")+
  facet_grid( ~ jobType)

pdfName <- paste("output/densitySep","TimeCohortOr.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=height)


#Dummy routine PC use
heatmap <- ggtern(graphData,mapping=aes(x=analyticalIndexDum, y=routinePCIndexDum, z=manualIndexDum,color=birthGroup)) +
  stat_density_tern(aes(fill=birthGroup),alpha=graphAlpha,bins=3, geom='polygon',weight=graphData$occObs)+
  theme_bw() +
  scale_fill_manual(values=c( "#0859AF", "#F5B041", "#922B21"))+
  scale_color_manual(values=c( "#17379B" ,"#9B6817", "#651F0C"))+
  theme_showarrows() +
  labs(x="", y="", z="", xarrow="Analytical", yarrow="Routine", zarrow="Manual")+
  theme_hidegrid_minor()+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(legend.position="bottom")+
  facet_grid( ~ jobType)

pdfName <- paste("output/densitySep","TimeCohortDum.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=height)


#Continuous routine PC use
heatmap <- ggtern(graphData,mapping=aes(x=analyticalIndexCont, y=contRoutinePCIndexCont, z=manualIndexDum,color=birthGroup)) +
  stat_density_tern(aes(fill=birthGroup),alpha=graphAlpha,bins=3, geom='polygon',weight=graphData$occObs)+
  theme_bw() +
  scale_fill_manual(values=c( "#0859AF", "#F5B041", "#922B21"))+
  scale_color_manual(values=c( "#17379B" ,"#9B6817", "#651F0C"))+
  theme_showarrows() +
  labs(x="", y="", z="", xarrow="Analytical", yarrow="Routine", zarrow="Manual")+
  theme_hidegrid_minor()+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(legend.position="bottom")+
  facet_grid( ~ jobType)

pdfName <- paste("output/densitySep","TimeCohortCont.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=height)

#Continuous routine PC use
heatmap <- ggtern(graphData,mapping=aes(x=analyticalIndexMod, y=moderatePCIndexMod, z=manualIndexMod,color=birthGroup)) +
  stat_density_tern(aes(fill=birthGroup),alpha=graphAlpha,bins=3, geom='polygon',weight=graphData$occObs)+
  theme_bw() +
  scale_fill_manual(values=c( "#0859AF", "#F5B041", "#922B21"))+
  scale_color_manual(values=c( "#17379B" ,"#9B6817", "#651F0C"))+
  theme_showarrows() +
  labs(x="", y="", z="", xarrow="Analytical", yarrow="Routine", zarrow="Manual")+
  theme_hidegrid_minor()+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(legend.position="bottom")+
  facet_grid( ~ jobType)


pdfName <- paste("output/densitySep","TimeCohortMod.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=height)

