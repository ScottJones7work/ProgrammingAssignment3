## Load the packages I'll need later
install.packages("reshape2")
install.packages("data.table")
packages <- c("data.table", "reshape2")
sapply(packages, require, character.only=TRUE, quietly=TRUE)

## get the working directory, then bring the file from internet location
## then unzip it
path <- getwd()
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(path, "dataFiles.zip"))
unzip(zipfile = "dataFiles.zip")

## Bring in the activity labels and limit to mean and std dev
activityLabels <- fread(file.path(path, "UCI HAR Dataset/activity_labels.txt"), col.names = c("classLabels", "activityName"))
features <- fread(file.path(path, "UCI HAR Dataset/features.txt"), col.names = c("index", "featureNames"))
featuresWanted <- grep("(mean|std)\\(\\)", features[, featureNames])
measurements <- features[featuresWanted, featureNames]
measurements <- gsub('[()]', '', measurements)

# Bring in the training datasets
train <- fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))[, featuresWanted, with = FALSE]
data.table::setnames(train, colnames(train), measurements)
trainActivities <- fread(file.path(path, "UCI HAR Dataset/train/Y_train.txt")
, col.names = c("Activity"))
trainSubjects <- fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt")
, col.names = c("SubjectNum"))
train <- cbind(trainSubjects, trainActivities, train)

## Bring in the test datasets
test <- fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))[, featuresWanted, with = FALSE]
data.table::setnames(test, colnames(test), measurements)
testActivities <- fread(file.path(path, "UCI HAR Dataset/test/Y_test.txt"), col.names = c("Activity"))
testSubjects <- fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt"), col.names = c("SubjectNum"))
test <- cbind(testSubjects, testActivities, test)

## merge the two together
bothtables <- rbind(train, test)

## Change the variable names
bothtables[["Activity"]] <- factor(bothtables[, Activity], levels = activityLabels[["classLabels"]], labels = activityLabels[["activityName"]])
bothtables[["SubjectNum"]] <- as.factor(bothtables[, SubjectNum])
bothtables <- reshape2::melt(data = bothtables, id = c("SubjectNum", "Activity"))
bothtables <- reshape2::dcast(data = bothtables, SubjectNum + Activity ~ variable, fun.aggregate = mean)

## and finally…
write.table(x=bothtables,file = "tidyData.csv",quote = FALSE)
