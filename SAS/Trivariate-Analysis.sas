/* Trivariate Analysis: Exercise */

/*
Problem 1

Please take a look at the attached supply chain data.
- Q: Analyze the distribution of product types across shipping methods and supplier regions. What is the most frequent combination of product type, shipping method, and supplier region?
- A:Product type= Apparel Shipping Method= Sea supplier region= South america
- Q: Evaluate the defect rates across different product types and shipping methods. Which combination of product type and shipping method has the highest defect rate, on average?
- A: Prodcut type= Electronics Shipping type=Air Aveagre rate= 5.1568750
- Q: Examine how the defect rate correlates with lead time across different shipping methods. Do you observe a connection between all three variables?
- A: there doesn't seem to be any correation for land but there is some correlatioin for sea and air
- Q: Investigate how lead time, defect rate, and order frequency correlate with each other. Are there relationships between all three variables?
- A: There is no relation shipbetween the variables
- Q: Compare the lead time across different shipping methods. Which shipping method has the longest lead time, on average? (Hint: See previous lectures.)
- A: Land has the longest Leadtime on average (30.7548571)
- Q: What is the overall average order frequency? (Hint: See previous lectures.)
- A: 19.7916683
*/
proc import datafile="/home/u63994028/05-Trivariate Analysis/Trivariate Analysis-Exercise-Data1.csv" out=SCD replace;
guessingrows=max;
run;
/* Print data */
proc print data=SCD (obs=10);
run;
proc freq data=SCD order=freq;
tables SupplierRegion*ProductType*ShippingMethod/ norow nocol nopercent;
run;
proc means data=SCD;
 class ProductType ShippingMethod;
 var DefectRate;
 run;
proc sort data=SCD;
    by ShippingMethod;
run;
proc corr data=SCD;
by ShippingMethod ;
var DefectRate LeadTime;
run;
proc sgplot data=SCD;
    scatter x=LeadTime y=DefectRate/ group=ShippingMethod;
run;

proc corr data=SCD;
Var LeadTime DefectRate	OrderFrequency;
run;
proc sgplot data=SCD;
    scatter x=OrderFrequency y=DefectRate / colorresponse=LeadTime colormodel=TwoColorRamp;
run;
proc means data= SCD;
class ShippingMethod;
Var LeadTime;
run;

proc means data=SCD n nmiss mean std min median max;
run;

/*
Problem 2

Please take a look at the attached customer service data.
- Q: Analyze the distribution of contact method, issue Type, and agent experience. What is the most frequent combination of contact method, issue Type, and agent experience?
- A: Contact Method= Phone Agent expirence=Mid-level Issue type= General Inquiry
- Q: Evaluate the customer satisfaction score across different issue types and contact methods. Which combination of issue type and contact method has the highest average customer satisfaction score?
- A: Issue type=Billing	   Contact method =Chat.  mean score is= 3.9
- Q: Examine how customer satisfaction score correlates with resolution time across different contact methods. Do you observe a connection between all three variables?
- A: There is some correlation
- Q: Investigate how resolution time, customer satisfaction score, and escalation count correlate with each other. Are there relationships between all three variables?
- A: 1)There is no relation between resolution time and escalatiom count
	 2)Customer Satisfaction Score has a relation with the other 2 variables
- Q: Compare the resolution time across different contact methods. Which contact method has the longest resolution time, on average? (Hint: See previous lectures.)
- A: Phone	30.4492958
- Q: What is the overall average customer satisfaction score? (Hint: See previous lectures.)
- A: 3.4828514
*/
proc import datafile="/home/u63994028/05-Trivariate Analysis/Trivariate Analysis-Exercise-Data2.csv" out=CSD replace;
guessingrows=max;
run;
proc print data=CSD (obs=10);
run;
proc freq data=CSD order=freq;
tables 	ContactMethod*IssueType*AgentExperience/ norow nocol nopercent;
run;
proc means data=CSD;
 class IssueType ContactMethod  ;
 var CustomerSatisfaction_Score	;
 run;
proc sort data=CSD;
    by 	ContactMethod;
run;
proc corr data=CSD;
by 	ContactMethod;
var ResolutionTime_Minutes	CustomerSatisfaction_Score;
run;
proc sgplot data=CSD;
    scatter x=ResolutionTime_Minutes y=CustomerSatisfaction_Score/ group=ContactMethod;
run;
proc corr data=CSD;
Var ResolutionTime_Minutes	CustomerSatisfaction_Score	EscalationCount;
run;
proc sgplot data=CSD;
    scatter x=ResolutionTime_Minutes y=CustomerSatisfaction_Score / colorresponse=EscalationCount colormodel=TwoColorRamp;
run;
proc means data= CSD;
class ContactMethod;
Var ResolutionTime_Minutes;
run;
proc means data=CSD n nmiss mean std min median max;
run;














