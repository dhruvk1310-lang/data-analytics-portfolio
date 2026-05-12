proc import datafile="/home/u63994028/Data mining BAN628/11-Midterm Project/Midterm Project-Data.csv" 
    out=MT
    replace;
    guessingrows=max;
    proc print data=MT (obs=10);
    run;
    /* Renaming variables to remove spaces */
data MT;
   set MT;
   rename 
       'property type'n = PropertyType
       'square meters'n = SquareMeters
       'n bedrooms'n = NumBedrooms
       'n bathrooms'n = NumBathrooms
       'year built'n = YearBuilt
       'air conditioning 'n = AirConditioning;
run;
proc contents data=MT;
run;
/* Converting variables to numeric data types using best32. */
data MT;
   set MT;

   /* Convert NumBathrooms */
   _temp1 = input(NumBathrooms, best32.);
   drop NumBathrooms;
   rename _temp1 = NumBathrooms;

   /* Convert NumBedrooms */
   _temp2 = input(NumBedrooms, best32.);
   drop NumBedrooms;
   rename _temp2 = NumBedrooms;

   /* Convert YearBuilt */
   _temp3 = input(YearBuilt, best32.);
   drop YearBuilt;
   rename _temp3 = YearBuilt;

   /* Convert SquareMeters */
   _temp4 = input(SquareMeters, best32.);
   drop SquareMeters;
   rename _temp4 = SquareMeters;

   /* Convert Price */
   _temp5 = input(Price, best32.);
   drop Price;
   rename _temp5 = Price;

run;

proc contents data=MT;
run;
proc means data=MT nmiss;
run;
/* Remove rows with missing values */
data CleanMT;
    set MT;
    if cmiss(of _all_) = 0 then output;
run;

/* Drop 'address' */
data MT;
    set MT;
    drop address;
run;
/* Calculate descriptive statistics */
proc means data=MT n nmiss mean std min median max;
   var Price SquareMeters NumBedrooms NumBathrooms YearBuilt;
run;

/* Calculate frequencies for categorical variables */
proc freq data=MT order=freq;
   tables PropertyType Neighborhood Lift Terrace Balcony Parking;
run;

/* Plot quantitative variables */
proc sgplot data=MT;
   histogram Price / scale=count;
run;

proc sgplot data=MT;
   histogram SquareMeters / scale=count ;
run;
/* Scatter plot of Price vs SquareMeters */
proc sgplot data=MT;
   scatter x=SquareMeters y=Price;
   reg x=SquareMeters y=Price;
run;

/* Scatter plot of Price vs NumBedrooms */
proc sgplot data=MT;
   scatter x=NumBedrooms y=Price;
   reg x=NumBedrooms y=Price;
run;

/* Scatter plot of Price vs NumBathrooms */
proc sgplot data=MT;
   scatter x=NumBathrooms y=Price;
   reg x=NumBathrooms y=Price;
run;

/* Box plot of Price by PropertyType */
proc sgplot data=MT;
   vbox Price / category=PropertyType;
run;

/* Box plot of Price by Neighborhood */
proc sgplot data=MT;
   vbox Price / category=Neighborhood;
   xaxis display=(nolabel) fitpolicy=rotate labelattrs=(size=12);
   yaxis label="Price";
run;
/* Calculate average Price for combinations of NumBedrooms and NumBathrooms */
proc means data=MT mean;
   class NumBedrooms NumBathrooms;
   var Price;
run;
/* Calculate average Price for combinations of NumBedrooms and PropertyType */
proc means data=MT mean;
   class NumBedrooms PropertyType;
   var Price;
run;
/* Calculate average Price for combinations of NumBathrooms and Neighborhood */
proc means data=MT mean;
   class NumBathrooms Neighborhood;
   var Price;
run;
/* Correlation analysis between numeric variables */
proc corr data=MT;
   var Price SquareMeters NumBedrooms NumBathrooms YearBuilt;
run;