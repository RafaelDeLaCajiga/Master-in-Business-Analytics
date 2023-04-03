# A1: OkCupid EDA
# Rafael de la Cajiga Leon
# 03/13/2023
# Hult International Business School

--------------------------------------------------------------------------------

# Step 1 Set the working directory
setwd("~/MBAN/Visualizing and Analyzing Data with R/A1 OkCupid EDA")

# Step 2 Load some libraries
options(scipen = 999)
library(radiant.data)
library(DataExplorer)
library(ggplot2)
#install.packages("ggmap")
library(maps)
library(ggthemes)
library(readr)
library(tidyr)
library(plotly)
library(reshape2)
library(dplyr)

# Step 3 Bring in some data
Profiles <- read.csv("~/MBAN/Visualizing and Analyzing Data with R/Hult_Visualizing-Analyzing-Data-with-R/DD1_Case_Info/A1_OKCupid/profiles.csv")
Location <- read.csv("~/MBAN/Visualizing and Analyzing Data with R/Hult_Visualizing-Analyzing-Data-with-R/DD1_Case_Info/A1_OKCupid/LatLon.csv")

# Step 4 Apply functions: Perform the task we want on our data
# Use the names function to review the data set columns
names(Profiles)
names(Location)

# Review the bottom 6 records of Profiles
tail(Location)
tail(Profiles)

# Basic statistics
summary(Profiles) 


Profiles <- Profiles %>%
  mutate(ID = row_number())

##### Enrich with one of the new data sets, you may want to do this with the other csv files
Profiles <- left_join(Profiles, Location, by ='location')
head(Profiles)

unique(Profiles$location)

# Filter for profiles with non-US locations
Profiles <- Profiles[!grepl("guadalajara, mexico|vancouver, british columbia, canada|kula, hawaii|edinburgh, united kingdom|cork, ireland|madrid, spain|honolulu, hawaii|nha trang, vietnam|kassel, germany|bonaduz, switzerland|london, united kingdom", Profiles$location), ]

unique(Profiles$location)

#We will focuse on profiles in the US only.


# Create a ggplot object
p <- ggplot(Profiles, aes(x = lon, y = lat)) +
  geom_point() +
  xlim(-130, -65) + ylim(25, 50)  # set the map bounds to focus on the US

# Add a map of the US as the background
us_map <- map_data("state")
p <- p + geom_polygon(data = us_map, aes(x = long, y = lat, group = group), fill = NA, color = "black")

# Display the plot
p



#Check of NA values
plot_missing(Profiles)

na_count <- colSums(is.na(Profiles))

barplot(na_count, 
        main = "Count of Null Values by Column", 
        xlab = "Column Names", 
        ylab = "Count of Null Values")
sort(na_count, decreasing = TRUE)


#The lack of information in Income makes it a useless column 
sum(is.na(Profiles$income))

# Remove a column
Profiles$income <- NULL

plot_missing(Profiles)

# Check what to do with the NA in the Offspring column
sum(is.na(Profiles$offspring))
unique(Profiles$offspring)

plotDF <- data.frame(table(Profiles$offspring,  Profiles$sex))

# Create the ggplot object
p <- ggplot(data = plotDF, aes(fill=Var2, y=reorder(Var1, -Freq, FUN=sum), x=Freq)) + 
  geom_bar(position="stack", stat="identity") +
  labs(title = "Offspring decision by gender", x = "Offspring", y = "Freq")

# Convert the ggplot object to a plotly object and add hover information
ggplotly(p, tooltip = c("Var1", "Var2", "Freq"))


#Since having or wanting kids may be important when dating, I decided not to drop the offspring column and just make the assumption that people with NA refers to "Don't have Kids, Don't know If I want"

Profiles$offspring[is.na(Profiles$offspring)] <- "Dont have Kids, Dont know If I want"
sum(is.na(Profiles$offspring))

#To make the Offspring info more digestible, I will be adding certain values and grouping them.
#Grouping variables 

Profiles$offspring <- gsub("has kids, and wants more", "has at least a kid, maybe wants more", Profiles$offspring)
Profiles$offspring <- gsub("has a kid, and wants more", "has at least a kid, maybe wants more", Profiles$offspring)
Profiles$offspring <- gsub("has kids, and might want more", "has at least a kid, maybe wants more", Profiles$offspring)
Profiles$offspring <- gsub("has a kid, and might want more", "has at least a kid, maybe wants more", Profiles$offspring)

