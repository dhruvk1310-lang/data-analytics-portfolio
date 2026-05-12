/* Lab Project 5 */

/* 
Part A
Please perform a product-level association rule analysis to identify which 
products customers often buy together and answer the following questions:

- Q1: What are the top 3 most frequently purchased products?
- A1: 1: Nest® Learning Thermostat 3rd Gen-USA - Stainless Steel: 5029
      2: Nest® Cam Outdoor Security Camera - USA: 3388
      3: Nest® Cam Indoor Security Camera - 3309

- Q2: What percentage of transactions include those products?
- A2: 20.06%
      13.51%
      13.02%

- Q3: Which product association rule has the highest lift? Please state 
the association rule using the format we've used in previous exercises 
(i.e., "If a customer purchases ...").
- A3: if a customer Purchases Nest® Cam Outdoor Security Camera - USA thrn the customer is 1.58 times more likely to purchase Nest® Cam Indoor Security Camera - USA

- Q4: Which product association rule has the highest support? Please state 
the association rule using the format we've used in previous exercises 
(i.e., "If a customer purchases ...").
- A4: if a customer Purchases Nest® Cam Outdoor Security Camera - USA thrn the customer is 1.58 times more likely to purchase Nest® Cam Indoor Security Camera - USA Which occurs in 2.81 percebntage of all transactions 

- Q5: Should the Google Merchandise Store make recommendations on their product 
pages based on association rules with highest lift or highest support? Why?
- A5: Google Merchandise Store should make recommendations on their product 
pages based on association rules with highest lift because Using highest lift is generally more effective for recommendation systems as it focuses on items that have a strong association beyond mere popularity


Part B
Please perform a category-level association rule analysis to identify which 
product categories customers often buy together and answer the following questions:

- Q6: What are the top 3 most frequently purchased product categories?
- A6: 	Nest-USA-11626
		Apparel- 8129
		Office-  3526

- Q7: What percentage of transactions include those product categories?
- A7: 46.39%
	  32.44%
	  14.06%

- Q8: Which product category association rule has the highest lift? Please 
state the association rule using the format we've used in previous exercises 
(i.e., "If a customer purchases ...").
- A8: If a customer purchases Lifestyle the they are 3.77 times more likely to purchase Drinkware

- Q9: Which product category association rule has the highest support? Please 
state the association rule using the format we've used in previous exercises 
(i.e., "If a customer purchases ...").
- A9: If a customer purchases Office products they are 1.36 times more likely to buy Apparel which occurs in 6.21% of the transactions

- Q10: Should the Google Merchandise Store make recommendations on their 
product category pages based on association rules with highest lift or highest 
support? Why?
- A10: by using association rules with the highest support on product category pages, the Google Merchandise Store can capitalize on known popular combinations to appeal to a wider audience and boost sales within commonly visited categories.
*/
/* Part A*/
proc import datafile="/home/u63994028/Data mining BAN628/22- Lab project 5/Lab Project 5-Data.csv" out=mydata replace;
    guessingrows=max;
run;
proc print data=mydata(obs=10);
run;
data mydata;
	set mydata;
	obsnum=_n_;
	do i=1 to countw('Product Category'n, ",");
		item=scan('Product Category'n, i, ",");
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
    by descending SUPPORT descending CONF descending LIFT;
run;

/* Print sorted rules to examine the results */
proc print data=rules(obs=10);
run;

