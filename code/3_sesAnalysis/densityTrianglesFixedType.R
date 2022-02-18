#aggregated density plots 
graphAlpha <- .4

###########################################################################################################################################
#Routine pc dummy
###########################################################################################################################################
#normal weighting
heatmap <- ggplot(graphData,mapping=aes(x=analyticalIndexDum, y=routinePCIndexDum, z=manualIndexDum,color=jobType))+coord_tern()+
  stat_density_tern(aes(fill=jobType),alpha=graphAlpha,bins=4, geom='polygon',weight=graphData$occObs)+
  theme_bw() +
  scale_fill_manual(values=c("#F5B041", "#0859AF", "#922B21"))+
  scale_color_manual(values=c("#9B6817", "#17379B", "#651F0C"))+
  theme_showarrows() +
  labs(x="", y="", z="", xarrow="Analytical", yarrow="Routine", zarrow="Manual")+
  theme_hidegrid_minor()+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(legend.position="bottom")+
  geom_text(aes(label=jobType), data=graphData%>%
              filter(toLabel==1))

pdfName <- paste("output/densitySep","DensityDumFixed.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=10)

#distance*observations in LFS
heatmap <- ggplot(graphData,mapping=aes(x=analyticalIndexDum, y=routinePCIndexDum, z=manualIndexDum,color=jobType))+coord_tern()+
  stat_density_tern(aes(fill=jobType),alpha=graphAlpha,bins=4, geom='polygon',weight=graphData$obsWeightLFS1)+
  theme_bw() +
  scale_fill_manual(values=c("#F5B041", "#0859AF", "#922B21"))+
  scale_color_manual(values=c("#9B6817", "#17379B", "#651F0C"))+
  theme_showarrows() +
  labs(x="", y="", z="", xarrow="Analytical", yarrow="Routine", zarrow="Manual")+
  theme_hidegrid_minor()+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(legend.position="bottom")+
  geom_text(aes(label=jobType), data=graphData%>%
              filter(toLabel==1))

pdfName <- paste("output/densitySep","DensityDumLFS1Fixed.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=10)


#distance*observations in LFS*observations in SES
heatmap <- ggplot(graphData,mapping=aes(x=analyticalIndexDum, y=routinePCIndexDum, z=manualIndexDum,color=jobType))+coord_tern()+
  stat_density_tern(aes(fill=jobType),alpha=graphAlpha,bins=4, geom='polygon',weight=graphData$obsWeightSES1)+
  theme_bw() +
  scale_fill_manual(values=c("#F5B041", "#0859AF", "#922B21"))+
  scale_color_manual(values=c("#9B6817", "#17379B", "#651F0C"))+
  theme_showarrows() +
  labs(x="", y="", z="", xarrow="Analytical", yarrow="Routine", zarrow="Manual")+
  theme_hidegrid_minor()+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(legend.position="bottom")+
  geom_text(aes(label=jobType), data=graphData%>%
              filter(toLabel==1))

pdfName <- paste("output/densitySep","DensityDumSES1Fixed.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=10)



#distance*observations in SES
heatmap <- ggplot(graphData,mapping=aes(x=analyticalIndexDum, y=routinePCIndexDum, z=manualIndexDum,color=jobType))+coord_tern()+
  stat_density_tern(aes(fill=jobType),alpha=graphAlpha,bins=4, geom='polygon',weight=graphData$distObsSES1)+
  theme_bw() +
  scale_fill_manual(values=c("#F5B041", "#0859AF", "#922B21"))+
  scale_color_manual(values=c("#9B6817", "#17379B", "#651F0C"))+
  theme_showarrows() +
  labs(x="", y="", z="", xarrow="Analytical", yarrow="Routine", zarrow="Manual")+
  theme_hidegrid_minor()+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(legend.position="bottom")+
  geom_text(aes(label=jobType), data=graphData%>%
              filter(toLabel==1))

pdfName <- paste("output/densitySep","DensityDumdistSES1Fixed.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=10)
