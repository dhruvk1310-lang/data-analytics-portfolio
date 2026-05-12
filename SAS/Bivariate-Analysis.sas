/* Bivariate Analysis: Exercise */

/*
Problem 1

Please take a look at the attached hotel bookings data.
- Q: Explore the distribution of room types across different booking sources. What is the most frequently booked room type for each booking source?
- A: Single room is the most booked room for all the booking source.
- Q: Examine the stay duration across different booking sources. Which booking source has the longest  stay duration, on average?
- A: Agency
- Q: Investigate how stay duration correlates with its cancellation rate. Do you observe a connection between these two variables?
- A: there is no relation between the 2 variables 
- Q: What is the average cancellation rate? (Hint: See previous lectures.)
- A: 0.1218806
- Q: Which room type is least frequent? (Hint: See previous lectures.)
- A: suite is the least frequent 
*/
proc import datafile="/home/u63994028/04-Bivariate Analysis/Bivariate Analysis-Exercise-Data1.csv" out=BD replace;
guessingrows=max;
run;

proc print data=BD (obs=10);
run;

proc freq data=BD order=freq;
tables 	RoomType*bookingsource / norow nocol nopercent;
run;
proc means data= BD;
class BookingSource;
Var StayDuration;
run;
proc corr data=BD;
var StayDuration CancellationRate;
run;
proc sgplot data= BD;
scatter x= cancellationrate  y=stayduration;
run;
proc means data= BD n nmiss mean std min median max;
run;
proc freq data=BD order=freq;
tables RoomType / norow nocol nopercent;
run;
/*
Problem 2

Please take a look at the attached restaurant operations data.
- Q: Explore the distribution of cuisine types across different meal times. What is the most frequently ordered cuisine type for each meal time?
- A: Lunch= Italian Dinner=mexican brekfast is japanese
- Q: Examine the average order value across different meal times. Which meal time has the highest average order value?
- A: BreakFast:21.1479208 Lunch:28.7366329 Dinner:45.8414286. Dinner has the highest order value
- Q: Investigate how the table turnover rate correlates with the average order value. Do you observe a connection between these two variables?
- A: There is a negative correlation as the average order value increases, the table turnover rate tends to decrease. there are some exceptions in the data
- Q: What is the average table turnover rate? (Hint: See previous lectures.)
- A: 1.0017946
- Q: Which cuisine type is least frequent? (Hint: See previous lectures.)
- A: Japanese is the least frequent
*/
proc import datafile="/home/u63994028/04-Bivariate Analysis/Bivariate Analysis-Exercise-Data2.csv" out=OD replace;
guessingrows=max;
run;
proc print data=OD(obs=10);
run;
proc freq data=OD order=freq;
tables CuisineType*mealtime;
run;
proc means data= OD;
class mealtime ;
Var AvgOrderValue;
run;
proc sgplot data= OD;
scatter x=TableTurnoverRate y=AvgOrderValue ;
run;
proc means data= OD ;
run;
proc freq data=OD order=freq;
tables CuisineType;
run;


/*
Problem 3

Please take a look at the attached ticket sales data.
- Q: Explore the distribution of event types across different ticket purchase timings. What is the most frequently attended event type for each purchase timing?
- A: Concert is the most frequent for all
- Q: Examine the average ticket price across different ticket purchase timings. Which purchase timing has the highest average ticket price?
- A: Last Minute has the highest average ticket price
- Q: Investigate how ticket price correlates with sales volume. Do you observe a connection between these two variables?
- A: There is a direct/positive relation as ticket prices go up sales volume go down
- Q: What is the average sales volume? (Hint: See previous lectures.)
- A: 4346.42
- Q: Which event type is least frequent? (Hint: See previous lectures.)
- A: Sports is the least frequent
*/
proc import datafile="/home/u63994028/04-Bivariate Analysis/Bivariate Analysis-Exercise-Data3.csv" out=SD replace;
guessingrows=max;
run;
proc print data=SD(obs=10);
run;
proc freq data=sD order=freq;
tables 	EventType*TicketPurchaseTiming / norow nocol nopercent;
run;
proc means data= SD;
class 	TicketPurchaseTiming ;
Var TicketPrice;
run;
proc sgplot data= SD;
scatter x=TicketPrice y=SalesVolume ;
run;
proc means data= SD ;
run;
proc freq data=SD order=freq;
tables EventType;
run;

