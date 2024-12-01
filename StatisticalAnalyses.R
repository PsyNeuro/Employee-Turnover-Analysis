#install.packages("readr")
#install.packages("tidyverse")
#install.packages("rstatix")
#install.packages("tidyverse")
#install.packages("car")

                  # load libraries 

library(readxl)   # read data 
library(ggplot2)  # plot data 
library(tidyverse)# clean and view data
library(rstatix)  # statistics 
library(car)

#load data 
data1 <- read.csv("C:/Users/janus/.cache/kagglehub/datasets/tawfikelmetwally/employee-dataset/versions/1/Employee.csv")
print(data1)

                                      #### average no. female and male new hires over six years ####


# extract new hires yearly by gender

counts <- data1 %>% 
  filter(JoiningYear >= 2012 & JoiningYear <= 2018) %>% 
  group_by(Gender,JoiningYear) %>% 
  summarise(count = n(), .groups = "drop")

# assumption testing
shapiro.test(x = counts$count)          # W = 0.94644, p-value = 0.5069
counts %>%
  levene_test(formula = count ~ Gender) # df1 = 1, df2 = 12, statistic = 0.009, p = 0.92

# t-test
new_hires <- counts %>% 
  t.test(count ~ Gender, data = ., alternative = "less")

new_hires

# t = -1.8401, df = 11.979, p-value = 0.04532
# I have grouped the data for every year into one t test calculation, this leads to significance, but just barely
# this does not mean the insight is less valid as we did not consider the variation within a year

# If we look at specific cities, like Bangalore and Pune, we see differences

# Pune
counts_Pune <- data1 %>% 
  filter(City == "Pune") %>% 
  group_by(Gender,JoiningYear) %>% 
  summarise(count = n(), .groups = "drop")

# assumption testing
shapiro.test(x = counts_Pune$count)             # W = 0.8414, p-value = 0.01701
counts_Pune %>%
  levene_test(formula = count ~ Gender)         # df1 = 1, df2 = 12, statistic = 0.7, p = 0.42

counts_Pune

Pune_new_hires <- counts_Pune %>%              # t = -0.32352, df = 8.2935, p-value = 0.7543
  t.test(count ~ Gender, data = .)


# Bangalore
counts_Bangalore <- data1 %>% 
  filter(JoiningYear >= 2012 & JoiningYear <= 2018) %>% 
  filter(City == "Bangalore") %>% 
  group_by(Gender, JoiningYear) %>% 
  summarise(count = n(), .groups = "drop")

# assumption testing
shapiro.test(x = counts_Bangalore$count)      # W = 0.90869, p-value = 0.1509
counts_Bangalore %>%
  levene_test(formula = count ~ Gender)       # df1 = 1, df2 = 12, statistic = 1.45, p = 0.25

Bangalore_new_hires <- counts_Bangalore %>%   # t = -7.3853, df = 8.7758, p-value = 4.766e-05
  t.test(count ~ Gender, data = .)

Bangalore_new_hires

                                                  #### Turnover ####

# assumption testing
shapiro.test(x = data1$LeaveOrNot)            # W = 0.60017, p-value < 2.2e-16
data1 %>%
  levene_test(formula = LeaveOrNot ~ Gender)  # df1 = 1, df2 = 4651, statistic = 238, p = 1.95e-52

t.test(LeaveOrNot ~ Gender, data = data1)     # t = 15.043, df = 3656.5, p-value < 2.2e-16

                                                  #### Gender Pay gap ####


# Here we will do a t test on Pay predicted by gender, we will make gender categories as integer values
# which will calculate average pay added together
Gender = as.factor(data1$Gender)
Pay = as.integer(data1$PaymentTier)

# Assumption tests
shapiro.test(x = Pay)                                 # W = 0.57102, p-value < 2.2e-16
data1 %>%
  levene_test(formula = PaymentTier ~ Gender)         # df1 = 1, df2 = 4651, statistic = 272, p = 1.83e-59

tgender <- t.test(Pay ~ Gender, alternative = "less") # t = -15.737, df = 3349.6, p-value < 2.2e-16



                                                #### Gender Pay gap (Pune) ####

#extract the data
PuneBranch <- which(data1$City == "Pune")
PuneGender <- Gender[PuneBranch]
PunePay <- Pay[PuneBranch]

# Assumption testing  
shapiro.test(x = PunePay)                 # W = 0.71763, p-value < 2.2e-16
leveneTest(PunePay, PuneGender)           # df = 1, F value = 19.49, p-value = 1.093e-05

punegender = t.test(PunePay ~ PuneGender,
                    alternative = "less") # t = -18.515, df = 1182.8, p-value < 2.2e-16


#### Are women at the Pune branch less educated, this would reasonably lead to less pay ####

Pune = data1[PuneBranch, ]
class(Pune$Education)
Pune$Education = as.numeric(factor(Pune$Education, levels = c("Bachelors","Masters","PHD")))
table(Pune$Education)

gender_edu = aov(formula = Education ~ Gender,data = Pune)

summary(gender_edu)

#### Are women at the Pune branch less experienced, this would reasonably lead to less pay ####

Pune$ExperienceInCurrentDomain = as.numeric(Pune$ExperienceInCurrentDomain)

gender_exp = aov(formula = ExperienceInCurrentDomain ~ Gender,data = Pune)
summary(gender_exp)
