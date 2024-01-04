#version 3.2.1
library('ggplot2')
library('dplyr')
library('tidyverse')
library('viridis')
library('paletteer')


#version 3.1.0
library('ggtern')

alpha=.4

setwd("C:/Users/thecs/Dropbox/1_boston_university/8-Research Assistantship/ukData")
dataset <- read.csv("./data/additional_processing/empshares_graphs.csv")


#Distinguishing the average arrow

dataset$deskilled[dataset$occupation==9999]<- -1
#Distinguishing the average arrow
dataset$survived[dataset$occupation==9999]<- -1
dataset$survived_BKY[dataset$occupation==9999]<- -1

dataset$all_increase=dataset$coef1>0
dataset$all_increase[dataset$occupation==9999]<- -1


directions <- dataset$all_increase


colors <- case_when(sign(directions) == 1 ~ "Increase in the GCSE- share",
                    sign(directions) == 0 ~ "No increase in the GCSE- share",
                    sign(directions)==-1 ~ "Population average")

sizes <- case_when(sign(directions) == 1 ~ 1,
                   sign(directions) == 0 ~ .5,
                   sign(directions)==-1 ~ 2.5)


direction_graph <- ggtern(dataset, aes(x=empshare_1, y=empshare_2, z=empshare_3,color=colors)) + 
  geom_path(arrow=arrow(length=unit(0.2,"cm")),aes(group=occupation),linewidth=sizes)+
  theme(legend.position = "bottom")+
  theme_bw() +
  theme_showarrows()+
  scale_color_manual(values=c("#69b3a2", "gray85", "black"))+
  labs(x="", y="", z="", xarrow="Higher GCSE or less share", yarrow="Higher A-levels share", zarrow="Higher Bacherlor+ share")+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(legend.position = "bottom")+
  labs(color="Change type")+
  theme(panel.grid.major = element_line(color = "black",
                                        linewidth = 0.5,
                                        linetype = 2))+
  theme_hidegrid_minor()

pdf_name <- "./results/figures/direction_triangle_all_increases.png"
ggsave(pdf_name,direction_graph,dpi = 700,width=10,height=10)  


directions <- dataset$simple_reject1

colors <- case_when(sign(directions) == 1 ~ "Significant increase in the GCSE- share (10% significance)",
                    sign(directions) == 0 ~ "No significant increase in the GCSE- share",
                    sign(directions)==-1 ~ "Population average")

sizes <- case_when(sign(directions) == 1 ~ 1,
                   sign(directions) == 0 ~ .5,
                   sign(directions)==-1 ~ 2.5)

direction_graph <- ggtern(dataset, aes(x=empshare_1, y=empshare_2, z=empshare_3,color=colors)) + 
  geom_path(arrow=arrow(length=unit(0.2,"cm")),aes(group=occupation),linewidth=sizes)+
  theme(legend.position = "bottom")+
  theme_bw() +
  theme_showarrows()+
  scale_color_manual(values=c("#69b3a2", "gray85", "black"))+
  labs(x="", y="", z="", xarrow="Higher GCSE or less share", yarrow="Higher A-levels share", zarrow="Higher Bacherlor+ share")+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(legend.position = "bottom")+
  labs(color="Change type")+
  theme(panel.grid.major = element_line(color = "black",
                                        linewidth = 0.5,
                                        linetype = 2))+
  theme_hidegrid_minor()

pdf_name <- "./results/figures/direction_triangle.png"
ggsave(pdf_name,direction_graph,dpi = 700,width=10,height=10)  

directions <- dataset$reject1

colors <- case_when(sign(directions) == 1 ~ "Significant increase in the GCSE- share (10% significance)",
                    sign(directions) == 0 ~ "No significant increase in the GCSE- share",
                    sign(directions)==-1 ~ "Population average")

sizes <- case_when(sign(directions) == 1 ~ 1,
                   sign(directions) == 0 ~ .5,
                   sign(directions)==-1 ~ 2.5)

