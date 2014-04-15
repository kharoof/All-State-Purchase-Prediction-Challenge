##Lets fit some models
library(caret)
library(doMC)
registerDoMC(cores=4)



inTrain <- createDataPartition(y=data$purchase.choice, p=0.9,list=FALSE)
data.df <- data.frame(data)
training = data.df[inTrain,]
testing = data.df[-inTrain,]


predictors.model = outcome ~ wday + location.state + hour + car.age


model.ctree <- train(predictors.model,data=training, method="ctree")
ctreePred <- predict(model.ctree, testing)
ctreeProb <- predict(model.ctree, testing, type="prob")
confusionMatrix(ctreePred, testing$purchase.choice)


model.rpart <- train(predictors.model,data=training, method="rpart")
rpartPred <- predict(model.rpart, testing)
rpartProb <- predict(model.rpart, testing, type="prob")
confusionMatrix(rpartPred, testing$purchase.choice)
