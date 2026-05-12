/* Removing Rows: Exercise */

/*
Problem 1

First, please make the following changes to the attached online gaming activity data: 
1. Delete the in-game rank variable
2. Rename the remaining variables for your convenience
3. Ensure that all categorical variables are properly encoded (i.e., nominal variables should be encoded as text strings and ordinal variables should be encoded as numeric values). Note the following value mappings:
- Game Genre: 1=Adventure, 2=RPG, 3=Shooter, 4=Simulation, 5=Strategy
- Platform: 1=Console, 2=Mobile, 3=PC
- Player Level: 1=Casual, 2=Competitive, 3=Hardcore
- Region: 1=Africa, 2=Asia, 3=Europe, 4=North America, 5=South America

4. Ensure that all quantitative variables are numeric data types (i.e., Num)
5. Remove all missing values
6. Keep only mobile games

Then, please answer the following questions using the final dataset (Hint: It should contain 296 rows):
- Q: What is the average player retention rate?
- A: 0.5825676
- Q: Which region has the highest average player level?
- A: Region 5 {South America} Avg Player Level=	2.0937500
- Q: Which genre has the highest average in-game purchases?
- A: Adventure has the highest value 16.7225758
- Q: Is session duration related to in-game purchases? If so, how?
- A: There is no correlation
*/
proc import datafile="/home/u63994028/Data mining BAN628/09-Removing Rows/Removing Rows-Exercise-Data1.csv" out=PD replace;
	guessingrows=max;
run;
proc print data=PD(obs=10);
run;
data PD;
	set PD;
    drop "In-Game Rank"n ;
    run;
 
data PD;
	set PD;
	rename "Game Genre"n = GameGenre
    	"Player Level"n = PlayerLevel
    	"Session Duration (mins)"n = SessionDuration_mins
    	"In-Game Purchases (USD)"n = InGamePurchases_USD
    	"Player Retention Rate"n = PlayerRetentionRate;
    	run;
    	
 data PD;
    set PD;
    length _temp $50;
    if GameGenre = 1 then _temp = "Adventure";
    else if GameGenre = 2 then _temp = "RPG";
    else if GameGenre = 3 then _temp = "Shooter";
    else if GameGenre = 4 then _temp = "Simulation";
    else if GameGenre = 5 then _temp = "Strategy";
    drop GameGenre;
    rename _temp=GameGenre;
run;

 data PD;
    set PD;
    length _temp $50;
    if Platform = 1 then _temp = "Console";
    else if Platform = 2 then _temp = "Mobile";
    else if Platform = 3 then _temp = "PC";
    drop Platform ;
    rename _temp=Platform;
run;

data PD;
    set PD;
    if 	PlayerLevel = "Casual" then _temp = 1;
    else if PlayerLevel = "Competitive" then _temp = 2;
    else if PlayerLevel = "Hardcore" then _temp = 3;
    drop PlayerLevel;
    rename _temp= PlayerLevel;
run;
proc print data=PD (obs=10);
    run;
    data PD;
    set PD;
    if Region = "Africa" then _temp = 1;
    else if Region = "Asia" then _temp = 2;
    else if Region = "Europe" then _temp = 3;
     else if Region = "North America" then _temp = 4;
      else if Region = "South America" then _temp = 5;
    drop Region;
    rename _temp= Region;
run;

    proc contents data=PD;
    run;
    data PD;
    set PD;
    _temp = input(PlayerRetentionRate, best32.);
    drop PlayerRetentionRate;
    rename _temp=PlayerRetentionRate;
run;
 proc contents data=PD;
    run;
    Proc print data=PD (obs=10);run;
data PD;
    set PD;
    if cmiss(of _all_) = 0 then output;
run;
    proc means data=PD nmiss;
run;
data PD;
    set PD;
    if Platform = "Mobile" then output;
