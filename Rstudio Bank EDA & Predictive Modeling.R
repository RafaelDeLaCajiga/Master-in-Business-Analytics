#' Author: Rafael de la Cajiga Leon
#' Date: Mar 21, 2023
#' A2: National City Bank National City Bank EDA & Modeling

# Setwd
setwd("~/MBAN/Visualizing and Analyzing Data with R")
options(scipen=999)

# Libraries
library(vtreat)
library(MLmetrics)
library(pROC)
library(ggplot2)
library(dplyr)
library(readr)
library(data.table)
library(caret)
library(randomForest)
library(DataExplorer)

# Import Data

# Test to predict
ProspectCustomers <- read.csv("https://raw.githubusercontent.com/kwartler/Hult_Visualizing-Analyzing-Data-with-R/main/DD1_Case_Info/A2_NationalCityBank/ProspectiveCustomers.csv")

#Train the model
CurrCustomer <- read.csv('https://raw.githubusercontent.com/kwartler/Hult_Visualizing-Analyzing-Data-with-R/main/DD1_Case_Info/A2_NationalCityBank/training/CurrentCustomerMktgResults.csv')

Household_Axiom_Data <- read.csv('https://raw.githubusercontent.com/kwartler/Hult_Visualizing-Analyzing-Data-with-R/main/DD1_Case_Info/A2_NationalCityBank/training/householdAxiomData.csv')

Household_Credit_Data <- read.csv('https://raw.githubusercontent.com/kwartler/Hult_Visualizing-Analyzing-Data-with-R/main/DD1_Case_Info/A2_NationalCityBank/training/householdCreditData.csv')

Household_Vehicle_Data <- read.csv('https://raw.githubusercontent.com/kwartler/Hult_Visualizing-Analyzing-Data-with-R/main/DD1_Case_Info/A2_NationalCityBank/training/householdVehicleData.csv')


# Joining all the current customer data together 
CurrCustomer <- left_join(CurrCustomer,Household_Axiom_Data)
CurrCustomer <- left_join(CurrCustomer,Household_Credit_Data)
CurrCustomer <- left_join(CurrCustomer,Household_Vehicle_Data)

names(CurrCustomer)
summary(CurrCustomer)

# Joining all the Prospective customer data together
ProspectCustomers <- left_join(ProspectCustomers, Household_Axiom_Data)
ProspectCustomers <- left_join(ProspectCustomers, Household_Credit_Data)
ProspectCustomers <- left_join(ProspectCustomers, Household_Vehicle_Data)

names(ProspectCustomers)

#Drop unwanted columns
CurrCustomer$CallStart <- NULL
CurrCustomer$CallEnd <- NULL
CurrCustomer$dataID <- NULL
ProspectCustomers$dataID <- NULL

dim(CurrCustomer)



# put the Y_AcceptedOffer variable in the last column position to simplify modeling
CurrCustomer$Y_accepted_offer <- copy(CurrCustomer$Y_AcceptedOffer)
CurrCustomer$Y_AcceptedOffer <- NULL

names(CurrCustomer)

# put the Y_AcceptedOffer variable in the last column position for prediciton
ProspectCustomers$Y_accepted_offer <- copy(ProspectCustomers$Y_AcceptedOffer)
ProspectCustomers$Y_AcceptedOffer <- NULL

names(ProspectCustomers)

##### Model ####

# change Y_Accepted to binary

CurrCustomer$Y_accepted_offer <- ifelse(CurrCustomer$Y_accepted_offer %in% "Accepted", 1 , CurrCustomer$Y_accepted_offer)
CurrCustomer$Y_accepted_offer <- ifelse(CurrCustomer$Y_accepted_offer %in% "DidNotAccept", 0 , CurrCustomer$Y_accepted_offer)
CurrCustomer$Y_accepted_offer <- as.numeric(CurrCustomer$Y_accepted_offer)


summary(CurrCustomer)


# Identify the informative and target
AcceptedOffer       <- names(CurrCustomer)[26]
InformativeVars <- names(CurrCustomer)[c(2, 5:23)] 


# Segment the prep data
set.seed(1993)
idx         <- sample(1:nrow(CurrCustomer),.1*nrow(CurrCustomer))
prepData    <- CurrCustomer[idx,]
nonPrepData <- CurrCustomer[-idx,]

# Design a categorical variable 
plan <- designTreatmentsC(prepData, 
                          InformativeVars,
                          AcceptedOffer, 1)

