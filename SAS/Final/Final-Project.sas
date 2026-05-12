proc import datafile="/home/u63994028/Final Project/heart_disease_patients.csv" out=heart_disease_data replace;
	guessingrows=max;
run;
Proc print data=heart_disease_data (obs=10);run;

/* Display Summary Statistics */
proc means data=heart_disease_data n mean std min max;
    var age trestbps chol thalach oldpeak;
run; /* This procedure generates summary statistics, including count, mean, standard deviation, minimum, and maximum values for the specified numerical variables. */

proc sgpanel data=heart_disease_data;
    panelby oldpeak;
    vbox chol / category=thalach;
    title 'Distribution of Cholesterol by Maximum Heart Rate and ST Depression';
run;

/* Count Plots for Categorical Variables */
proc freq data=heart_disease_data;
    tables sex cp fbs restecg exang slope / plots=freqplot;
run;

/* Correlation Analysis */
proc corr data=heart_disease_data plots(maxpoints=10000)=matrix(histogram);
    var age trestbps chol thalach oldpeak;
run;

/* Plot Correlation of Quantitative Variables */
proc sgplot data=heart_disease_data;
    scatter x=thalach y=trestbps / colorresponse=oldpeak colormodel=ThreeColorRamp;
    title 'Correlation between Maximum Heart Rate and Resting Blood Pressure';
run;

/* Plot Relationship of Age, Cholesterol, and Maximum Heart Rate */
proc sgplot data=heart_disease_data;
    scatter x=age y=chol / colorresponse=thalach colormodel=TwoColorRamp;
    title 'Relationship between Age, Cholesterol, and Maximum Heart Rate';
run;

proc stdize data=heart_disease_data out=HDD_standardized;
run;

/* Print standardized data */
proc print data=HDD_standardized(obs=10);
run;

/* Principal Component Analysis */
title "Principal Component Analysis";

/* Perform PCA with 2 principal components */
proc princomp data=HDD_standardized out=df_pca plots=none n=2;
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

/* Cluster Analysis Using Hierarchical Clustering */
title "Hierarchical Clustering";

/* Identify clusters using dendrogram */
proc cluster data=df_pca outtree=df_tree method=ward notie noprint;
    var Prin1 Prin2;
    id obsnum;
run;

/* Create clusters */
proc tree data=df_tree out=df_cluster_hierarchical n=2;
    id obsnum;
run;

/* Clean cluster output */
data df_cluster_hierarchical;
    set df_cluster_hierarchical;
    keep obsnum CLUSTER;
    rename CLUSTER=CLUSTER_HIERARCHICAL;
run;

/* Sort cluster output for subsequent merge */
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
data heart_disease_data;
    set heart_disease_data;
    obsnum = _n_;
run;

/* Merge cluster output into original data */
data heart_disease_data;
    merge heart_disease_data df_cluster_hierarchical;
    by obsnum;
    drop obsnum;
run;

/* Count number of observations in each cluster */
proc freq data=heart_disease_data;
    tables CLUSTER_HIERARCHICAL / nocum;
run;

/* Calculate unique value counts of each nominal variable for each cluster (in %) */
proc freq data=heart_disease_data;
    tables CLUSTER_HIERARCHICAL*sex / nocum nofreq nocol nopercent;
    tables CLUSTER_HIERARCHICAL*cp / nocum nofreq nocol nopercent;
    tables CLUSTER_HIERARCHICAL*restecg / nocum nofreq nocol nopercent;
run;

/* Calculate the average of each quantitative variable for each cluster */
proc means data=heart_disease_data mean;
    var age trestbps chol thalach oldpeak;
    class CLUSTER_HIERARCHICAL;
run;

/* Cluster Analysis Using K-Means Clustering */
title "K-Means Clustering";

/* Create clusters */
proc fastclus data=df_pca out=df_cluster_kmeans noprint maxclusters=2;
    var Prin1 Prin2;
    id obsnum;
run;

/* Clean cluster output */
data df_cluster_kmeans;
    set df_cluster_kmeans;
    keep obsnum CLUSTER;
    rename CLUSTER=CLUSTER_KMEANS;
run;

/* Sort cluster output for subsequent merge */
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
data heart_disease_data;
    set heart_disease_data;
    obsnum = _n_;
run;

/* Merge cluster output into original data */
data heart_disease_data;
    merge heart_disease_data df_cluster_kmeans;
    by obsnum;
    drop obsnum;
run;

/* Count number of observations in each cluster */
proc freq data=heart_disease_data;
    tables CLUSTER_KMEANS / nocum;
run;

/* Calculate unique value counts of each nominal variable for each cluster (in %) */
proc freq data=heart_disease_data;
    tables CLUSTER_KMEANS*sex / nocum nofreq nocol nopercent;
    tables CLUSTER_KMEANS*cp / nocum nofreq nocol nopercent;
    tables CLUSTER_KMEANS*restecg / nocum nofreq nocol nopercent;
run;

/* Calculate the average of each quantitative variable for each cluster */
proc means data=heart_disease_data mean;
    var age trestbps chol thalach oldpeak;
    class CLUSTER_KMEANS;
run;

 
