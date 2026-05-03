
#Load Data and Prepare Library
dental <- read.csv("dentaldat.csv")
library(tidyverse)
library(ggplot2)
library(MASS)
library(bootstrap)
library(DAAG)

# Deleting Pre_Surg_Time and Post_Surg_Time
# Rationale: 
# Will be using only Response Variable to Total Treatment Time on both 
# Part a and b

# 1. Data Cleaning
#Check Completeness of data
n_total <- nrow(dental) 
n_completeEntries <- sum(complete.cases(dental))
cat("Total observations:", n_total, "\n")
cat("Complete cases:", n_completeEntries, "\n")

# 1.2 Delete Column Pre_Surg_Time, Post_Surg_Time and Number
dental$Pre_surgery_time <- NULL
dental$Post_surgery_time <- NULL
dental$Number <- NULL

view(dental)
glimpse(dental)

# Log Transformation of data
dental$Treatment_time <- log(dental$Treatment_time)
dental$Age_start_treatment <- log(dental$Age_start_treatment)


# 2. Data processing
dental$Sex <- as.factor(dental$Sex)
dental$Skeletal_AP <- as.factor(dental$Skeletal_AP)
dental$Vertical <- as.factor(dental$Vertical)
dental$Transverse <- as.factor(dental$Transverse)
dental$Max <- as.factor(dental$Max)
dental$Mand <- as.factor(dental$Mand)
dental$Single_Bimax <- as.factor(dental$Single_Bimax)
dental$Exo <- as.factor(dental$Exo)
dental$Other <- as.factor(dental$Other)
dental$Hospital <- as.factor(dental$Hospital)

# 3. Visualization of data

hist(dental$Age_start_treatment,
     xlim = c(0,5),
     xlab = "Age Start Treatment",
     main = "Histogram of Age Start Treatment",
     breaks = 20,
     col = "pink")
axis(side = 1, at = seq(0,5, by = 1))

hist(dental$Treatment_time,
     xlim = c(4,8),
     xlab = "Treatment Time (days)",
     main = "Histogram of Treatment Time",
     breaks = 20,
     col = "lightblue")
axis(side = 1, at = seq(0,2500, by = 250))
summary(dental)

##################   4. Linear Model 2a) ########################################

model.exo <- lm((logTreatment_time) ~ Age_start_treatment + Skeletal_AP
                + Single_Bimax + Exo + Hospital + Sex, data = dental)

model.vertical <- lm((Treatment_time) ~ Age_start_treatment + Skeletal_AP
                     + Single_Bimax + Vertical + Hospital + Sex, data = dental)

model.Transverse <- lm((Treatment_time) ~ Age_start_treatment + Skeletal_AP
                       + Single_Bimax + Transverse + Hospital + Sex, data = dental)

model.Mand <- lm((Treatment_time) ~ Age_start_treatment + Skeletal_AP
                 + Single_Bimax + Mand + Hospital + Sex, data = dental)

model.singbi <- lm((Treatment_time) ~ Age_start_treatment + Skeletal_AP
                   + Single_Bimax + Hospital + Sex, data = dental)

model.other <- lm((Treatment_time) ~ Age_start_treatment + Skeletal_AP
                  + Single_Bimax + Other + Hospital + Sex, data = dental)

model.OHE <- lm((Treatment_time) ~ Other + Hospital + Exo, data = dental)

summary(model.exo)
summary(model.vertical)
summary(model.Transverse)
summary(model.Mand)
summary(model.singbi)
summary(model.other)
summary(model.OHE)

# Best predictor other (other surgery performed), private hospital and exo (atleast one tyooth)


#Homoscedascity Assumption
plot(model.OHE, which = 1, add.smooth = FALSE)
abline(h = 0, col ="red")

#Normality Assumption 
qqnorm(model.OHE$residuals,
       main = "Normal Q-Q Plot of residuals for the fitted Values")
qqline(model.OHE$residuals, col = "blue")



