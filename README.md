# Getting And Cleaning Data

With the data set being used: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

To eventually come up with a tidy data set for later analysis in the project, all primary requirements below need to be fulfilled:

1.	Merges the training and the test sets to create one data set.

2.	Extracts only the measurements on the mean and standard deviation for each measurement.

3.	Uses descriptive activity names to name the activities in the data set

4.	Appropriately labels the data set with descriptive variable names.

5.	From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject

In run_analysis.R, we can find all steps needed to meet these requirements and more importantly, come up with a final tidy data set, basically:

1. Load training and test sets and merge them into one.

2. Load features info and keep only feature columns containing standard deviation and mean as well as polish the names of these extracted columns.

3. Load activities, polish activities names to apply these names with the corresponding code

4. Bind data with features, subject and activities

5. Create second tidy data that summarize mean of each of the features of each person in each activity.