# Apply to xVars
treated_train <- prepare(plan, nonPrepData)


# Partition to avoid over fitting
set.seed(1993)
idx        <- sample(1:nrow(treated_train),.8*nrow(treated_train))
train      <- treated_train[idx,]
validation <- treated_train[-idx,]



##### logistic regression model #####



fit <- glm(Y_accepted_offer ~., data = train, family ='binomial')
summary(fit)
bestFit <- step(fit, direction='backward')

summary(bestFit)

length(coefficients(fit))
length(coefficients(bestFit))

pred1 <- predict(bestFit,  train, type='response')

cutoff      <- 0.5
answers <- ifelse(pred1 >= cutoff, 1,0)

results <- data.frame(actual  = train$Y_accepted_offer,
                      ID    = CurrCustomer$HHuniqueID[idx],
                      answers = answers,
                      probs   = pred1)
head(results)


# Get a confusion matrix
(confMat <- ConfusionMatrix(results$answers, results$actual))

# Visually how well did we separate our answers?
ggplot(results, aes(x=probs, color=as.factor(actual))) +
  geom_density()



# VALIDATION

# Get predictions 
pred1 <- predict(bestFit,  validation, type='response')




# Organize 
results <- data.frame(actual  = validation$Y_accepted_offer,
                      ID    = CurrCustomer$HHuniqueID[idx],
                      answers = answers,
                      probs   = pred1)
head(results)

# Get a confusion matrix
(confMat <- ConfusionMatrix(results$answers, results$actual))

# Accuracy
sum(diag(confMat)) / sum(confMat)
val_accuracy <- Accuracy(results$answers, results$actual)

# Visually Plot
ggplot(results, aes(x=probs, color=as.factor(actual))) +
  geom_density()


# Prediction 

# Randomize the entire data set to ensure no auto-correlation 
set.seed(1993)
ProspectCustomers <- ProspectCustomers[sample(1:nrow(ProspectCustomers),nrow(ProspectCustomers)),]


# Identify the informative and target
AcceptedOffer       <- names(ProspectCustomers)[26]
informativeVars <- names(ProspectCustomers)[c(2, 5:23)] 


# Apply to xVars
test <- prepare(plan, ProspectCustomers)


# Test  

# Get predictions for the test 
pred1 <- predict(bestFit,  test, type='response')
pred1

# Classify 
cutoff      <- 0.66
answers <- ifelse(pred1 >= cutoff, 1,0)

# Organize w/Actual
results_clients <- data.frame(
  ID    = ProspectCustomers$HHuniqueID,
  answers = answers,
  probs   = pred1)
head(results_clients)

# count the number of people that accepted 
sum(answers == 1)

# Data Frame result
results_clients<-  head(results_clients[results_clients$answers == 1, ], 100) 
results_clients

# Sort the accepted data by descending predicted probability
Pilot_Clients <- results_clients[order(results_clients$probs, decreasing = TRUE), ]
Pilot_Clients


##### DECISION TREE #####

# Fit a decision tree with caret
#set.seed(1993)
#fit <- train(as.factor(Y_accepted_offer) ~., #formula based
             #data = treated_train, #data in
             #"recursive partitioning (trees)
             #method = "rpart", 
             #Define a range for the CP to test
             #tuneGrid = data.frame(cp = c(0.0001, 0.001,0.005, 0.01, 0.05, 0.07,
                                          #0.1)), 
             #ie don't split if there are less than 1 record left and only do a               split if there are at least 2+ records
             #control = rpart.control(minsplit = 1, minbucket = 2)) 

# Examine
#fit

# Plot the CP Accuracy Relationship to adust the tuneGrid inputs
#plot(fit)

# Plot a pruned tree
#prp(fit$finalModel, extra = 1)

# Make some predictions on the training set
#trainCaret <- predict(fit, treated_train)
#head(trainCaret)

# Get the conf Matrix
#confusionMatrix(trainCaret, as.factor(treated_train$Y_accepted_offer))

# Now more consistent accuracy & fewer rules!
#testCaret <- predict(fit,treated_train)
#confusionMatrix(testCaret,as.factor(treated_train$Y_accepted_offer))


##### Random Forest #####

# Fit a random forest model with Caret
sample_Fit <- train(as.factor(Y_accepted_offer) ~ .,
                    data = treated_train,
                    method = "rf",
                    verbose = FALSE,
                    ntree = 100,
                    tuneGrid = data.frame(mtry = c(2, 4, 6)))

