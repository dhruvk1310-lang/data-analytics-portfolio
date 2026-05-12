/* Univariate Analysis: Exercise */

/*
Problem 1

Please take a look at the attached product inventory data.
- Q: What is the shortest and longest average days in inventory?
- A: Shortest day is 1.2 and Longest is 365
- Q: What is the median units sold?
- A: 450
- Q: Which warehouse location is least frequent?
- A: West is the least frequent with a frequency of "215"
- Q: Which product category is most frequent?
- A: Toys is the most frequent with a frequency of 280
- Q: Plot each variable. What is noteworthy about the distribution of average days in inventory?
- A: For most of the product categories the average day is between 1.2-2.5 days
*/
proc import datafile="/home/u63994028/03-Univariate Analysis/Univariate Analysis-Exercise-Data1.csv" out=Inventory replace; 
guessingrows=max;
run;
proc print data=inventory (obs=10);
run;
proc means data= inventory n nmiss mean std min median max;
run;
proc freq data= inventory order= freq;
tables WarehouseLocation ProductCategory/ norow nocol nopercent;
run;
proc sgplot data= inventory; 
vbar ProductCategory / categoryorder=respdesc;
run;
proc sgplot data= inventory; 
vbar WarehouseLocation / categoryorder=respdesc;
run;
proc sgplot data= inventory; histogram UnitsSold;
run;
proc sgplot data= inventory; histogram AverageDaysInInventory / binwidth= 5 binstart=2.5;
run;



/*
Problem 2

Please take a look at the attached employee salary data.
- Q: Which education level is most frequent?
- A: Associate Degree is the most frequent 
- Q: What is the youngest and oldest age?
- A: 20 is the youngest abd 65 is the oldest
- Q: What is the median salary?
- A: 46222
- Q: Which department is least frequent?
- A: HR and Engineering are least frequent with a frequency of 190
- Q: Plot each variable. What is noteworthy about the distribution of age?
- A: Nobody is aged below 20 years 
*/
proc import datafile="/home/u63994028/03-Univariate Analysis/Univariate Analysis-Exercise-Data2.csv" out=Education replace; 
guessingrows=max;
run;
proc print data=Education (obs=10);
run;
proc means data= Education n nmiss mean std min median max;
run;
proc freq data= Education order= freq;
tables EducationLevel Department/ norow nocol nopercent;
run;
proc sgplot data= Education; 
vbar Department / categoryorder=respdesc;
run;
proc sgplot data= Education; 
vbar EducationLevel / categoryorder=respdesc;
run;
proc sgplot data= Education; histogram Age/ binwidth=10 binstart=5;
run;
proc sgplot data= Education; histogram AnnualSalary / binwidth= 10000 binstart=5000;
run;

/*
Problem 3

Please take a look at the attached customer satisfaction data.
- Q: What is the fewest and most number of complaints?
- A: fewest is 1 and most is 5 
- Q: What is the median response time?
- A: 4.5
- Q: Which service type is least frequent?
- A: Billing is the least FREQUENT 
- Q: Which customer satisfaction issue is most frequent?
- A: response time
- Q: Plot each variable. What is noteworthy about the distribution of the number of complaints?
- A: there are no service typyes with 0 complaints 
*/

proc import datafile="/home/u63994028/03-Univariate Analysis/Univariate Analysis-Exercise-Data3.csv" out=Service replace; 
guessingrows=max;
run;
proc print data=Service (obs=10);
run;
proc means data= Service n nmiss mean std min median max;
run;
proc freq data= Service order= freq;
tables ServiceType CustomerSatisfaction/ norow nocol nopercent;
run;
proc sgplot data= Service; 
vbar ServiceType / categoryorder=respdesc;
run;
proc sgplot data= service; 
vbar CustomerSatisfaction / categoryorder=respdesc;
run;
proc sgplot data= Service; histogram ResponseTime_Hours/ binwidth=1 binstart=0.5;
run;
proc sgplot data= Service; histogram NumberOfComplaints/ binwidth= 1 binstart=0.5;
run;
























