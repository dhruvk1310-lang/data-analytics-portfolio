# Sales and Profitability Analysis (Python)

**Question:** What drives profit across 700 sales transactions, and can a model predict it?

An end-to-end Python project on a public financial sample dataset from Kaggle: five customer segments and five countries across 2013 and 2014.

**Slides:** [Sales and Profitability Analysis (PDF)](https://dhruvk1310-lang.github.io/dhruvs-portfolio/decks/Dhruv-Khanna-Sales-Profitability.pdf)

## Files

| File | What it is |
|---|---|
| [`Final-Project.ipynb`](./Final-Project.ipynb) | The full notebook: cleaning, analysis and models |
| [`Financials.csv`](./Financials.csv) | The dataset |
| [`Final-Project-Report.docx`](./Final-Project-Report.docx) | Written report |
| [`Final-Presentation.pptx`](./Final-Presentation.pptx) | Class presentation |

## What I did

- **Cleaned** the discount field (dollar signs, dashes, blanks) and treated extreme outliers with the IQR rule.
- **Engineered** profit margin, profit per unit and a four-level profit category, and parsed dates for trend analysis.
- **Compared three models** for predicting profit, using mean absolute error on a held-out test set.

## Results

- **Profit follows sales, not production cost:** the correlation with sales is 0.48, with manufacturing price just 0.02.
- **Profit peaks every June and December**, in both years.
- **Government is the largest segment**, at 300 of the 700 transactions.
- **A decision tree beat linear regression by 25%:** mean absolute error of $1.15M vs $1.52M (KNN: $1.31M).

**What I'd improve:** the best model still misses by about $1.1M on an average profit near $1.5M. Next steps are keeping the accounting identity intact when treating outliers, adding product and sale price as features, and comparing every model against a simple baseline.
