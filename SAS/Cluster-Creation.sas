/* Cluster Creation: Exercise */

/*
Problem 1

Please analyze the attached suppler data (where each row/observation is one supplier) and create clusters of suppliers with similar characteristics.

- Q1: What is the optimal number of clusters?
- A1: 3
- Q2: How many observations are in each cluster?
- A2: Cluster	No.of Obs	
         1	       25	
         2	       25	
         3	       50
*/
proc import datafile="/home/u63994028/Data mining BAN628/16-Cluster Creation/Cluster Creation-Exercise-Data1.csv" out=SD replace;
	guessingrows=max;
run;
proc print data=SD(obs=10);
run;
proc contents data=SD;
run;
data SD;
    set SD;
    if cmiss(of _all_) = 0 then output;
run;
proc means data=SD nmiss;
run;
proc stdize data=SD out=SD_standardized;
run;
proc print data=SD_standardized(obs=10);
run;
proc cluster data=SD_standardized method=ward outtree=SD__cluster;
run;
proc tree data=SD__cluster out=SD__cluster n=3 noprint;
run;
proc freq data=SD__cluster;
tables CLUSTER /nocum;
run;
/*
Problem 2

Please analyze the attached data about publicly traded pharmaceutical companies (where each 
row/observation is one company) and create clusters of companies with similar characteristics.

- Q1: What is the optimal number of clusters?
- A1: 2
- Q2: How many observations are in each cluster?
- A2: Cluster	No.of Obs	
          1	       11	
          2	       10	


*/
proc import datafile="/home/u63994028/Data mining BAN628/16-Cluster Creation/Cluster Creation-Exercise-Data2.csv" out=PC replace;
	guessingrows=max;
run;
proc print data=PC(obs=10);
run;
proc contents data=PC;
run;
data PC;
    set PC;
    if cmiss(of _all_) = 0 then output;
run;
proc means data=PC nmiss;
run;
proc stdize data=PC out=PC_standardized;
run;
proc print data=PC_standardized(obs=10);
run;
proc cluster data=PC_standardized method=ward outtree=PC__cluster;
run;
proc tree data=PC__cluster out=PC__cluster n=2 noprint;
run;
proc freq data=PC__cluster;
tables CLUSTER /nocum;
run;
