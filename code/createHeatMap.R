#========================================================================================================================

#     	Project: SMK teacher and headmaster training

#       Author: César Garro-Marín
#       Creates triangle density graphs


#========================================================================================================================

#creating simplex heatmaps

#version 3.2.1
library('ggplot2')
library('tidyverse')

#version 3.1.0
library('ggtern')


#parameter for graph creation
education <-        2
nBins <-            8
graphAlpha <-       .6
fillColor <-        "firebrick3"
pointColor <-       "blue2"
width <- 8
height <- 4



setwd("C:/Users/thecs/Dropbox (Boston University)/boston_university/8-Research Assistantship/ukData")
source("code/graphRFunctions.R")


#######################################################################################################################
#Aggregated graphs
#######################################################################################################################
dataset <- read.csv("./tempFiles/skillSESDatabaseAgg.csv")
dataset <- fixLabels(dataset,0)

#nice graph with all the education levels
indexes <- dataset
graphArray <- returnGraphArray(indexes,1)

#graph with all education levels together
graphData <- graphArray[[1]][[5]]
graphName <- graphArray[[2]][[5]]

#density graphs
source("codeFiles/3_sesAnalysis/densityTriangles.R")
source("codeFiles/3_sesAnalysis/scatterTriangles.R")

#graphs limiting to jobs in fixed categories

indexes <- dataset%>%
  filter(sameType==1)
graphArray <- returnGraphArray(indexes,1)

#graph with all education levels together
graphData <- graphArray[[1]][[5]]
graphName <- graphArray[[2]][[5]]

#have corrected weighting with sqrt
source("codeFiles/3_sesAnalysis/densityTrianglesFixedType.R")
source("codeFiles/3_sesAnalysis/scatterTrianglesFixedType.R")

#######################################################################################################################
#Restricted type plots
#######################################################################################################################
dataset <- read.csv("./tempFiles/skillSESDatabaseAgg_restricted.csv")
dataset <- fixLabels(dataset,4)

#nice graph with all the education levels
indexes <- dataset



source("codeFiles/3_sesAnalysis/densityTrianglesRestricted.R")


######################################################################################
#Time split scatterplots
######################################################################################
dataset <- read.csv("./tempFiles/skillSESDatabaseAggTimeSplit.csv")
dataset <- fixLabels(dataset)
dataset <- dataset%>%rename(
  occObs=observations
)
height <- 3.5

indexes <- dataset
graphArray <- returnGraphArray(indexes,1)

graphData <- graphArray[[1]][[5]]
graphName <- graphArray[[2]][[5]]

#density graphs
source("codeFiles/3_sesAnalysis/timeSplitDensity.R")
#scatter graphs
source("codeFiles/3_sesAnalysis/timeSplitScatter.R")

######################################################################################
#Splitting by age
######################################################################################
dataset <- read.csv("./tempFiles/skillSESdatabaseAgeSplit.csv")
dataset <- fixLabels(dataset)
dataset <- dataset%>%rename(
  occObs=observations
)

height <- 3.5

indexes <- dataset
graphArray <- returnGraphArray(indexes,1)
graphData <- graphArray[[1]][[5]]
graphName <- graphArray[[2]][[5]]

#density graphs
source("codeFiles/3_sesAnalysis/birthSplitDensity.R")
#scatter graphs
source("codeFiles/3_sesAnalysis/birthSplitScatter.R")


######################################################################################
#Splitting by cohort
######################################################################################
dataset <- read.csv("./tempFiles/skillSESdatabaseCohortSplit.csv")
dataset <- fixLabels(dataset,2)
dataset <- dataset%>%rename(
  occObs=observations
)

height <- 3.5

indexes <- dataset
graphArray <- returnGraphArray(indexes,1)
graphData <- graphArray[[1]][[5]]
graphName <- graphArray[[2]][[5]]

#density graphs
source("codeFiles/3_sesAnalysis/cohortSplitDensity.R")
#scatter graphs
source("codeFiles/3_sesAnalysis/cohortSplitScatter.R")

#########################################################################################################################
#Individual level graphs
#########################################################################################################################

dataset <- read.csv("./tempFiles/skillSESDatabase.csv")
dataset <- fixLabels(dataset,1)

indexes <- returnIndexes(dataset, "Index","alternativeEducation")
graphArray <- returnGraphArray(indexes,1)


for (graph in 1:4) {
  #density only
  graphData <- graphArray[[1]][[graph]]
  graphName <- graphArray[[2]][[graph]]
  
  heatmap <-individualGraph(graphData,graphAlpha,nBins,fillColor)+
    facet_grid( ~ jobType)+
    theme(legend.position="none") 
  
  pdfName <- paste("output/densityEduc",graphName,education,".pdf",sep="")
  ggsave(pdfName,heatmap,dpi = 700,width = width,height = height)
  
  #density + geom points
  heatmap <- individualGraph(graphData,graphAlpha,nBins,fillColor)+
    facet_grid( ~ jobType)+
    geom_point(aes(alpha=1/100),size=.2)+
    theme(legend.position="none")
  
  pdfName <- paste("output/densityEduc",graphName,"Points",education,".pdf",sep="")
  ggsave(pdfName,heatmap,dpi = 700,width = width,height = height)
}

#graph with all education levels together
graphData <- graphArray[[1]][[5]]
graphName <- graphArray[[2]][[5]]

graphAlpha=.4
heatmap <- ggtern(graphData, aes(x=analyticalIndex, y=RIndex, z=manualIndex)) +
  stat_density_tern(aes(fill=jobType),alpha=graphAlpha,bins=3, geom='polygon',weight=graphData$occObs)+
  theme_bw() +
  scale_fill_manual(values=c("#F5B041", "#0859AF", "#922B21"))+
  scale_color_manual(values=c("#9B6817", "#17379B", "#651F0C"))+
  theme_showarrows() +
  labs(x="", y="", z="", xarrow="Analytical", yarrow="Routine", zarrow="Manual")+
  theme_hidegrid_minor()+
  theme(plot.title = element_text(hjust = 0.5))+
  theme(legend.position="bottom")

pdfName <- paste("output/densitySep",education,"Indiv.pdf",sep="")
ggsave(pdfName,heatmap,dpi = 700,width = width,height = height)


graphArray <- returnGraphArray(indexes,2)

for (graph in 1:2) {
  #density only
  graphData <- graphArray[[1]][[graph]]
  graphName <- graphArray[[2]][[graph]]
  
  heatmap <- individualGraph(graphData,graphAlpha,nBins,fillColor)+
    facet_grid( ~ alternativeEducation)
  
  pdfName <- paste("output/densityJob",graphName,education,".pdf",sep="")
  ggsave(pdfName,heatmap,dpi = 700,width = width,height = height)
}