Profiles$offspring <- gsub("doesn't have kids, but wants them", "high chances of wanting kids", Profiles$offspring)
Profiles$offspring <- gsub("might want kids", "high chances of wanting kids", Profiles$offspring)
Profiles$offspring <- gsub("wants kids", "high chances of wanting kids", Profiles$offspring)

Profiles$offspring <- gsub("has kids", "Has at least a kid", Profiles$offspring)
Profiles$offspring <- gsub("has a kid", "Has at least a kid", Profiles$offspring)

# Create a subset of the data with only the relevant columns
offspring_df <- subset(Profiles, select = c("sex", "offspring"))

# Compute the frequency table of sex and offspring
offspring_freq_table <- table(offspring_df$sex, offspring_df$offspring)

# Compute the proportion table of sex and offspring
offspring_prop_table <- prop.table(offspring_freq_table, margin = 1)

# Make in percentage
offspring_prop_table<- offspring_prop_table*100

#Round to 2 decimal points
offspring_prop_table <- round(offspring_prop_table, 2)
offspring_prop_table <- t(offspring_prop_table)
offspring_prop_table

# With the amount of NA values that got transformed into "Don't have Kids, Don't know If I want", we see that more than half females and over 60% males rather not answer this question. From the users that do answer, both male and female, over 12% don't have kids but don't specify if they would want them or not.

# There are around 3% more women that date having at least 1 kid than men that have at least 1 kid.

#Clean Data of the interesting features for my insights
names(Profiles)

#Age is an important variable to build personas and possibly find insights per age group
sum(is.na(Profiles$age))
table(Profiles$age)

Profiles <- subset(Profiles, age != 109 & age != 110)

Profiles$age_group <- cut(Profiles$age, 
                          breaks = c(0, 25, 30, 40, Inf), 
                          labels = c("under 25", "25-30", "30-40", "40+"))


# Create a subset of the data with only the relevant columns
age_group_df <- subset(Profiles, select = c("sex", "age_group"))

# Compute the frequency table of sex and offspring
age_group_freq_table <- table(age_group_df$sex, age_group_df$age_group)

# Compute the proportion table of sex and offspring
age_group_prop_table <- prop.table(age_group_freq_table, margin = 1)

# Make in percentage
age_group_prop_table<- age_group_prop_table*100

#Round to 2 decimal points
age_group_prop_table <- round(age_group_prop_table, 2)
age_group_prop_table <- t(age_group_prop_table)
age_group_prop_table

# Convert the frequency table to a data frame
age_group_df <- as.data.frame(age_group_freq_table)

# Rename the columns of the data frame
colnames(age_group_df) <- c("sex", "age_group", "count")

# Convert the data from wide to long format
library(tidyr)
age_group_df_long <- pivot_longer(age_group_df, cols = count, names_to = "count_type", values_to = "count")

# Plot a line graph to visualize where users are and how it fluctuates by age group.
ggplot(data = age_group_df_long, aes(x = age_group, y = count, group = sex, color = sex)) +
  geom_line() +
  ggtitle("Number of Users by Age Group and Sex") +
  xlab("Age Group") +
  ylab("Number of Users")

# Another interesting value that could help me get an insight is Pets 
sum(is.na(Profiles$pets))
table(Profiles$pets)

Profiles$pets[is.na(Profiles$pets)] <- "No Information Provided"
sum(is.na(Profiles$pets))

table(Profiles$pets)

# By grouping some values where the user has a cat or a dog (but not both) helps make the data more digestible

#Has a Cat
Profiles$pets <- gsub('dislikes dogs and has cats', "has at least one cat", Profiles$pets)
Profiles$pets <- gsub('has cats', "has at least one cat", Profiles$pets)
Profiles$pets <- gsub('likes dogs and has cats', "has at least one cat", Profiles$pets)
Profiles$pets <- gsub('likes dogs and has at least one cat', "has at least one cat", Profiles$pets)


# Has a Dog
Profiles$pets <- gsub('has dogs', "has at least one dog", Profiles$pets)
Profiles$pets <- gsub('has dogs and dislikes cats', "has at least one dog", Profiles$pets)
Profiles$pets <- gsub('has dogs and likes cats', "has at least one dog", Profiles$pets)
Profiles$pets <- gsub('has at least one dog and has at least one cat', "has at least one dog", Profiles$pets)
Profiles$pets <- gsub('has at least one dog and dislikes cats', "has at least one dog", Profiles$pets)
Profiles$pets <- gsub('has at least one dog and likes cats', "has at least one dog", Profiles$pets)

