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

pdfName <- paste("output/densitySep","DensityDum.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=10)

#distance*observations in LFS
heatmap <- ggplot(graphData,mapping=aes(x=analyticalIndexDum, y=routinePCIndexDum, z=manualIndexDum,color=jobType))+coord_tern()+
  stat_density_tern(aes(fill=jobType),alpha=graphAlpha,bins=4, geom='polygon',weight=graphData$weight_obs_LFS1)+
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

pdfName <- paste("output/densitySep","DensityDumLFS1.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=10)


#distance*sqrt(observations in LFS*observations in SES)
heatmap <- ggplot(graphData,mapping=aes(x=analyticalIndexDum, y=routinePCIndexDum, z=manualIndexDum,color=jobType))+coord_tern()+
  stat_density_tern(aes(fill=jobType),alpha=graphAlpha,bins=4, geom='polygon',weight=graphData$weight_LFS_SES1)+
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

pdfName <- paste("output/densitySep","DensityDumSES1.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=10)



#distance*observations in SES
heatmap <- ggplot(graphData,mapping=aes(x=analyticalIndexDum, y=routinePCIndexDum, z=manualIndexDum,color=jobType))+coord_tern()+
  stat_density_tern(aes(fill=jobType),alpha=graphAlpha,bins=4, geom='polygon',weight=graphData$weight_obs_SES1)+
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

pdfName <- paste("output/densitySep","DensityDumdistSES1.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=10)

# #####################################################################################
# 
# #Routine pc continuous
# ###########################################################################################################################################
# heatmap <- ggplot(graphData,mapping=aes(x=analyticalIndexCont, y=contRoutinePCIndexCont, z=manualIndexCont,color=jobType))+coord_tern()+
#   stat_density_tern(aes(fill=jobType),alpha=graphAlpha,bins=4, geom='polygon',weight=graphData$occObs)+
#   theme_bw() +
#   scale_fill_manual(values=c("#F5B041", "#0859AF", "#922B21"))+
#   scale_color_manual(values=c("#9B6817", "#17379B", "#651F0C"))+
#   theme_showarrows() +
#   labs(x="", y="", z="", xarrow="Analytical", yarrow="Routine", zarrow="Manual")+
#   theme_hidegrid_minor()+
#   theme(plot.title = element_text(hjust = 0.5))+
#   theme(legend.position="bottom")+
#   geom_text(aes(label=jobType), data=graphData%>%
#               filter(toLabel==1))
# 
# pdfName <- paste("output/densitySep","DensityCont.pdf",sep="")
# ggsave(pdfName,heatmap,dpi = 700,width=10,height=10)
# 
# 
# #moderade dummy graph
# heatmap <- ggplot(graphData,mapping=aes(x=analyticalIndexMod, y=moderatePCIndexMod, z=manualIndexMod,color=jobType))+coord_tern()+
#   stat_density_tern(aes(fill=jobType),alpha=graphAlpha,bins=4, geom='polygon',weight=graphData$occObs)+
#   theme_bw() +
#   scale_fill_manual(values=c("#F5B041", "#0859AF", "#922B21"))+
#   scale_color_manual(values=c("#9B6817", "#17379B", "#651F0C"))+
#   theme_showarrows() +
#   labs(x="", y="", z="", xarrow="Analytical", yarrow="Routine", zarrow="Manual")+
#   theme_hidegrid_minor()+
#   theme(plot.title = element_text(hjust = 0.5))+
#   theme(legend.position="bottom")+
#   geom_text(aes(label=jobType), data=graphData%>%
#               filter(toLabel==1))
# 
# pdfName <- paste("output/densitySep","DensityMod.pdf",sep="")
# ggsave(pdfName,heatmap,dpi = 700,width=10,height=10)
# 
# 
# #aggregated density plots 
# graphAlpha <- 0.1
# #Then I show it according to their final type
# heatmap <- ggplot(graphData,mapping=aes(x=analyticalIndexDum, y=routinePCIndexDum, z=manualIndexDum,shape=jobType,size=occObs))+coord_tern()+
#   stat_density_tern(alpha=graphAlpha,bins=4, geom='polygon',weight=graphData$occObs)+
#   geom_point(data=indexes%>%filter(switcherOneTime==1&timeType==1),aes(alpha=0.8),color="#CC3366")+
#   theme_bw() +
#   theme_showarrows() +
#   labs(x="", y="", z="", xarrow="Analytical", yarrow="Routine", zarrow="Manual")+
#   theme_hidegrid_minor()+
#   theme(plot.title = element_text(hjust = 0.5))+
#   theme(legend.position="bottom")+
#   scale_alpha(guide = 'none')+
#   scale_size(guide = 'none')
# pdfName <- paste("output/densitySep","SwithStart.pdf",sep="")
# ggsave(pdfName,heatmap,dpi = 700,width=10,height=10)
# 
# 
# #aggregated density plots 
# graphAlpha <- 0.1
# #Then I show it according to their final type
# heatmap <- ggplot(graphData,mapping=aes(x=analyticalIndexDum, y=routinePCIndexDum, z=manualIndexDum,shape=jobType,size=occObs))+coord_tern()+
#   stat_density_tern(alpha=graphAlpha,bins=4, geom='polygon',weight=graphData$occObs)+
#   geom_point(data=indexes%>%filter(switcherOneTime==1&timeType==1),aes(alpha=0.8),color="#CC3366")+
#   theme_bw() +
#   theme_showarrows() +
#   labs(x="", y="", z="", xarrow="Analytical", yarrow="Routine", zarrow="Manual")+
#   theme_hidegrid_minor()+
#   theme(plot.title = element_text(hjust = 0.5))+
#   theme(legend.position="bottom")+
#   scale_alpha(guide = 'none')+
#   scale_size(guide = 'none')
# pdfName <- paste("output/densitySep","SwitchStart.pdf",sep="")
# ggsave(pdfName,heatmap,dpi = 700,width=10,height=10)
# 
# #aggregated density plots 
# graphAlpha <- 0.1
# #Then I show it according to their final type
# heatmap <- ggplot(graphData,mapping=aes(x=analyticalIndexDum, y=routinePCIndexDum, z=manualIndexDum,shape=jobType,size=occObs))+coord_tern()+
#   stat_density_tern(alpha=graphAlpha,bins=4, geom='polygon',weight=graphData$occObs)+
#   geom_point(data=indexes%>%filter(switcherOneTime==1&timeType==2),aes(alpha=0.8),color="#CC3366")+
#   theme_bw() +
#   theme_showarrows() +
#   labs(x="", y="", z="", xarrow="Analytical", yarrow="Routine", zarrow="Manual")+
#   theme_hidegrid_minor()+
#   theme(plot.title = element_text(hjust = 0.5))+
#   theme(legend.position="bottom")+
#   scale_alpha(guide = 'none')+
#   scale_size(guide = 'none')
# pdfName <- paste("output/densitySep","SwitchEnd.pdf",sep="")
# ggsave(pdfName,heatmap,dpi = 700,width=10,height=10)

