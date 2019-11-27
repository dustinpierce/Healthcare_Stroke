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
ggplot(data = df, aes(x = stroke)) + geom_bar() # want to add text to this to include records
str(df) # need to map all non-id character features to factor/numeric
summary(df) # will also need indicator/dummy variables for multi-class categorical
unique(df$smoking_status) # NA is viewed as a character but is actually null
unique(df$work_type) # similar NA issue; will need dummary variables for each category
unique(df$Residence_type) # similar NA issue; will need dummary variables for each category
unique(df$gender) # includes "other" option so cannot use binary indicator
unique(df$ever_married) # binary -- convert to indicator feature
unique(df$hypertension)
class(df$hypertension) # binary and numeric!
class(df$id) # need to convert to character
# Engineering features based on above suggestions
df <- df %>% mutate(id = as.character(id),
                    ever_married = ifelse(ever_married == "Yes", 1, 0),
                    gender = ifelse(gender == "Male", 1,
                                    ifelse(gender == "Female", 0, NA)),
                    Residence_type = ifelse(Residence_type == "Urban", 1,
                                            ifelse(Residence_type == "Rural", 0, NA)),
                    # interim fix below, need to add dummy variables for below
                    work_type = as.factor(work_type),
                    smoking_status = as.factor(smoking_status))
# Dropping smoking status for now b/c 31% null -- can revisit on next iteration
(sum(is.na(df$smoking_status))/dim(df)[1])*100
df <- df %>% select(-smoking_status)
## Now will create indicator variables for all categorical features
dummies <- fastDummies::dummy_cols(df %>% select(-id))
dummies <- dummies %>% dplyr::select(-work_type) %>%
dplyr::rename(work_type_Self_employed = `work_type_Self-employed`)
names(df)
names(dummies)
summary(dummies)
dplyr::setdiff(names(dummies), names(df))
dplyr::setdiff(names(df), names(dummies))
# re-assigning id
dummies$id <- df$id
# Checking equality for common features before and after transform
all.equal(df %>% select(-work_type), dummies %>% select(-work_type_children,
                                                        -work_type_Private,
                                                        -work_type_Self_employed,
                                                        -work_type_Govt_job,
                                                        -work_type_Never_worked))
