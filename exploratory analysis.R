##Main Program file
## Load the data
library(data.table)
data <-  fread("./data/train.csv")

no.observations <- nrow(data)

##Lets do some one way analysis to further understand the data.
##This should include a check for missing values or impossible values in each column

##customer_ID - A unique identifier for the customer
setnames(data, "customer_ID","customer")
no.customers <- length(unique(data$customer))


##shopping_pt - Unique identifier for the shopping point of a given customer
setnames(data, "shopping_pt","shopping.pt")
##summary(data$shopping.pt)
##Shopping points go from 1 to 6, mean 4.22, it takes on average 4.22 shopping points to get a hit
##hist(data$shopping.pt, main="Distribution of Shopping Points")
setkey(data, "customer", "shopping.pt")



##record_type - 0=shopping point, 1=purchase point
data[,record.type:=record_type]
##quick check does each customer buy something?
##sum(data$record_type) == no.customers
##Create a descriptive factor
set(data,j="record.type",value=factor(data[["record.type"]], levels=c(0,1),labels=c("Quote", "Purchase")))


##day - Day of the week (0-6, 0=Monday)
setnames(data, "day","wday")
##summary(data[,"wday",with=F])
##Create a descriptive factor
set(data,j="wday",value=factor(data[["wday"]], levels=c(0:6),labels=c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")))
library(plyr)
##Total Number of Customers
no.customers
##Completed purchases by day
data[,sum(record_type),by=wday]
##Transactions by day
ddply(data, .(record_type, wday), summarise, no.transactions=length(record_type))


##time - Time of day (HH:MM)
##Extract the hour and minute of each transaction
data[,hour:=as.numeric(substr(time,1,2))]
data[,min:=as.numeric(substr(time,4,5))]

##summary(data[,"hour", with=F])
##summary(data[,"min", with=F])

##state - State where shopping point occurred
data[,location.state:=state]
##quick check does each customer buy something?
##Create a descriptive factor
set(data,j="location.state",value=factor(data[["location.state"]]))

##location - Location ID where shopping point occurred
data[,location.id:=location]
##quick check does each customer buy something?
##Create a descriptive factor
set(data,j="location.id",value=factor(data[["location.id"]]))

##Is the id unique per state or overall?
summary.location.id.state <- ddply(data, .(location.id, location.state), summarise,count=length(location.id))
summary.location.id <- as.factor(summary.location.id.state$location.id)
##table values > 1 mean that the id is not unique,
##i.e. different purchases from different states can have the same id
#max(table(summary.location.id))
#min(table(summary.location.id))

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
##summary(data$age.oldest)
##age_youngest - Age of the youngest person in customer’s group
data[,age.youngest:=as.factor(age_youngest)]
##summary(data$age.youngest)


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

##cost - cost of the quoted coverage options
#summary(data[,"cost", with=F])
#hist(data$cost)
#plot(density((data$cost)))

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

data.cleaned  <- data[,key.fields, with=F]
setkey(data.cleaned, "customer", "location.state", "location.id", "shopping.pt")

options("width"=200) # Set the display with options in R
#head(data.cleaned, 9)
##Why does this customer have multiple shopping points at the same time with the same factors. Are these just duplicate records?
##We should probably remove these for analysis then recalculate the shopping point numbers, or better to rely on durations of how long a customer spends looking at products

##Look at variation in cost per customer
data.cleaned[,cost.mean:=mean(cost), by=customer]
data.cleaned[,cost.var:=cost-cost.mean]
library(ggplot2)
#ggplot(data.cleaned, aes(x=cost.var, y=record.type))+geom_point()+geom_jitter(aes(y=record.type))

##Look at duration from first to last sale point
##Check if some transactions happen on different days
data.cleaned[,max(as.numeric(wday))-min(as.numeric(wday)), by=customer]
data.cleaned[J(10000014)]

##Add an increment column for each day
day.diff <- c(0,diff(as.numeric(data.cleaned$wday)))
day.diff <- ifelse(day.diff<0,day.diff+7, day.diff)

day.inc <- sapply(2:nrow(data.cleaned), function(x) ifelse(data.cleaned$record.type[x-1]=="Purchase",0,day.diff[x]))

data.cleaned$day.inc <- c(0,day.inc)

#ggplot(data.cleaned, aes(x=day.inc,fill=wday))+geom_histogram()
##Customers who look for products on Sundays buy them that day

write.csv(data.cleaned, file="./data/cleandata.csv")

##Clean up workspace
rm(list=setdiff(ls(),"data.cleaned"))

##Do factors change over shopping history?
##If not then it might be possible to just make predictions on risk factors? Do we use shopping history or just factors? or both?

