library("doMC")
library("reshape2")


data_dir <- "./data/"
train_file <- paste0(data_dir,"training.csv")
test_file <- paste0(data_dir,"test.csv")

d_train <- read.csv(train_file,stringsAsFactors=FALSE)
im_train <- d_train$Image
d_train$Image <- NULL
d_test <- read.csv(test_file,stringsAsFactors=FALSE)

registerDoMC()
im_train <- foreach(im=im_train, .combine = rbind) %dopar% {
    as.integer(unlist(strsplit(im," ")))
}
im_test <- foreach(im = d_test$Image, .combine = rbind) %dopar% {
    as.integer(unlist(strsplit(im," ")))
}
d_test$Image <- NULL

save(d_train,im_train,d_test,im_test,file = "data.Rd")

load('data.Rd')

p <- matrix(data=colMeans(d_train,na.rm = TRUE),nrow=nrow(d_test),ncol=ncol(d_train),byrow=TRUE)
colnames(p) <- names(d_train)
predictions <- data.frame(ImageID=1:nrow(d_test),p)
submission <- melt(predictions, id.vars="ImageID", variable.name="FeatureName", value.name="Location")

example_submission <- read.csv(paste0(data_dir, 'SampleSubmission.csv'))
sub_col_names      <- names(example_submission)
example_submission <- read.csv(paste0(data_dir,"SampleSubmission.csv"))
example_submission$Location <- NULL
submission <- merge(example_submission,submission,all.x = TRUE,sort = FALSE)


