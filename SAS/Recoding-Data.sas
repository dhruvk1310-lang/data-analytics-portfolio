/* Recoding Data: Exercise */

/*
Problem 1
Please ensure that all variables are properly encoded in the attached rental car data. Nominal variables should be encoded as text strings and ordinal variables should be encoded as numeric values. Note the following value mappings:
- Car Type: 1=Compact, 2=SUV, 3=Sedan, 4=Truck
- Customer Satisfaction: 1=Very Dissatisfied, 2=Dissatisfied, 3=Neutral, 4=Satisfied, 5=Very Satisfied
- Fuel Efficency Rating: 1=Very Poor, 2=Poor, 3=Average, 4=Good, 5=Excellent
- Rental Location: 1=Downtown, 2=Airport, 3=Suburb
- Rental Purpose: 1=Business, 2=Leisure, 3=Relocation, 4=Emergency, 5=Other
- Vehicle Condition: 1=Poor, 2=Fair, 3=Good, 4=Very Good, 5=Excellent

Afterwards, please answer the following questions: (Hint: See previous lectures)
- Q: What is the average customer satisfaction?
- A: 3.683
- Q: Which rental purpose has the highest average rental cost?
- A: Leisure 666.38
- Q: Which rental location has the highest average vehicle condition rating?
- A: Rent location 3 has the highest average VCR 
- Q: Which car type has the highest average fuel efficiency rating?
- A: SUV (3.37)
*/


proc import datafile="/home/u63994028/Data mining BAN628/08-Recording Data/Recoding Data-Exercise-Data1.csv" out=Data1 replace;
    guessingrows=max;
run;
/* Print data */
proc print data=Data1(obs=10);
run;
data Data1;
    set Data1;
    if "Customer Satisfaction"n = "Very Dissatisfied" then _temp = 1;
    else if "Customer Satisfaction"n = "Dissatisfied" then _temp = 2;
    else if "Customer Satisfaction"n = "Neutral" then _temp = 3;
    else if "Customer Satisfaction"n = "Satisfied" then _temp= 4;
    else if "Customer Satisfaction"n = "Very Satisfied" then _TEMP= 5;
    drop "Customer Satisfaction"n;
    rename _temp="Customer Satisfaction"n;
    run;
proc print data=Data1 (obs=10);
run;    
data Data1;
    set Data1;
    if "Fuel Efficiency Rating"n = "Very Poor" then _temp = 1;
    else if "Fuel Efficiency Rating"n = "Poor" then _temp = 2;
    else if "Fuel Efficiency Rating"n = "Average" then _temp = 3;
    else if "Fuel Efficiency Rating"n = "Good" then _temp= 4;
    else if "Fuel Efficiency Rating"n = "Excellent" then _TEMP= 5;
    drop "Fuel Efficiency Rating"n;
    rename _temp="Fuel Efficiency Rating"n;
    run;
   proc print data=Data1 (obs=10);
   run;
data Data1;
    set Data1;
    length _temp $50;
    if "Rental Location"n = 1 then _temp = "Downtown";
    else if "Rental Location"n = 2 then _temp = "Airport";
    else if "Rental Location"n = 3 then _temp = "Suburb";
    drop "Rental Location"n;
    rename _temp="Rental Location"n;
    run;   
proc print data= Data1 (obs=10);run;
data Data1;
    set Data1;
    length _temp $50;
    if "Rental Purpose"n = 1 then _temp = "Business";
    else if "Rental Purpose"n = 2 then _temp = "Leisure";
    else if "Rental Purpose"n = 3 then _temp = "Relocation";
    else if "Rental Purpose"n = 4 then _temp = "Emergency";
    else if "Rental Purpose"n = 5 then _temp = "Other";
    
    drop "Rental Purpose"n;
    rename _temp="Rental Purpose"n;
    run;  
proc print data= Data1(obs=10);run;
  
