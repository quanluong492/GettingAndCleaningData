
## run_analysis.R
##
## Coursera: Getting and Cleaning Data
## Final assignment
##
## By: Quan Luong

setwd("D:/Coursera/Course 3/getdata_projectfiles_UCI HAR Dataset")
## The default data directory
##
data_directory <- 'UCI HAR Dataset'


## The assignment calls for the script to be runnable as long as the working
## directory contains "Samsung Data" (unclear)
##
## As long as the train and test directories are found, the script will assume
## it's been place into the root directory of the source package data.
##
if( dir.exists( "train" ) & dir.exists( "test" ) ){
  data_directory <- '.'
}


##
## 1. Merges the training and the test sets to create one data set. 

## Load training data

train_x <- read.table (
  file.path( data_directory, "train", "X_train.txt" ),
  header       = FALSE,
  dec          = ".",
  fill         = TRUE,
  comment.char = "",
  colClasses   = sapply( train_x, class )
)

## Load test data

test_x <- read.table (
  file.path( data_directory, "test", "X_test.txt" ),
  header       = FALSE,
  dec          = ".",
  fill         = TRUE,
  comment.char = "",
#  colClasses   = sapply( test_x, class )
)

## Merge train with test

x <- rbind( train_x, test_x )

# remove train_x and test_x after merging them into 1 dataset
rm( train_x, test_x )

## Merge activities 

train_y <- read.table ( file.path( data_directory, "train", "y_train.txt" ) )
test_y <- read.table ( file.path( data_directory, "test", "y_test.txt" ) )
y <- rbind( train_y, test_y )
names( y )[1] <- "activity"
rm( train_y, test_y )

## Merge subjects

train_sub <- read.table(file.path(data_directory,"train","subject_train.txt"))
test_sub <- read.table(file.path(data_directory, "test", "subject_test.txt" ))

subjects <- rbind(train_sub, test_sub)
rm(train_sub, test_sub)


## 2. Extracts the measurements on mean and standard deviation ------------------

## Load features
features <- read.table(
  file.path( data_directory, 'features.txt' ),
  col.names = c( 'id', 'name' )
)

## Exstract only the std() and mean() columns
data <- x[, grep( 'std\\(\\)|mean\\(\\)', features[,2] )]
rm( x )

## Create a vector of names to tidy-up
sanitized_names = grep( 'std\\(\\)|mean\\(\\)', features[,2], value=TRUE )


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
names( data ) <- tolower( polished_names )

## 3. Uses descriptive activity names --------------------------------

## Load activities
activities <- read.table(
  file.path(data_directory,"activity_labels.txt"), 
  col.names=c('id', 'name'))

## Tidy the strings: lowercase and no underscores
activities[,2] <- tolower( activities[,2] )
activities[,2] <- gsub( '_', '', activities[,2], fixed=TRUE )


## Character variables when applicable should be factors
y[,1] = as.factor( activities[y[,1], 2] )

## 4. Appropriately labels the data set with descriptive variable names -------

## Other descriprive variable names were already handled above #2.
names( subjects ) <- "subject"


## Bind all the columns togeder to form tidy_data
tidy_data <- cbind( subjects, y, data )

## 5. Creates a second, independent tidy data set 
##    with the average of each variable for each activity and each subject.------

## Generate subject.activity groups

grouped <- split(
  tidy_data,
  as.factor( paste( tidy_data$subject, tidy_data$activity, sep="." ) )
)

## sapply() the Colmeans to generate the report. t() transposes the result.

report <- data.frame(
  t(
    sapply( grouped, function(x){ colMeans( x[, 3:68 ], na.rm=TRUE ) } )
  )
)

## Reinsert subject and activity columns

activity <- as.factor( sub( '(\\d+)\\.(.*)', '\\2', rownames( report ) ) )
subject  <- as.numeric( sub( '(\\d+)\\.(.*)', '\\1', rownames( report ) ) )
rownames( report ) <- NULL

## Bind all the rows into a single report
report <- cbind( "subject" = subject, "activity" = activity, report )
report <- report[ order( report$subject, report$activity ), ]

dim(report)

## Write the report file

write.table( report, file="independent_tidy_data.txt", row.names=FALSE )
