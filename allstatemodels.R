##some preliminary models with rattle

library(rattle)
rattle()

library(caret)
library(doMC)
registerDoMC(cores=4)

source("./PrepareData.R")
data <- data.frame(data)
data <- data[,c(4,6:12,14:16,20:27)]
inTrainIndexes <- createDataPartition(data$purchase.choice, p=.1, list = FALSE)
training = data[inTrainIndexes,]
testing = data[-inTrainIndexes,]

predictors.model = purchase.choice ~ .

fitControl <- trainControl(## 10-fold CV
                           method = "repeatedcv",
                           number = 10,
                           ## repeated ten times
                           repeats = 10)

model.rpart <- train(predictors.model,data=training, method="rpart")
rpartPred <- predict(model.rpart, testing)
rpartProb <- predict(model.rpart, testing, type="prob")
confusionMatrix(rpartPred, testing$purchase.choice)
varImp(model.rpart)
#Automatically selects appropiate features
model.ctree2 <- train(predictors.model,data=training, method="ctree2")
ctree2Pred <- predict(model.ctree2, testing)
ctree2Prob <- predict(model.ctree2, testing, type="prob")
confusionMatrix(ctree2Pred, testing$purchase.choice)


predictors.model = purchase.choice ~ shopping.pt+option.g+cost+option.d+option.g+option.f+car.age

model.nnet <- train(predictors.model,data=training, method="nnet")
nnetPred <- predict(model.nnet, testing)
nnetProb <- predict(model.nnet, testing, type="prob")
confusionMatrix(nnetPred, testing$purchase.choice)



model.cforest <- train(predictors.model,data=training, method="cforest")
cforestPred <- predict(model.cforest, testing)
cforestProb <- predict(model.cforest, testing, type="prob")
confusionMatrix(cforestPred, testing$purchase.choice)

                           
##If model is true, use the mark as prediction
##Else use model fitted to each class to make prediction for each option
##For each customer 
                           
                           