proc print data= Data1 (obs=20);run;
/* 1. Calculate the average customer satisfaction */
proc means data=Data1 mean;
    var "Customer Satisfaction"n;
run;

/* 2. Find the rental purpose with the highest average rental cost */
/* Check the data structure to see if variables are numeric or character */
proc contents data=Data1;
run;
/* Convert "Rental Cost USD" and "Vehicle Condition Rating" to numeric */
/* Convert "Rental Cost USD" to numeric */
data Data1;
    set Data1;
    _temp = input("Rental Cost USD"n, best32.);
    drop "Rental Cost USD"n;
    rename _temp = "Rental Cost USD"n;
run;

/* Print the data to verify conversion */
proc print data=Data1(obs=10);
run;


proc means data=Data1 mean maxdec=2;
    class "Rental Purpose"n;
    var "Rental Cost USD"n;
run;

/* 3. Find the rental location with the highest average vehicle condition rating */
proc freq data=Data1;
    tables "Vehicle Condition Rating"n / missing;
run;
proc print data=Data1(obs=10);
    var "Vehicle Condition Rating"n;
run;

proc means data=Data1 mean maxdec=2;
    class "Rental Location"n;
    var "Vehicle Condition Rating"n;
run;

/* 4. Find the car type with the highest average fuel efficiency rating */
proc means data=Data1 mean maxdec=2;
    class "Car Type"n;
    var "Fuel Efficiency Rating"n;
run;



/*
Problem 2
Please ensure that all variables are properly encoded in the attached rental car data. Nominal variables should be encoded as text strings and ordinal variables should be encoded as numeric values. Note the following value mappings:
- Building Type: 1=Commercial, 2=Industrial, 3=Residential
- Region: 1=North, 2=South, 3=East, 4=West
- Energy Source: 1=Electricity, 2=Natural Gas, 3=Solar
- Occupancy Rate: 1=Low, 2=Moderate, 3=High
- Energy Efficiency: 1=Poor, 2=Average, 3=Good, 4=Excellent
- Maintenance Level: 1=Low, 2=Medium, 3=High

Afterwards, please answer the following questions: (Hint: See previous lectures)
- Q: What is the average cost per kWh? 
- A: 0.15
- Q: Which building type has the highest average occupancy rate?
- A: 1.99 Industrial
- Q: Which region has the highest average monthly consumption?
- A: West 24691.10
- Q: Which energy source has the highest average maintenance level?
- A: 2.0762463 Electicity 
*/
proc import datafile="/home/u63994028/Data mining BAN628/08-Recording Data/Recoding Data-Exercise-Data2.csv" out=Data2 replace;
    guessingrows=max;
run;
/* Print data */
proc print data=Data2(obs=10);
run;
/* Recode Building Type */
data Data2;
    set Data2;
    length _temp $50;
    if 'Building Type'n = 1 then _temp = "Commercial";
    else if 'Building Type'n = 2 then _temp = "Industrial";
    else if 'Building Type'n = 3 then _temp = "Residential";
    drop 'Building Type'n;
    rename _temp = 'Building Type'n;
run;

/* Recode Region */
data Data2;
    set Data2;
    length _temp $50;
    if 'Region'n = 1 then _temp = "North";
    else if 'Region'n = 2 then _temp = "South";
    else if 'Region'n = 3 then _temp = "East";
    else if 'Region'n = 4 then _temp = "West";
    drop 'Region'n;
    rename _temp = 'Region'n;
run;

/* Recode Energy Source */
data Data2;
    set Data2;
    length _temp $50;
    if 'Energy Source'n = 1 then _temp = "Electricity";
    else if 'Energy Source'n = 2 then _temp = "Natural Gas";
    else if 'Energy Source'n = 3 then _temp = "Solar";
    drop 'Energy Source'n;
    rename _temp = 'Energy Source'n;
run;

