# Impact of Interest Rate on Loan Default in P2P Platforms 📊

[cite_start]This repository contains the R code, datasets, and the final research paper for an academic project completed in March 2024[cite: 3]. 

[cite_start]The motivation of this study is to analyze the impact of interest rates on loan default rates using a large-scale dataset obtained from a leading P2P lending company[cite: 5]. [cite_start]Specifically, we analyzed data from LendingClub [cite: 69][cite_start], focusing on loans issued in the first quarter of 2016[cite: 5]. 

## 📁 Repository Contents

* [cite_start]**`Paper_Applied.pdf`**: The final research paper detailing our methodology, literature review, descriptive statistics, and conclusions[cite: 12].
* **`Code.R`**: The main R script used for data cleaning, outlier treatment, exploratory data analysis (EDA), and building the logistic regression and prediction models.
* **`README.md`**: This document.

### 💾 Datasets Explained
[cite_start]The original LendingClub database comprises over 2 million rows and 151 variables (1.6GB), which is too large to be hosted here[cite: 72]. To make the analysis reproducible, we provided the specific subsets we used:

1. **`data_RandomS.xlsx`**: This is our primary working dataset. [cite_start]After filtering the massive original dataset for January-March 2016 [cite: 74] [cite_start]and cleaning missing values, we extracted a random sample of 15,000 records[cite: 79]. 
2. **`train.xlsx`**: (Referred to as `model.xlsx` in the R script). This dataset contains 70% of the `data_RandomS.xlsx` sample. It was used to train our Econometric Logistic Regression Model.
3. **`test.xlsx`**: (Referred to as `predict.xlsx` in the R script). This dataset contains the remaining 30% of the sample. It was used exclusively to test the predictive capability of our model and build the confusion matrix.

## 🛠️ Technologies & Libraries Used

* **Language**: R
* **Key Libraries**: `tidyverse`, `readxl`, `psych`, `summarytools`, `sandwich`, `lmtest`, `jtools`, `margins`, `writexl`.

## 🚀 Methodology & Key Findings

[cite_start]We employed a logistic model to regress the interest rate on loan default, controlling for various factors including debt-to-income ratio, number of current credit lines, delinquency in the last two years, number of mortgage accounts, and loan term[cite: 5]. 

**Key findings:**
* All variables have a positive impact on the probability of default, except for the number of mortgage accounts that have a negative impact[cite: 7]. 
* [cite_start]For a one percentage point increase in the interest rate, the average change in the probability of loan default increases by 1.7 percentage points[cite: 142].
* [cite_start]**Conclusion**: Increasing interest rates might not be the best strategy to reduce the risk of loan default[cite: 165].

## 👨‍💻 Authors

* NOCERA Alessio [cite: 2]
* [cite_start]LATIL Quentin [cite: 2]
* [cite_start]WANG Qi [cite: 2]
* GUO Ruiqi [cite: 2]
