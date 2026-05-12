/* ARA Preparation: Exercise */


/* 
Problem 1

Perform an association rule analysis of patients' symptoms. Then answer the following questions:
- Q1: What is the format of the original data: List or wide?
- A1: wide 
- Q2: What is the most frequent itemset?
- A2: Cough: 1378	
- Q3: What association rule has the highest lift?
- A3: Cough & Diabetes ==> HistoryOfHeartDisease & Smoker
- Q4: What is the lift of the association rule?
- A4: 2.06
- Q5: What is the support (in %) of the association rule?
- A5: 13.16
- Q6: How would you restate these findings in the form of "If a patient has symptoms of ... then they are ... times more likely to have symptoms of ... (and vice versa), which occurs in ... percent of all patient records."?
- A6: If a patient has symptoms of Cough & Diabetes then they are 2.06 times more likely to have symptoms of HistoryOfHeartDisease & Smoker (and vice versa), which occurs in 13.16 percent of all patient records.
*/
/* ARA Preparation: Demo */

/* EXAMPLE 1: RESHAPE DATA FROM LIST TO LONG FORMAT */

/* Load data */
/* TODO: Update file */
proc import datafile="/home/u63994028/Data mining BAN628/21- ARA Preperation/ARA Preparation-Exercise-Data1.csv" out=mydata replace;
	guessingrows=max;
run;
/* Print data to check format */
proc print data=mydata(obs=10);
run;

/* Add an observation number to each row */
data mydata;
	set mydata;
	obsnum=_n_;
run;

/* Print data again to verify the changes */
proc print data=mydata(obs=10);
run;

/* Transpose the dataset from wide to long format */
/* TODO: Update variables  */
proc transpose data=mydata out=mydata;
	by obsnum;
	var Smoker	Pregnant Cough	Allergies HistoryOfHeartDisease	Diabetes PatientDate;
run;

/* Print data again to verify the changes */
proc print data=mydata(obs=10);
run;

/* Clean up transposed data */
data mydata;
	set mydata;
	if upcase(COL1)="TRUE" then output;
	drop COL1;
	rename _NAME_=item;
run;

/* Print data again to verify the changes */
proc print data=mydata(obs=10);
run;

/* Proceed with association rule analysis as usual... */

/* Create a metadata catalog for association analysis */
proc dmdb data=mydata dmdbcat=metadata;
	id obsnum;
	class item;
run;

/* Calculate frequent itemsets in the data */
proc assoc data=mydata dmdbcat=metadata out=itemsets;
	customer obsnum;
	target item;
run;

/* Print itemsets to examine the results */
proc print data=itemsets(obs=10);
run;

/* Generate association rules from the calculated itemsets */
proc rulegen in=itemsets out=rules;
run;

/* Sort the association rules by lift, confidence, and support for prioritization */
proc sort data=rules;
    by descending LIFT descending CONF descending SUPPORT;
run;

/* Print sorted rules to examine the results */
proc print data=rules(obs=10);
run;



/* 
Problem 2

Perform an association rule analysis of web pages visited. Then answer the following questions:
- Q1: What is the format of the original data: List or wide?
- A1: List
- Q2: What is the most frequent itemset?
- A2: homepage 1613
- Q3: What association rule has the highest lift?
- A3: homepage & pricing & services ==> clients & contact
- Q4: What is the lift of the association rule?
- A4: 1.24
- Q5: What is the support (in %) of the association rule?
- A5: 27.74
- Q6: How would you restate these findings in the form of "If a user visits ... then they are ... times more likely to visit ... (and vice versa), which occurs in ... percent of all user sessions."?
- A6: TBDIf a user visits homepage & pricing then they are 1.24 times more likely to visit clients & contact (and vice versa), which occurs in 27.74 percent of all user sessions.
*/
proc import datafile="/home/u63994028/Data mining BAN628/21- ARA Preperation/ARA Preparation-Exercise-Data2.csv" out=mydata replace;
	guessingrows=max;
run;
/* Print data to check format */
proc print data=mydata(obs=10);
run;
data mydata;
	set mydata;
	obsnum=_n_;
	do i=1 to countw(page, ",");
		item=scan(page, i, ",");
		output;
	end;
	keep obsnum item;
run;

proc print data=mydata(obs=10);
run;
proc dmdb data=mydata dmdbcat=metadata;
	id obsnum;
	class item;
