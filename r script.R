#Item based collaborative filtering: 2 approaches
library(sqldf)

#function for calculating the cosine similarity
cosim <- function(u, v){
  return(diag(u%*%v)/sqrt(sum(diag(u%*%t(u)))*sum(diag(v%*%t(v)))))
}

all_files <- as.character( list.files("D:/Business Analytics/Summer 2015/Predictive Marketing Analytics/SAS Data & Programs/SASUniversityEdition/Netflix/download/training_set"))
directory <- ("D:/Business Analytics/Summer 2015/Predictive Marketing Analytics/SAS Data & Programs/SASUniversityEdition/Netflix/download/training_set/")
file_paths <- paste(directory, all_files, sep="")

simat <- data.frame()
cosimat <- data.frame()


pb <- txtProgressBar(min = 0, max = 100, style = 3)

#calculate the similarity matrix in df: simat
n <- 10

#simat using pearson correlation coeff
for(i in 1:(n-1)){
  for(j in (i+1):n){
    m1 <- read.csv(fp[i], skip = 1)
    m2 <- read.csv(fp[j], skip = 1)
    colnames(m1) <- c("CustID", "R1", "Date")
    colnames(m2) <- c("CustID", "R2", "Date")
    m1 <- sqldf('select m1.CustID, m1.R1
                from m1
                inner join users on m1.CustID = users.CustID')
    m2 <- sqldf('select m2.CustID, m2.R2
                from m2
                inner join users on m2.CustID = users.CustID')
    v <- sqldf('select R1, R2
               from m1
               inner join m2 on m1.CustID = m2.CustID')
    #x <- cosim(v[,1], v[,2])
    x <- cor(v[,1], v[,2])
    
    simat <- rbind(simat, c(i, j, x))
    simat <- rbind(simat, c(j, i, x))
    rm(m1)
    rm(m2)
    rm(v)
    gc()
    setTxtProgressBar(pb, round((i/n)*100, 0))
  }
}

#naming columns and removing some incorrect rows
colnames(simat) <- c("M1", "M2", "SimInd")
simat <- simat[!(duplicated(simat)),]
simat <- na.omit(simat)
simat <- simat[!(simat$M1==simat$M2),]

head(simat)

#cosimat using pearson correlation coeff
for(i in 1:(n-1)){
  for(j in (i+1):n){
    m1 <- read.csv(fp[i], skip = 1)
    m2 <- read.csv(fp[j], skip = 1)
    colnames(m1) <- c("CustID", "R1", "Date")
    colnames(m2) <- c("CustID", "R2", "Date")
    m1 <- sqldf('select m1.CustID, m1.R1
                from m1
                inner join users on m1.CustID = users.CustID')
    m2 <- sqldf('select m2.CustID, m2.R2
                from m2
                inner join users on m2.CustID = users.CustID')
    v <- sqldf('select R1, R2
               from m1
               inner join m2 on m1.CustID = m2.CustID')
    x <- cosim(v[,1], v[,2])
    #x <- cor(v[,1], v[,2])
    
    cosimat <- rbind(cosimat, c(i, j, x))
    cosimat <- rbind(cosimat, c(j, i, x))
    rm(m1)
    rm(m2)
    rm(v)
    gc()
    setTxtProgressBar(pb, round((i/n)*100, 0))
  }
}

#naming columns and removing some incorrect rows
colnames(cosimat) <- c("M1", "M2", "CoSimInd")
cosimat <- cosimat[!(duplicated(cosimat)),]
cosimat <- na.omit(cosimat)
cosimat <- cosimat[!(cosimat$M1==simat$M2),]

head(cosimat)

rm(all_files)
rm(directory)
rm(file_paths)
rm(i, j, n, pb)
rm(cosim)
rm(x)

#weighted prediction using cosine similarity

#function for predicting movie rating using similarity weighted average
predIBCF <- function(mov, user){
  urat <- t.movies[t.movies$CustID==user,]
  mrat <- cosimat[cosimat$M1==mov,c(1,3)]
  umrat <- sqldf('select CoSimInd, Rating
                 from urat
                 inner join mrat on urat.MovID = mrat.M2')
  umrat <- na.omit(umrat)
  return((umrat$CoSimInd%*%umrat$Rating)/sum(umrat$CoSimInd))
}

cos.pred <- t.movies[sample(1:nrow(t.movies), 500, replace=FALSE),]

rownames(cos.pred) <- seq(length=nrow(cos.pred)) 


for(i in 1:500){
  cos.pred$PredRat[i] <- predIBCF(cos.pred$MovID[i],cos.pred$CustID[i])  
}

head(cos.pred)

#calculating RMSE
sqrt(sum((cos.pred$Rating-cos.pred$PredRat)^2)/nrow(cos.pred))

#writing to file
write.csv(cos.pred, file = "<location>/cosinepred.txt")

#prediction using kNN with k = 3 and correlation similarity

#function for predicting movie rating using kNN average
predIBCFnn <- function(mov, user){
  urat <- t.movies[t.movies$CustID==user,]
  mrat <- simat[simat$M1==mov,c(1,3)]
  umrat <- sqldf('select SimInd, Rating
                 from urat
                 inner join mrat on urat.MovID = mrat.M2')
  umrat <- na.omit(umrat)
  umrat <- umrat[order(umrat$SimInd),]
  umrat <- tail(umrat,5)
  return(mean(umrat$Rating))
}

knn.pred <- t.movies[sample(1:nrow(t.movies), 500, replace=FALSE),]

rownames(knn.pred) <- seq(length=nrow(cos.pred)) 


for(i in 1:500){
  knn.pred$PredRat[i] <- predIBCFnn(knn.pred$MovID[i],knn.pred$CustID[i])  
}

head(knn.pred)

#calculating RMSE
sqrt(sum((knn.pred$Rating-knn.pred$PredRat)^2)/nrow(knn.pred))

#writing to file
write.csv(cos.pred, file = "<file location>/knnpred.txt")