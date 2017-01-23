
## Coursera: Getting and Cleaning Data
## Final assignment
## By: Quan Luong

setwd("D:/Coursera/Course 3/getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset")

## 1. Merges the training and the test sets to create one data set. 

## Load training data

train_x <- read.table("train/X_train.txt")

## Load test data
test_x <- read.table ("test/X_test.txt")

## Merge train with test
x <- rbind( train_x, test_x )

# remove train_x and test_x after merging them into 1 dataset
rm( train_x, test_x )

## Merge activities 

train_y <- read.table("train/y_train.txt")
test_y <- read.table("test/y_test.txt")
y <- rbind( train_y, test_y )
names( y )[1] <- "activity"
rm( train_y, test_y )

## Merge subjects

train_sub <- read.table("train/subject_train.txt")
test_sub <- read.table("test/subject_test.txt")
subjects <- rbind(train_sub, test_sub)
rm(train_sub, test_sub)

## 2. Extracts the measurements on mean and standard deviation ------------------

## Load features
features <- read.table("features.txt",
  col.names = c( 'id', 'name' ))

## Exstract only the std() and mean() columns
data <- x[, grep( 'std\\(\\)|mean\\(\\)', features[,2] )]
rm(x)

## Create a vector containing column names of std() and mean()
polished_names = grep( 'std\\(\\)|mean\\(\\)', features[,2], value=TRUE )

## Polish the names.

transform <- list(
  '^t([A-Z]{1})'   = 'Time\\1',
  '^f([A-Z]{1})'   = 'Frequency\\1',
  'mean\\(\\)'     = 'Mean',
  'std\\(\\)'      = 'StandardDeviation',
  'Acc'            = 'Acceleration',
  'Mag'            = 'Magnitude'
)

for(regex in names(transform) ){
  polished_names <- sub(regex, transform[regex], polished_names, fixed=FALSE )
}

## Remove '-' and '_'
polished_names <- gsub( '-', '', polished_names, fixed=TRUE )
polished_names <- gsub( '_', '', polished_names, fixed=TRUE )

## Lowercase the column names
names(data) <- tolower(polished_names)

## 3. Uses descriptive activity names --------------------------------

## Load activities
activities <- read.table("activity_labels.txt", 
  col.names=c("id", "name"))

## Tidy the strings: lowercase and no underscores
activities[,2] <- tolower( activities[,2] )
activities[,2] <- gsub( '_', '', activities[,2], fixed=TRUE )


## Factorize values in y for respective activities
y[,1] = as.factor(activities[y[,1], 2])

## 4. Appropriately labels the data set with descriptive variable names -------

## Other descriprive variable names were already handled above #2.
names(subjects) <- "subject"

## Bind all the columns togeder to form tidy_data
tidy_data <- cbind(subjects, y, data)

## 5. Creates a second, independent tidy data set 
##    with the average of each variable for each activity and each subject
## using packages plyr  ------

library(plyr)
second_tidy_data <- ddply(tidy_data, .(subject, activity), 
                          function(x) colMeans(x[, 3:68]))

## Write the file

write.table(second_tidy_data, file="second_tidy_data.txt", row.names=FALSE )
