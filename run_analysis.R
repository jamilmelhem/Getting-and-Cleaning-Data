# Script does the following 
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

#install required packages if not installed
if (!require("data.table")) { install.packages("data.table") }
if (!require("reshape2")) { install.packages("reshape2") }

#load required packages
library("data.table")
library("reshape2")

# read data into data frames
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")
feature_names <- read.table("UCI HAR Dataset/features.txt")
X_test_data <- read.table("UCI HAR Dataset/test/X_test.txt")
y_test_data <- read.table("UCI HAR Dataset/test/y_test.txt")
X_train_data <- read.table("UCI HAR Dataset/train/X_train.txt")
y_train_data <- read.table("UCI HAR Dataset/train/y_train.txt")

# Assign header column names
names(subject_test) <- "Subject_ID"
names(subject_train) <- "Subject_ID"
names(X_test_data) <- feature_names[,2]
names(X_train_data) <- feature_names[,2]
names(y_train_data) <- "Activity_ID"
names(y_test_data) <- "Activity_ID"
names(activity_labels) <- c("Activity_ID", "Activity_Label")


# reduce x test and train columns to only mean and std columns
desired_features = grepl("mean|std", feature_names[,2])
X_test_data = X_test_data[,desired_features]
X_train_data = X_train_data[,desired_features]

# Load activity labels
y_test_data = merge(y_test_data,activity_labels,all=TRUE)
y_train_data = merge(y_train_data,activity_labels,all=TRUE)

# Bind data
combined_test_data <- as.data.table(cbind(subject_test, y_test_data, X_test_data))
combined_train_data <- as.data.table(cbind(subject_train, y_train_data, X_train_data))
combined_data = rbind(combined_test_data, combined_train_data)

# unpivot, compute mean and pivot back
id_labels = names(combined_data[,1:3])
data_labels = setdiff(colnames(combined_data), id_labels)
melt_data = melt(combined_data, id = id_labels, measure.vars = data_labels)
tidy_data   = dcast(melt_data, Subject_ID + Activity_ID + Activity_Label ~ variable, mean)

#write tidy data to a file
write.table(tidy_data, file = "tidy_data.txt",row.name=FALSE)