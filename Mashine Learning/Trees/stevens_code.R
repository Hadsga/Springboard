#Goal of the model and data
'Predicting if Justice Stevens vote to reverse (1 = reverse, 0 = affirm) the 
lower court decision.'
'The data are cotain cases from Cases from 1994 through 2001'


library(rpart)
library(rpart.plot)
library(caTools)
library(ROCR)
library(dplyr)

#Reading data
stevens = read.csv("C:/Users/X1/Desktop/Springboard New/Mashine Learning/Trees/stevens.csv")
set.seed(3000)

#Preprocessing
split = sample.split(stevens$Reverse, SplitRatio = 0.7)
Train = subset(stevens, split == T)
Test = subset(stevens, split == F)

#Modelbuliding
stevensTree = rpart(Reverse ~ Circuit + Issue + Petitioner + Respondent + LowerCourt + Unconst, data = Train, method = "class", control = rpart.control(minbucket = 25))   
prp(stevensTree)   

#Modelevaluation
predictCart = predict(stevensTree, newdata = Test, type = "class")
table(Test$Reverse, predictCart)
(41+71)/(41+36+22+71)

PredictRoc = predict(stevensTree, newdata = Test)
PredictRoc
pred = prediction(PredictRoc[,2], Test$Reverse)
perf = performance(pred, "tpr", "fpr")
plot(perf)

