
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


pdfName <- paste("output/densitySep","ScatterDum.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=10)

#distance * observations in LFS
heatmap <- ggplot(graphData,mapping=aes(x=analyticalIndexDum, y=routinePCIndexDum, z=manualIndexDum,color=jobType,size=weight_obs_LFS1,shape=jobType))+coord_tern()+
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


pdfName <- paste("output/densitySep","ScatterDumLFS1.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=10)


#distance * observations in LFS * observations in SES
heatmap <- ggplot(graphData,mapping=aes(x=analyticalIndexDum, y=routinePCIndexDum, z=manualIndexDum,color=jobType,size=weight_LFS_SES1,shape=jobType))+coord_tern()+
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

pdfName <- paste("output/densitySep","ScatterDumSES1.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=10)

#distance * observations in SES
heatmap <- ggplot(graphData,mapping=aes(x=analyticalIndexDum, y=routinePCIndexDum, z=manualIndexDum,color=jobType,size=weight_obs_SES1,shape=jobType))+coord_tern()+
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

pdfName <- paste("output/densitySep","ScatterDumdistSES1.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=10)




###########################################################################################################################################
#Routine pc continuous
###########################################################################################################################################
#original weighting
heatmap <- ggplot(graphData,mapping=aes(x=analyticalIndexCont, y=contRoutinePCIndexCont, z=manualIndexCont,color=jobType,size=occObs,shape=jobType))+coord_tern()+
  geom_point(alpha=scatterAlpha)+
  theme_bw() +
  scale_fill_manual(values=c("#F5B041", "#0859AF", "#922B21"))+
  scale_color_manual(values=c("#9B6817", "#17379B", "#651F0C"))+
  theme_showarrows() +
  labs(x="", y="", z="", xarrow="Analytical", yarrow="Routine", zarrow="Manual")+
  theme_hidegrid_minor()+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(legend.position="bottom")+
  geom_text(aes(label=jobType,size=200), data=graphData%>%
              filter(toLabel==1))

pdfName <- paste("output/densitySep","ScatterCont.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=10)


#moderade dummy graph
heatmap <- ggplot(graphData,mapping=aes(x=analyticalIndexMod, y=moderatePCIndexMod, z=manualIndexMod,color=jobType,size=occObs,shape=jobType))+coord_tern()+
  geom_point(alpha=scatterAlpha)+
  theme_bw() +
  scale_fill_manual(values=c("#F5B041", "#0859AF", "#922B21"))+
  scale_color_manual(values=c("#9B6817", "#17379B", "#651F0C"))+
  theme_showarrows() +
  labs(x="", y="", z="", xarrow="Analytical", yarrow="Routine", zarrow="Manual")+
  theme_hidegrid_minor()+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(legend.position="bottom")+
  geom_text(aes(label=jobType,size=200), data=graphData%>%
              filter(toLabel==1))

pdfName <- paste("output/densitySep","ScatterMod.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=10)
