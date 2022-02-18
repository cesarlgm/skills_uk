#aggregated density plots 
graphAlpha <- .4

graphData <- dataset%>%
  filter(grLM_border_l==1)

#low education
###########################################################################################################################################
#normal weighting
heatmap <- ggplot(graphData,mapping=aes(x=analyticalIndexDum, y=routinePCIndexDum, z=manualIndexDum,color=job_type_r))+coord_tern()+
  stat_density_tern(aes(fill=job_type_r),alpha=graphAlpha,bins=4, geom='polygon',weight=graphData$weight_LFS_SES1)+
  theme_bw() +
  scale_fill_manual(values=c("#F5B041", "#0859AF", "#922B21"))+
  scale_color_manual(values=c("#9B6817", "#17379B", "#651F0C"))+
  theme_showarrows() +
  labs(x="", y="", z="", xarrow="Analytical", yarrow="Routine", zarrow="Manual")+
  theme_hidegrid_minor()+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(legend.position="bottom")

pdfName <- paste("output/restricted_grLM_border_l.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=10)


#mid education
graphData <- dataset%>%
  filter(grLM_border_m==1)
###########################################################################################################################################
#normal weighting
heatmap <- ggplot(graphData,mapping=aes(x=analyticalIndexDum, y=routinePCIndexDum, z=manualIndexDum,color=job_type_r))+coord_tern()+
  stat_density_tern(aes(fill=job_type_r),alpha=graphAlpha,bins=4, geom='polygon',weight=graphData$weight_LFS_SES1)+
  theme_bw() +
  scale_fill_manual(values=c("#F5B041", "#0859AF", "#922B21"))+
  scale_color_manual(values=c("#9B6817", "#17379B", "#651F0C"))+
  theme_showarrows() +
  labs(x="", y="", z="", xarrow="Analytical", yarrow="Routine", zarrow="Manual")+
  theme_hidegrid_minor()+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(legend.position="bottom")


pdfName <- paste("output/restricted_grLM_border_m.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=10)




#mid education
graphData <- dataset%>%
  filter(grMH_border_m==1)
###########################################################################################################################################
#normal weighting
heatmap <- ggplot(graphData,mapping=aes(x=analyticalIndexDum, y=routinePCIndexDum, z=manualIndexDum,color=job_type_r))+coord_tern()+
  stat_density_tern(aes(fill=job_type_r),alpha=graphAlpha,bins=4, geom='polygon',weight=graphData$weight_LFS_SES1)+
  theme_bw() +
  scale_fill_manual(values=c("#F5B041", "#0859AF", "#922B21"))+
  scale_color_manual(values=c("#9B6817", "#17379B", "#651F0C"))+
  theme_showarrows() +
  labs(x="", y="", z="", xarrow="Analytical", yarrow="Routine", zarrow="Manual")+
  theme_hidegrid_minor()+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(legend.position="bottom")


pdfName <- paste("output/restricted_grMH_border_m.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=10)


#high education
graphData <- dataset%>%
  filter(grMH_border_h==1)
###########################################################################################################################################
#normal weighting
heatmap <- ggplot(graphData,mapping=aes(x=analyticalIndexDum, y=routinePCIndexDum, z=manualIndexDum,color=job_type_r))+coord_tern()+
  stat_density_tern(aes(fill=job_type_r),alpha=graphAlpha,bins=4, geom='polygon',weight=graphData$weight_LFS_SES1)+
  theme_bw() +
  scale_fill_manual(values=c("#F5B041", "#0859AF", "#922B21"))+
  scale_color_manual(values=c("#9B6817", "#17379B", "#651F0C"))+
  theme_showarrows() +
  labs(x="", y="", z="", xarrow="Analytical", yarrow="Routine", zarrow="Manual")+
  theme_hidegrid_minor()+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(legend.position="bottom")


pdfName <- paste("output/restricted_grMH_border_h.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=10)

#===================================================================================================
#---------------------------------------------------------------------------------------------------
#transitioning jobs

graphData <- dataset%>%
  filter(grLM_trans_l==1)

#low education
###########################################################################################################################################
#normal weighting
heatmap <- ggplot(graphData,mapping=aes(x=analyticalIndexDum, y=routinePCIndexDum, z=manualIndexDum,color=job_type_r))+coord_tern()+
  stat_density_tern(aes(fill=job_type_r),alpha=graphAlpha,bins=4, geom='polygon',weight=graphData$weight_LFS_SES1)+
  theme_bw() +
  scale_fill_manual(values=c("#F5B041", "#0859AF", "#922B21"))+
  scale_color_manual(values=c("#9B6817", "#17379B", "#651F0C"))+
  theme_showarrows() +
  labs(x="", y="", z="", xarrow="Analytical", yarrow="Routine", zarrow="Manual")+
  theme_hidegrid_minor()+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(legend.position="bottom")

pdfName <- paste("output/restricted_grLM_trans_l.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=10)


#mid education
graphData <- dataset%>%
  filter(grLM_trans_m==1)
###########################################################################################################################################
#normal weighting
heatmap <- ggplot(graphData,mapping=aes(x=analyticalIndexDum, y=routinePCIndexDum, z=manualIndexDum,color=job_type_r))+coord_tern()+
  stat_density_tern(aes(fill=job_type_r),alpha=graphAlpha,bins=4, geom='polygon',weight=graphData$weight_LFS_SES1)+
  theme_bw() +
  scale_fill_manual(values=c("#F5B041", "#0859AF", "#922B21"))+
  scale_color_manual(values=c("#9B6817", "#17379B", "#651F0C"))+
  theme_showarrows() +
  labs(x="", y="", z="", xarrow="Analytical", yarrow="Routine", zarrow="Manual")+
  theme_hidegrid_minor()+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(legend.position="bottom")


pdfName <- paste("output/restricted_grLM_trans_m.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=10)



graphData <- dataset%>%
  filter(grMH_trans_m==1)

#mid education
###########################################################################################################################################
#normal weighting
heatmap <- ggplot(graphData,mapping=aes(x=analyticalIndexDum, y=routinePCIndexDum, z=manualIndexDum,color=job_type_r))+coord_tern()+
  stat_density_tern(aes(fill=job_type_r),alpha=graphAlpha,bins=4, geom='polygon',weight=graphData$weight_LFS_SES1)+
  theme_bw() +
  scale_fill_manual(values=c("#F5B041", "#0859AF", "#922B21"))+
  scale_color_manual(values=c("#9B6817", "#17379B", "#651F0C"))+
  theme_showarrows() +
  labs(x="", y="", z="", xarrow="Analytical", yarrow="Routine", zarrow="Manual")+
  theme_hidegrid_minor()+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(legend.position="bottom")

pdfName <- paste("output/restricted_grMH_trans_m.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=10)


graphData <- dataset%>%
  filter(grMH_trans_h==1)

#mid education
###########################################################################################################################################
#normal weighting
heatmap <- ggplot(graphData,mapping=aes(x=analyticalIndexDum, y=routinePCIndexDum, z=manualIndexDum,color=job_type_r))+coord_tern()+
  stat_density_tern(aes(fill=job_type_r),alpha=graphAlpha,bins=4, geom='polygon',weight=graphData$weight_LFS_SES1)+
  theme_bw() +
  scale_fill_manual(values=c("#F5B041", "#0859AF", "#922B21"))+
  scale_color_manual(values=c("#9B6817", "#17379B", "#651F0C"))+
  theme_showarrows() +
  labs(x="", y="", z="", xarrow="Analytical", yarrow="Routine", zarrow="Manual")+
  theme_hidegrid_minor()+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(legend.position="bottom")

pdfName <- paste("output/restricted_grMH_trans_h.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width=10,height=10)

