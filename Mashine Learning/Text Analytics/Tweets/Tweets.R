# Goal of the model and background information
'The goal is to predict positive and negative Tweets.'
'The data are 1181 Tweets about Apple .'
'The Tweets contain only the text (no information about the user, date, etc.)'
'All Tweets were manually annotated by Amazon Mechanical Trunk.'
'Their valence (positive / negative / neutral) were estimated numerically (-2 to +2) by 5 people.'
'The valence value of each tweet is the arithmetic mean of the 5 ratings.'

# Loading Packages 
library(SnowballC)
library(NLP)
library(tm)
library(dplyr)
library(caTools)
library(rpart)
library(rpart.plot)

#Reading the data
setwd("C:/Users/X1/Desktop/Springboard/Text Analytics/Tweets")
tweets = read.csv("tweets.csv", stringsAsFactors = FALSE) 

#Exploring the data
glimpse(tweets)
range(tweets$Avg)
table(tweets$Avg)
tweets$Negative = as.factor(tweets$Avg <= -1) 
table(tweets$Negative)

#Preprocessing the data
corpus = Corpus(VectorSource(tweets$Tweet)) 
corpus[[1]]$content
corpus = tm_map(corpus, tolower) 
corpus[[1]]$content
corpus = tm_map(corpus, removePunctuation) 
corpus[[1]]$content
stopwords("english")[1:10]
corpus = tm_map(corpus, removeWords, c("apple", stopwords("english"))) 
corpus = tm_map(corpus, stemDocument) 

frequencies = DocumentTermMatrix(corpus) 
frequencies
inspect(frequencies[1000:1005, 505:515])
findFreqTerms(frequencies, lowfreq = 20)
sparse = removeSparseTerms(frequencies, 0.995) 
sparse
tweetsSparse = as.data.frame(as.matrix(sparse)) 
colnames(tweetsSparse) = make.names(colnames(tweetsSparse)) 
tweetsSparse$Negative = tweets$Negative 

set.seed(123)
split = sample.split(tweetsSparse$Negative, SplitRatio = 0.7)
trainSparse = subset(tweetsSparse, split == T)
testSparse = subset(tweetsSparse, split == F)

#Modelbuilding
tweetCART = rpart(Negative ~., data = trainSparse, method = "class") 
prp(tweetCART)

#Modelevaluation
predictCART = predict(tweetCART, newdata = testSparse, type = "class") 
table(testSparse)
table(testSparse$Negative, predictCART)
(294+18)/(294+6+37+18)
table(testSparse$Negative)
300/(300+55)

