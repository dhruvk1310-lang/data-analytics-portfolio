/* Lab Project 1 */

/*
You have been hired as a consultant by EduAnalytics, a consulting firm specializing in providing 
insights to educational institutions. Your client, Bright Future High School, is interested in 
understanding the factors that influence student performance on exams. The school administration 
believes that by analyzing student performance data, they can tailor their educational strategies 
to improve outcomes and address disparities among different student groups. The dataset you have 
been provided contains students' gender, race/ethnicity, parental level of education, type of 
lunch received, whether they completed a test preparation course, and their scores in math, 
reading, and writing. Your goal is to explore the data using exploratory data analysis techniques 
(i.e., univariate, bivariate, and trivariate analyses) to uncover five (5) key insights that can 
help Bright Future High School develop strategies to enhance student performance.

- Q: What is your 1st key insight?
- A:Males outperform females in math and writing, while females excel in reading.
The spread of scores shows more outliers for males in math and writing, while females have more consistent performance, especially in reading.
The median reading score for females is higher than that of males, showing a gender gap in certain subjects.
Males tend to show a broader range of scores, indicating more variance in their performance, particularly in math.
How this helps the school: The school can tailor instructional strategies, providing targeted support in math and writing for females, while offering reading interventions for males. 
Gender-specific teaching approaches, such as differentiated instruction or single-gender study groups, could be introduced to address these disparities.


- Q: What is your 2nd key insight?
- A: Students whose parents have higher education levels (bachelor’s degree or above) consistently perform better in all subjects, particularly math.
Those with parents who only completed high school tend to score lower across the board, indicating a strong link between parental education and student success.
The pattern holds for all subjects, emphasizing the importance of family background in shaping student outcomes.
Students with less-educated parents tend to have more variability in their scores, especially in math.
How this helps the school: 
The school could introduce family engagement programs or workshops to educate parents on how to support their children's academic efforts. 
Providing resources to parents with lower education levels may help reduce these disparities and foster a more supportive home learning environment.


- Q: What is your 3rd key insight?
- A: Students receiving free/reduced lunch (a marker of lower socioeconomic status) score lower on average in all subjects, especially math.
There is a noticeable performance gap between students who pay for lunch and those on free/reduced lunch, suggesting that socioeconomic factors play a role in academic achievement.
Free/reduced lunch students show more variability in their scores, with more low-performing outliers, especially in math and writing.
Paid lunch students tend to have higher mean scores in reading and more stable performance across subjects.
How this helps the school: The school can offer targeted tutoring or academic support to students from lower-income backgrounds.
Additional funding could be allocated for after-school programs, providing extra help in math and writing, which would benefit free/reduced lunch students.


- Q: What is your 4th key insight?
- A: Students whose parents have higher education levels (bachelor’s degree or above) consistently perform better in all subjects, particularly math.
Those with parents who only completed high school tend to score lower across the board, indicating a strong link between parental education and student success.
The pattern holds for all subjects, emphasizing the importance of family background in shaping student outcomes.
Students with less-educated parents tend to have more variability in their scores, especially in math.
How this helps the school: The school could introduce family engagement programs or workshops to educate parents on how to support their children's academic efforts.
 Providing resources to parents with lower education levels may help reduce these disparities and foster a more supportive home learning environment.
 
 
- Q: What is your 5th key insight?
- A: Different ethnic groups show varying levels of performance, with Group D consistently scoring the highest across all subjects.
Group A shows the lowest performance, particularly in math and writing, highlighting a significant achievement gap.
Group E displays a wider range of writing scores, with numerous low-performing outliers.
The disparities in academic performance across ethnic groups suggest unequal access to resources or educational opportunities.
How this helps the school: The school should implement culturally responsive teaching methods and offer tailored academic support to underperforming groups. 
Mentorship programs, culturally relevant curriculum adjustments, 
and outreach to underrepresented groups can help close these gaps and ensure equal opportunities for academic success.
*/

proc import datafile="/home/u63994028/LAB Project 1/Lab Project 1-Data.csv" out=EA replace;
guessingrows=max;
run;
proc print data= EA (obs=10);
run;
proc means data=EA mean median std min max;
    var math_score reading_score writing_score;
run;

proc freq data=EA;
    tables gender race_ethnicity parental_education lunch test_prep_course;
run;

proc sgplot data=EA;
    vbox math_score / category=gender;
    title "Distribution of Math Scores by Gender";
run;

proc sgplot data=EA;
    vbox reading_score / category=gender;
    title "Distribution of Reading Scores by Gender";
run;

proc sgplot data=EA;
    vbox writing_score / category=gender;
    title "Distribution of Writing Scores by Gender";
run;

proc sgplot data=EA;
    vbox math_score / category=test_prep_course;
    title "Distribution of Math Scores by Test Preparation Course";
run;

proc sgplot data=EA;
    vbox reading_score / category=test_prep_course;
    title "Distribution of Reading Scores by Test Preparation Course";
run;

proc sgplot data=EA;
    vbox writing_score / category=test_prep_course;
    title "Distribution of Writing Scores by Test Preparation Course";
run;

proc corr data=EA;
    var math_score reading_score writing_score;
run;

proc sgpanel data=EA;
    panelby gender;
    vbar math_score / group=test_prep_course;
    title "Math Scores by Gender and Test Preparation Course";
run;

proc sgpanel data=EA;
    panelby gender;
    vbar reading_score / group=test_prep_course;
    title "Reading Scores by Gender and Test Preparation Course";
run;

proc sgpanel data=EA;
    panelby gender;
    vbar writing_score / group=test_prep_course;
    title "Writing Scores by Gender and Test Preparation Course";
run;

proc means data=EA mean std;
    class gender test_prep_course;
    var math_score reading_score writing_score;
run;