/* Lab Project 2 */

/*
Imagine you're a data analyst at a global video game company. You've been asked to provide input for the company's new game development strategy. To this end, you've been given the attached historical dataset which contains sales data (in millions of units) along with critic and user review scores obtained from Metacritic.com. Despite the dataset’s age, the company believes there may be valuable lessons in consumer preferences, platform performance, and the role of critic/user reviews. Your task is to explore a subset of the data that you're interested in, such as a subset of platforms, years, genres, and/or ratings (by removing any rows that you want to exclude from your analysis) with the goal of uncovering 5 key insights that can improve the company's new game development strategy. To do so, please first preprocess the data and then explore the data using exploratory data analysis techniques (i.e., uni-/bi-/trivariate analyses).

To preprocess the data, please:
- Rename the variables for your convenience
- Ensure the following categorical variables are properly encoded:
  - Platform: 1=Atari, 2=Bandai, 3=Microsoft, 4=NEC, 5=Nintendo, 6=Panasonic, 7=PC, 8=Sega, 9=Sony
  - Rating: 1=E (Everyone, age 0+), 2=E10+ (Everyone, age 10+), 3=T (Teenager, age 13+), 4=M (Mature, age 17+), 5=AO (Adults Only, age 18+)
- Ensure that all quantitative variables are numeric data types (i.e., NUM)
- Remove any rows with missing values
- Remove any rows that you want to exclude from your analysis
- Remove any variables that aren't part of your analysis (do you exploratatry data analysis from here)
- Save the final dataset as a CSV file

After exploring the data using uni-/bi-/trivariate analyses, please answer the following questions:
- Q: Which subset of the data did you focus your analysis on?
- A: Genre

- Q: What is your 1st key insight?
- A: Platform Targeting: Since Sony and Microsoft dominate popular genres like:
Action, Role-Playing, and Shooter, the company should focus on developing games in these genres for these platforms to tap into their larger audience base. 
For niche genres like Simulation, PC might be the ideal platform to target.
- Q: What is your 2nd key insight?
- A: Given NA's dominance in sales across most genres, especially Fighting and Shooter, 
the company should prioritize marketing and releasing new titles in these genres in North America. 
EU shows stronger interest in Racing games, so the company should consider focusing on this genre for the European market.

- Q: What is your 3rd key insight?
- A: Critic Scores Influence: Since Platform, Puzzle, and Strategy games receive the highest critic scores, 
creating high-quality games in these genres could lead to positive reviews, boosting visibility and sales. 
Ensuring high production quality in these genres can improve the game's long-term success.

- Q: What is your 4th key insight?
- A:The Shooter genre has the highest user count potential, so focusing on quality in this genre could yield strong engagement. 
Platform games also show promise but need consistency to reduce variability in user appeal. 
Puzzle games have the lowest user interest, suggesting the need for innovation or deprioritization.

- Q: What is your 5th key insight?
- A: The scatter plot shows the relationship between CriticScore and UserCount, which aligns with the weak positive correlation indicated earlier. 
While there is some upward trend, most games with lower critic scores (below 60) tend to have very low user counts,
and as the critic score increases (above 80), there are a few outliers with significantly higher user counts. However, the majority of games still cluster around lower user counts regardless of critic score, suggesting that while higher critic scores can drive user engagement, they are not the sole factor influencing popularity.
*/
proc import datafile="/home/u63994028/Data mining BAN628/10-LAB Project 2/Lab Project 2-Data.csv" 
    out=VGC 
    replace;
    guessingrows=max;
run;
Proc print data= VGC (obs=10);
run;
data VGC;
	set VGC;
    drop VAR1;
    run;
    data VGC;
	set VGC;
	rename "Year of Release"n = ReleasedYear
    	"NA Sales"n = NAsales
    	"EU Sales"n = EUsales
    	"JP Sales"n = JPsales
    	"Other Sales"n = Othersales
    	"Critic Score"n = CriticScore
    	"Critic Count"n = CrticCount
    	"User Score"n = UserScore
    	"User Count"n= UserCount;
    	run;
 data VGC;
    set VGC;
    length _temp $50;
    if Platform = 1 then _temp = "Atari";
    else if Platform = 2 then _temp= "Bandai";
    else if Platform = 3 then _temp = "Microsoft";
    else if Platform = 4 then _temp = "NEC";
    else if Platform = 5 then _temp = "Nintendo";
    else if Platform = 6 then _temp = "Panasonic";
    else if Platform = 7 then _temp = "PC";
    else if Platform = 8 then _temp = "Sega";
    else if Platform = 9then _temp = "Sony";
    drop Platform ;
    rename _temp=Platform;
run;
 data VGC;
    set VGC;
    if 	Rating = "E" then _temp = 1;
    else if Rating = "E10+" then _temp = 2;
    else if	Rating = "T" then _temp = 3;
    else if	Rating ="M" then _temp = 4;
    else if Rating ="A)" then _temp = 5;
    drop Rating;
    rename _temp=Rating;
run;
data VGC;
    set VGC;
    if cmiss(of _all_) = 0 then output;
run;


data VGC;
    set VGC;
    _temp = input(CrticCount, best32.);
    drop CrticCount;
    rename _temp = CrticCount;
run;
data VGC;
    set VGC;
    _temp = input(EUsales, best32.);
    drop EUsales;
    rename _temp = EUsales;
run;
data VGC;
    set VGC;
    _temp = input(JPsales, best32.);
    drop JPsales;
    rename _temp = JPsales;
run;
data VGC;
    set VGC;
    _temp = input(Othersales, best32.);
    drop Othersales;
    rename _temp = Othersales;
run;
data VGC;
    set VGC;
    _temp = input(UserScore, best32.);
    drop UserScore;
    rename _temp = UserScore;
run;
proc contents data=VGC; run;
    	Proc print data =VGC (obs=10);run;
proc export data=VGC outfile="/home/u63994028/Data mining BAN628/10-LAB Project 2/Lab Project 2-DataClean.csv" replace;
run;
proc freq data=VGC order=freq;
tables 	Platform*Genre / norow nocol nopercent;
run;
   proc means data=VGC;
   class Genre ;
Var EUsales NAsales JPsales Othersales;
run;

   proc means data=VGC;
   class Genre ;
Var CriticScore;
run;
   proc means data=VGC;
   class Genre ;
Var UserCount;
run;
proc means data=VGC;
Class Genre;
Var Rating;
run;
proc corr data=VGC;
var CriticScore UserCount;
run;
proc sgplot;
scatter x=CriticScore y=UserCount;
run;
