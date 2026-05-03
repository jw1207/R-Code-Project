# R-Code-Project
OVERVIEW
This project analyzes factors affecting dental treatment duration using statistical modeling and machine learning techniques in R.

The objective is to:

1. Identify key predictors of treatment time
2. Compare multiple linear regression models
3. Evaluate model performance using cross-validation
4. Classify treatments into Short vs Long duration using LDA

DATASET
The dataset (dentaldat.csv) contains patient and treatment-related variables such as:

1. Age at start of treatment
2. Type of surgery (e.g., Extractions, Bimaxillary)
3. Skeletal structure classifications
4. Hospital type
5. Treatment duration

DATA PREPROCESSING
1. Data Cleaning
  a.Checked for missing values using complete.cases()
  b.Removed irrelevant columns:
  c.Pre_surgery_time
  d.Post_surgery_time
  e.Number
2. Feature Transformation
Applied log transformation to:
  a.Treatment_time
  b.Age_start_treatment

Converted categorical variables into factors:
   Sex, Hospital, Surgical types, Skeletal classifications

EXPLORATORY DATA ANALYSIS
Histograms used to understand distributions of:
  a.Treatment time
  b.Age at start of treatment
  
Summary statistics generated for all variables

Linear Regression Models (Part A)

Multiple regression models were built to determine the best predictors of treatment time.

Models Tested:
1. Extractions model
2. Vertical pattern model
3. Transverse model
4. Mandibular model
5. Single/Bimax model
6. Other surgery model
   
Reduced model:
Treatment_time ~ Other + Hospital + Exo

Model Diagnostics:
1. Homoscedasticity checked using residual plots
2. Normality checked using Q-Q plots
Key Insight:

The most important predictors identified:

1. Other surgical procedures
2. Hospital type
3. Extractions (Exo)

Model Evaluation (Cross-Validation)

Used 10-fold cross-validation repeated 1000 times to evaluate models.

Metrics used:
1. PRESS (Prediction Error Sum of Squares)
2. MSE (Mean Squared Error)
3. RMSE (Root Mean Squared Error)
   
Outcome:
1. Compared all models based on average error metrics
2. Selected model with lowest prediction error

Classification with LDA (Part B)

Objective:
Classify treatment duration into:

1. Short (< 2 years)
2. Long (≥ 2 years)

Steps:

1. Created binary variable:
    Treatment_Duration = "Short" or "Long"
2. Built Linear Discriminant Analysis (LDA) model

Features Used:
1. Demographics (Age, Sex)
2. Surgical factors
3. Skeletal classifications
4. Hospital type

LDA Results
1. Visualized separation using:
  a. LD1 histogram
  b. Density plots
2. Evaluated model using:
  a. Confusion Matrix
  b. Overall Accuracy (Hit Rate)

Key Findings
1. Surgical complexity significantly impacts treatment duration
2. Hospital type influences treatment outcomes
3. LDA provides reasonable classification between short and long treatments
4. Simpler models can perform well when key predictors are selected

Libraries Used

1. tidyverse
2. ggplot2
3. MASS
4. bootstrap
5. DAAG
