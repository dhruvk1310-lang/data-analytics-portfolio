proc import datafile="/home/u63994028/Data mining BAN628/19-Lab project 4/Lab Project 4-Data.csv" out=WD replace; 
guessingrows=max;
run;
proc print data=WD (obs=10);
run;
/* Removing non-numeric text from the variables and Converting Numeric data from Char to num*/
data WD;
    set WD;
    _temp = input(compress('fixed acidity'n, '0123456789.', 'k'), best32.);
    drop 'fixed acidity'n;
    rename _temp='fixed acidity'n;
run;
data WD;
    set WD;
    _temp = input(compress('volatile acidity'n, '0123456789.', 'k'), best32.);
    drop 'volatile acidity'n;
    rename _temp='volatile acidity'n;
run;
data WD;
    set WD;
    _temp = input(compress('free sulfur dioxide'n, '0123456789.', 'k'), best32.);
    drop 'free sulfur dioxide'n;
    rename _temp='free sulfur dioxide'n;
run;
data WD;
    set WD;
    _temp = input(compress(alcohol, '0123456789.', 'k'), best32.);
    drop alcohol;
    rename _temp='alcohol%'n;
run;
data WD;
    set WD;
    _temp = input(compress(quality, '0123456789.', 'k'), best32.);
    drop quality;
    rename _temp=quality;
run;
proc print data=WD (obs=10);
run;
proc contents data=WD;
run;
/* Handling Missing Values */
proc means data=WD nmiss;
run;
data WD;
    set WD;
    if cmiss(of _all_) = 0 then output;
run;
proc means data=WD nmiss;
run;
data WD_subset;
	set WD;
    drop ID color;
run;
/* PCA */
proc stdize data=WD_subset out=WD_standardized;
run;
proc princomp data=WD_standardized out=WD_pca plots=score(ncomp=2) n=2;
run;
/* Handling outliers*/
data WD;
set WD;
if _n_ not in (150,4295) then output;
run;
/*PREPROCESSING(after outliers)*/
proc print data=WD (obs=10);
run;
proc means data=WD nmiss;
run;
proc stdize data=WD out=WD_standardized;
run;
proc princomp data=WD_standardized out=WD_pca plots=none;
run;
proc princomp data=WD_standardized out=WD_pca plots=score(ncomp=2) n=2;
run;
proc sgplot data=WD_pca;
	scatter x=Prin1 y=Prin2;
run;
/* Add observation numbers to PCA output for subsequent merge */
data WD_pca;
	set WD_pca;
	obsnum = _n_;
run;

/* CLUSTER ANALYSIS USING HIERARCHICAL CLUSTERING */

/* TODO: Set section title */
title "Hierarchical Clustering";

/* Identify clusters using dendrogram */
proc cluster data=WD_pca outtree=WD_tree method=ward notie noprint;
	var Prin1 Prin2;
	id obsnum;
run;

/* TODO: Create clusters */
proc tree data=WD_tree out=WD_cluster_hierarchical n=2;
	id obsnum;
run;

/* Clean cluster output */
data WD_cluster_hierarchical;
	set WD_cluster_hierarchical;
	keep obsnum CLUSTER;
	rename CLUSTER=CLUSTER_HIERARCHICAL;
run;

/* Sort cluster output for subsquent merge */
proc sort data=WD_cluster_hierarchical;
	by obsnum;
run;

/* Merge cluster output into PCA output */
data WD_pca;
    merge WD_pca WD_cluster_hierarchical;
    by obsnum;
run;

/* Plot the principal components with clusters */
proc sgplot data=WD_pca;
	scatter x=Prin1 y=Prin2 / group=CLUSTER_HIERARCHICAL;
run;

/* Add observation numbers to original data for subsequent merge */
data WD;
	set WD;
	obsnum = _n_;
run;

/* Merge cluster output into original data */
data WD;
    merge WD WD_cluster_hierarchical;
    by obsnum;
    drop obsnum;
run;

/* Count number of observations in each cluster */
proc freq data=WD;
	tables CLUSTER_HIERARCHICAL / nocum;
run;

/* TODO: Calculate unique value counts of each nominal variable for each cluster (in %) */
proc freq data=WD;
    tables CLUSTER_HIERARCHICAL*Color/ nocum nofreq nocol nopercent;
run;

/* TODO: Calculate the average of each quantitative variable for each cluster */
proc means data=WD mean;
	var 'citric acid'n	'residual sugar'n	chlorides	density	pH	sulphates 'fixed acidity'n	'volatile acidity'n	'free sulfur dioxide'n	'alcohol%'n	quality;
	class CLUSTER_HIERARCHICAL;
run;

title "K-Means Clustering";

/* TODO: Create clusters */
proc fastclus data=WD_pca out=WD_cluster_kmeans noprint maxclusters=2;
	var prin1 prin2;
	id obsnum;
run;

/* Clean cluster output */
data WD_cluster_kmeans;
	set WD_cluster_kmeans;
	keep obsnum CLUSTER;
	rename CLUSTER=CLUSTER_KMEANS;
run;

/* Sort cluster output for subsquent merge */
proc sort data=WD_cluster_kmeans;
	by obsnum;
run;

/* Merge cluster output into PCA output */
data WD_pca;
    merge WD_pca WD_cluster_kmeans;
    by obsnum;
run;

/* Plot the principal components with clusters */
proc sgplot data=WD_pca;
	scatter x=Prin1 y=Prin2 / group=CLUSTER_KMEANS;
run;

/* Add observation numbers to original data for subsequent merge */
data WD;
	set WD;
	obsnum = _n_;
run;

/* Merge cluster output into original data */
data WD;
    merge WD WD_cluster_kmeans;
    by obsnum;
    drop obsnum;
run;

/* Count number of observations in each cluster */
proc freq data=WD;
	tables CLUSTER_KMEANS / nocum;
run;
/* TODO: Calculate unique value counts of each nominal variable for each cluster (in %) */
proc freq data=WD;
    tables CLUSTER_KMEANS*Color/ nocum nofreq nocol nopercent;
run;

/* TODO: Calculate the average of each quantitative variable for each cluster */
proc means data=WD mean;
	var 'citric acid'n	'residual sugar'n	chlorides	density	pH	sulphates 'fixed acidity'n	'volatile acidity'n	'free sulfur dioxide'n	'alcohol%'n	quality;
	class CLUSTER_KMEANS;
run;
 
























