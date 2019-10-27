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

We use the following packages to train evaluate models: random forest [randomForest](https://cran.r-project.org/web/packages/randomForest/randomForest.pdf), support vector machine [libsvm](https://cran.r-project.org/web/packages/e1071/vignettes/svmdoc.pdf), neural network [neuralnet](https://cran.r-project.org/web/packages/neuralnet/neuralnet.pdf) and logistic regression [glm2](https://cran.r-project.org/web/packages/glm2/glm2.pdf).

In addition to these modeling packages, we make use of [bootstrap](https://cran.r-project.org/web/packages/bootstrap/bootstrap.pdf) to address target class inbalance and [mice](https://cran.r-project.org/web/packages/mice/mice.pdf) to handle missing data.

The user needs these packages installed as well as the most current version or R and RStudio to leverage this work.