direction_graph <- ggtern(dataset, aes(x=empshare_1, y=empshare_2, z=empshare_3,color=colors)) + 
  geom_path(arrow=arrow(length=unit(0.2,"cm")),aes(group=occupation),linewidth=sizes)+
  theme(legend.position = "bottom")+
  theme_bw() +
  theme_showarrows()+
  scale_color_manual(values=c("#69b3a2", "gray85", "black"))+
  labs(x="", y="", z="", xarrow="Higher GCSE or less share", yarrow="Higher A-levels share", zarrow="Higher Bacherlor+ share")+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(legend.position = "bottom")+
  labs(color="Change type")+
  theme(panel.grid.major = element_line(color = "black",
                                        linewidth = 0.5,
                                        linetype = 2))+
  theme_hidegrid_minor()
  

pdf_name <- "./results/figures/direction_triangle_step_up.png"
ggsave(pdf_name,direction_graph,dpi = 700,width=10,height=10)  



directions <- dataset$survived_BKY_mean


colors <- case_when(sign(directions) == 1 ~ "Significant increase in the GCSE- share (10% significance)",
                    sign(directions) == 0 ~ "No significant increase in the GCSE- share",
                    sign(directions)==-1 ~ "Population average")

sizes <- case_when(sign(directions) == 1 ~ 1,
                   sign(directions) == 0 ~ .5,
                   sign(directions)==-1 ~ 2.5)

direction_graph <- ggtern(dataset, aes(x=empshare_1, y=empshare_2, z=empshare_3,color=colors)) + 
  geom_path(arrow=arrow(length=unit(0.2,"cm")),aes(group=occupation),linewidth=sizes)+
  theme(legend.position = "bottom")+
  theme_bw() +
  theme_showarrows()+
  scale_color_manual(values=c("#69b3a2", "gray85", "black"))+
  labs(x="", y="", z="", xarrow="Higher GCSE or less share", yarrow="Higher A-levels share", zarrow="Higher Bacherlor+ share")+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(legend.position = "bottom")+
  labs(color="Change type")+
  theme(panel.grid.major = element_line(color = "black",
                                        linewidth = 0.5,
                                        linetype = 2))+
  theme_hidegrid_minor()

pdf_name <- "./results/figures/direction_triangle_BKY.png"
ggsave(pdf_name,direction_graph,dpi = 700,width=10,height=10)  


################################################################################
#Census graphs
################################################################################
dataset <- read.csv("./data/additional_processing/empshares_graphs_census.csv")

#Distinguishing the average arrow
dataset$deskilled[dataset$occupation==9999]<- -1
#Distinguishing the average arrow
dataset$survived[dataset$occupation==9999]<- -1
dataset$survived_BKY[dataset$occupation==9999]<- -1

directions <- dataset$deskilled


colors <- case_when(sign(directions) == 1 ~ "red3",
                    sign(directions) == 0 ~ "gray80",
                    sign(directions)==-1 ~ "deepskyblue3")

sizes <- case_when(sign(directions) == 1 ~ 1,
                   sign(directions) == 0 ~ .5,
                   sign(directions)==-1 ~ 2.5)

direction_graph <- ggtern(dataset, aes(x=empshare_1, y=empshare_2, z=empshare_3)) + 
  geom_path(arrow=arrow(length=unit(0.2,"cm")),aes(group=occupation),color=colors,linewidth=sizes)+
  theme_bw() +
  theme_showarrows() +
  labs(x="", y="", z="", xarrow="Higher GCSE or less share", yarrow="Higher A-levels share", zarrow="Higher Bacherlor+ share")+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(legend.position = "bottom")+
  theme(panel.grid.major = element_line(color = "black",
                                        linewidth = 0.5,
                                        linetype = 2))+
  theme_hidegrid_minor()

pdf_name <- "./results/figures/direction_triangle.png"
ggsave(pdf_name,direction_graph,dpi = 700,width=10,height=10)  

