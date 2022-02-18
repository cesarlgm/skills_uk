
##########################################################################################
#creating scatterplot graphs
##########################################################################################
scatterAlpha=.4

###########################################################################################################################################
#Routine pc dummy
###########################################################################################################################################
#original weighting
heatmap <- ggplot(graphData,mapping=aes(x=analyticalIndexDum, y=routinePCIndexDum, z=manualIndexDum,color=jobType,size=occObs,shape=jobType))+coord_tern()+
  geom_point(alpha=scatterAlpha)+
  theme_bw() +
  scale_fill_manual(values=c("#F5B041", "#0859AF", "#922B21"))+
  scale_color_manual(values=c("#9B6817", "#17379B", "#651F0C"))+
  theme_showarrows() +
  labs(x="", y="", z="", xarrow="Analytical", yarrow="Routine", zarrow="Manual")+
  theme_hidegrid_minor()+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(legend.position="bottom")+
  scale_size(guide = 'none')

pdfName <- paste("output/densitySep","ScatterDumFixed.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=10)

#distance * observations in LFS
heatmap <- ggplot(graphData,mapping=aes(x=analyticalIndexDum, y=routinePCIndexDum, z=manualIndexDum,color=jobType,size=obsWeightLFS1,shape=jobType))+coord_tern()+
  geom_point(alpha=scatterAlpha)+
  theme_bw() +
  scale_fill_manual(values=c("#F5B041", "#0859AF", "#922B21"))+
  scale_color_manual(values=c("#9B6817", "#17379B", "#651F0C"))+
  theme_showarrows() +
  labs(x="", y="", z="", xarrow="Analytical", yarrow="Routine", zarrow="Manual")+
  theme_hidegrid_minor()+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(legend.position="bottom")+
  scale_size(guide = 'none')

pdfName <- paste("output/densitySep","ScatterDumLFS1Fixed.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=10)


#distance * observations in LFS * observations in SES
heatmap <- ggplot(graphData,mapping=aes(x=analyticalIndexDum, y=routinePCIndexDum, z=manualIndexDum,color=jobType,size=obsWeightSES1,shape=jobType))+coord_tern()+
  geom_point(alpha=scatterAlpha)+
  theme_bw() +
  scale_fill_manual(values=c("#F5B041", "#0859AF", "#922B21"))+
  scale_color_manual(values=c("#9B6817", "#17379B", "#651F0C"))+
  theme_showarrows() +
  labs(x="", y="", z="", xarrow="Analytical", yarrow="Routine", zarrow="Manual")+
  theme_hidegrid_minor()+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(legend.position="bottom")+
  scale_size(guide = 'none')

pdfName <- paste("output/densitySep","ScatterDumSES1Fixed.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=10)

#distance * observations in SES
heatmap <- ggplot(graphData,mapping=aes(x=analyticalIndexDum, y=routinePCIndexDum, z=manualIndexDum,color=jobType,size=obsWeightSES1,shape=jobType))+coord_tern()+
  geom_point(alpha=scatterAlpha)+
  theme_bw() +
  scale_fill_manual(values=c("#F5B041", "#0859AF", "#922B21"))+
  scale_color_manual(values=c("#9B6817", "#17379B", "#651F0C"))+
  theme_showarrows() +
  labs(x="", y="", z="", xarrow="Analytical", yarrow="Routine", zarrow="Manual")+
  theme_hidegrid_minor()+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(legend.position="bottom")+
  scale_size(guide = 'none')

pdfName <- paste("output/densitySep","ScatterDumdistSES1Fixed.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=10)