run;

proc assoc data=mydata dmdbcat=metadata out=itemsets;
	customer obsnum;
	target item;
run;

proc print data=itemsets(obs=10);
run;

proc rulegen in=itemsets out=rules;
run;

proc sort data=rules;
    by descending LIFT descending CONF descending SUPPORT;
run;
proc print data=rules(obs=10);
run;


/* 
Problem 3

Perform an association rule analysis of client services. Then answer the following questions:
- Q1: What is the format of the original data: List or wide?
- A1: List
- Q2: What is the most frequent itemset?
- A2: checking_account_holder: 1540
- Q3: What association rule has the highest lift?
- A3: brokerage_account_holder & credit_card_owner & insurance_policy_holder ==> checking_account_holder & wealth_management_client
- Q4: What is the lift of the association rule?
- A4: 1.70
- Q5: What is the support (in %) of the association rule?
- A5: 6.21
- Q6: How would you restate these findings in the form of "If a client is a ... then they are ... times more likely to be a ... (and vice versa), which occurs in ... percent of all client records."?
- A6: TBDIf a client is a brokerage_account_holder & credit_card_owner & insurance_policy_holder then they are 1.7 times more likely to be a checking_account_holder & wealth_management_client (and vice versa), which occurs in 6.21 percent of all client records.
*/
proc import datafile="/home/u63994028/Data mining BAN628/21- ARA Preperation/ARA Preparation-Exercise-Data3.csv" out=mydata replace;
	guessingrows=max;
run;
proc print data=mydata(obs=10);
run;
data mydata;
	set mydata;
	obsnum=_n_;
	do i=1 to countw(service, ",");
		item=scan(service, i, ",");
		output;
	end;
	keep obsnum item;
run;

proc print data=mydata(obs=10);
run;
proc dmdb data=mydata dmdbcat=metadata;
	id obsnum;
	class item;
run;

proc assoc data=mydata dmdbcat=metadata out=itemsets;
	customer obsnum;
	target item;
run;

proc print data=itemsets(obs=10);
run;

proc rulegen in=itemsets out=rules;
run;

proc sort data=rules;
    by descending LIFT descending CONF descending SUPPORT;
run;
proc print data=rules(obs=10);
run;

/* 
Problem 4

Perform an association rule analysis of customer indicators. Then answer the following questions:
- Q1: What is the format of the original data: List or wide?
- A1: wide 
- Q2: What is the most frequent itemset?
- A2: event_attendee: 1611
- Q3: What association rule has the highest lift?
- A3: loyalty_program_member & social_media_follower ==> event_attendee & newsletter_subscriber & survey_participant
- Q4: What is the lift of the association rule?
- A4: 1.7
- Q5: What is the support (in %) of the association rule?
- A5: 5.59
- Q6: How would you restate these findings in the form of "If a customer is a ... then they are ... times more likely to be a ... (and vice versa), which occurs in ... percent of all customer records."?
- A6: TBDIf a customer is a  loyalty_program_member & social_media_follower then they are 1.2 times more likely to be a event_attendee & newsletter_subscriber & survey_participant (and vice versa), which occurs in 5.59 percent of all customer records.
*/
proc import datafile="/home/u63994028/Data mining BAN628/21- ARA Preperation/ARA Preparation-Exercise-Data4.csv" out=mydata replace;
	guessingrows=max;
run;
proc print data=mydata(obs=10);
run;
data mydata;
	set mydata;
	obsnum=_n_;
run;
proc print data=mydata(obs=10);
run;
proc transpose data=mydata out=mydata;
	by obsnum;
	var newsletter_subscriber	loyalty_program_member	survey_participant	event_attendee	referral_program_participant	social_media_follower;
run;
proc print data=mydata(obs=10);
run;
data mydata;
	set mydata;
	if upcase(COL1)="TRUE" then output;
	drop COL1;
	rename _NAME_=item;
run;
proc print data=mydata(obs=10);
run;
proc dmdb data=mydata dmdbcat=metadata;
	id obsnum;
	class item;
run;
proc assoc data=mydata dmdbcat=metadata out=itemsets;
	customer obsnum;
	target item;
run;
proc print data=itemsets(obs=10);
run;

proc rulegen in=itemsets out=rules;
run;
proc sort data=rules;
    by descending LIFT descending CONF descending SUPPORT;
run;

proc print data=rules(obs=10);
run;


