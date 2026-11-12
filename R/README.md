# R: Global Developer Survey Analysis and coursework

## Featured project: Global Developer Survey

**Question:** What shapes a developer's pay and job satisfaction?

Cleaning and testing a global developer survey of 65,437 responses across 48 variables.

**Slides:** [Global Developer Survey Analysis (PDF)](https://dhruvk1310-lang.github.io/dhruvs-portfolio/decks/Dhruv-Khanna-Developer-Survey.pdf)
**Report:** [`Final-Project/Final.docx`](./Final-Project/Final.docx) · [`Final-Project/Executive-Summary.docx`](./Final-Project/Executive-Summary.docx)

### What I did

- **Cleaned** the survey: filtered invalid pay and satisfaction values, turned text ranges like "Less than 1 year" into numbers, and split multi-select employment answers into yes/no columns.
- **Tested** relationships with chi-square tests, ANOVA and correlation on about 15,900 complete responses.

### Results

- Median total pay is **$66k**; the mean ($86k) is pulled up by extreme outliers.
- Work setup: 6,819 hybrid, 6,460 fully remote and 2,619 fully in person. Remote setup varies strongly by country (χ² = 3,402.5, p < .001).
- **Every test was significant, but the effects are small.** Years of coding correlates with pay at r = 0.15, which means it explains only about **2%** of the variation in pay. With a sample this large, significance alone says little; effect size is what matters.

## Coursework

The other files are class labs and assignments, covering cleaning, describing, filtering, merging, missing data, correlation, mean-difference tests, forecasting, decomposition, geospatial analysis and validation.
