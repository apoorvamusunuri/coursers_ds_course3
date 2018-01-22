url = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url = url, destfile = "./data.zip", method = "curl")

#Files were downloaded and extracted (code not shown)

#Reading in all the files:
wd<-getwd()
folder <- file.path(wd, "UCI HAR Dataset")
subject_test <- fread(file.path(folder, "test", "subject_test.txt"))
X_test <- fread(file.path(folder, "test", "X_test.txt"))
Y_test <- fread(file.path(folder, "test", "Y_test.txt"))

subject_train <- fread(file.path(folder, "train", "subject_train.txt"))
X_train <- fread(file.path(folder, "train", "X_train.txt"))
Y_train <- fread(file.path(folder, "train", "Y_train.txt"))

#To know what columns are means, extract features.txt that contains feature number and feature names:
features <- fread(file.path(folder, "features.txt"))
setnames(features, names(features), c("feature_num", "feature_name"))

#1. Merging test and train set: now, I am combining the test and train files: subject_train/test, X_train/test and Y_train/test
subject <- rbind(subject_test, subject_train)
setnames(subject, "V1", "subject")
head(subject)

X <- rbind(X_test, X_train)
setnames(X, names(X), features$feature_name)
head(X)
names(X)

Y <- rbind(Y_test, Y_train)
setnames(Y, "V1", "activity_num")
head(Y)

combined <- cbind(subject, X, Y)

#2. Extract only the measurements on the mean and standard deviation for each measurement:
head(combined)
names(combined)

#set key:
setkey(combined,subject,activity_num)

#select only features with mean/standard deviantion in name:
sub_feat <- features[grepl("mean\\(\\)|std\\(\\)", features$feature_name),]
sub_feat

#create a column in sub_feat df to match the column names in combined table:
sub_feat$feature_code <- sub_feat[,paste0("V", feature_num)]
sub_feat

#select only these variables from combined table:
col_req <- c(key(combined), sub_feat$feature_name)
col_req
combined <- combined[,col_req,with = FALSE]

head(combined)
names(combined)

#3. Use descriptive activity names to name the activities in the data set:
#read in activity labels:
activity_labels <- fread(file.path(folder, "activity_labels.txt"))
setnames(activity_labels, names(activity_labels), c("activity_num", "activity"))

#4. Appropriately label the data set with descriptive variable names:
combined <- merge(combined, activity_labels, by = "activity_num", all.x = TRUE)

#add activity to key:
setkey(combined,subject,activity_num, activity)
names(combined)


colNames = colnames(combined)
#creating descriptive variable names:
for (i in 1:length(colNames)) 
{
  colNames[i] = gsub("\\()","",colNames[i])
  colNames[i] = gsub("-std$","StdDev",colNames[i])
  colNames[i] = gsub("-mean","Mean",colNames[i])
  colNames[i] = gsub("^(t)","time",colNames[i])
  colNames[i] = gsub("^(f)","freq",colNames[i])
  colNames[i] = gsub("([Gg]ravity)","Gravity",colNames[i])
  colNames[i] = gsub("([Bb]ody[Bb]ody|[Bb]ody)","Body",colNames[i])
  colNames[i] = gsub("[Gg]yro","Gyro",colNames[i])
  colNames[i] = gsub("AccMag","AccMagnitude",colNames[i])
  colNames[i] = gsub("([Bb]odyaccjerkmag)","BodyAccJerkMagnitude",colNames[i])
  colNames[i] = gsub("JerkMag","JerkMagnitude",colNames[i])
  colNames[i] = gsub("GyroMag","GyroMagnitude",colNames[i])
};

colnames(combined) = colNames
head(combined)
names(combined)

data <- combined

#5. Create a second, independent tidy data set with the average of each variable for each activity and each subject:
data$activity <- as.factor(data$activity)
data$subject <- as.factor(data$subject)
head(data)
m <- data.table(melt(data, id = c("activity", "subject")))
head(m)

#final tidy dataset we want:
mean <- dcast(m, subject + activity ~ variable, mean)
write.table(mean, "tidy.txt", row.names = F)