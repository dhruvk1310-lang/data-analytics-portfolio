/* Lab Project 3 */

/*
Imagine you're a data analyst working for an international education consultancy. Your company advises universities on strategies to improve their global rankings. You've been given the Times Higher Education World University Ranking, a dataset containing rankings and key metrics for 800 universities around the world, including:

- world_rank: World rank of the university
- university_name: Name of the university
- country: Country of the university
- teaching: University score for teaching excellence (out of 100)
- international: University score for ability to attract international staff (out of 100)
- research: University score for research excellence (out of 100)
- citations: University score for research citations received (out of 100)
- income: University score for income from industry (out of 100)
- num_students: Number of students at the university
- student_staff_ratio: Ratio of students to staff
- international%: Percent of international students (out of 100)
- female%: Percent of female students (out of 100)

Your task is to come up with 5 key insights that can help universities improve their global rankings. At least 2 key insights must come from an exploratory data analysis and at least 2 key insights must come from a principal component analysis of the data. When you are done, please answer the following questions:

- Q1: What is your 1st key insight?
- A1:Top-ranked universities show higher scores in both teaching and research compared to lower-ranked institutions. 
     This indicates that strong performance in these areas is crucial for improving global rankings. 
     Universities aiming to boost their standing should focus on enhancing their teaching quality and research output.

- Q2: What is your 2nd key insight
- A2: The student-to-staff ratio plays an important role in determining university rankings. 
      Universities with a lower ratio (more staff per student) tend to be ranked higher, 
      possibly due to better student satisfaction and more personalized teaching.

- Q3: What is your 3rd key insight
- A3: Research quality and citation impact are the most significant factors driving global university rankings. 
      Universities that produce high-quality research and receive more citations tend to rank higher. 
      While teaching and internationalization also matter, their impact is secondary to research and citation metrics.

- Q4: What is your 4th key insight
- A4: PCA Analysis 1:-
    The PCA shows that research (-0.8154 correlation) and citations (-0.9034 correlation) are the strongest predictors of rankings, 
    with teaching (-0.7652 correlation) also playing a significant role. 
    Internationalization contributes moderately with a correlation of -0.5591. 
    The first principal component (Prin1), which explains 47% of the total variance, 
    confirms these metrics as the primary drivers of university success.

- Q5: What is your 5th key insight
- A5: PCA Analysis 2(outliers analysis):-
      Outliers like Anadolu University have extremely high student-to-staff ratios, with 162.6 compared to the typical average of below 20. 
      Their research scores are low, with Anadolu at 22.6, Cairo University at 11.1, and Universiti Teknologi MARA at 7.7. 
      Additionally, their international presence is minimal, with 1% for Anadolu and 0% for Universiti Teknologi MARA, 
      which significantly limits their ability to improve global rankings.
*/
proc import datafile="/home/u63994028/Data mining BAN628/15-LAB project 3/Lab Project 3-Data.csv" out=UNI replace;
	guessingrows=max;
run;
proc print data=UNI(obs=10);
run;
data UNI;
    set UNI;
    if cmiss(of _all_) = 0 then output;
run;

/*1st Insight*/
proc means data=UNI mean std min max;
	class world_rank;
	var teaching research;
run;
proc means data=UNI mean std min max;
	var teaching research;
run;

proc means data=UNI mean std min max;
	class world_rank;
	var student_staff_ratio;
run;
proc stdize data=UNI out=UNI_standardized;
run;
proc corr data=UNI_standardized noprob;
run;
proc princomp data=UNI_standardized out=UNI_pca plots=score(ncomp=2) n=4;
run;
data UNI_outliers;
    set UNI;
    if _n_ in (545,560,688);
run;
proc corr data=UNI_pca noprob;
	var Prin1 Prin2;
run;
proc print data=UNI_outliers;
run; 
proc sgplot data=UNI_pca;
	scatter x=Prin1 y=Prin2;
run;








































