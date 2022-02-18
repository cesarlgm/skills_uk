#creates time split density scatter plots

#######################################################################################################################
#Time split scatterplots
#######################################################################################################################

graphAlpha <- .5

#Original indexes
heatmap <- ggtern(graphData,mapping=aes(x=analyticalIndexOr, y=RIndexOr, z=manualIndexOr,color=young,shape=young,size=occObs)) +
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

pdfName <- paste("output/densitySep","TimeAgeScatterOr.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=height)


#Dummy routine PC use
heatmap <- ggtern(graphData,mapping=aes(x=analyticalIndexDum, y=routinePCIndexDum, z=manualIndexDum,color=young,shape=young,size=occObs)) +
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

pdfName <- paste("output/densitySep","TimeAgeScatterDum.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=height)


#Continuous routine PC use
heatmap <- ggtern(graphData,mapping=aes(x=analyticalIndexCont, y=contRoutinePCIndexCont, z=manualIndexDum,color=young,shape=young,size=occObs)) +
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

pdfName <- paste("output/densitySep","TimeAgeScatterCont.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=height)

#Continuous routine PC use
heatmap <- ggtern(graphData,mapping=aes(x=analyticalIndexMod, y=moderatePCIndexMod, z=manualIndexMod,color=young,shape=young,size=occObs)) +
  geom_point(alpha=graphAlpha)+
  theme_bw() +
  scale_fill_manual(values=c( "#0859AF", "#F5B041", "#922B21"))+
  scale_color_manual(values=c( "#17379B" ,"#9B6817", "#651F0C"))+
  theme_showarrows() +
  labs(x="", y="", z="", xarrow="Analytical", yarrow="Routine", zarrow="Manual")+
  theme_hidegrid_minor()+
  theme(plot.title = element_text(hjust = 0.5))+
  facet_grid( ~ jobType)


pdfName <- paste("output/densitySep","TimeAgeScatterMod.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=height)
