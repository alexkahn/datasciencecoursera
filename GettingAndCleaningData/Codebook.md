Codebook for run_analysis.R
===========================
## Or, how come arbitrary decisions were made.
Before we get started, here are the labels used to re-codify the data available in the `y_test.txt` and `y_train.txt` files.
### Activity labels (from activity_labels.txt)

1. WALKING
2. WALKING_UPSTAIRS
3. WALKING_DOWNSTAIRS
4. SITTING
5. STANDING
6. LAYING

Since these are pretty descriptive (not interested in defining things like "Walking") let's get moving.

### Varibles
Since I was trained to use descriptive names for variables, I think they'll mostly describe themselves but since some people are picky with respect to directions, here's a go at it:

* `subject_id` : (int) used to identify a specific person whose data are being observed and collected (30 total)
* `activity` : (factor) used to identify the specific action a subject is performing (6 total, described above)
* others: variables used as containers for intermediate operations which do not end up in the final files/ objects.

### Data
The data used in this cleaning were obtained from [UCI's Machine Learning Repository](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones) while the files used in the analysis are located on the Peer Assesment page for the course.

## The Cleaning Bit
**Note**: Make sure you are in a directory that contains all of the data files.
First, let's read in our data files, since there are only six, we may not get any extra ground by automating this process; even though it would be easy to set-up.

```
X_test <-read.table("test/X_test.txt")
y_test <-read.table("test/y_test.txt")
subject_test <-read.table("test/subject_test.txt")

X_train <- read.table("train/X_train.txt")
y_train <- read.table("train/y_train.txt")
subject_train <- read.table("train/subject_train.txt")

features <- read.table("features.txt", stringsAsFactors=FALSE)
```
Now that we have our files ready, let's see what we can do about the column names.
```{r}
# This will give us all the names, but we only want means and SDs
names(X_test)<- features$V2
```
Well that's unfortunate. We really don't want to have to have to pick the one's out we don't want to keep. Luckily, `grep` exists. So, let's use regular expressions (not very interesting ones) to find the column names we want to keep. Since `grep` returns indicies where all the "hits" are, we can hold on to those for later.
```{r}
means <- grep("[Mm]ean",features$V2)    # gives us mean() & The Means calculated
                                        # for the angle() variables
x1 <- grep("meanFreq()", features$V2)   # gives us just meanFreq() vars we don't
                                        # want to keep.

keep_cols_index <- setdiff(means,x1)
stds <- grep("[Ss]td", features$V2)
```
So we've got our column names accounted for, now we want to focus on subsetting our `X` data frames.
```{r}
X_test <- X_test[,c(keep_cols_index,stds)]
names(X_test) <- features$V2[c(keep_cols_index, stds)]
X_train <- X_train[,c(keep_cols_index,stds)]
names(X_train) <- features$V2[c(keep_cols_index, stds)]
```
Now we've got our two big data frames with the proper column dimensions and column names. Next, we'll tackle the `y` side of our test and train data.
```{r}
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
```
Now we're cooking. We've got everything `merge()` needs to give us what we want. So without further ado, let's put these things together.

```{r}
test <- cbind(subject_test, y_test, X_test)
train <- cbind(subject_train, y_train, X_train)
full <- merge(test, train, all=TRUE)
```
This next chunk of code creates a second, independent tidy data set with the average of each variable for each activity and each subject. 
```{r}
library(reshape2)
fullMelt <- melt(full, id.vars = c("activity","subject_id"), measure.variables=3:75)
tidy_data <- acast(fullMelt, subject_id ~ variable ~ activity, mean)
save(tidy_data,file="tidy_UCI_HAR_dataset_averages_by_subject_and_activity.RData" )
```
There you have it! A clean data frame and another file with some summary data!