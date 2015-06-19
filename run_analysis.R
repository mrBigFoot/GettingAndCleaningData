
##########################################################################
##                                                                      ##
##                     Getting and Cleaning Data                        ##
##                            Coursersa                                 ##
##                              2015                                    ##
##                                                                      ##
##                            -Project-                                 ##
##                                                                      ##
##########################################################################

cdir<-getwd()

if (!exists("haveData")){
  
  read.table("features.txt",skip=F)[,2]->features
  read.table("train\\X_train.txt",skip=F)->train_x # training data
  read.table("train\\y_train.txt",skip=F)->y_train # actvity code
  read.table("train\\subject_train.txt",skip=F)->subject_train

  read.table("test\\X_test.txt",skip=F)->test_x # test data
  read.table("test\\y_test.txt",skip=F)->y_test # activity number
  read.table("test\\subject_test.txt",skip=F)->subject_test # the subjects
  read.table("activity_labels.txt",skip=F)->xactions # action codes

  haveData<-T
}

actions<-xactions
names(actions)<-c("Code","Description")

## Part (1): Merge the test and training data together

cbind(subject_train,y_train,train_x)->train_x
cbind(subject_test,y_test,test_x)->test_x
merged_data<-rbind(train_x,test_x)
names(merged_data)<-c("subject","activity",as.character(features))

setwd(cdir)

## Part (2): Extract mean and standard deviation from measurements
##           mean and std ambiguous in question so as per course chat 
##           room disambguate with mean and std columns regarded as ending 
##           in mean() or std()

grepl("mean()",names(merged_data),fixed=T)->mean_colms
grepl("std()",names(merged_data),fixed=T)->std_colms
#use index for columns we want
index<-mean_colms|std_colms
index[1:2]<-c(1,1)
merged_data<-merged_data[,as.logical(index)] # extract mean and std colms
 
## Parts(3+4): Use descriptive activity names for the activities and
##             appropriately label data set with descriptive variable names


merged_data$activity<-actions$Description[as.numeric(merged_data$activity)] 
gsub('_','',merged_data$activity)->merged_data$activity #clean activity names
gsub('_','',merged_data$activity)->merged_data$activity
 
gsub("BodyBody","",names(merged_data))->names(merged_data) # removes error in data


## Part(5): From the data set in Part(4) create an independent tidy
##          data set with average of each variable for each activity 
##          and subject

require(plyr)

# generate summarized data
summarized_data<-ddply(merged_data,.(subject,activity),function(x) colMeans(x[,3:length(names(x))])) #replace duplicates with means

names(summarized_data)<-tolower(names(summarized_data))

# Following rules for tidy data remove brackets,dashes and repetiton of "body"
names(summarized_data)<-gsub("[\\(\\)|-]","",names(summarized_data))
 
summarized_data
