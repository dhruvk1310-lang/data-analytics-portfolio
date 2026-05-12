/* Managing Variables: Exercise */

/*
Problem 1
Please take a look at the attached real estate listings data and answer the following questions. Delete any variables not used in your analysis, rename the remaining ones for convenience, and save the final data as a CSV file.
- Q: What is the average number of bathrooms? (Hint: See previous lectures)
- A: 2.0638697
- Q: Which property type has the highest average property area? (Hint: See previous lectures)
- A: Condo 
- Q: What is the relationship between property area and listing price? (Hint: See previous lectures)
- A: The scatter plot shows a positive correlation between Property_Area and Listing_Price. As the property area increases, the listing price tends to increase as well.
*/


/* Load data */
proc import datafile="/home/u63994028/Data mining BAN628/07- Managing Variables/Managing Variables-Exercise-Data1.csv" out=listings replace;
    guessingrows=max;
    
/* Print data */
proc print data=listings(obs=10);
run;

/* Delete variables */
data listings;
	set listings;
    drop "Neighborhood Rating"n 
    	"Proximity to Transport"n 
    	"Time on Market (days)"n
    	"Renovation Status"n ;
run;

/* Print data */
proc print data=listings(obs=10);
run;

/* Rename variables */
data listings;
	set listings;
	rename "Property Area (sqft)"n = Property_Area
    	"Listing Price (000s)"n = Listing_Price 
    	 "Property Type"n = Property_Type
    	"Number of Bathrooms"n = Number_of_Bathrooms;
run;

/* Print data */
proc print data=listings(obs=10);
run;

/* Calculate descriptive statistics */
proc means data=listings;
run;

/* Show data info */
proc contents data=listings;
run;

/* Convert Project_Duration (quantitative variable) to numeric data type */
/* FYI: Any text strings will generate errors in the log and become missing values */
data listings;
    set listings;
    _temp = input(Number_of_Bathrooms, best12.);
    drop Number_of_Bathrooms;
    rename _temp=Number_of_Bathrooms;
run;

/* Show data info */
proc contents data=listings;
run;

/* Calculate descriptive statistics */
proc means data=listings;
run;

data listings;
   set listings;
   _temp = input(Number_of_Bathrooms, best32.); 
   drop Number_of_Bathrooms;
   rename _temp=Number_of_Bathrooms;
run;


proc contents data=listings;
run;

data listings;
    set listings;
    Property_Area_num = input(Property_Area, best32.); 
    drop Property_Area; 
    rename Property_Area_num = Property_Area; 
run;

proc means data=listings mean std;
   class Property_Type;
   var Property_Area;
run;

proc corr data=listings;
   var Property_Area Listing_Price;
run;

proc sgplot data=listings;
   scatter x=Property_Area y=Listing_Price ;
  run;
  
  /* Save data as CSV file */
proc export data=listings outfile="/home/u63994028/Data mining BAN628/07- Managing Variables/Managing Variables-Exercise-Data1-final.csv" replace;
run;


/*
Problem 2
Please take a look at the attached online learning platform data and answer the following questions. Delete any variables not used in your analysis, rename the remaining ones for convenience, and save the final data as a CSV file.
- Q: What is the average course rating? (Hint: See previous lectures)
- A: 3.4823589
- Q: Which course category has the highest average completion rate? (Hint: See previous lectures)
- A: Finance
- Q: What is the relationship between instructor experience and course duration? (Hint: See previous lectures)
- A: The scatter plot seems quite disperesed implying that there is no direct relationship between the two.
*/

proc import datafile="/home/u63994028/Data mining BAN628/07- Managing Variables/Managing Variables-Exercise-Data2.csv" out=olp replace;
    guessingrows=max;
    run;
    
    
    /* Print data */
proc print data=olp(obs=10);
run;

/* Delete variables */
data olp;
	set olp;
    drop "Platform Name"n 
    	"Enrollment Type"n 
    	"Instructor Level"n ;
