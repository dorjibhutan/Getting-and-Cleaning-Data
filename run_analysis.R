library(dplyr)
Url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
File <- "UCI HAR Dataset.zip"
if (!file.exists(File)) {
        download.file(Url, File, mode = "wb")
}
Path <- "UCI HAR Dataset"
if (!file.exists(Path)) {
        unzip(File)
}
trainingSubjects <- read.table(file.path(Path, "train", "subject_train.txt"))
trainingValues <- read.table(file.path(Path, "train", "X_train.txt"))
trainingActivity <- read.table(file.path(Path, "train", "y_train.txt"))
testSubjects <- read.table(file.path(Path, "test", "subject_test.txt"))
testValues <- read.table(file.path(Path, "test", "X_test.txt"))
testActivity <- read.table(file.path(Path, "test", "y_test.txt"))
features <- read.table(file.path(Path, "features.txt"), as.is = TRUE)
activities <- read.table(file.path(Path, "activity_labels.txt"))
colnames(activities) <- c("activityId", "activityLabel")
humanActivity <- rbind(
        cbind(trainingSubjects, trainingValues, trainingActivity),
        cbind(testSubjects, testValues, testActivity)
)
rm(trainingSubjects, trainingValues, trainingActivity, 
   testSubjects, testValues, testActivity)
colnames(humanActivity) <- c("subject", features[, 2], "activity")
columnsToKeep <- grepl("subject|activity|mean|std", colnames(humanActivity))
humanActivity <- humanActivity[, columnsToKeep]
humanActivity$activity <- factor(humanActivity$activity, 
                                 levels = activities[, 1], labels = activities[, 2])
humanActivityCols <- colnames(humanActivity)
humanActivityCols <- gsub("[\\(\\)-]", "", humanActivityCols)
humanActivityCols <- gsub("^f", "frequencyDomain", humanActivityCols)
humanActivityCols <- gsub("^t", "timeDomain", humanActivityCols)
humanActivityCols <- gsub("Acc", "Accelerometer", humanActivityCols)
humanActivityCols <- gsub("Gyro", "Gyroscope", humanActivityCols)
humanActivityCols <- gsub("Mag", "Magnitude", humanActivityCols)
humanActivityCols <- gsub("Freq", "Frequency", humanActivityCols)
humanActivityCols <- gsub("mean", "Mean", humanActivityCols)
humanActivityCols <- gsub("std", "StandardDeviation", humanActivityCols)
humanActivityCols <- gsub("BodyBody", "Body", humanActivityCols)
colnames(humanActivity) <- humanActivityCols
humanActivityMeans <- humanActivity %>% 
        group_by(subject, activity) %>%
        summarise_all(funs(mean))
write.table(humanActivityMeans, "tidy_data.txt", row.names = FALSE, 
            quote = FALSE)