run;
proc print
data=PD 
(obs=10);
run;
proc means data=PD n nmiss mean std min median max;
run;
proc means data= PD;
class Region;
Var PlayerLevel;
run;
proc means data= PD;
class GameGenre;
Var InGamePurchases_USD;
run;
proc corr data=PD;
var SessionDuration_mins InGamePurchases_USD;
run;
proc sgplot data= PD;
scatter x= SessionDuration_mins  y=InGamePurchases_USD;
run;
/*
Problem 2

First, please make the following changes to the attached fitness club data: 
1. Delete the fitness level and membership tier variables
2. Rename the remaining variables for your convenience
3. Ensure that all categorical variables are properly encoded (i.e., nominal variables should be encoded as text strings and ordinal variables should be encoded as numeric values). Note the following value mappings:
- Health Goal: 1=Endurance, 2=Flexibility, 3=Muscle Gain, 4=Weight Loss
- Region: 1=East, 2=North, 3=South, 4=West
- Satisfaction Level: 1=Low, 2=Medium, 3=High
- Trainer Usage: 1=Never, 2=Occasionally, 3=Frequently

4. Ensure that all quantitative variables are numeric data types (i.e., Num)
5. Remove all missing values
6. Keep only fitness clubs located in the north or the east

Then, please answer the following questions using the final dataset (Hint: It should contain 497 rows):
- Q: What is the average monthly spend?
- A: 57.32
- Q: Which health goal has the highest average monthly visits?
- A: Flexibility	102	102	8.7647059
- Q: Which region has the higher average trainer usage?
- A: North, 1.92 average
- Q: Is satisfaction level related to membership length? If so, how?
- A: There dosen't seem to be any correlations 
*/
proc import datafile="/home/u63994028/Data mining BAN628/09-Removing Rows/Removing Rows-Exercise-Data2.csv" out=FCD replace;
	guessingrows=max;
run;
proc print data=FCD(obs=10);
run;
data FCD;
	set FCD;
    drop "Fitness Level"n 
    "Membership Tier"n;
    run;
    proc print data=FCD (obs=10);
    run;

data FCD;
	set FCD;
	rename "Health Goal"n = HealthGoal
    	"Satisfaction Level"n = SatisfactionLevel
    	"Trainer Usage"n = TrainerUsage
    	"Monthly Visits"n = MonthlyVisits
    	"Monthly Spend USD"n =  MonthlySpend_USD
    	"Membership Length Years"n= MembershipLength_Years;
    	run;
    	  proc print data=FCD (obs=10);
    run;
 data FCD;
    set FCD;
    length _temp $50;
    if Region = 1 then _temp = "East";
    else if Region = 2 then _temp = "South";
    else if Region = 3 then _temp = "North";
    else if Region = 4 then _temp = "West";
    drop Region;
    rename _temp=Region;
run;

data FCD;
    set FCD;
    if 	TrainerUsage = "Never" then _temp = 1;
    else if TrainerUsage = "Occasionally" then _temp = 2;
    else if TrainerUsage = "Frequently" then _temp = 3;
    drop TrainerUsage;
    rename _temp= TrainerUsage;
run;
proc print data=FCD (obs=10);
    run;
  proc contents data=FCD;
    run;
    data FCD;
    set FCD;
    _temp = input(MonthlySpend_USD, best32.);
    drop MonthlySpend_USD;
    rename _temp=MonthlySpend_USD;
run;
  data FCD;
    set FCD;
    _temp = input(	MonthlyVisits, best32.);
    drop MonthlyVisits;
    rename _temp=MonthlyVisits;
run;
 proc contents data=FCD;
    run;
    Proc print data=FCD (obs=10);run;
data FCD;
    set FCD;
    if cmiss(of _all_) = 0 then output;
run;
    proc means data=FCD nmiss;
run;
data FCD;
    set FCD;
    if Region = "East" or Region = "North" then output;
run;
proc print
data=FCD ;
run;
proc means data=FCD n nmiss mean std min median max;
run;
proc means data= FCD;
class HealthGoal;
Var MonthlyVisits;
run;
proc means data= FCD;
class Region;
Var TrainerUsage;
run;
proc corr data=FCD;
var SatisfactionLevel MembershipLength_Years;
run;
proc sgplot data= FCD;
scatter x= SatisfactionLevel y=MembershipLength_Years;
run;

