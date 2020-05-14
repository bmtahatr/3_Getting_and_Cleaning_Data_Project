# This section is dedicated to the download and unzip the of dataset:
if (!file.exists(filename)){
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
    download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
    unzip(filename) 
}
# This section is dedicated to the load of the anted features
packages <- c("data.table", "reshape2")
activityLabels <- fread(file.path(path, "UCI HAR Dataset/activity_labels.txt"), col.names = c("classLabels", "activityName"))
features <- fread(file.path(path, "features.txt"), col.names = c("index", "featureNames"))
featuresWanted <- grep("(mean|std)\\(\\)", features[, featureNames])
measurements <- features[featuresWanted, featureNames]
measurements <- gsub('[()]', '', measurements)
# This section is dedicated to the load of the train datasets
train <- fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))[, featuresWanted, with = FALSE] 
data.table::setnames(train, colnames(train), measurements)
trainActivities <- fread(file.path(path, "UCI HAR Dataset/train/Y_train.txt"), col.names = c("Activity"))
trainSubjects <- fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt"), col.names = c("SubjectNum"))
# This section is dedicated to the load of the test datasets
test <- fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))[, featuresWanted, with = FALSE]
data.table::setnames(test, colnames(test), measurements)
testActivities <- fread(file.path(path, "UCI HAR Dataset/test/Y_test.txt"), col.names = c("Activity"))
testSubjects <- fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt"), col.names = c("SubjectNum"))
test <- cbind(testSubjects, testActivities, test)
# This section is dedicated to the merge of the train and test datasets
combined <- rbind(train, test)
combined[["Activity"]] <- factor(combined[, Activity], levels = activityLabels[["classLabels"]]
                                  , labels = activityLabels[["activityName"]])
combined[["SubjectNum"]] <- as.factor(combined[, SubjectNum])
combined <- reshape2::melt(data = combined, id = c("SubjectNum", "Activity"))
combined <- reshape2::dcast(data = combined, SubjectNum + Activity ~ variable, fun.aggregate = mean)
# This instruction is dedecated to the generation of the new tidy formated dataset
data.table::fwrite(x = combined, file = "tidyData.txt", quote = FALSE)