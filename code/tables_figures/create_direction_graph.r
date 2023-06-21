#version 3.2.1
library('ggplot2')
library('dplyr')
library('tidyverse')

#version 3.1.0
library('ggtern')

alpha=.4

setwd("C:/Users/thecs/Dropbox (Boston University)/1_boston_university/8-Research Assistantship/ukData")
dataset <- read.csv("./data/additional_processing/empshares_graphs.csv")

directions <- dataset$deskilled


colors <- case_when(sign(directions) == 1 ~ "red",
                    sign(directions) == 0 ~ "gray")

direction_graph <- ggtern(dataset, aes(x=empshare1, y=empshare2, z=empshare3)) + 
  geom_path(arrow=arrow(length=unit(0.2,"cm")),aes(group=bsoc00Agg),color=colors)+
  theme_rgbw() + 
  theme_bw() +
  theme_showarrows() +
  labs(x="", y="", z="", xarrow="Higher GCSE or less share", yarrow="Higher A-levels share", zarrow="Higher Bacherlor+ share")+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(legend.position="bottom")+
  scale_size(guide = 'none')+
  theme_hidegrid_minor()

pdf_name <- "./results/figures/direction_triangle.png"
ggsave(pdf_name,direction_graph,dpi = 700,width=10,height=10)  

directions <- dataset$survives

colors <- case_when(sign(directions) == 1 ~ "red",
                    sign(directions) == 0 ~ "gray")

direction_graph <- ggtern(dataset, aes(x=empshare1, y=empshare2, z=empshare3)) + 
  geom_path(arrow=arrow(length=unit(0.2,"cm")),aes(group=bsoc00Agg),color=colors)+
  theme_rgbw() + 
  theme_bw() +
  theme_showarrows() +
  labs(x="", y="", z="", xarrow="Higher GCSE or less share", yarrow="Higher A-levels share", zarrow="Higher Bacherlor+ share")+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(legend.position="bottom")+
  scale_size(guide = 'none')+
  theme_hidegrid_minor()

pdf_name <- "./results/figures/direction_triangle.png"
ggsave(pdf_name,direction_graph,dpi = 700,width=10,height=10)  