training_data <- dummies %>% tidyr::drop_na()
(dim(training_data)[1]/dim(df)[1])*100 # preserve ~97% of records after dropping null
### Notes:
summary(training_data)
# 1.Filtering unrealistic values of BMI
max(training_data$bmi, na.rm = TRUE) # doesn't seem realistic according to cdc
training_data <- training_data %>% filter(bmi < 50)
dim(training_data)[1]/dim(dummies)[1] # still have ~95% of original records 
# 2. Quick look at stroke cases
summary(training_data %>% filter(stroke == 1))
rm(dummies)
########################################################################
# scaled_data <- as.data.frame(scale(training_data %>% select(age, avg_glucose_level, bmi),
#                                    center = TRUE, scale = TRUE))
# training_data <- cbind(training_data %>% select(-age,-avg_glucose_level,-bmi), scaled_data)
# rm(scaled_data)
# Comparing stroke versus non-stroke patients
stroke_cases <- training_data %>% filter(stroke == 1)
stroke_cases_no <- training_data %>% filter(stroke == 0)
# stroke victims older compared to non-stroke
summary(stroke_cases$age) # Mean = 68.68, Median = 72 (yrs old)
summary(stroke_cases_no$age) # Mean = 41.41, Median = 43 (yrs old)
summary(stroke_cases$hypertension) # 27% have hypertension compared to 8% for non-stroke
summary(stroke_cases_no$hypertension)
summary(stroke_cases$heart_disease) # 22% have heart disease compared to 4% for non-stroke
summary(stroke_cases_no$heart_disease)
summary(stroke_cases$ever_married) # 89% YES ever married compared to 63% for non-stroke
summary(stroke_cases_no$ever_married)
summary(stroke_cases$avg_glucose_level) # glucose levels mean/median = 130.25/104.6
summary(stroke_cases_no$avg_glucose_level) # glucose level mean/median = 102.97/91.14
rm(stroke_cases, stroke_cases_no)
## Class imbalance
# Original proportions of classes (0 = NO, 1 = YES)
# Original proportions of classes (0 = NO, 1 = YES)
prop.table(table(training_data$stroke))*100
# Setting formula with linear features
formula_linear <- as.formula(stroke ~ gender + age + hypertension + heart_disease + ever_married + Residence_type + avg_glucose_level + bmi + work_type_children + work_type_Private + work_type_Never_worked + work_type_Self_employed + work_type_Govt_job)
########################################################################
## Balancing classed with ROSE package
# 50/50 split
data_rose_0.5 <- ROSE(formula_linear, p = 0.5, data = training_data, seed = 123, hmult.majo=0, hmult.mino=0)$data
dim(data_rose_0.5) # 40163 x 14
prop.table(table(data_rose_0.5$stroke))*100 
summary(data_rose_0.5)
# 75/25 split
data_rose_0.75 <- ROSE(formula_linear, p = 0.75, data = training_data, seed = 123)$data
dim(data_rose_0.75) # 40706 x 14
prop.table(table(data_rose_0.75$stroke))*100
summary(data_rose_0.75)
set.seed(13)
data_rose_0.5_stroke <- data_rose_0.5 %>% filter(stroke == 1)
stroke_index <- sample(seq_len(nrow(data_rose_0.5_stroke)), size = 0.8*dim(data_rose_0.5_stroke)[1])
train_stroke <- data_rose_0.5_stroke[stroke_index, ]
test_stroke <- data_rose_0.5_stroke[-stroke_index, ]
data_rose_0.5_nostroke <- data_rose_0.5 %>% filter(stroke == 0)
nostroke_index <- sample(seq_len(nrow(data_rose_0.5_nostroke)), size = 0.8*dim(data_rose_0.5_nostroke)[1])
train_nostroke <- data_rose_0.5_nostroke[nostroke_index,]
test_nostroke <- data_rose_0.5_nostroke[-nostroke_index,]
train <- rbind(train_stroke,train_nostroke)
test <- rbind(test_stroke, test_nostroke)
rm(data_rose_0.5_stroke, stroke_index, train_stroke, test_stroke,data_rose_0.5_nostroke, nostroke_index, train_nostroke, test_nostroke)
#Principal Component Analysis
pc <- prcomp(train[,c(1:14)], center = TRUE, scale. = TRUE)
attributes(pc) # checking to see what attributes are store in pca
pc$center # gives the average of all the variables
pc$scale # checking the scale to see that the sd is calculated for each variable.
print(pc)
summary(pc)
screeplot(pc)
screeplot(pc,type="l")
str(pc)
#bi plot
library(devtools)
install_github("vqv/ggbiplot")
library(ggbiplot)
ggbiplot(pc)
g <- ggbiplot(pc, obs.scale = 1, var.scale = 1, groups = train$stroke,ellipse = TRUE, circle = TRUE, ellipse.prob = 0.75)
g <- g + scale_color_discrete(name ='')
g <- g + theme(legend.direction = 'horizontal',
                         legend.position = 'top')
print(g)
# Data Visualisation, Age, Bmi and Average Glucose.
#BMI
ggplot(train, aes(as.factor(stroke), bmi))+
 geom_boxplot(col = "blue")+
 labs(
  title = "BMI by Stroke",
  x = "stroke"
 )+
 theme(plot.title = element_text(hjust = .5)) #Based on the boxplot, bmi is not higher risk for stroke victims than non-stroke victims.

#avg_gluecose_level
ggplot(train, aes(as.factor(stroke), avg_glucose_level))+
 geom_boxplot(col = "blue")+
 ggtitle("Distribution of Glucose by Stroke")+
 xlab("stroke")+
 theme(plot.title = element_text(hjust = .5)) # Based on the boxplot, It appears that the average glucose level for stroke victims is higher than non-stroke victims
# Age
 ggplot(train, aes(as.factor(stroke), age))+
 geom_boxplot(col = "blue")+
 labs(
  title = "Age vs Stroke",
  x = "stroke"
 )+
 theme(plot.title = element_text(hjust = .5))#The boxplot shows that the median age for stroke victims is higher than the median age of non-stroke victims.
 
