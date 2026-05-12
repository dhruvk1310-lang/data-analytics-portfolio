/* TODO: Load data */
proc import datafile="/home/u63994028/Data mining BAN628/18-Cluster Evaluation/Cluster Evaluation-Exercise 1-Data.csv" out=df replace;
	guessingrows=max;
run;
title "Problem 1";
/* Print data */
proc print data=df(obs=10);
run;

/* Show data info */
proc contents data=df;
run;

/* 
PREPROCESSING 

PCA and cluster analysis both require:
 - No missing values
 - Only quantitative variables
 - Standardized data 
*/

/* TODO: Set section title */
title "Preprocessing";

/* Count missing values */
proc means data=df nmiss;
run;

/* Keep rows with no missing values */
data df;
    set df;
    if cmiss(of _all_) = 0 then output;
run;

/* Count missing values */
proc means data=df nmiss;
run;

/* TODO: Create subset containing only quantitative variables */
data df_subset;
    set df;
    drop Employee_ID Department;
run;

/* Standardize the data */
proc stdize data=df_subset out=df_standardized;
run;

/* PRINCIPAL COMPONENT ANALYSIS */

/* TODO: Set section title */
title "Principal Component Analysis";

/* Perform PCA with 2 principal components */
proc princomp data=df_standardized out=df_pca plots=none n=2 ;
run;

/* Plot the principal components */
proc sgplot data=df_pca;
	scatter x=Prin1 y=Prin2;
run;

/* Add observation numbers to PCA output for subsequent merge */
data df_pca;
	set df_pca;
	obsnum = _n_;
run;

/* CLUSTER ANALYSIS USING HIERARCHICAL CLUSTERING */

/* TODO: Set section title */
title "Hierarchical Clustering";

/* Identify clusters using dendrogram */
proc cluster data=df_pca outtree=df_tree method=ward notie noprint;
	var Prin1 Prin2;
	id obsnum;
run;

/* TODO: Create clusters */
proc tree data=df_tree out=df_cluster_hierarchical n=2;
	id obsnum;
run;

/* Clean cluster output */
data df_cluster_hierarchical;
	set df_cluster_hierarchical;
	keep obsnum CLUSTER;
	rename CLUSTER=CLUSTER_HIERARCHICAL;
run;

/* Sort cluster output for subsquent merge */
proc sort data=df_cluster_hierarchical;
	by obsnum;
run;

/* Merge cluster output into PCA output */
data df_pca;
    merge df_pca df_cluster_hierarchical;
    by obsnum;
run;

/* Plot the principal components with clusters */
proc sgplot data=df_pca;
	scatter x=Prin1 y=Prin2 / group=CLUSTER_HIERARCHICAL;
run;

/* Add observation numbers to original data for subsequent merge */
data df;
	set df;
	obsnum = _n_;
run;

/* Merge cluster output into original data */
data df;
    merge df df_cluster_hierarchical;
    by obsnum;
    drop obsnum;
run;

/* Count number of observations in each cluster */
proc freq data=df;
	tables CLUSTER_HIERARCHICAL / nocum;
run;

/* TODO: Calculate unique value counts of each nominal variable for each cluster (in %) */
proc freq data=df;
    tables CLUSTER_HIERARCHICAL*Department / nocum nofreq nocol nopercent;
   
run;

/* TODO: Calculate the average of each quantitative variable for each cluster */
proc means data=df mean;
	var Technical_Skills Communication_Skills Years_of_Experience Project_Completion_Rate Satisfaction_Level;
	class CLUSTER_HIERARCHICAL;
run;

/* CLUSTER ANALYSIS USING K-MEANS CLUSTERING */

/* TODO: Set section title */
title "K-Means Clustering";

/* TODO: Create clusters */
proc fastclus data=df_pca out=df_cluster_kmeans noprint maxclusters=2;
	var prin1 prin2;
	id obsnum;
run;

/* Clean cluster output */
data df_cluster_kmeans;
	set df_cluster_kmeans;
	keep obsnum CLUSTER;
	rename CLUSTER=CLUSTER_KMEANS;
