

#defining graphs functions

fixLabels <- function(dataset,type=0){
  #First I label the education here
  dataset$alternativeEducation <- as_factor(dataset$alternativeEducation)
  levels(dataset$alternativeEducation) <- c("Below GCSE C", "GCSE C to A lev.", "Bachelor +")
  
  #sadly I don't get any observation in the low-high border
  if (type<4) {
    dataset$jobType <- as_factor(dataset$jobType)
    levels(dataset$jobType) <- c("Below GCSE C", "GCSE C to A lev.", "Bachelor +",
                                 "Below GCSE C / GCSE C to A lev.", "Below GCSE C / Bachelor+",
                                 "GCSE C to A lev. / Bachelor+")
  }
  else {
    dataset$job_type_r <- as_factor(dataset$job_type_r)
    levels(dataset$job_type_r) <- c("Low", "Mid", "High",
                                 "Low-Mid", "Mid-High", "Low to Low-Mid",
                                 "Mid to Low-Mid", "Mid to Mid-High", 
                                 "Low-Mid to Mid", "Mid-High to High")
  }
    
  if (type==3){
    dataset$period <- as_factor(dataset$period)
    levels(dataset$period) <- c("2001-2006","2012-2017")
  }
  else if (type==1){
    dataset$young <- as_factor(dataset$young)
    levels(dataset$young) <- c("40-60 year-olds","20-40 year-olds")
  }
  else if (type==2) {
    dataset$birthGroup <-as_factor(dataset$birthGroup)
    levels(dataset$birthGroup) <- c("1941-1980","1981+")
  }
  return(dataset)
}

#function for subsetting data
returnIndexes <- function(dataset,index,education){
  columns1 <- c(education,"bsoc00Agg","jobType","graphLow","graphMid","graphHigh","graphMidH","borderGraph12","borderGraph23", "graphSep")
  if (index=="Factor"){
    columns2 <- c("analyticalFactor", "RFactor", "manualFactor")
  }
  else if (index=="Index") {
    columns2 <- c("analyticalIndex", "RIndex", "manualIndex")
  }
  else if (index=="Ort") {
    columns2 <- c("analyticalOrt", "ROrt", "manualOrt")
  }
  indexes <- dataset%>%
    select( c(columns1,columns2))
  return(indexes)
}

returnGraphArray <- function(indexes,graphType){
  if (graphType==1){
    #Low education graph
    lowGraph <- indexes%>%
      filter(graphLow==1)
    
    #Low education graph
    midGraph <- indexes%>%
      filter(graphMid==1)
    
    #Low education graph
    highGraph <- indexes%>%
      filter(graphHigh==1)
    
    #Low education graph
    midHGraph <- indexes%>%
      filter(graphMidH==1)
    
    graphSep <- indexes %>%
      filter(graphSep==1)
    
    data <- list(lowGraph,midGraph,highGraph,midHGraph,graphSep)
    names <- c("Low","Mid","High","MidH","Sep")
  }
  else if (graphType==2) {
    borderGraph12 <- indexes%>%
      filter(borderGraph12==1)
    borderGraph23 <- indexes%>%
      filter(borderGraph23==1)
    data <- list(borderGraph12,borderGraph23)
    names <- c("LowMid","MidHigh")
  }
  result <- list(data,names)
  return(result)
}

individualGraph <- function(graphData,graphAlpha,nBins,fillColor,weight=1){
  ggtern(graphData, aes(x=analyticalIndex, y=RIndex, z=manualIndex)) +
    stat_density_tern(aes(fill=..level..),alpha=graphAlpha,bins=nBins, geom='polygon',weight=weight) +
    scale_fill_gradient2(high = fillColor) +
    theme_bw() +
    theme_showarrows() +
    labs(x="", y="", z="", xarrow="Analytical", yarrow="Routine", zarrow="Manual")+
    theme_hidegrid_minor()+
    theme(plot.title = element_text(hjust = 0.5))+
    theme(legend.position="none") 
}