sample_Fit$bestTune$mtry
sample_Fit

# Too see probabilities
predProbs   <- predict(sample_Fit,  
                       treated_train, 
                       type = c("prob"))

# To get classes with 0.50 cutoff
predClasses <- predict(sample_Fit,  treated_train)

# Confusion Matrix; MLmetrics has the same function but use CARET in this example.
caret::confusionMatrix(predClasses, as.factor(treated_train$Y_accepted_offer))

# Other interesting model artifacts
varImp(sample_Fit)
plot(varImp(sample_Fit), top = 20)

# Add more trees to the forest with the randomForest package (caret takes a long time bc its more thorough)
moreTrees <- randomForest(as.factor(Y_accepted_offer) ~ .,
                           data  = treated_train, 
                           ntree = 500,
                           mtry  = 6)

# Confusion Matrix, compare to 3 trees ~63% accuracy
trainClass <- predict(moreTrees, treated_train)
confusionMatrix(trainClass, as.factor(treated_train$Y_accepted_offer))

# Look at improved variable importance
varImpPlot(moreTrees)

# plot the RF with a legend
layout(matrix(c(1,2),nrow=1),
       width=c(4,1)) 
par(mar=c(5,4,4,0)) #No margin on the right side
plot(moreTrees, log="y")
par(mar=c(5,0,4,2)) #No margin on the left side
plot(c(0,1),type="n", axes=F, xlab="", ylab="")
legend("top", colnames(moreTrees$err.rate),col=1:4,cex=0.8,fill=1:4)


# Let's optimize # of trees 
someVoters <- randomForest(as.factor(Y_accepted_offer) ~ .,
                           data = treated_train, 
                           ntree=200,
                           mtyr = 6)

# Confusion Matrix
trainClass <- predict(someVoters, treated_train)
confusionMatrix(trainClass, as.factor(treated_train$Y_accepted_offer))

### Now let's apply to the validation test set
oneHundredVotes        <- predict(sample_Fit,    validation)
fiveHundredVoters <- predict(moreTrees,    validation)
twoHundredVoters  <- predict(someVoters, validation)

# Accuracy Comparison from MLmetrics and natural occurence in the test set
Accuracy(nonPrepData$Y_accepted_offer, oneHundredVotes)
Accuracy(nonPrepData$Y_accepted_offer, fiveHundredVoters)
Accuracy(nonPrepData$Y_accepted_offer, twoHundredVoters)
proportions(table(nonPrepData$Y_accepted_offer))



#### Done Modeling, Look for Insights in the ####

# 100 Clients to run the pilot with
Pilot_Clients

# The most important variables that gave the best prediction model
varImp(moreTrees)


names(ProspectCustomers)
# Lets make a data set of the ProspectCustomers where we only keep the 10 more important variables
Insight_Customers<- subset(ProspectCustomers, select = c("HHuniqueID", 
                                                         "RecentBalance",
                                                         "Age",
                                                         "carMake",
                                                         "NoOfContacts",
                                                         "DigitalHabits_5_AlwaysOn",
                                                         "Job",
                                                         "past_Outcome",
                                                         "DaysPassed"))
names(Insight_Customers)
summary(Insight_Customers)

Pilot_Clients$HHuniqueID <- Pilot_Clients$ID

# Move HHuniqueID to the first column
Pilot_Clients <- select(Pilot_Clients, HHuniqueID, everything())
Pilot_Clients$ID <- NULL
Pilot_Clients

Pilot_Clients_insights <- left_join(Pilot_Clients,Insight_Customers, by= "HHuniqueID")
Pilot_Clients_insights

#Check of NA values with in our 100 customer dataset
plot_missing(Pilot_Clients_insights)

na_count <- colSums(is.na(Pilot_Clients_insights))
na_count

summary(Pilot_Clients_insights)

Pilot_Clients_insights$past_Outcome

# I have 18 entries with no information regarding a Past Outcome. I can't fill out the NA information since it would possibly alter my insights.

# Lets Visualize each variable to look for insights

age_df <- subset(Pilot_Clients_insights, select = c("Age"))

# calculate frequency for the Age column using table() function
age_freq_table <- table(Pilot_Clients_insights$Age)

age_freq_df <- count(Pilot_Clients_insights, Age)

# create bar plot using ggplot2

ggplot(age_freq_df, aes(x = Age, y = n)) + 
  geom_bar(stat = "identity", fill = "steelblue") + 
  labs(x = "Age", y = "Count", title = "Count of Users by Age")

