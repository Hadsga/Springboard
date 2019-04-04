#Goal and backgroung information
'The goal is to identify emails which are relevant to an investigation into the company.'
'The data set contains 885 emails in the inboxes of former Enron executives.'
'Each email is anotetd manualy (0 = not relevant/1 = relevant).'


#Loading packages
library(tm)
library(caTools)
library(rpart)
library(rpart.plot)
library(ROCR)
library(dplyr)

#Reading the data
setwd("C:/Users/X1/Desktop/Springboard New/Mashine Learning/Text Analytics/Enron")
emails = read.csv("energy_bids.csv", stringsAsFactors = T) 

#Exploring the data
glimpse(emails)
emails$email[1]
emeils$responsive 
strwrap(emails$email[[1]]) 
emails$responsive[1] 
strwrap(emails$email[[2]]) 
emails$responsive[2]  
table(emails$responsive) 

#Preprocessing
corpus = Corpus(VectorSource(emails$email)) 
strwrap(corpus[[1]])
corpus = tm_map(corpus, tolower) 
corpus = tm_map(corpus, removePunctuation) 
corpus = tm_map(corpus, removeWords, stopwords("english"))
corpus = tm_map(corpus, stemDocument) 


dtm = DocumentTermMatrix(corpus) 
dtm
dtm = removeSparseTerms(dtm, 0.97) 
dtm
labeledTerms = as.data.frame(as.matrix(dtm)) 
labeledTerms$responsive = emails$responsive 
str(labeledTerms)


set.seed(144)
spl = sample.split(labeledTerms$responsive, 0.7)
train = (subset(labeledTerms, spl == T))
test = (subset(labeledTerms, spl == F))

#Modelbuilding
emailCART = rpart(responsive~., data = train, method = "class") 
prp(emailCART)  

# Modelevaluation
pred = predict(emailCART, newdata = test) 
pred[1:10,]  
pred.prob = pred[,2] 
table(test$responsive, pred.prob >= 0.5) 
(195+25)/(195+20+17+25)
table(test$responsive)
215/(215+42) 

predROCR = prediction(pred.prob, test$responsive)
perfROCR = performance(predROCR, "tpr", "fpr")
plot(perfROCR, colorize = T)
performance(predROCR, "auc")@y.values