run;

/* Sort cluster output for subsquent merge */
proc sort data=df_cluster_kmeans;
	by obsnum;
run;

/* Merge cluster output into PCA output */
data df_pca;
    merge df_pca df_cluster_kmeans;
    by obsnum;
run;

/* Plot the principal components with clusters */
proc sgplot data=df_pca;
	scatter x=Prin1 y=Prin2 / group=CLUSTER_KMEANS;
run;

/* Add observation numbers to original data for subsequent merge */
data df;
	set df;
	obsnum = _n_;
run;

/* Merge cluster output into original data */
data df;
    merge df df_cluster_kmeans;
    by obsnum;
    drop obsnum;
run;

/* Count number of observations in each cluster */
proc freq data=df;
	tables CLUSTER_KMEANS / nocum;
run;

/* TODO: Calculate unique value counts of each nominal variable for each cluster (in %) */
proc freq data=df;
    tables CLUSTER_HIERARCHICAL*Department / nocum nofreq nocol nopercent;
   
run;

/* TODO: Calculate the average of each quantitative variable for each cluster */
proc means data=df mean;
	var Technical_Skills Communication_Skills Years_of_Experience Project_Completion_Rate Satisfaction_Level;
	class CLUSTER_HIERARCHICAL;
run;
 
 
 
 title "Problem 2";
 /* TODO: Load data */
proc import datafile="/home/u63994028/Data mining BAN628/18-Cluster Evaluation/Cluster Evaluation-Exercise 2-Data.csv" out=df2 replace;
	guessingrows=max;
run;

/* Print data */
proc print data=df2(obs=10);
run;

/* Show data info */
proc contents data=df2;
run;

/* 
PREPROCESSING 

PCA and cluster analysis both require:
 - No missing values
 - Only quantitative variables
 - Standardized data 
*/

/* TODO: Set section title */
title "Preprocessing";

/* Count missing values */
proc means data=df2 nmiss;
run;

/* Keep rows with no missing values */
data df2;
    set df2;
    if cmiss(of _all_) = 0 then output;
run;

/* Count missing values */
proc means data=df2 nmiss;
run;

/* TODO: Create subset containing only quantitative variables */
data df2_subset;
    set df2;
    drop Preferred_Shopping_Channel Loyalty_Status;
run;

/* Standardize the data */
proc stdize data=df2_subset out=df2_standardized;
run;

/* PRINCIPAL COMPONENT ANALYSIS */

/* TODO: Set section title */
title "Principal Component Analysis";

/* Perform PCA with 2 principal components */
proc princomp data=df2_standardized out=df2_pca plots=none n=2 ;
run;

/* Plot the principal components */
proc sgplot data=df2_pca;
	scatter x=Prin1 y=Prin2;
run;

/* Add observation numbers to PCA output for subsequent merge */
data df2_pca;
	set df2_pca;
	obsnum = _n_;
run;

/* CLUSTER ANALYSIS USING HIERARCHICAL CLUSTERING */

/* TODO: Set section title */
title "Hierarchical Clustering";

/* Identify clusters using dendrogram */
proc cluster data=df2_pca outtree=df2_tree method=ward notie noprint;
	var Prin1 Prin2;
	id obsnum;
run;

/* TODO: Create clusters */
proc tree data=df2_tree out=df2_cluster_hierarchical n=4;
	id obsnum;
run;

/* Clean cluster output */
data df2_cluster_hierarchical;
	set df2_cluster_hierarchical;
	keep obsnum CLUSTER;
	rename CLUSTER=CLUSTER_HIERARCHICAL;
run;

/* Sort cluster output for subsquent merge */
proc sort data=df2_cluster_hierarchical;
	by obsnum;
run;

/* Merge cluster output into PCA output */
data df2_pca;
    merge df2_pca df2_cluster_hierarchical;
    by obsnum;
run;

/* Plot the principal components with clusters */
proc sgplot data=df2_pca;
	scatter x=Prin1 y=Prin2 / group=CLUSTER_HIERARCHICAL;
