/* ARA Implementation: Exercise */

/*
Problem 1

- Q1: Which itemset is the most frequent?
- A1: Chocolate : 421	
- Q2: Which association rule has the highest lift? 
- A2: Butter & Corn & Milk & Nutmeg ==> Beans & Bread
- Q3: What is the lift of the association rule above?
- A3: 2.91
- Q4: What is the support (in %) of the association rule above?
- A4: 2.11
- Q5: Please restate these findings in the form of "If someone buys ... 
then they are ... times more likely to buy ... (and vice versa), 
which occurs in ... percent of all transactions."
- A5: If a customer buys Butter & Corn & Milk & Nutmeg then they are 2.91 times more likely to buy Beans & Bread which occur in 2.11% of the transactions
*/
proc import datafile="/home/u63994028/Data mining BAN628/20-ARA Implementation/ARA Implementation-Exercise-Data1.csv" out=mydata replace;
    guessingrows=max;
run;

/* Print data */
proc print data=mydata(obs=10);
run;

/* TODO: Generate metadata catalog */
proc dmdb data=mydata dmdbcat=metadata;
    id id;
    class products;
run;

/* TODO: Calculate frequent itemsets */
proc assoc data=mydata dmdbcat=metadata out=itemsets;
    customerid;
    target products;
run;

/* Print frequent itemsets */
proc print data=itemsets(obs=100);
run;

/* Generate association rules */
proc rulegen in=itemsets out=rules;
run;

/* Sort association rules by lift, confidence, and support */
proc sort data=rules;
    by descending LIFT descending CONF descending SUPPORT;
run;

/* Print association rules */
proc print data=rules(obs=10);
run;

/*
Problem 2

- Q1: Which itemset is the most frequent?
- A1: Coffee: 1098
- Q2: Which association rule has the highest lift? 
- A2: Medialuna ==> Coffee
- Q3: What is the lift of the association rule above?
- A3: 1.21
- Q4: What is the support (in %) of the association rule above?
- A4: 5.23
- Q5: Please restate these findings in the form of "If someone buys ... 
then they are ... times more likely to buy ... (and vice versa), 
which occurs in ... percent of all transactions."
- A5: If a customer buys Medialuna then they are 1.21 times more likely to buy Coffee which occur in 5.23% of the transactions 
*/
proc import datafile="/home/u63994028/Data mining BAN628/20-ARA Implementation/ARA Implementation-Exercise-Data2.csv" out=mydata2 replace;
    guessingrows=max;
run;

/* Print data */
proc print data=mydata2(obs=10);
run;

/* TODO: Generate metadata catalog */
proc dmdb data=mydata2 dmdbcat=metadata;
    id Transaction;
    class Item;
run;

/* TODO: Calculate frequent itemsets */
proc assoc data=mydata2 dmdbcat=metadata out=itemsets;
    customer Transaction;
    target Item;
run;

/* Print frequent itemsets */
proc print data=itemsets(obs=100);
run;

/* Generate association rules */
proc rulegen in=itemsets out=rules;
run;

/* Sort association rules by lift, confidence, and support */
proc sort data=rules;
    by descending LIFT descending CONF descending SUPPORT;
run;

/* Print association rules */
proc print data=rules(obs=10);
run;

/*
Problem 3

- Q1: Which itemset is the most frequent?
- A1: Toothpaste: 452	
- Q2: Which association rule has the highest lift? 
- A2: Dustpan ==> Toothpaste
- Q3: What is the lift of the association rule above?
- A3: 1.44
- Q4: What is the support (in %) of the association rule above?
- A4: 0.35
- Q5: Please restate these findings in the form of "If someone buys ... 
then they are ... times more likely to buy ... (and vice versa), 
which occurs in ... percent of all transactions."
- A5: If someone buys a Dustpan, then they are 1.44 times more likely to buy Toothpaste, which occurs in 0.35% of all transactions.
*/
proc import datafile="/home/u63994028/Data mining BAN628/20-ARA Implementation/ARA Implementation-Exercise-Data3.csv" out=mydata3 replace;
    guessingrows=max;
run;

/* Print data */
proc print data=mydata3(obs=10);
run;

/* TODO: Generate metadata catalog */
proc dmdb data=mydata3 dmdbcat=metadata;
    id Transaction_ID;
    class product;
run;

/* TODO: Calculate frequent itemsets */
proc assoc data=mydata3 dmdbcat=metadata out=itemsets;
    customer Transaction_ID;
    target product;
run;

/* Print frequent itemsets */
proc print data=itemsets(obs=100);
run;

/* Generate association rules */
proc rulegen in=itemsets out=rules;
run;

/* Sort association rules by lift, confidence, and support */
proc sort data=rules;
    by descending LIFT descending CONF descending SUPPORT;
run;

/* Print association rules */
proc print data=rules(obs=10);
run;

