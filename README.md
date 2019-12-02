# *Stat-613: Final Project*

This project reflects the work of Abdul, Casey and Dustin for our final project in Dr. Wall's *Stat-613: Data Science course*. 

## High-level Understanding: 

In this project, we seek to accomplish the following tasks:

1. Tidy, visualize, and understand healthcare data related to stroke

2. Predict whether or not a patient will have a stroke

3. Design a shiny app to investigates results through visualization, summary statistics and model evaluation

## Data Understanding

### **Pre-requisites**
***
For this project, we communicate and contribute code in R (`v 3.6.0`) via RStudio and shinyapps.io

### **Data Source(s)**
***
We obtained our dataset from Kaggle [Healthcare Dataset Stroke Data](https://www.kaggle.com/asaumya/healthcare-dataset-stroke-data). This dataset contains information on more than 40,000 patients along dimensions such as gender, BMI, smoke history, and more. 

### **Codebase configuration**
***
For this project we work with the tidyverse [tidyverse](https://www.tidyverse.org/) across the board to manipulate, visualize, transform and otherwise understand data 

We use the following packages to train and evaluate models: random forest [randomForest](https://cran.r-project.org/web/packages/randomForest/randomForest.pdf), support vector machine [libsvm](https://cran.r-project.org/web/packages/e1071/vignettes/svmdoc.pdf), neural network [neuralnet](https://cran.r-project.org/web/packages/neuralnet/neuralnet.pdf) and logistic regression [glm2](https://cran.r-project.org/web/packages/glm2/glm2.pdf).

In addition to these modeling packages, we make use of [ROSE](https://cran.r-project.org/web/packages/ROSE/ROSE.pdf) to address class inbalance, [fastDummies](https://cran.r-project.org/web/packages/fastDummies/fastDummies.pdf) to convert categorical data to binary variables, [png](https://cran.r-project.org/web/packages/png/png.pdf) to display png files in RMarkdown, and [caret](https://cran.r-project.org/web/packages/caret/caret.pdf) to otherwise investigate model related tasks such as principal component analysis, partitioning data, etc.

The user needs these packages installed as well as the most current version or R and RStudio to leverage this work.

## Data Preparation

Data was downloaded from Kaggle and imported as a csv to begin analysis.

### **Feature engineering**
***

- **Missing data**:
Missing data was not a significant problem in this project. After all initial transformations were complete, we opted to drop 1 entire column that was 31% null (smoking status) and then drop all rows with 1 or more `NA` after.

- **Reasonable data**:
The variable BMI (body mass index) had some unreasonable values (e.g. `BMI = 67`); according to the CDC, values this high are unfeasible. Thus, we removed all cases with a BMI greater than 50%. After handling missing values and filter BMI we still had 95% of the original rows in the raw data.

- **Transformations**:

- One column (`id`) was numeric and thus was converted to character

- Each categorical column was converted to a collection of binary indicator variables (1 for each category in that variable)

- Any feature with 0 variance after transformation was removed from the training data


### **Class imbalance**
***

We address the class imbalance problem with the ROSE package by randomly oversampling according to a smoothed-bootstrap approach. In other words, we generate synthetic data that is representative of the rare class (having a stroke in this case) to balance occurrences of stroke and non-stroke. This allows us to train models in a minimally biased manner. 


### **Partition data**
***

For the purposes of this project, we apply a 90% - 10% train and test partition for model training. 


## Modeling

### **Principal component analysis**
***

We utilize prinicpal component analysis to visualize and better understand which features best explain the variance of the data.

### **Binary classification framework**
***

For each model type used in this project (neural network, logistic regression, and random forest), we compute both the class probabilities and class predictions for each. We set the threshold for class prediction to 0.5

### **Model training**
***

Recall that for the purposes of the project, we train one model on 90% of the training data and validate on the remaining 10%. The following models were trained:

- **Logistic regression**:
The logistic regression model is trained in the typical fashion (using the binomial distribution). We calculate both log-likelihood and class probabilities in order to visualize the logits. As mentioned above, we construct class predictions by values over/under 0.5 

- **Neural network**:
We train a neural network with the neuralnet package. This model utilizes 1 hidden layer with 2 neurons, binary cross entropy as the error function, sigmoid activation function and resilient backpropagation without backtracking algorithm.

- **Random forest**:
The random forest model is trained on 150 trees. The default values for the remaining parameters were reasonable for our use case.

- **Voting classifier**:
This model is an ensemble classifier comprised of predictive information from all 3 models discussed above. The prediction from this ensemble is determined by the average predicted probablity from all models. 

## Evaluation

### **Metrics and other considerations**
***

Models were assessed by 2 key metrics - *accuracy* and *AUC* (area under the ROC curve) - and to a lesser extent by sensitivity. We consider the confusion matrix and ROC curve or each model. 

## Deployment

### **ShinyApp**
***

Key insights and metrics are viewable on our project shinyApp. [Stroke](https://caseyag.shinyapps.io/StrokeDataShiny/)