#Dislikes Pets
Profiles$pets <- gsub("dislikes cats", "Dislikes Pets", Profiles$pets)
Profiles$pets <- gsub("dislikes dogs and Dislikes Pets", "Dislikes Pets", Profiles$pets)
Profiles$pets <- gsub("dislikes dogs", "Dislikes Pets", Profiles$pets)
Profiles$pets <- gsub("dislikes dogs and dislikes cats", "Dislikes Pets", Profiles$pets)
Profiles$pets <- gsub("likes dogs and Dislikes Pets", "Dislikes Pets", Profiles$pets)

#Likes Pets, we dont know if it has one
Profiles$pets <- gsub("likes cats", "Likes Pets, we dont know if it has one", Profiles$pets)
Profiles$pets <- gsub("Dislikes Pets and Likes Pets, we dont know if it has one", "Likes Pets, we dont know if it has one", Profiles$pets)
Profiles$pets <- gsub("likes dogs", "Likes Pets, we dont know if it has one", Profiles$pets)
Profiles$pets <- gsub("likes dogs and likes cats", "Likes Pets, we dont know if it has one", Profiles$pets)
Profiles$pets <- gsub("likes dogs and Likes Pets, we dont know if it has one", "Likes Pets, we dont know if it has one", Profiles$pets)
Profiles$pets <- gsub("Likes Pets, we dont know if it has one and Likes Pets, we dont know if it has one", "Likes Pets, we dont know if it has one", Profiles$pets)

table(Profiles$pets)

# Create a subset of the data with only the relevant columns
pets_df <- subset(Profiles, select = c("pets", "age_group"))

# Compute the frequency table of pets and age_group
pets_freq_table <- table(pets_df$age_group, pets_df$pets)

# Compute the proportion table of pets and age_group
pets_prop_table <- prop.table(pets_freq_table, margin = 1)

# Make in percentage
pets_prop_table<- pets_prop_table*100

#Round to 2 decimal points
pets_prop_table <- round(pets_prop_table, 2)
pets_prop_table <- t(pets_prop_table)
pets_prop_table

# 33% of users in the age group 25-30 years old dislike pets. Considering that "Dislike Pets" involves dislike cats, dislike dogs, and disliking both.

# Create a subset of the data with only the relevant columns
pets_gender_df <- subset(Profiles, select = c("pets", "sex"))

# Compute the frequency table of pets and age_group
pets_gender_freq_table <- table(pets_gender_df$pets, pets_gender_df$sex)

# Compute the proportion table of pets and age_group
pets_gender_prop_table <- prop.table(pets_gender_freq_table, margin = 1)

# Make in percentage
pets_gender_prop_table<- pets_gender_prop_table*100

#Round to 2 decimal points
pets_gender_prop_table <- round(pets_gender_prop_table, 2)
pets_gender_prop_table <- t(pets_gender_prop_table)
pets_gender_prop_table


# When it comes to the different responses by male and female users, we see a gap specially in cat owners, with 58.83% of them being female vs 41.17% being male. At the same time, male users tend to not fill out the whole information and just declare that they like pets. Also, with a little over 65%, male users dominated the null information for this variable.
# Secondary Research: https://nypost.com/2023/02/13/single-and-desperate-for-a-date-put-a-dog-in-your-dating-profile/

#Now that we have the categorized offspring and pets, having the "wow" insight would be if there's a relationship between having pets and not having offspring. At the same time, maybe there's a change as people grow.

tail(Profiles$offspring)
tail(Profiles$pets)

# Create a subset of the data with only the relevant columns
pets_offspring_df <- subset(Profiles, select = c("pets", "offspring"))

# Compute the frequency table of pets and age_group
pets_offspring_freq_table <- table(pets_offspring_df$offspring, pets_offspring_df$pets)

# Compute the proportion table of pets and age_group
pets_offspring_prop_table <- prop.table(pets_offspring_freq_table, margin = 1)

# Make in percentage
pets_offspring_prop_table<- pets_offspring_prop_table*100

#Round to 2 decimal points
pets_offspring_prop_table <- round(pets_offspring_prop_table, 2)
pets_offspring_prop_table <- t(pets_offspring_prop_table)
pets_offspring_prop_table

# Convert the data to long format
pets_offspring_melted <- melt(pets_offspring_prop_table, id.vars = c("offspring", "variable"))

colnames(pets_offspring_melted) <- c("offspring", "pets", "value")
colnames(pets_offspring_melted)

ggplot(pets_offspring_melted, aes(x = value, y = offspring, fill = pets)) +
  geom_bar(stat = "identity") +
  labs(x = "Responses", y = "Offspring Status", fill = "Pets") +
  ggtitle("Percentage of Pets Owned by Offspring Status")+
  scale_fill_brewer(palette = "Paired")



#END