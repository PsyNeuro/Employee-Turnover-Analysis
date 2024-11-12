#install.packages("readr")
#install.packages("tidyverse")
#install.packages("rstatix")

library(readxl)
library(ggplot2)
library(tidyverse)
library(rstatix)
data1 = read.csv("C:/Users/janus/.cache/kagglehub/datasets/tawfikelmetwally/employee-dataset/versions/1/Employee.csv")
print(data1)


#### Is there a significant difference in pay between Genders? ####

# Here we will do a t test on Pay predicted by gender, we will make gender categories as integer values
# which will calculate average pay added together
Gender = as.factor(data1$Gender)
Pay = as.integer(data1$PaymentTier)

# use Shapiro's Test to check the normal distribution of data, it violates this assumption
shapiro.test(x = Pay)

data1 %>% 
  levene_test(formula = PaymentTier~Gender)

# t.test(Pay~Gender, alternative = "less")

t.test(Pay ~ Gender, alternative = "less")

