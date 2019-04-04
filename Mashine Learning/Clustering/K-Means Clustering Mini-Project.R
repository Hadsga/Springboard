# This mini-project is based on the K-Means exercise from 'R in Action'
# Go here for the original blog post and solutions

# Exercise 0: Install these packages if you don't have them already

# install.packages(c("cluster", "rattle.data","NbClust"))
library(cluster)
library(rattle.data)
library(NbClust)
library(dplyr)

# Now load the data and look at the first few rows
data(wine, package="rattle.data")
head(wine)

# Exercise 1: Remove the first column from the data and scale
# it using the scale() function

df = wine %>% select(-Type) %>% scale()
wine$Type

# Now we'd like to cluster the data using K-Means. 
# How do we decide how many clusters to use if you don't know that already?
# We'll try two methods.

# Method 1: A plot of the total within-groups sums of squares against the 
# number of clusters in a K-means solution can be helpful. A bend in the 
# graph can suggest the appropriate number of clusters. 

wssplot <- function(data, nc=15, seed=1234){
	              wss <- (nrow(data)-1)*sum(apply(data,2,var))
               	      for (i in 2:nc){
		        set.seed(seed)
	                wss[i] <- sum(kmeans(data, centers=i)$withinss)}
	                
		      plot(1:nc, wss, type="b", xlab="Number of Clusters",
	                        ylab="Within groups sum of squares")
	   }

wssplot(df)

# Exercise 2:
#   * How many clusters does this method suggest?

      # Answer: The method suggests 3 Clusters because the obvious bend of the graph starts at 3  clusters. 


#   * Why does this method work? What's the intuition behind it?
      # Answer: The method works because it can be calculated when the WSS only increase by a small 
      # amount i.e. the cases are quite similar. More clusters would not be more informative. 

#   * Look at the code for wssplot() and figure out how it works!
      # Answer: The idea of this method is to divide a dataset into a prior specified 
      # number of clusters (k). Therefore, k different points will be selected 
      # as beginning centers. Next, every value in the dataset will be arranged to 
      # its next center.  After that, the centers will be calculated anew. Then, every 
      # value in the dataset will be arranged to its next center again. After that, the 
      # centers will be calculated anew ...etc. The procedure will be as long repeated 
      # until the centers don't move anymore.  In this case, 15 clusters were selected as 
      # the beginning centers, but it´s not clear if 15 clusters are needed for this analyses. 
      # The graph shows the optimal number of clusters.  It describes the cohesion of the 
      # clusters in relation to the number of clusters. This will be realized through the WSS. 
      # The smaller the number the coherent the cluster is. So after 3 to 4 clusters, the coherent 
      # doesn't improve noticeably so 3 to 4 clusters are optimal. 

# Method 2: Use the NbClust library, which runs many experiments
# and gives a distribution of potential number of clusters.

library(NbClust)
set.seed(1234)
nc <- NbClust(df, min.nc=2, max.nc=15, method="kmeans")
barplot(table(nc$Best.n[1,]),
	          xlab="Numer of Clusters", ylab="Number of Criteria",
		            main="Number of Clusters Chosen by 26 Criteria")


# Exercise 3: How many clusters does this method suggest? 
  # Answer: 3 Clusters 


# Exercise 4: Once you've picked the number of clusters, run k-means 
# using this number of clusters. Output the result of calling kmeans()
# into a variable fit.km

set.seed(1234)
fit.km <- kmeans(df, 3, nstart=25)                           
fit.km$size

fit.km$centers  

# Now we want to evaluate how well this clustering does.

# Exercise 5: using the table() function, show how the clusters in fit.km$clusters
# compares to the actual wine types in wine$Type. Would you consider this a good
# clustering?

aggregate(wine[-1], by=list(cluster=fit.km$cluster), mean)
ct.km <- table(wine$Type, fit.km$cluster)
ct.km

  # Answer: The table shows how many observations are in each cluster. 
  # It´s important that there are not too many clusters with 
  # just a few observations, because it may make it difficult to interpret the 
  # results. For the three cluster solution, the table looks fine. 


# Exercise 6:
# * Visualize these clusters using  function clusplot() from the cluster library
# * Would you consider this a good clustering?

cs <- clusplot(df, fit.km$cluster)
 
  # Answer: This is a good clustering because the clusters are not redundant and 
  # there are no overservations which aren´t within a cluster. 