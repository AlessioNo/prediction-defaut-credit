# R Script Title: Impact of interest rate on loan default
# Author: NOCERA Alessio, LATIL Quentin, WANG Qi, GUO Ruiqi
# Date: March 19, 2024
# Operating System: Windows 10
# Machine Type: Laptop

#########################################################################################
#########################CAN'T RUN CODE UNTIL LINE 59####################################
#########################################################################################

# why? : because the original data frame (accepted_2007_to_2018Q4) is way too heavy to send it to you

# library(tidyverse)

# Lending Club has made available the information on all transactions that have been conducted on the 
# platform from 2007 to 2019. The database (accepted_2007_to_2018Q4) comprises over 2 million rows  
# and 151 variables, making it exceptionally large (1.6GB)

# df <- accepted_2007_to_2018Q4

# We selected data from January 2016 to March 2016, resulting in just under 135,000 records.
# We used subset to filter the data frame

# df1 <- subset(df, issue_d == "Jan-2016" | issue_d == "Feb-2016" | issue_d == "Mar-2016")

# We used subset to only keep "Fully Paid" and "Charged off"(=default) and to remove "current",
# "in grace period" and "late" to loan_status

# df2 <- subset(df1, loan_status == "Charged Off" | loan_status == "Fully Paid")

# We selected potential explanatory variables in addition to loan_status (dependent variable)
# and int_rate (independent variable) and obtained a data frame with 30 variables

# df3 <- select(df2, loan_amnt, term, int_rate, installment, grade, sub_grade, emp_title ,emp_length 
#              ,home_ownership ,annual_inc ,verification_status ,issue_d ,loan_status ,purpose ,title ,
#              zip_code ,addr_state ,dti ,earliest_cr_line ,open_acc ,pub_rec ,revol_bal ,revol_util ,
#              total_acc ,initial_list_status ,application_type ,mort_acc ,pub_rec_bankruptcies,
#              delinq_2yrs, fico_range_low)

# We removed all the lines where there are NA. Our new data frame had now a little bit more than 115k rows
# Still too big to send it.

# df4 <- na.omit(df3)

# However, even this subset was substantial, prompting us to further streamline our analysis. 
# We got a random sample of 15,000 rows

# df5 <- df4[sample(nrow(df4), 15000), ]

# We used the write_xlsx function from the writexl library to write the contents of the data frame df5
# to an Excel file named "RandomS.xlsx" to avoid problem with the random sample (change of sample)

# library(writexl)
# write_xlsx(df5,"RandomS.xlsx")

#! START RUNNING CODE FROM BELLOW BECAUSE THE ORIGINAL DATA FRAME IS TOO HEAVY TO START FROM THE BEGINNING
# SO WE CAN'T SEND IT 

library(tidyverse)
library(readxl)
library(psych)
library(summarytools)
library(sandwich)
library(lmtest)
library(jtools)
library(margins)
library(writexl)

# Read the excel named "RandomS"
library(readxl)
RandomS <- read_excel("RandomS.xlsx")
View(RandomS)

df5 <- RandomS

##################################################################### Variable modifications

# We created a new binary variable called business. 
df5$business <- ifelse(df5$purpose == "small_business", 1, 0)

# We turned delinquency into a binary variable using ifelse function to deal with outliers. 
df5$delinq <- ifelse(df5$delinq_2yrs == 0, 0, 1)

# Change charged off and fully paid to 1 and 0 and loan_status can only take those two values
df5$loan_status[df5$loan_status == "Charged Off"] <- 1
df5$loan_status[df5$loan_status == "Fully Paid"] <- 0

# Same thing for the application type
df5$application_type[df5$application_type == "Joint App"] <- 1
df5$application_type[df5$application_type == "Individual"] <- 0

# Same thing for the term
df5$term[df5$term == "60 months"] <- 1
df5$term[df5$term == "36 months"] <- 0

# We used the function gsub to remove all the characters that are not numbers from the employment length
df5$emp_length <- gsub("years", "", df5$emp_length)
df5$emp_length <- gsub("year", "", df5$emp_length)
df5$emp_length <- gsub("\\+", "", df5$emp_length)
df5$emp_length <- gsub("< 1", "0", df5$emp_length)

# Check data types of variables
sapply(df5, class)

# We made sure that the variable that we planned to test in the econometric regression were all set to 
# the good types of variables 
df5$annual_inc<-as.numeric(df5$annual_inc)
df5$dti<-as.numeric(df5$dti)
df5$delinq_2yrs<-as.numeric(df5$delinq_2yrs)
df5$open_acc<-as.numeric(df5$open_acc)
df5$loan_amnt<-as.numeric(df5$loan_amnt)
df5$int_rate<-as.numeric(df5$int_rate)
df5$installment<-as.numeric(df5$installment)
df5$business<-as.character(df5$business)
df5$emp_length<-as.numeric(df5$emp_length)
df5$delinq<-as.character(df5$delinq)