run;

/* Add observation numbers to original data for subsequent merge */
data df2;
	set df2;
	obsnum = _n_;
run;

/* Merge cluster output into original data */
data df2;
    merge df2 df2_cluster_hierarchical;
    by obsnum;
    drop obsnum;
run;

/* Count number of observations in each cluster */
proc freq data=df2;
	tables CLUSTER_HIERARCHICAL / nocum;
run;

/* TODO: Calculate unique value counts of each nominal variable for each cluster (in %) */
proc freq data=df2;
    tables CLUSTER_HIERARCHICAL*Preferred_Shopping_Channel / nocum nofreq nocol nopercent;
    tables CLUSTER_HIERARCHICAL*Loyalty_Status / nocum nofreq nocol nopercent;
run;

/* TODO: Calculate the average of each quantitative variable for each cluster */
proc means data=df2 mean;
	var Purchase_Frequency	Avg_Spend_Per_Purchase	Discount_Usage Customer_Satisfaction;
	class CLUSTER_HIERARCHICAL;
run;

/* CLUSTER ANALYSIS USING K-MEANS CLUSTERING */

/* TODO: Set section title */
title "K-Means Clustering";

/* TODO: Create clusters */
proc fastclus data=df2_pca out=df2_cluster_kmeans noprint maxclusters=4;
	var prin1 prin2;
	id obsnum;
run;

/* Clean cluster output */
data df2_cluster_kmeans;
	set df2_cluster_kmeans;
	keep obsnum CLUSTER;
	rename CLUSTER=CLUSTER_KMEANS;
run;

/* Sort cluster output for subsquent merge */
proc sort data=df2_cluster_kmeans;
	by obsnum;
run;

/* Merge cluster output into PCA output */
data df2_pca;
    merge df2_pca df_cluster_kmeans;
    by obsnum;
run;

/* Plot the principal components with clusters */
proc sgplot data=df2_pca;
	scatter x=Prin1 y=Prin2 / group=CLUSTER_KMEANS;
run;

/* Add observation numbers to original data for subsequent merge */
data df2;
	set df2;
	obsnum = _n_;
run;

/* Merge cluster output into original data */
data df2;
    merge df2 df2_cluster_kmeans;
    by obsnum;
    drop obsnum;
run;

/* Count number of observations in each cluster */
proc freq data=df2;
	tables CLUSTER_KMEANS / nocum;
run;
/* TODO: Calculate unique value counts of each nominal variable for each cluster (in %) */
proc freq data=df2;
    tables CLUSTER_HIERARCHICAL*Preferred_Shopping_Channel / nocum nofreq nocol nopercent;
    tables CLUSTER_HIERARCHICAL*Loyalty_Status / nocum nofreq nocol nopercent;
run;

/* TODO: Calculate the average of each quantitative variable for each cluster */
proc means data=df2 mean;
	var Purchase_Frequency	Avg_Spend_Per_Purchase	Discount_Usage Customer_Satisfaction;
	class CLUSTER_HIERARCHICAL;
run;

title "Problem 3";
 /* TODO: Load data */
proc import datafile="/home/u63994028/Data mining BAN628/18-Cluster Evaluation/Cluster Evaluation-Exercise 3-Data.csv" out=df3 replace;
	guessingrows=max;
run;

/* Print data */
proc print data=df3(obs=10);
run;

/* Show data info */
proc contents data=df3;
run;

/* 
PREPROCESSING 

PCA and cluster analysis both require:
 - No missing values
 - Only quantitative variables
 - Standardized data 
*/

/* TODO: Set section title */
title "Preprocessing";

/* Count missing values */
proc means data=df3 nmiss;
run;

/* Keep rows with no missing values */
data df3;
    set df3;
    if cmiss(of _all_) = 0 then output;
run;

/* Count missing values */
proc means data=df3 nmiss;
run;
/* Standardize the data */
proc stdize data=df3 out=df3_standardized;
run;

/* PRINCIPAL COMPONENT ANALYSIS */