# The Majority of our Pilot clients are under 40 years old. What else could we find for them?

under_40 <- Pilot_Clients_insights %>%
  group_by(Age <= 40)
under_40


# count number of unique identifiers
num_under_40 <- under_40 %>% 
  distinct(HHuniqueID) %>% 
  count()

# 58% of our pilot customers are under 40 years old. Does it happen the same in the ProspectCustomer df?

under_40p <- ProspectCustomers %>%
  group_by(Age <= 40)
under_40

# count number of unique identifiers
num_under_40p <- under_40p %>% 
  distinct(HHuniqueID) %>% 
  count()
num_under_40p

# 54% of the ProspectCustomer df is under 40 years old.

## What jobs do those people have? ##

# get jobs of users in Pilot_Clients_insights
jobs_Pilot_Clients <- Pilot_Clients_insights %>% 
  distinct(HHuniqueID, Job) %>% 
  group_by(Job) %>% 
  summarize(count = n()) %>% 
  arrange(desc(count))

cat("\n\nJobs of users in Pilot:\n")
print(jobs_Pilot_Clients)

# get jobs of users in the bigger DF to compare
jobs_prospect <- ProspectCustomers %>% 
  distinct(HHuniqueID, Job) %>% 
  group_by(Job) %>% 
  summarize(count = n()) %>% 
  arrange(desc(count))

cat("\n\nJobs of users in Pilot:\n")
print(jobs_prospect)


# Most of our pilot clients are in Management roles followed by a surprising amount of retired clients and then students and technicians. In comparison, out of the Prospect data, only 7% of the whole dataframe is retired.

# create a bar chart of job counts

ggplot(jobs_Pilot_Clients, aes(x =count , y = Job)) +
  geom_bar(stat = "identity", fill = "Blue", color = "black") +
  xlab("Count") +
  ylab("Job") +
  ggtitle("Job Counts in Pilot Clients")

# Which car do our pilot clients be offering as colateral?
CarMake_Pilot_Clients <- Pilot_Clients_insights %>% 
  distinct(HHuniqueID, carMake) %>% 
  group_by(carMake) %>% 
  summarize(count = n()) %>% 
  arrange(desc(count))

print(n= 100, CarMake_Pilot_Clients)

# Which car does the whole data have?
CarMake_Prospect <- ProspectCustomers %>% 
  distinct(HHuniqueID, carMake) %>% 
  group_by(carMake) %>% 
  summarize(count = n()) %>% 
  arrange(desc(count))

print(CarMake_Prospect)

# While most car owners in the bigger Data Set drive a Chevrolet, in our selected 100 customers, the biggest share is with Nissan  with 11% and  9% with Chevrolet followed by Dodge and then Toyota.


# Analyse clients by RecentBalance and check those under 2000

df_sub <- subset(Pilot_Clients_insights, RecentBalance < 2000)

df_sum <- aggregate(RecentBalance ~ HHuniqueID, data = df_sub, sum)

ggplot(df_sum, aes(x = HHuniqueID, y = RecentBalance)) +
  geom_bar(stat = "identity", fill = "blue") +
  ggtitle("Recent Balance for Users with a Value Under 2000") +
  xlab("User") +
  ylab("Recent Balance")

# Count the number of rows in df_sub to get the total of clients with recent balance under 2000
df_sub_count <- nrow(df_sub)

# Count the number of rows in the original dataframe
total_count <- nrow(Pilot_Clients_insights)

# Calculate the percentage of users with a RecentBalance under 2000
percent_sub <- (df_sub_count / total_count) * 100

# Print the percentage
cat(sprintf("%.2f%% of the users have a RecentBalance under 2000.", percent_sub))

# 71% of our Pilot Clients have a Recent Balance under $2000. This could point to them being clients in need of a credit and most likely they have a used car based on the previous insight.

df_sub2 <- subset(ProspectCustomers, RecentBalance < 2000)

# Count the number of rows in df_sub to get the total of clients with recent balance under 2000
df_sub_count2 <- nrow(df_sub2)

# Count the number of rows in the original dataframe
total_count2 <- nrow(ProspectCustomers)

# Calculate the percentage of users with a RecentBalance under 2000
percent_sub2 <- (df_sub_count2 / total_count2) * 100

# Print the percentage
cat(sprintf("%.2f%% of the users have a RecentBalance under 2000.", percent_sub2))


#END