# Even Thought loan_status is a binary variable, to use it in a logit regressions as the dependent
# variable, we must put it as numeric
df5$loan_status <- as.numeric(df5$loan_status)

# Our new data frame with selected variables after reviewing literature
df6 <- select(df5, loan_status, int_rate, term, dti, open_acc, delinq, mort_acc)

# Now that we have chosen our variables, let's label them
label(df6$loan_status) <- "Status of the loan: 1=Charged Off & 0=Fully Paid"
label(df6$int_rate) <- "Interest rate"
label(df6$term) <- "Duration of the loan: 1=60 months & 0=36 months"
label(df6$dti) <- "Debt to income ratio"
label(df6$open_acc) <- "Number of current credit lines"
label(df6$delinq) <- "Delinquency: 1=one or more default in the last 2yrs & 0=no default in the last 2yrs"
label(df6$mort_acc) <- "Number of current mortgage accounts"
# To views labels
label(df6, all= TRUE)

############################################################################### Outliers

# We used box plots to identify outliers so we could remove them manually
# In a standard box plot, outliers are often considered points that fall outside 1.5 times
# the interquartile range (IQR) beyond the upper or lower quartiles.
boxplot(df6$open_acc)
boxplot(df6$mort_acc)
boxplot(df6$dti)

# after removing top outlier. We can indentify other outliers better
# The following codes are used for Figure 1 & 2
boxplot(df6$dti)
df18 <- subset(df6, dti <= 100)
boxplot(df18$dti)

# we create df8 which have the same variable has df6 but whitout the outliers
# we use subset function to remove rows with values over a certain level for some variables
df8 <- df6
df8 <- subset(df8, open_acc <= 30)
df8 <- subset(df8, mort_acc <= 8)
df8 <- subset(df8, dti <= 55)


############################################################## Descriptive statistics / Graphs

############################ Summaries

# good for quantitative
# The following code is used for Table 4
library(psych)
describe(df8, quant = c(.25,.75))

# good for qualitative
# The following code is used for Table 3
library(summarytools)
dfSummary(df8)

########################### Graphs between loan_status and our binary variables

# The codes of this section are not used

# Creating a pivot table to count the occurrences of each combination  for loan status and term
table <- table(df8$loan_status, df8$term)

# Bar Chart
barplot(table, beside = TRUE,
        col = c("lightblue", "lightgreen"),
        xlab = "Term", ylab = "Frequency",
        names.arg = c("36 month", "60 month"),
        main = "Bar Chart term/loan_status")
legend('topright', legend=c('Fully paid', 'Default'), fill=c('lightblue', 'lightgreen'))


# Extractions of frequencies for the combinations
frequ_00_01 <- table[1, ]
frequ_10_11 <- table[2, ]

# Computations of ratios
ratioo_00_01 <- frequ_00_01[2]/frequ_00_01[1]
ratioo_10_11 <-  frequ_10_11[2]/frequ_10_11[1]

# Results
cat("Ratio of people that defaulted on people that didn't if term equal to 36month:", ratioo_00_01, "\n")
cat("Ratio of people that defaulted on people that didn't if term equal to 60month:", ratioo_10_11, "\n")

# We do the same for loan status and delinquency
table1 <- table(df8$loan_status, df8$delinq)

# Bar chart
barplot(table1, beside = TRUE,
        col = c("lightblue", "lightgreen"),
        names.arg = c("no delinquency", "delinquency"),
        main = "Bar Chart Delinq/loan_status",
        xlab = "Delinquency",
        ylab = "Frequency")
legend('topright', legend=c('Fully paid', 'Default'), fill=c('lightblue', 'lightgreen'))

# Extractions of frequencies for the combinations
freq_00_01 <- table1[1, ]
freq_10_11 <- table1[2, ]

# Computation of ratios
ratio_00_01 <- freq_00_01[2]/freq_00_01[1]
ratio_10_11 <-  freq_10_11[2]/freq_10_11[1]

# Results
cat("Ratio of people that defaulted on people that didn't if no delinquency in the last 2yrs:", ratio_00_01, "\n")
cat("Ratio of people that defaulted on people that didn't if delinquency in the last 2yrs:", ratio_10_11, "\n")

############################## Plots for our continuous variables

# Box plot 
# The following code is used for Figure 3
boxplot(df8$int_rate~df8$loan_status,  main='Boxplot of interest rates by loan status modalities',
        xlab='Loan Status',
        ylab='Interest Rate')

# The following plot codes are not used
boxplot(df8$open_acc~df8$loan_status)
boxplot(df8$mort_acc~df8$loan_status)
boxplot(df8$dti~df8$loan_status)

# Grouped bar chart int_rate
barplot(tapply(df8$int_rate, df8$loan_status, mean), 
        beside=TRUE, col=c('lightblue', 'lightgreen'),ylim=c(0, max(df8$int_rate) + 1),
        names.arg=unique(df8$loan_status),
        main='Average Interest Rate by Loan Status',
        xlab='Loan Status',
        ylab='Average Interest Rate')