/* TODO: Set section title */
title "Principal Component Analysis";

/* Perform PCA with 2 principal components */
proc princomp data=df3_standardized out=df3_pca plots=none n=2 ;
run;

/* Plot the principal components */
proc sgplot data=df3_pca;
	scatter x=Prin1 y=Prin2;
run;

/* Add observation numbers to PCA output for subsequent merge */
data df3_pca;
	set df3_pca;
	obsnum = _n_;
run;

/* CLUSTER ANALYSIS USING HIERARCHICAL CLUSTERING */

/* TODO: Set section title */
title "Hierarchical Clustering";

/* Identify clusters using dendrogram */
proc cluster data=df3_pca outtree=df3_tree method=ward notie noprint;
	var Prin1 Prin2;
	id obsnum;
run;

/* TODO: Create clusters */
proc tree data=df3_tree out=df3_cluster_hierarchical n=5;
	id obsnum;
run;

/* Clean cluster output */
data df3_cluster_hierarchical;
	set df3_cluster_hierarchical;
	keep obsnum CLUSTER;
	rename CLUSTER=CLUSTER_HIERARCHICAL;
run;

/* Sort cluster output for subsquent merge */
proc sort data=df3_cluster_hierarchical;
	by obsnum;
run;

/* Merge cluster output into PCA output */
data df3_pca;
    merge df3_pca df3_cluster_hierarchical;
    by obsnum;
run;

/* Plot the principal components with clusters */
proc sgplot data=df3_pca;
	scatter x=Prin1 y=Prin2 / group=CLUSTER_HIERARCHICAL;
run;

/* Add observation numbers to original data for subsequent merge */
data df3;
	set df3;
	obsnum = _n_;
run;

/* Merge cluster output into original data */
data df3;
    merge df3 df3_cluster_hierarchical;
    by obsnum;
    drop obsnum;
run;

/* Count number of observations in each cluster */
proc freq data=df3;
	tables CLUSTER_HIERARCHICAL / nocum;
run;

/* TODO: Calculate the average of each quantitative variable for each cluster */
proc means data=df3 mean;
	var Weekly_Visit_Frequency	Avg_Spend_Per_Visit	Organic_Purchase_Rate	Discount_Usage_Rate	Total_Products_Bought;
	class CLUSTER_HIERARCHICAL;
run;

/* CLUSTER ANALYSIS USING K-MEANS CLUSTERING */

/* TODO: Set section title */
title "K-Means Clustering";

/* TODO: Create clusters */
proc fastclus data=df3_pca out=df3_cluster_kmeans noprint maxclusters=5;
	var prin1 prin2;
	id obsnum;
run;

/* Clean cluster output */
data df3_cluster_kmeans;
	set df3_cluster_kmeans;
	keep obsnum CLUSTER;
	rename CLUSTER=CLUSTER_KMEANS;
run;

/* Sort cluster output for subsquent merge */
proc sort data=df3_cluster_kmeans;
	by obsnum;
run;

/* Merge cluster output into PCA output */
data df3_pca;
    merge df3_pca df_cluster_kmeans;
    by obsnum;
run;

/* Plot the principal components with clusters */
proc sgplot data=df3_pca;
	scatter x=Prin1 y=Prin2 / group=CLUSTER_KMEANS;
run;

/* Add observation numbers to original data for subsequent merge */
data df3;
	set df3;
	obsnum = _n_;
run;

/* Merge cluster output into original data */
data df3;
    merge df3 df3_cluster_kmeans;
    by obsnum;
    drop obsnum;
run;

/* Count number of observations in each cluster */
proc freq data=df3;
	tables CLUSTER_KMEANS / nocum;
run;
/* TODO: Calculate the average of each quantitative variable for each cluster */
proc means data=df3 mean;
	var Weekly_Visit_Frequency	Avg_Spend_Per_Visit	Organic_Purchase_Rate	Discount_Usage_Rate	Total_Products_Bought;
	class CLUSTER_HIERARCHICAL;
run;





