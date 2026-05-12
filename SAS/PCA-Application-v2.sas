/* PCA (Principal Component Analysis) Integration: Exercise */

/*
Problem 1

Please analyze the attached customer behavior data (where each row/observation is 
one customer) to identify potential groups of customers with similar characteristics 
(i.e., clusters) as well as potential outliers.

- Q1: How many extreme outliers are in the data?
- A1: 5
- Q2: What are the row numbers of the extreme outliers?
- A2: 40,135,555,893,931
- Q3: After deleting the extreme outliers, how many principal components are retained 
(using the Kaiser Rule)?
- A3: 4
- Q4: After deleting the extreme outliers, what is the total variance explained by all 
retained principal components?
- A4: 58.11%
- Q5: After deleting the extreme outliers, how many potential clusters are in the data?
- A5: 2
*/
proc import datafile="/home/u63994028/Data mining BAN628/14 PCA Application/PCA Application-Exercise-Data1.csv" out=CB replace;
	guessingrows=max;
run;
proc print data=CB(obs=10);
run;
proc contents data=CB;
run;
proc means data=CB nmiss;
run;
proc stdize data=CB out=CB_standardized;
run;
proc print data=CB_standardized(obs=10);
run;
proc princomp data=CB_standardized out=CB_pca plots=none;
run;
proc princomp data=CB_standardized out=CB_pca plots=score(ncomp=2) n=4;
run;
data CB_outliers;
    set CB;
    if _n_ in (40,135,555,893,931);
run;
proc print data=CB_outliers;
run;
data CB;
    set CB;
    if _n_ not in (40,135,555,893,931);
run;
proc contents data=CB;
run;
proc means data=CB nmiss;
run;
proc stdize data=CB out=CB_standardized;
run;
proc print data=CB_standardized(obs=10);
run;
proc princomp data=CB_standardized out=CB_pca plots=none;
run;
proc princomp data=CB_standardized out=CB_pca plots=score(ncomp=2) n=4;
run;

/*
Problem 2

Please analyze the attached corporate travel expense data (where each row/observation 
is one  travel expense) to identify potential groups of travel expenses with similar 
characteristics (i.e., clusters) as well as potential outliers.

- Q1: How many extreme outliers are in the data?
- A1: 4
- Q2: What are the row numbers of the extreme outliers?
- A2: 141,272,313,694
- Q3: After deleting the extreme outliers, how many principal components are retained 
(using the Kaiser Rule)?
- A3: 4
- Q4: After deleting the extreme outliers, what is the total variance explained by all 
retained principal components?
- A4: 65.21%
- Q5: After deleting the extreme outliers, how many potential clusters are in the data?
- A5: There aren't any clusters 
*/
proc import datafile="/home/u63994028/Data mining BAN628/14 PCA Application/PCA Application-Exercise-Data2.csv" out=TED replace;
	guessingrows=max;
run;
proc print data=TED(obs=10);
run;
proc contents data=TED;
run;
proc means data=TED nmiss;
run;
proc stdize data=TED out=TED_standardized;
run;
proc print data=TED_standardized(obs=10);
run;
proc princomp data=TED_standardized out=TED_pca plots=none;
run;
proc princomp data=TED_standardized out=TED_pca plots=score(ncomp=2) n=4;
run;
data TED_outliers;
    set TED;
    if _n_ in (149,272,313,694);
run;
proc print data=TED_outliers;
run;
data TED;
    set TED;
    if _n_ not in (149,272,313,694);
run;
proc contents data=TED;
run;
proc means data=TED nmiss;
run;
proc stdize data=TED out=TED_standardized;
run;
proc print data=TED_standardized(obs=10);
run;
proc princomp data=TED_standardized out=TED_pca plots=none;
run;
proc princomp data=TED_standardized out=TED_pca plots=score(ncomp=2) n=4;
run;