# Grouped bar chart open_acc
barplot(tapply(df8$open_acc, df8$loan_status, mean), 
        beside=TRUE, col=c('lightblue', 'lightgreen'),ylim=c(0, max(df8$open_acc) + 1),
        names.arg=unique(df8$loan_status),
        main='Average open accounts by Loan Status',
        xlab='Loan Status',
        ylab='Average open accounts')

# Grouped bar chart mort_acc
barplot(tapply(df8$mort_acc, df8$loan_status, mean), 
        beside=TRUE, col=c('lightblue', 'lightgreen'),ylim=c(0, max(df8$mort_acc) + 1),
        names.arg=unique(df8$loan_status),
        main='Average mortgage accounts by Loan Status',
        xlab='Loan Status',
        ylab='Average mortgage accounts')

# Grouped bar chart dti
barplot(tapply(df8$dti, df8$loan_status, mean), 
        beside=TRUE, col=c('lightblue', 'lightgreen'),ylim=c(0, max(df8$dti) + 1),
        names.arg=unique(df8$loan_status),
        main='Average Debt to income ratio by Loan Status',
        xlab='Loan Status',
        ylab='Average debt to income ratio')

######################################################################## Econometric
library(sandwich)
library(lmtest)
library(jtools)

# After testing for significant results in the regression we decided to keep the term, dti, open_acc,
# delinq and mort_acc as our control variables
logit <- glm(loan_status ~ int_rate+ term + dti + open_acc + delinq + mort_acc, data = df8,
             family = binomial(link='logit'))
summary(logit)

# Display the summary of the logit regression with robust standard errors
# The following code is used for Table 5
coeftest(logit, vcov = vcovHC, type = "HC1")

#Test for multicollinearity between continuous var
# We made a data frame with only the continuous var
df7 <- select(df8,int_rate, dti, open_acc, mort_acc)

# Compute the correlation matrix
cor_matrix <- cor(df7)
# Print the correlation matrix
print(cor_matrix)

################################################################# Calculate average marginal effect

library(margins)

# We use the margins function to obtain the AME of the logit model
# The following code is used for Table 5
AMElogit <- margins(logit)
summary(AMElogit)

################################################################ Endogeneity

# The following code is used for Figure 4 
plot(logit$residuals, df8$int_rate, xlab='Residuals',ylab='Interest rate')

################################################################ Prediction Model

# Don't run the following line. Instead read directly the two samples so that we have the same 
# results when using the predict model 

# Generate a vector of indices for the first subset
# Randomsample <- sample(1:nrow(df8), size = 0.7 * nrow(df8))

# Create two subsets based on the indices
# subset1 <- df8[Randomsample, ]
# subset2 <- df8[-Randomsample, ]

# library(writexl)
# transform the random samples into
# write_xlsx(subset1,"model.xlsx")
# write_xlsx(subset2,"predict.xlsx")

# Read the excel random samples 
model <- read_excel("model.xlsx")
predict <- read_excel("predict.xlsx")

# use data "model" for the econometric regression
logitmodel <- glm(loan_status ~ int_rate+ term + dti + open_acc + delinq + mort_acc, data = model, family = binomial(link='logit'))
summary(logitmodel)

# use data "predict" for prediction
df.predict <- predict(logitmodel, newdata=predict, type='response')
# to see what it looks like
head(df.predict)

# We have to choose a threshold for the prediction. Lets try with 0.5
df.predict <- ifelse(df.predict > 0.5, 1, 0)
# Transform into factors
df.predict <- factor(df.predict, levels = c(0,1), labels = c("predicted Fully Paid", "predicted Default"))
predict$Decision <- factor(predict$loan_status, levels = c(0,1), labels = c("Fully Paid", "Defaulted"))

# Create the confusion table
confusion_table <- table(df.predict, predict$Decision)
print(confusion_table)

# Another way to view the result of the confusion table is by dividing every values by the sum 
# of the values of the column
# The following code is used for Table 6
percent.col <- prop.table(table(df.predict, predict$Decision),2)
print(percent.col)

# Reset df.predict for the new threshold
df.predict <- predict(logitmodel, newdata=predict, type='response')
# We have to choose a threshold for the prediction. Here we chose 0.2 after careful consideration
df.predict <- ifelse(df.predict > 0.2, 1, 0)
# Transform into factors
df.predict <- factor(df.predict, levels = c(0,1), labels = c("predicted Fully Paid", "predicted Default"))
predict$Decision <- factor(predict$loan_status, levels = c(0,1), labels = c("Fully Paid", "Defaulted"))

# The following code is used for Table 7
percent.col <- prop.table(table(df.predict, predict$Decision),2)
print(percent.col)

# We do a mosaic plot which allows us to easily understand the proportions of the confusion matrix
# The following code is used for Figure 5
mosaicplot(table(predict$Decision, df.predict))

