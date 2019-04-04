library(dplyr)
library(tidyr)
library(stringr)


X_train = read.table("C:/Users/X1/Desktop/Springboard Data/UCI HAR Dataset/train/X_train.txt", quote="\"", comment.char="")
y_train = read.table("C:/Users/X1/Desktop/Springboard Data/UCI HAR Dataset/train/y_train.txt", quote="\"", comment.char="")
subject_train = read.table("C:/Users/X1/Desktop/Springboard Data/UCI HAR Dataset/train/subject_train.txt", quote="\"", comment.char="")
X_test = read.table("C:/Users/X1/Desktop/Springboard Data/UCI HAR Dataset/test/x_test.txt", quote="\"", comment.char="")
y_test = read.table("C:/Users/X1/Desktop/Springboard Data/UCI HAR Dataset/test/y_test.txt", quote="\"", comment.char="")
subject_test = read.table("C:/Users/X1/Desktop/Springboard Data/UCI HAR Dataset/test/subject_test.txt", quote="\"", comment.char="")
features = read.table("C:/Users/X1/Desktop/Springboard Data/UCI HAR Dataset/features.txt", quote="\"", comment.char="")


colnames(X_train) = features$V2
y_train = rename(y_train, activity = V1)
subject_train = rename(subject_train, subject = V1)
train = cbind(subject_train, y_train, X_train)


colnames(X_test) = features$V2
y_test = rename(y_test, activity = V1)
subject_test = rename(subject_test, subject = V1)
test = cbind(subject_test, y_test, X_test)

total = rbind(train, test)


column_names = make.names(names=names(total), 
                           unique=TRUE, 
                           allow_ = TRUE)

names(total) = column_names

total_mean_std = total %>% select(activity, 
                                   subject, 
                                   contains("mean"), 
                                   contains("std"))

total_mean_std = total_mean_std %>% rename(ActivityLabel = activity)


total_new_columns = total_mean_std %>% 
  mutate(ActivityName = ifelse(ActivityLabel == 1, "WALKING", 
                        ifelse(ActivityLabel == 2, "WALKING_UPSTAIRS", 
                        ifelse(ActivityLabel == 3, "WALKING_DOWNSTAIRS", 
                        ifelse(ActivityLabel == 4, "SITTING",
                        ifelse(ActivityLabel == 5, "STANDING",
                        ifelse(ActivityLabel == 6, "LAYING", NA)))))))

total_new_columns = total_new_columns %>% 
  select(subject, ActivityName, ActivityLabel, everything())

tidy_data_set = total_new_columns %>% 
  select(subject, ActivityLabel, ActivityName, subject, contains("mean"))

save(tidy_data_set,file="tidy_data_set.Rda")
