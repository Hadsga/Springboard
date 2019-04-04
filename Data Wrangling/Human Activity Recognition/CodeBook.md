#### Packages

    library(tidyverse)

### 1 Description of the dataset

The "Human Activity Recognition" dataset is built from the recordings of
30 subjects performing activities of daily living while carrying a
waist-mounted smartphone with embedded inertial sensors. The dataset is
available at the following URL:
<https://archive.ics.uci.edu/ml/machine-learning-databases/00240/UCI%20HAR%20Dataset.zip>

The experiments have been carried out with a group of 30 volunteers
within an age bracket of 19-48 years. Each person performed six
activities (WALKING, WALKING\_UPSTAIRS, WALKING\_DOWNSTAIRS, SITTING,
STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the
waist. Using its embedded accelerometer and gyroscope, we captured
3-axial linear acceleration and 3-axial angular velocity at a constant
rate of 50Hz. The experiments have been video-recorded to label the data
manually. The obtained dataset has been randomly partitioned into two
sets, where 70% of the volunteers were selected for generating the
training data and 30% the test data.

The sensor signals (accelerometer and gyroscope) were pre-processed by
applying noise filters and then sampled in fixed-width sliding windows
of 2.56 sec and 50% overlap (128 readings/window). The sensor
acceleration signal, which has gravitational and body motion components,
was separated using a Butterworth low-pass filter into body acceleration
and gravity. The gravitational force is assumed to have only
low-frequency components, therefore a filter with 0.3 Hz cutoff
frequency was used. From each window, a vector of features was obtained
by calculating variables from the time and frequency domain.

Data:

-   "features": List of all features.
-   "subject\_train"/"subject\_test": An ID of the subject who carried
    out the experiment.
-   "y\_train/"y\_test": The activity labels.
-   "X\_train"/"X\_test": The training and the testing data.

### 2 Load the data in RStudio

The first task is to load the training and test datasets into RStudio,
each in their own data frame.

    X_train = read.table("C:/Users/X1/Desktop/Springboard Data/UCI HAR Dataset/train/X_train.txt", quote="\"", comment.char="")

    y_train = read.table("C:/Users/X1/Desktop/Springboard Data/UCI HAR Dataset/train/y_train.txt", quote="\"", comment.char="")

    subject_train = read.table("C:/Users/X1/Desktop/Springboard Data/UCI HAR Dataset/train/subject_train.txt", quote="\"", comment.char="")

    X_test = read.table("C:/Users/X1/Desktop/Springboard Data/UCI HAR Dataset/test/x_test.txt", quote="\"", comment.char="")

    y_test = read.table("C:/Users/X1/Desktop/Springboard Data/UCI HAR Dataset/test/y_test.txt", quote="\"", comment.char="")

    subject_test = read.table("C:/Users/X1/Desktop/Springboard Data/UCI HAR Dataset/test/subject_test.txt", quote="\"", comment.char="")

    features = read.table("C:/Users/X1/Desktop/Springboard Data/UCI HAR Dataset/features.txt", quote="\"", comment.char="")

### 3 Merge data sets

Initially, the column names (variables) will be assigned to
`x_train/x_test`. The column names for both data sets are the values of
the variable `features` because they represent the different
measurements.

    glimpse(features)

    ## Observations: 561
    ## Variables: 2
    ## $ V1 <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, ...
    ## $ V2 <fct> tBodyAcc-mean()-X, tBodyAcc-mean()-Y, tBodyAcc-mean()-Z, tB...

To assign the features to `X_train` and `X_test` the `colnames` function
of the `dplyr`package is used.

    colnames(X_train) = features$V2
    colnames(X_test) = features$V2

The columns (variables) of `y_train/y_test` and the
`subject_train/subject_test` have the same names.

    colnames(y_train)

    ## [1] "V1"

    colnames(y_test)

    ## [1] "V1"

    colnames(subject_train)

    ## [1] "V1"

    colnames(subject_test)

    ## [1] "V1"

Since `subject_train/subject_test` are the ID´s of `y_train/y_test` they
have to be merged. This is only possible if the names of the columns are
distinct. Therefore they will be renamed. `y_train/y_test` will get the
the name `activity` and `subject_train/subject_test` will get the colum
names `subject`

    y_train = rename(y_train, activity = V1)
    y_test = rename(y_test, activity = V1)

    subject_train = rename(subject_train, subject = V1)
    subject_test = rename(subject_test, subject = V1)

Then, the activity labels and subjects will be added to the training and
testing data.

    train = cbind(subject_train, y_train, X_train)
    test = cbind(subject_test, y_test, X_test)

Now, the training and the test sets will be be merged to create one data
set.

    total = rbind(train, test)

### 4 Mean and standard deviation

The next task is to create two new columns, containing the mean and
standard deviation for each measurement respectively. To handle this all
columns will be filtered out which contains a mean or a standard
derivation. First, the `make.names` and the `name` function has to be
applied in order to select the column names probably. Then, those
columns will be selected that contains the character "mean" and the
character "std". This will be done through the `select` function using
the `contains` option.

    column_names = make.names(names=names(total), 
                               unique=TRUE, 
                               allow_ = TRUE)

    names(total) = column_names

    total_mean_std = total %>% select(activity, 
                                      subject, 
                                      contains("mean"), 
                                      contains("std"))


    total_mean_std[1:6] %>% head()

    ##   activity subject tBodyAcc.mean...X tBodyAcc.mean...Y tBodyAcc.mean...Z
    ## 1        5       1         0.2885845       -0.02029417        -0.1329051
    ## 2        5       1         0.2784188       -0.01641057        -0.1235202
    ## 3        5       1         0.2796531       -0.01946716        -0.1134617
    ## 4        5       1         0.2791739       -0.02620065        -0.1232826
    ## 5        5       1         0.2766288       -0.01656965        -0.1153619
    ## 6        5       1         0.2771988       -0.01009785        -0.1051373
    ##   tGravityAcc.mean...X
    ## 1            0.9633961
    ## 2            0.9665611
    ## 3            0.9668781
    ## 4            0.9676152
    ## 5            0.9682244
    ## 6            0.9679482

### 5 Adding new variables

Now, two new variables will be created called `ActivityLabel` and
`ActivityName` that label all observations with the corresponding
activity labels and names respectively. The variable `ActivityLabel` is
created through the `rename` function of the `dplyr` package. For the
variable `ActivityName` the `mutate` function of the `dplyr` package and
the `ifelese` function is used.

    total_new_columns = total_mean_std %>% 
      rename(ActivityLabel = activity)


    total_new_columns = total_new_columns %>% 
      mutate(ActivityName = ifelse(ActivityLabel == 1, "WALKING", 
                            ifelse(ActivityLabel == 2, "WALKING_UPSTAIRS", 
                            ifelse(ActivityLabel == 3, "WALKING_DOWNSTAIRS", 
                            ifelse(ActivityLabel == 4, "SITTING",
                            ifelse(ActivityLabel == 5, "STANDING",
                            ifelse(ActivityLabel == 6, "LAYING", NA)))))))

    total_new_columns = total_new_columns %>% 
      select(subject, 
             ActivityName, 
             ActivityLabel, 
             everything())

    total_new_columns[1:2] %>% head()

    ##   subject ActivityName
    ## 1       1     STANDING
    ## 2       1     STANDING
    ## 3       1     STANDING
    ## 4       1     STANDING
    ## 5       1     STANDING
    ## 6       1     STANDING

### 6 Creating tidy data set

Finally, an independent tidy data set with the average of each variable
for each activity and each subject has to be created. For this task,
only the variables `subject`, `ActivityLabel` and `ActivityName` will be
selected. Moreover, all variables will be selected which contains the
character "mean". This is carried out through the `select` an `contains`
function of the `dplyr` package. Then, the dataset will be saved as
`tidy_data_set.Rda`.

    tidy_data_set = total_new_columns %>% 
      select(subject, ActivityLabel, ActivityName, contains("mean"))

    save(tidy_data_set,file="tidy_data_set.Rda")