/* Recode Occupancy Rate as numeric */
data Data2;
    set Data2;
    if 'Occupancy Rate'n = "Low" then _temp = 1;
    else if 'Occupancy Rate'n = "Moderate" then _temp = 2;
    else if 'Occupancy Rate'n = "High" then _temp = 3;
    drop 'Occupancy Rate'n;
    rename _temp = 'Occupancy Rate'n;
run;

/* Recode Energy Efficiency */
data Data2;
    set Data2;
    length _temp $50;
    if 'Energy Efficiency'n = 1 then _temp = "Poor";
    else if 'Energy Efficiency'n = 2 then _temp = "Average";
    else if 'Energy Efficiency'n = 3 then _temp = "Good";
    else if 'Energy Efficiency'n = 4 then _temp = "Excellent";
    drop 'Energy Efficiency'n;
    rename _temp = 'Energy Efficiency'n;
run;

/* Recode Maintenance Level */
/* Check the structure and data types of Data2 */
proc contents data=Data2;
run;
/* Check unique values in the Maintenance Level column */
proc freq data=Data2;
    tables 'Maintenance Level'n / missing;
run;
/* Recode the Maintenance Level to ensure correct values */
data Data2;
    set Data2;
    if 'Maintenance Level'n = "Low" then _temp = "1";
    else if 'Maintenance Level'n = "Medium" then _temp = "2";
    else if 'Maintenance Level'n = "High" then _temp = "3";
    drop 'Maintenance Level'n;
    rename _temp = 'Maintenance Level'n;
run;

/* Print to check the values */
proc print data=Data2;
run;


/* Print the data to verify the changes */
proc print data=Data2(obs=10);
run;
/* 1. Calculate the average cost per kWh */
proc contents data=Data2;run;
/* Convert Cost per kWh and Monthly Consumption to numeric */
/* Convert 'Cost per kWh' to numeric */
data Data2;
    set Data2;
    _temp = input('Cost per kWh'n, best32.);
    drop 'Cost per kWh'n;
    rename _temp = 'Cost per kWh'n;
run;

/* Convert 'Monthly Consumption (kWh)' to numeric */
data Data2;
    set Data2;
    _temp = input('Monthly Consumption (kWh)'n, best32.);
    drop 'Monthly Consumption (kWh)'n;
    rename _temp = 'Monthly Consumption (kWh)'n;
run;

/* Print the data to verify the conversion */
proc print data=Data2(obs=10);
run;
/* 1. Calculate the average cost per kWh */
proc means data=Data2 mean maxdec=2;
    var 'Cost per kWh'n;
run;

/* 2. Find the building type with the highest average occupancy rate */

data Data2;
    set Data2;
    if 'Building Type'n = " " then 'Building Type'n = "Industrial"; 
    run;

proc print data=Data2(obs=10);
run;

proc means data=Data2 mean ;
    class 'Building Type'n;
    var 'Occupancy Rate'n;
run;

/* 3. Find the region with the highest average monthly consumption */
proc means data=Data2 mean ;
    class 'Region'n;
    var 'Monthly Consumption (kWh)'n;
run;

/* 4. Find the energy source with the highest average maintenance level */
/* Convert 'Occupancy Rate' to numeric */
data Data2;
    set Data2;
    _temp = input('Maintenance Level'n, best32.);
    drop 'Maintenance Level'n;
    rename _temp = 'Maintenance Level'n;
run;

/* Print the data to verify the conversion */
proc print data=Data2(obs=10);
run;

proc means data=Data2 mean ;
    class 'Energy Source'n;
    var 'Maintenance Level'n;
run;

   




