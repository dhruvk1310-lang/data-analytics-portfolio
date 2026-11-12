# SAS: Heart Disease Risk Segmentation and coursework

## Featured project: Heart Disease Risk Segmentation

**Question:** Without diagnosis labels, can patients be split into clear risk groups?

PCA and cluster analysis on 303 patients and 12 clinical measures, built in SAS.

**Slides:** [Heart Disease Risk Segmentation (PDF)](https://dhruvk1310-lang.github.io/dhruvs-portfolio/decks/Dhruv-Khanna-Heart-Disease-Segmentation.pdf)
**Code:** [`Final/Final-Project.sas`](./Final/Final-Project.sas) · **Summary:** [`Final/Final-Project-Summary.docx`](./Final/Final-Project-Summary.docx) · **Data:** [`Final/heart_disease_patients.csv`](./Final/heart_disease_patients.csv)

### Approach

1. **Profile:** distributions, frequencies and Pearson correlations.
2. **Reduce:** PCA to find the main dimensions of variation.
3. **Segment:** hierarchical clustering and k-means, as a check that the groups are real and not an artifact of one method.
4. **Describe:** profile each cluster and compare the two methods.

### Results

- **The first two principal components explain only 34.3% of the variance**, with maximum heart rate and ST depression contributing most. Risk is spread across many measures, so clustering uses all of them.
- **Both methods find the same two groups:**
  - *Older, higher risk:* mean age 58 to 59, resting blood pressure 134 to 138 mm Hg, ST depression 1.7, more men and more severe chest pain.
  - *Younger, lower risk:* mean age 51, maximum heart rate 161 to 163 bpm, ST depression 0.37, mostly women and milder chest pain.

**Next step:** bring in diagnosis labels to test whether the higher-risk cluster really has more heart disease, then build a supervised model such as logistic regression.

## Coursework

The other `.sas` files are class labs: managing and recoding variables, univariate, bivariate and trivariate analysis, PCA, and cluster creation, description and evaluation.
