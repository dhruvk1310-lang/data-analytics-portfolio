/* Cluster Description: Exercise */

/* Load data */
/* TODO: CHANGE FILE NAME! */
proc import datafile="/home/u63994028/Data mining BAN628/17- Cluster Description/Cluster Description-Exercise-Data.csv" out=LSI replace;
	guessingrows=max;
run;

/* Print data */
proc print data=LSI(obs=10);
run;

/* Show data info */
proc contents data=LSI;
run;

/* 
PREPROCESSING 

Cluster analysis requires:
 - No missing values
 - Only quantitative variables
 - Standardized data 
*/

/* Count missing values */
proc means data=LSI nmiss;
run;

/* Keep rows with no missing values */
data LSI;
    set LSI;
    if cmiss(of _all_) = 0 then output;
run;

/* Count missing values */
proc means data=LSI nmiss;
run;

/* Create subset containing only quantitative variables */
/* TODO: CHANGE VARIABLES! */
data LSI_subset;
    set LSI;
    drop Location_ID Region;
run;

/* Show subset info */
proc contents data=LSI_subset;
run;

/* Standardize the data */
proc stdize data=LSI_subset out=LSI_standardized;
run;

/* Print standardized data */
proc print data=LSI_standardized(obs=10);
run;

/* Add observation number to standardized data for subsequent merge */
data LSI_standardized;
	set LSI_standardized;
	obsnum = _n_;
run;

/* CLUSTER ANALYSIS */

/* Identify clusters using dendrogram */
proc cluster data=LSI_standardized outtree=LSI_tree method=ward print=0 notie plots(maxpoints=10000)=dendrogram(vertical);
	id obsnum;
run;

/* Create clusters */
/* TODO: CHANGE NUMBER OF CLUSTERS! */
proc tree data=LSI_tree out=LSI_cluster n=2 noprint;
	id obsnum;
run;

/* Sort cluster subset for subsquent merge */
proc sort data=LSI_cluster;
	by obsnum;
run;

/* Add observation number to original data for subsequent merge */
data LSI;
	set LSI;
	obsnum = _n_;
run;

/* Merge original data with cluster subset */
data LSI(drop=obsnum);
    merge LSI LSI_cluster(keep=obsnum CLUSTER);
    by obsnum;
run;

/* Print data (Note: Now contains CLUSTER variable) */
proc print data=LSI(obs=10);
run;

/* Count number of observations in each cluster */
proc freq data=LSI;
	tables CLUSTER / nocum;
run;

/* Calculate unique value counts (in %) of each nominal variable for each cluster (i.e., % within each cluster) */
/* TODO: CHANGE VARIABLES! */
proc freq data=LSI;
    tables CLUSTER*Region / nocum nofreq nocol nopercent;
run;

/* Calculate the average of each quantitative variable for each cluster */
proc means data=LSI mean;
	class CLUSTER;
run;

