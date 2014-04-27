#-------------------------------------------------------------------------------
# run_analysis.R
# Author: Alex Kahn
# Description: please see the file README.md and Codebook.md for more info.
#-------------------------------------------------------------------------------
setwd("C:/Users/Owner/Documents/Coursera/UCI HAR Dataset/")


X_test <-read.table("test/X_test.txt")
y_test <-read.table("test/y_test.txt")
subject_test <-read.table("test/subject_test.txt")

X_train <- read.table("train/X_train.txt")
y_train <- read.table("train/y_train.txt")
subject_train <- read.table("train/subject_train.txt")

features <- read.table("features.txt", stringsAsFactors=FALSE)

# This will give us all the names, but we only want means and SDs
names(X_test)<- features$V2

# Let's use regex to find the ones we want
# grep will search the text for matches and give us the indecies
means <- grep("[Mm]ean",features$V2) # gives us mean() & The Means calculated
                                     # for the angle() variables
x1 <- grep("meanFreq()", features$V2) # gives us just meanFreq() vars we don't
                                      # want to keep.
x2 <- grep("mean()", features$V2) # just for testing/ debugging

keep_cols_index <- setdiff(means,x1)
stds <- grep("[Ss]td", features$V2)

# now we can subset X_test for those columns and give them names
X_test <- X_test[,c(keep_cols_index,stds)]
names(X_test) <- features$V2[c(keep_cols_index, stds)]
X_train <- X_train[,c(keep_cols_index,stds)]
names(X_train) <- features$V2[c(keep_cols_index, stds)]

# get our labels together - name some columns
levels <- c("WALKING", "WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS",
            "SITTING", "STANDING", "LAYING")
names(y_test) <- "activity"
y_test$activity <- as.factor(y_test$activity)
levels(y_test$activity) <- levels

names(y_train) <- "activity"
y_train$activity <- as.factor(y_train$activity)
levels(y_train$activity) <- levels

# subject_test - the id of the subject from whom the data were collected.
names(subject_test) <- "subject_id"
names(subject_train) <- "subject_id"


test <- cbind(subject_test, y_test, X_test)
train <- cbind(subject_train, y_train, X_train)
full <- merge(test, train, all=TRUE)

    
# Creates a second, independent tidy data set with the average of each variable
#  for each activity and each subject. 

library(reshape2)
fullMelt <- melt(full, id.vars = c("activity","subject_id"), measure.variables=3:75)
tidy_data <- acast(fullMelt, subject_id ~ variable ~ activity, mean)
save(tidy_data,file="tidy_UCI_HAR_dataset_averages_by_subject_and_activity.txt")