run;

/* Print data */
proc print data=olp(obs=10);
run;

/* Rename variables */
data olp;
	set olp;
	rename "Course Category"n = Course_Category
    	"Course Rating"n = Course_Rating 
    	 "Completion Rate"n = Completion_Rate
    	"Instructor Experience (Years)"n = Instructor_Experience
    	"Course Duration (Hours)"n = Course_Duration ;
run;

/* Print data */
proc print data=olp(obs=10);
run;

/* Calculate descriptive statistics */
proc means data=olp;
run;


data olp;
    set olp;
    _temp = input(Course_Rating, best12.);
    drop Course_Rating;
    rename _temp=Course_Rating;
run;


/* Calculate descriptive statistics */
proc means data=olp;
run;

data olp;
    set olp;
    _temp = input(Completion_Rate, best32.);
    drop Completion_Rate;
    rename _temp=Completion_Rate;
run;

Proc means data=olp;
run;

proc means data=olp mean std;
   class Course_Category;
   var Completion_Rate;
run;

proc corr data=olp;
   var Instructor_Experience Course_Duration;
run;

proc sgplot data=olp;
   scatter x=Instructor_Experience y=Course_Duration ;
  run;

/* Save data as CSV file */
proc export data=olp outfile="/home/u63994028/Data mining BAN628/07- Managing Variables/Managing Variables-Exercise-Data2-Final.csv" replace;
run;

/*
Problem 3
Please take a look at the attached event planning data and answer the following questions. Delete any variables not used in your analysis, rename the remaining ones for convenience, and save the final data as a CSV file.
- Q: What is the average attendee satisfaction? (Hint: See previous lectures)
- A: 3.9927555
- Q: Which location size has the highest average attendee capacity (Hint: See previous lectures)
- A: Small
- Q: What is the relationship between total ticket sales and ticket price? (Hint: See previous lectures)
- A: The scatter plot shows a positive correlation between Total_Ticket_Sales and Ticket_Price. As the total ticket sales increase, the ticket price tends to increase as well.
*/

proc import datafile="/home/u63994028/Data mining BAN628/07- Managing Variables/Managing Variables-Exercise-Data3.csv" out=epd replace;
    guessingrows=max;
    run;
    
    
    /* Print data */
proc print data=epd(obs=10);
run;

/* Delete variables */
data epd;
	set epd;
    drop "Event Type"n  
    	"Ticket Type"n
    	"Marketing Channel"n;
run;

/* Print data */
proc print data=epd(obs=10);
run;

/* Rename variables */
data epd;
	set epd;
	rename "Attendee Capacity"n = Attendee_Capacity
    	"Ticket Price"n = Ticket_Price
    	 "Total Ticket Sales"n = Total_Ticket_Sales
    	 "Location Size"n = Location_Size
    	"Avg Attendee Satisfaction"n = Avg_Attendee_Satisfaction ;
run;

proc means data=epd;
run;

data epd;
    set epd;
    _temp = input(Ticket_Price, best12.);
    drop Ticket_Price;
    rename _temp=Ticket_Price;
run;

data epd;
    set epd;
    _temp = input(Avg_Attendee_Satisfaction, best12.);
    drop Avg_Attendee_Satisfaction;
    rename _temp=Avg_Attendee_Satisfaction;
run;

proc means data=epd;
run;

proc means data=epd mean std ;
   class Location_Size;
   var Attendee_Capacity;
run;

proc corr data=epd;
   var Total_Ticket_Sales Ticket_Price;
run;

proc sgplot data=epd;
   scatter x=Total_Ticket_Sales y=Ticket_Price ;
  run;

/* Save data as CSV file */
proc export data=epd outfile="/home/u63994028/Data mining BAN628/07- Managing Variables/Managing Variables-Exercise-Data3-final.csv" replace;
run;
