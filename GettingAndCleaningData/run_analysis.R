# Merges the training and the test sets to create one data set.
# Extracts only the measurements on the mean and standard deviation for each 
#  measurement. 
# Uses descriptive activity names to name the activities in the data set
# Appropriately labels the data set with descriptive activity names. 
# Creates a second, independent tidy data set with the average of each variable
#  for each activity and each subject. 

list.files(), list.dirs() # look for "test" and "train" dirs.
                          # read in the necessary files

# Make sure you are in a directory that contains all of the data files.
# read in the data from test first, it's smaller.



X_test <-read.table("test/X_test.txt")
y_test <-read.table("test/y_test.txt")
subject_test <-read.table("test/subject_test.txt")
X_train <- read.table("train/X_train.txt")
y_train <- read.table("train/y_train.txt")
subject_train <- read.table("train/subject_train.txt")
features <- read.table("features.txt", stringsAsFactors=FALSE)
# This will give us all the names, but we only want means and SDs
names(X_test)<- t(features$V2)

# Let's use regex to find the ones we want
means <- grep("[Mm]ean",features$V2) # be sure about these boys.
stds <- grep("[Ss]td", features$V2)

# now we can subset X_test for those columns
X_test <- X_test[,c(means,stds)]
#-------------------------------------------------------------------------------
# Activity labels - y_test & y_train
# 1 WALKING
# 2 WALKING_UPSTAIRS
# 3 WALKING_DOWNSTAIRS
# 4 SITTING
# 5 STANDING
# 6 LAYING
#-------------------------------------------------------------------------------
# Activity labels
labels<-list("1"="WALKING", "2"="WALKING_UPSTAIRS", "3"="WALKING_DOWNSTAIRS",
             "4"="SITTING", "5"="STANDING", "6"="LAYING")

# get our labels together - name some columns
levels <- c("WALKING", "WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS",
            "SITTING", "STANDING", "LAYING")
names(y_test) <- "activity"
activity_factors <- as.factor(y_test$activity)
levels(activity_factors) <- levels

# subject_test - the id of the subject from whom the data were collected.
names(subject_test) <- "subject_id"