library(readxl)
library(dplyr)
library(tidyr)

# 1. Load the data

setwd("../Dealing with missing values")
titanic = read_excel("titanic3.xls")

# 2. Replacing missing values 

# 2.1 Port of embarkation
# Find the missing values and replace them with S. 

titanic$embarked = replace_na(titanic$embarked, "S")

# 2.2 Age
# Calculate the mean of the Age column and use that value to populate the missing values. 

titanic$age = replace_na(titanic$age, mean(titanic$age, na.rm = T))

titanic$age = round(titanic$age, 0) 


# 2.3 Lifeboat
# Fill the missings with a dummy value e.g. the string 'None' or 'NA'. 

titanic$boat = replace_na(titanic$boat, "None")

# 2.4 Cabin
# Create a new column has_cabin_number which has 1 if there is a cabin number, and 0 otherwise.

titanic$has_cabin_number = ifelse(is.na(titanic$cabin) == TRUE, 1,0)


## 3. Save the data

write.csv(titanic, file = "titanic_clean.csv")
