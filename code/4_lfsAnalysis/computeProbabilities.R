#========================================================================================================================

#     	Project: SMK teacher and headmaster training

#       Author: César Garro-Marín
#       computing probabilities


#========================================================================================================================

library('tidyverse')
library('mvtnorm')

setwd("C:/Users/thecs/Dropbox/Boston University/8-Research Assistantship/ukData")

dataset <- read.csv("tempFiles/probabilityComputationFile.csv")
N <- length(dataset$bsoc00Agg)

#starting list of variance matrices
nParam <- 2
variances=array(data=NA,dim=c(nParam,nParam,N))


for (line in 1:N) {
  for (educ in 1:nParam) {
    name=paste("s",educ,sep="")
    variances[educ,educ,line] <- dataset[line,name]*(1-dataset[line,name])
    if (variances[educ,educ,line]==0) {
      variances[educ,educ,line]=.000001
    }
  }
   variances[1,2,line] <- -dataset$s1[line]*dataset$s2[line]
   variances[2,1,line] <- variances[1,2,line]
}


D=array(c(1,0,1,0,-1,-1),dim=c(3,2))

Sigma=array(data=NA,dim=c(nParam+1,nParam+1,N))
Mu=array(data=NA,dim=c(nParam+1,N))

#I fill up all the distributional components
for (line in 1:N) {
  Sigma[,,line] <- D%*%variances[,,line]%*%t(D)*(1/dataset$N[line])
  for (j in 1:(nParam+1)){
    name=paste("s",j,sep="")
    Mu[j,line] <- dataset[line,name]
  }
}

for (line in 1:N) {
  limit1=dataset$s_bar1[1]
  limit2=dataset$s_bar1[2]
  limit3=dataset$s_bar1[3]
  
  sigma <- Sigma[,,line]
  mu <- Mu[,line]
  
  dataset$p_12[line] <-pmvnorm(lower=c(limit1, limit2,-Inf),upper=c(Inf, Inf,limit3),mean=mu,sigma=sigma)
  dataset$p_13[line] <-pmvnorm(lower=c(limit1, -Inf,limit3),upper=c(Inf, limit2,Inf),mean=mu,sigma=sigma)
  dataset$p_23[line] <-pmvnorm(lower=c(-Inf, limit2,limit3),upper=c(limit1, Inf,Inf),mean=mu,sigma=sigma)
}
#I start computing probabilites
