library(data.table)
data <-  fread("./data/train.csv")

##customer_ID - A unique identifier for the customer
setnames(data, "customer_ID","customer")
##shopping_pt - Unique identifier for the shopping point of a given customer
setnames(data, "shopping_pt","shopping.pt")
##record_type - 0=shopping point, 1=purchase point
data[,record.type:=record_type]
set(data,j="record.type",value=factor(data[["record.type"]], levels=c(0,1),labels=c("Quote", "Purchase")))
##day - Day of the week (0-6, 0=Monday)
setnames(data, "day","wday")
set(data,j="wday",value=factor(data[["wday"]], levels=c(0:6),labels=c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")))
##time - Time of day (HH:MM)
##Extract the hour and minute of each transaction
data[,hour:=as.numeric(substr(time,1,2))]
data[,min:=as.numeric(substr(time,4,5))]
##state - State where shopping point occurred
data[,location.state:=state]
set(data,j="location.state",value=factor(data[["location.state"]]))
##location - Location ID where shopping point occurred
data[,location.id:=location]
set(data,j="location.id",value=factor(data[["location.id"]]))
##group_size - How many people will be covered under the policy (1, 2, 3 or 4)
data[,group.size:=as.factor(group_size)]
##homeowner - Whether the customer owns a home or not (0=no, 1=yes)
data[,homeowner.ind:=factor(homeowner, levels=c(0,1),labels=c("No","Yes"))]
##car_age - Age of the customer’s car
data[,car.age:=as.factor(car_age)]
##car_value - How valuable was the customer’s car when new
data[,car.value:=as.factor(car_value)]
##risk_factor - An ordinal assessment of how risky the customer is (1, 2, 3, 4)
data[,risk.factor:=   factor(risk_factor, ordered=T)]
##age_oldest - Age of the oldest person in customer's group
data[,age.oldest:=as.factor(age_oldest)]
##age_youngest - Age of the youngest person in customer’s group
data[,age.youngest:=as.factor(age_youngest)]
##married_couple - Does the customer group contain a married couple (0=no, 1=yes)
data[,married.couple:=factor(married_couple, levels=c(0,1), labels=c("Yes","No"))]
##C_previous - What the customer formerly had or currently has for product option C
##(0=nothing, 1, 2, 3,4)
data[,c.previous:=C_previous]
##duration_previous - how long (in years) the customer was covered by their previous
##issuer
data[,duration.previous:=as.numeric(duration_previous)]
##A,B,C,D,E,F,G - the coverage options
## A - 0,1,2
## B - 0,1
## C - 1,2,3,4
## D - 1,2,3
## E - 0,1
## F - 0,1,2,3
## G - 1,2,3,4
## Formatting the options should ensure no incorrect values and will ensure models fitted use
## an appropiate design matrix
data[,option.a:=factor(A, ordered=T, levels=c(0:2))]
data[,option.b:=factor(B, ordered=T, levels=c(0:1))]
data[,option.c:=factor(C, ordered=T, levels=c(1:4))]
data[,option.d:=factor(D, ordered=T, levels=c(1:3))]
data[,option.e:=factor(E, ordered=T, levels=c(0:1))]
data[,option.f:=factor(F, ordered=T, levels=c(0:3))]
data[,option.g:=factor(G, ordered=T, levels=c(1:4))]

##Only keep the key fields
key.fields <- c(
                                        # Unique Customer Identifier
  "customer"
  , "location.state"
  , "location.id"
                                        # Unique Transaction
  ,"shopping.pt"
  , "record.type"
                                        # Transaction Time
  , "wday",   "hour", "min"
                                        # Customer Factors/Features
  , "cost", "group.size", "homeowner.ind", "car.age", "car.value", "age.oldest", "age.youngest", "married.couple", "duration.previous", "c.previous", "risk.factor"
                                        # Option values for each Quote/Purchase
  , "option.a", "option.b", "option.c", "option.d", "option.e", "option.f", "option.g"
  )

data  <- data[,key.fields, with=F]
setkey(data, "customer", "location.state", "location.id", "shopping.pt")

options("width"=200) # Set the display with options in R

##Get the records that are purchases
data.purchases <- data[data$record.type=="Purchase", c("customer","option.a", "option.b", "option.c", "option.d", "option.e", "option.f", "option.g"), with=F]
##Set the key on this as customer
setkey(data.purchases, customer)

##Merge the answer with each transaction
data.merged <- merge(data, data.purchases)
##Test if the transaction is the ultimate purchase
ultimate.purchase <- apply(data.merged[,20:26, with=F] == data.merged[,27:33, with=F],1,all)

data$purchase.choice <- ultimate.purchase
##write.csv(data, file="./data/trainingData.csv")