# Cross Validation Process
formulae <- c(
  "Treatment_time ~ Age_start_treatment + Skeletal_AP + Single_Bimax + Exo + Hospital + Sex",
  "Treatment_time ~ Age_start_treatment + Skeletal_AP + Single_Bimax + Vertical + Hospital + Sex",
  "Treatment_time ~ Age_start_treatment + Skeletal_AP + Single_Bimax + Transverse + Hospital + Sex",
  "Treatment_time ~ Age_start_treatment + Skeletal_AP + Single_Bimax + Mand + Hospital + Sex",
  "Treatment_time ~ Age_start_treatment + Skeletal_AP + Single_Bimax + Hospital + Sex",
  "Treatment_time ~ Age_start_treatment + Skeletal_AP + Single_Bimax + Other + Hospital + Sex",
  "Treatment_time ~ Other + Hospital + Exo"
)

ncrossval <- 1000

PRESS.mat <- matrix(NA, nrow = ncrossval, ncol = length(formulae))
MSE.mat   <- matrix(NA, nrow = ncrossval, ncol = length(formulae))
RMSE.mat  <- matrix(NA, nrow = ncrossval, ncol = length(formulae))

model.fit <- function(x, y) {
  lm(y ~ x - 1)
}

predicted.values <- function(model.fit, x) {
  as.vector(x %*% coef(model.fit))   # safer
}

for (i in 1:ncrossval) {
  
  for (j in 1:length(formulae)) {
    
    pulse.10cv <- crossval(
      model.matrix(as.formula(formulae[j]), data = dental),
      dental$Treatment_time,
      ngroup = 10,
      theta.fit = model.fit,
      theta.predict = predicted.values
    )
    
    # Remove NA safely
    valid <- !is.na(pulse.10cv$cv.fit)
    
    PRESS.mat[i, j] <- sum((dental$Treatment_time[valid] - pulse.10cv$cv.fit[valid])^2)
    MSE.mat[i, j]   <- mean((dental$Treatment_time[valid] - pulse.10cv$cv.fit[valid])^2)
    RMSE.mat[i, j]  <- sqrt(MSE.mat[i, j])
  }
}

# Results
mean_PRESS <- apply(PRESS.mat, 2, mean, na.rm = TRUE)
mean_MSE   <- apply(MSE.mat, 2, mean, na.rm = TRUE)
mean_RMSE  <- apply(RMSE.mat, 2, mean, na.rm = TRUE)

mean_PRESS
min(mean_PRESS)
which.min(mean_PRESS)


min(mean_MSE)
which.min(mean_MSE)

min(mean_RMSE)
which.min(mean_RMSE)




######################################### part b ########################################
dental$Treatment_Duration <- ifelse(dental$Treatment_time >= log(730), "Long", "Short")
dental$Treatment_Duration <- as.factor(dental$Treatment_Duration)


ggplot(dental, aes(x = Hospital, fill = Treatment_Duration)) +
  geom_bar(position = "fill") +
  ylab("Proportion") +
  ggtitle("Proportion of Long Treatments by Hospital Type")

ggplot(dental, aes(x = Other, fill = Treatment_Duration)) +
  geom_bar(position = "fill") +
  ylab("Proportion") +
  ggtitle("Proportion of Long Treatments by Other Type")

ggplot(dental, aes(x = Exo, fill = Treatment_Duration)) +
  geom_bar(position = "fill") +
  ylab("Proportion") +
  ggtitle("Proportion of Long Treatments by Exo Type")

sum(dental$Treatment_Duration == "Long")
sum(dental$Treatment_Duration == "Short")
66 / (sum(dental$Treatment_Duration == "Long") + sum(dental$Treatment_Duration == "Short"))
129 / (sum(dental$Treatment_Duration == "Long") + sum(dental$Treatment_Duration == "Short"))

dental.lda <- lda(Treatment_Duration~ Age_start_treatment  + Sex + Skeletal_AP
                + Vertical + Transverse + Max + Single_Bimax + Exo + Hospital
                + Mand + Single_Bimax + Exo + Other + Hospital,
                 data = dental)


ld.values <- predict(dental.lda)
lda.data <- as.data.frame(ld.values$x)
str(lda.data)

lda.data$Treatment_Duration <- dental$Treatment_Duration


ldahist(lda.data$LD1, g = dental$Treatment_Duration)

# Confusion matrix
table(Predicted = ld.values$class, Actual = dental$Treatment_Duration)

# Overall Hit Rate
mean(ld.values$class == dental$Treatment_Duration)

ggplot(lda.data, aes(x = LD1, fill = Treatment_Duration)) +
  geom_density(alpha = 0.5) +
  labs(title = "LDA: LD1 by Treatment Duration",
       x = "LD1", y = "Density")