/*
Problem 3

First, please make the following changes to the attached social media advertising data: 
1. Delete the engagement level variable
2. Rename the remaining variables for your convenience
3. Ensure that all categorical variables are properly encoded (i.e., nominal variables should be encoded as text strings and ordinal variables should be encoded as numeric values). Note the following value mappings:
- Ad Platform: 1=Facebook, 2=Instagram, 3=LinkedIn, 4=Twitter
- Ad Relevance Score: 1=Poor, 2=Average, 3=Good, 4=Excellent
- Audience Interest: 1=Low, 2=Moderate, 3=High
- Post Type: 1=Carousel, 2=Image, 3=Text, 4=Video
- Target Audience Gender: 1=Female, 2=Male, 3=Non-Binary

4. Ensure that all quantitative variables are numeric data types (i.e., Num)
5. Remove all missing values
6. Keep only ads that ran on Facebook or Instagram

Then, please answer the following questions using the final dataset (Hint: It should contain 474 rows):
- Q: What is the average ad spend?
- A: 2483.79
- Q: Which post type has the highest average click through rate?
- A: Text 8.4808929
- Q: Which target audience gender has the higher average audience interest?
- A: Male 2.0714286
- Q: Is ad relevance score related to ad impressions? If so, how?
- A: The Pearson correlation coefficient between AdRelevanceScore and AdImpressions is -0.01963. 
This is a very small negative value, close to zero, 
which suggests that there is no significant linear relationship between these two variables
*/
proc import datafile="/home/u63994028/Data mining BAN628/09-Removing Rows/Removing Rows-Exercise-Data3.csv" 
    out=MAD 
    replace;
    guessingrows=max;
run;

/* Step 1: Delete the 'Engagement Level' variable */
data MAD;
    set MAD;
    drop "Engagement Level"n;
run;

/* Step 2: Rename variables */
data MAD;
    set MAD;
    rename 
        "Ad Platform"n = AdPlatform
        "Post Type"n = PostType
        "Target Audience Gender"n = TargetAudienceGender
        "Audience Interest"n = AudienceInterest
        "Ad Relevance Score"n = AdRelevanceScore
        "Ad Spend USD"n = AdSpendUSD
        "Ad Impressions"n = AdImpressions
        "Click Through Rate"n = ClickThroughRate;
run;

/* Step 3: Recode categorical variables */

/* Recode AdPlatform */
data MAD;
    set MAD;
    if AdPlatform = 1 then _temp = 'Facebook';
    else if AdPlatform = 2 then _temp = 'Instagram';
    else if AdPlatform = 3 then _temp = 'LinkedIn';
    else if AdPlatform = 4 then _temp = 'Twitter';
    drop AdPlatform;
    rename _temp = AdPlatform;
run;

/* Recode PostType */
data MAD;
    set MAD;
    length _temp $50;
    if PostType = 1 then _temp = 'Carousel';
    else if PostType = 2 then _temp = 'Image';
    else if PostType = 3 then _temp = 'Text';
    else if PostType = 4 then _temp = 'Video';
    drop PostType;
    rename _temp = PostType;
run;


/* Recode AudienceInterest */
data MAD;
    set MAD;
    if AudienceInterest = 'Low' then _temp = 1;
    else if AudienceInterest = 'Moderate' then _temp = 2;
    else if AudienceInterest = 'High' then _temp = 3;
    drop AudienceInterest;
    rename _temp = AudienceInterest;
run;

/* Recode AdRelevanceScore */

proc print data=MAD(obs=1000); 
run;


data MAD;
    set MAD;
    _temp = input(ClickThroughRate, best32.);
    drop ClickThroughRate;
    rename _temp = ClickThroughRate;
run;


data MAD;
    set MAD;
    _temp = input(AdSpendUSD, best32.);
    drop AdSpendUSD;
    rename _temp = AdSpendUSD;
run;


data MAD;
    set MAD;
    _temp = input(AdImpressions, best32.);
    drop AdImpressions;
    rename _temp = AdImpressions;
run;

proc contents data=MAD; 
run;


/* Step 5: Remove all missing values */
data MAD;
    set MAD;
    if cmiss(of _all_) = 0 then output;
run;

/* Step 6: Keep only ads that ran on Facebook or Instagram */
data MAD;
    set MAD;
    if AdPlatform = 'Facebook' or AdPlatform = 'Instagra' then output;
run;
proc print data=mad (obs=1000);run;
/* Checking the number of rows (expecting 474) */
proc means data=MAD n;
run;

/* Q1: What is the average ad spend? */
proc means data=MAD mean;
    var AdSpendUSD;
run;

/* Q2: Which post type has the highest average click-through rate? */
proc means data=MAD mean;
    class PostType;
    var ClickThroughRate;
run;

/* Q3: Which target audience gender has the higher average audience interest? */
proc means data=MAD mean;
    class TargetAudienceGender;
    var AudienceInterest;
run;

/* Q4: Is ad relevance score related to ad impressions? */
proc corr data=MAD;
    var AdRelevanceScore AdImpressions;
run;
proc sgplot data= MAD;
scatter x=AdRelevanceScore  y=AdImpressions;
run;
