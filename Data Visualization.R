library(tidyverse)
library(readr)
#install.packages("png")
library(png)
library(caret)
#install.packages("fastDummies")
library(fastDummies)
library(randomForest)
#install.packages("neuralnet")
library(neuralnet)
#install.packages("ROSE")
library(ROSE)
# Manually uploaded data after downloading to local from Kaggle
df <- read_csv("Healthcare Data set/train_2v.csv")
# using png package to display data dictionary 
prop.table(table(df$stroke, useNA = "ifany"))*100 # ~ 2% YES stroke (need to balance classes)
ggplot(data = df, aes(x = stroke)) + geom_bar()
ggplot(data = df, aes(bmi, age, color = work_type)) + geom_point() 
ggplot(data = df, aes(x = bmi, y = avg_glucose_level, color = work_type)) + geom_point()
ggplot(data = df, aes(reorder(work_type, avg_glucose_level),avg_glucose_level  , color = work_type))+
 geom_boxplot()+labs(title = "Distribution of Glucose by Work Type",x = "work_type")+
 theme(plot.title = element_text(hjust = .5))
