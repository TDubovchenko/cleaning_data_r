# load train data
xTrain <- read.table("./train/X_train.txt");
yTrain <- read.table("./train/y_train.txt");
subjectTrain <- read.table("./train/subject_train.txt");
# load test data
xTest <- read.table("./test/X_test.txt");
yTest <- read.table("./test/y_test.txt");
subjectTest <- read.table("./test/subject_test.txt");
# merge train data
train <- cbind(xTrain,yTrain,subjectTrain);
# merge test data
test <- cbind(xTest,yTest,subjectTest);
# remove unnecessary data
rm(list = ls()[grep(".Train$", ls())]);
rm(list = ls()[grep(".Test$", ls())]);
# merge train and test data
data <- rbind(train,test);
names(data)[562] <- "V562";
names(data)[563] <- "V563";
# remove unnecessary data
rm(train,test);
# load features names
features <- read.table("./features.txt");
# find features corresponding to mean or std
cols <- features[grepl("*(mean[(])|std*",features$V2),];
cols[2] <- lapply(cols[2], as.character);
# add 2 column names for activity type and subjectTest
vec <- vector();
vec["V1"] <- 562;
vec["V2"] <- "activitytype";
vec1 <- vector();
vec1["V1"] <- 563;
vec1["V2"] <- "subject";
cols<-rbind(cols,vec,vec1);
# construct variable names
cols$var <- paste0("V",cols$V1);
# extract columns from data corresponding to cols
table1 <- data[,names(data) %in% cols$var];
# create descriptive variable names
cols$descriptive <- sub("^t","time",cols$V2);
cols$descriptive <- sub("^f","fourier",cols$descriptive);
cols$descriptive <- sub("Acc","acceleration",cols$descriptive);
cols$descriptive <- sub("Mag","magnitude",cols$descriptive);
cols$descriptive <- gsub("[-()]","",cols$descriptive);
cols$descriptive <- tolower(cols$descriptive);
names(table1) <- cols$descriptive;
# label activities
activities <- read.table("./activity_labels.txt");
table1<-merge(table1,activities, by.x="activitytype", by.y="V1");
names(table1)[length(names(table1))]<-"activitytype";
table1<-table1[,-1];
table1$subject<-as.factor(table1$subject);
# summarize data
library(data.table);
DT <- data.table(table1);
summarizedData<-DT[, lapply(.SD, mean, na.rm=TRUE), by=list(subject,activitytype) ];
dd <- data.table(summarizedData);
write.table(dd, "tidy_data.txt", sep="\t");
