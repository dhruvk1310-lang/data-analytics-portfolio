/* PCA (Principal Component Analysis) Visualization: Exercise */

/*
Problem 1

Please analyze the attached retail store sales performance data to identify potential groups of stores 
with similar characteristics (i.e., clusters) as well as potential outliers.

- Q1: Examine the principal component loadings (a.k.a. eigenvectors). Which variables are most strongly (positively or 
negatively) correlated with each principal component? What does this mean for the interpretation of the 
principal components?
- A1: : 
For Prin1, the most strongly positively correlated variables are:
 Store_Size (0.375)
 Employees (0.373)
 Traffic (0.373)
 Monthly_Sales (0.369)
 and Avg_Trans_Value (0.363). 
 This indicates that Prin1 reflects the overall size and operational performance of the store, 
 with larger stores, more traffic, and higher sales scoring higher.
For Prin2, the most strongly positively correlated variable are:
 Discount_Rate (0.895),
 Promotions (0.375). 
 This suggests Prin2 represents a store's marketing strategy, 
 with stores offering higher discounts and promotions scoring higher.

In summary, Prin1 measures store size and performance, 
while Prin2 captures the focus on discounts and promotions.

- Q2: Examine the principal component plot. Do you notice any potential clusters and/or potential 
outliers in the data?

- A2: There appear to be three distinct clusters:
A group with low PC1 values (around -4), indicating smaller stores with less activity and possibly different strategies.
A group with PC1 values near 0, which represents stores of moderate size and activity.
A group with high PC1 values (between +2 and +4), representing larger stores with more employees, traffic, and transaction values.
This suggests that stores can be grouped based on their operational scale, with small, medium, and large stores forming distinct clusters. 
These clusters likely represent different business models or operational strategies, such as small boutique stores versus large retail outlets.
*/
proc import datafile="/home/u63994028/Data mining BAN628/12-PCA Viz/PCA Visualization-Exercise-Data1.csv" out=RS replace;
	guessingrows=max;
run;
proc print data=RS(obs=10);
run;
proc corr data=RS noprob;
run;
proc stdize data=RS out=RS_standardized;
run;
proc print data=RS_standardized(obs=10);
run;
proc princomp data=RS_standardized out=RS_pca n=2 plots=none;
run;
proc print data=RS_pca(obs=10);
run;
proc corr data=RS_pca noprob;
	var Prin1 Prin2;
run;
proc sgplot data=RS_pca;
	scatter x=Prin1 y=Prin2;
run;

/*
Problem 2

Please analyze the attached startup funding data to identify potential groups of startups with similar 
characteristics (i.e., clusters) as well as potential outliers.

- Q1: Examine the principal component loadings (a.k.a. eigenvectors). Which variables are most strongly (positively or 
negatively) correlated with each principal component? What does this mean for the interpretation of the 
principal components?
- A1: The variables most strongly correlated (positively or negatively) with Prin1 are:
Funding_MUSD (0.429), Cap_Invest_MUSD (0.432), Experience_Yrs (0.427), Team_Size (0.400).
This suggests that Prin1 represents overall business size and financial investment. 
Companies with higher funding, more capital investment, greater team size, and more experienced leadership tend to score higher on this component. 
In essence, Prin1 reflects the scale and financial strength of a company.

The variables most strongly correlated (positively or negatively) with Prin2 are:

Investors (0.610), Rev_Growth_Rate (0.465), Cap_Invest_MUSD (0.283).
Experience_Yrs (-0.361), Team_Size (-0.390).
Prin2 contrasts company growth and investor interest with experience and team size. 
Higher values on Prin2 indicate companies with more investors and higher revenue growth, but with less experience and smaller teams. 
Thus, Prin2 represents a growth and investment factor, emphasizing fast-growing companies that may be newer or have smaller teams.

- Q2: Examine the principal component plot. Do you notice any potential clusters and/or potential 
outliers in the data?
- A2: The data seems to exhibit two clusters, possibly representing different business profiles.
There are a few outliers that may warrant further investigation to understand what differentiates them from the rest of the data
*/
proc import datafile="/home/u63994028/Data mining BAN628/12-PCA Viz/PCA Visualization-Exercise-Data2.csv" out=FD replace;
	guessingrows=max;
run;
proc print data=FD(obs=10);
run;
proc corr data=FD noprob;
run;
proc stdize data=FD out=FD_standardized;
run;
proc print data=FD_standardized(obs=10);
run;
proc princomp data=FD_standardized out=FD_pca n=2 plots=none;
run;
proc print data=FD_pca(obs=10);
run;
proc corr data=FD_pca noprob;
	var Prin1 Prin2;
run;
proc sgplot data=FD_pca;
	scatter x=Prin1 y=Prin2;
run;