/*
Problem 3
Please ensure that all variables are properly encoded in the attached healthcare insurance claims data. Nominal variables should be encoded as text strings and ordinal variables should be encoded as numeric values. Note the following value mappings:
- Claim Status: 1=Approved, 2=Denied, 3=Pending
- Claim Type: 1=Accident, 2=Check-up, 3=Surgery
- Patient Recovery: 1=Poor, 2=Average, 3=Good
- Patient Satisfaction: 1=Poor, 2=Average, 3=Good, 4=Excellent
- Risk Assessment: 1=Low, 2=Medium, 3=High
- Treatment Type: 1=Emergency, 2=Inpatient, 3=Outpatient

Afterwards, please answer the following questions: (Hint: See previous lectures)
- Q: What is the average patient satisfaction? 
- A: 2.5511651
- Q: Which claim type has the highest average claim amount?
- A: surgery=844.69
- Q: Which treatment type has the highest average hospital visits?
- A: Treatment type 1 (emergency) has the highest visit [2.13]
- Q: Which claim status has the highest average patient recovery?
- A: Pending status has highest patient recivery with Avg of 2.22
*/
proc import datafile="/home/u63994028/Data mining BAN628/08-Recording Data/Recoding Data-Exercise-Data3.csv"out=Data3 replace;
    guessingrows=max;
run;

Proc print data=Data3 (obs=10);
run;
data Data3;
    set Data3;
    length _temp $50;
    if 'Claim Status'n = 1 then _temp = "Approved";
    else if 'Claim Status'n = 2 then _temp = "Denied";
    else if 'Claim Status'n = 3 then _temp = "Pending";
    drop 'Claim Status'n;
    rename _temp = 'Claim Status'n;
run;
data Data3;
set Data3;
Length _temp $50;
if 	"Claim Type"n= 1 then _temp= "Accident";
else if 	"Claim Type"n= 2 then _temp= "Check Up";
else if 	"Claim Type"n= 3 then _temp= "Surgery";
drop "Claim Type"n;
rename _temp = "Claim Type"n;
run;

/* Recode 'Patient Recovery' to numeric */


data Data3;
    set Data3;
    if 'Patient Satisfaction'n = "Poor" then _temp = "1";
    else if 'Patient Satisfaction'n = "Average" then _temp = "2";
    else if 'Patient Satisfaction'n = "Good" then _temp = "3";
    else if "Patient Satisfaction"n = "Excellent" then _temp= "4";
    drop 'Patient Satisfaction'n;
    rename _temp = 'Patient Satisfaction'n;
run;
data Data3;
    set Data3;
    if 'Risk Assessment'n = "Low" then _temp = "1";
    else if 'Risk Assessment'n = "Medium" then _temp = "2";
    else if 'Risk Assessment'n = "High" then _temp = "3";
    drop 'Risk Assessment'n;
    rename _temp = 'Risk Assessment'n;
    run;
    data Data3;
    set Data3;
    if 'Treatment Type'n = "Emergency" then _temp = "1";
    else if 'Treatment Type'n = "Inpatient" then _temp = "2";
    else if 'Treatment Type'n = "Outpatient" then _temp = "3";
    drop 'Treatment Type'n;
    rename _temp = 'Treatment Type'n;
    run;
Proc print data= Data3 (obs=10);
run;
data Data3;
    set Data3;
    _temp = input('Patient Satisfaction'n, best32.);
    drop 'Patient Satisfaction'n;
    rename _temp = 'Patient Satisfaction'n;
run;

proc means data=Data3 mean ;
    var 'Patient Satisfaction'n;
run;
data Data3;
    set Data3;
    _temp = input('Claim Amount'n, best32.);
    drop 'Claim Amount'n;
    rename _temp = 'Claim Amount'n;
run;
proc means data=Data3 mean ;
    class 'Claim Type'n;
    var 'Claim Amount'n;
run;
data Data3;
    set Data3;
    _temp = input('Hospital Visits'n, best32.);
    drop 'Hospital Visits'n;
    rename _temp = 'Hospital Visits'n;
run;
proc means data=Data3 mean maxdec=2;
    class 'Treatment Type'n;
    var 'Hospital Visits'n;
run;

proc means data=Data3 mean maxdec=2;
    class 'Claim Status'n;
    var 'Patient Recovery'n;
run;

