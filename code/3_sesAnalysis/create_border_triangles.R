#version 3.2.1
library('ggplot2')
library('dplyr')
library('tidyverse')
library('rlang')

#version 3.1.0
library('ggtern')

setwd("C:/Users/thecs/Dropbox (Boston University)/boston_university/8-Research Assistantship/ukData")
dataset <- read.csv("./data/additional_processing/skill_triangle_graphs1.csv")



gradient_graph <- function(mydata, legend="",name="",x_name,y_name,z_name) {
  graph <- ggtern(mydata, aes(x=x, y=y, z=z)) + 
    geom_point(aes(color=gradient ,size=obs))+
    scale_color_gradient(low = "white", high = "red") + 
    theme_rgbw() + 
    theme_bw() +
    theme_showarrows() +
    labs(x="", y="", z="", xarrow=x_name, yarrow=y_name, zarrow=z_name,color=legend)+
    theme(plot.title = element_text(hjust = 0.5))+
    theme(legend.position="right")+
    scale_size(guide = 'none')+
    theme_hidegrid_minor()+
    facet_grid(~year)
    pdf_name <- paste("results/figures/border_triangle_",name,".png")
    ggsave(pdf_name,graph,dpi = 700,width=10,height=5)  
}

extract_dataset <- function(mydata,column,x,y,z){
  mydata$gradient=mydata[[column]]
  mydata$x <- mydata[[x]]
  mydata$y <- mydata[[y]]
  mydata$z <- mydata[[z]]
  return(mydata)
}

#MRA graphs
{
  mydata <- extract_dataset(dataset,"empshare12","manual","routine","abstract")
  gradient_graph(mydata,legend="% mid /(% low+ % mid)",name="mra12",x_name = "manual",y_name = "routine",z_name = "abstract") 
  
  
  mydata <- extract_dataset(dataset,"empshare23","manual","routine","abstract")
  start_graph <- gradient_graph(mydata,legend="% high /(% high+ % mid)",name="mra23","manual","routine","abstract") 
  
  
  mydata <- extract_dataset(dataset,"empshare13","manual","routine","abstract")
  start_graph <- gradient_graph(mydata,legend="% high /(% high+ % low)",name="mra13","manual","routine","abstract") 
}


dataset <- read.csv("./data/additional_processing/skill_triangle_graphs2.csv")


#MSA graphs
{
  mydata <- extract_dataset(dataset,"empshare12","manual","social","abstract")
  gradient_graph(mydata,legend="% mid /(% low+ % mid)",name="msa12","manual","social","abstract") 
  
  
  mydata <- extract_dataset(dataset,"empshare23","manual","social","abstract")
  start_graph <- gradient_graph(mydata,legend="% high /(% high+ % mid)",name="msa23","manual","social","abstract") 
  
  
  mydata <- extract_dataset(dataset,"empshare13","manual","social","abstract")
  start_graph <- gradient_graph(mydata,legend="% high /(% high+ % low)",name="msa13","manual","social","abstract") 
}


dataset <- read.csv("./data/additional_processing/skill_triangle_graphs3.csv")


#MRS graphs
{
  mydata <- extract_dataset(dataset,"empshare12","manual","routine","social")
  gradient_graph(mydata,legend="% mid /(% low+ % mid)",name="mrs12","manual","routine","social") 
  
  
  mydata <- extract_dataset(dataset,"empshare23","manual","routine","social")
  start_graph <- gradient_graph(mydata,legend="% high /(% high+ % mid)",name="mrs23","manual","routine","social") 
  
  
  mydata <- extract_dataset(dataset,"empshare13","manual","routine","social")
  start_graph <- gradient_graph(mydata,legend="% high /(% high+ % low)",name="mrs13","manual","routine","social") 
}

dataset <- read.csv("./data/additional_processing/skill_triangle_graphs4.csv")

#SRA graphs
{
  mydata <- extract_dataset(dataset,"empshare12","social","routine","abstract")
  gradient_graph(mydata,legend="% mid /(% low+ % mid)",name="sra12","social","routine","abstract") 
  
  
  mydata <- extract_dataset(dataset,"empshare23","social","routine","abstract")
  start_graph <- gradient_graph(mydata,legend="% high /(% high+ % mid)",name="sra23","social","routine","abstract") 
  
  
  mydata <- extract_dataset(dataset,"empshare13","social","routine","abstract")
  start_graph <- gradient_graph(mydata,legend="% high /(% high+ % low)",name="sra13","social","routine","abstract") 
}