/* Introduction: Exercise */

/*
Problem 1

Please take a look at the attached customer satisfaction data:

|QuantaQuench|FluxCharge|
|------------|----------|
|          29|        94|
|          78|        74|
|          42|        30|

- Q: What is the average customer satisfaction per product?
- A: QuantaQuench- 49.6666667|FluxCharge 66.0000000
- Q: Which product has the highest average customer satisfaction?
- A: FluxCharge
*/
data Customer_Satisfasction;
	input QuantaQuench FluxCharge ;
	datalines;
	29 94
	78 74
	42 30
	;
run;

/*print dataset*/
proc print data= Customer_Satisfasction;
run;
/* calc*/
proc means data= Customer_Satisfasction;
run;






/*
Problem 2

Please take a look at the attached online ad spend data:

|Search|Social|Display|
|------|------|-------|
|    59|    90|     65|
|    49|    29|     39|
|    42|    46|     79|
|    33|    82|     88|

- Q: What is the average online ad spend per channel?
- A: Search 45.7500000|Social 61.7500000 Display 67.7500000
- Q: Which channel has the lowest average online ad spend?
- A: Search
*/

c

/*
Problem 3

Please take a look at the attached commission data:

|Smith|
|-----|
|   51|
|   37|
|    2|
|   20|
|   85|

- Q: What is the lowest commission?
- A: 2.00
- Q: What is the highest commission?
- A: 85
- Q: What is the average commission?
- A: 39
*/

data commissionData;
	input Smith ;
	datalines;
	51
	37
	2
	20
	85
	;
run;

/*print dataset*/
proc print data= CommissionData;
run;
/* calc*/
proc means data= CommissionData;
run;
