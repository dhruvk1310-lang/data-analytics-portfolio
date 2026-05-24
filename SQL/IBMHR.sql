-- 1. Attrition rate by department
SELECT 
    Department,
    COUNT(*) AS total_employees,
    SUM(Attrition) AS employees_left,
    ROUND(SUM(Attrition) * 100.0 / COUNT(*), 2) AS attrition_rate_pct
FROM ibm_hr.HR
GROUP BY Department
ORDER BY attrition_rate_pct DESC;
-- 2. Average monthly income by job role
SELECT 
    JobRole,
    ROUND(AVG(MonthlyIncome), 2) AS avg_monthly_income,
    COUNT(*) AS headcount
FROM ibm_hr.HR
GROUP BY JobRole
ORDER BY avg_monthly_income DESC;
-- 3. Overtime impact on attrition
SELECT 
    OverTime,
    COUNT(*) AS total_employees,
    SUM(Attrition) AS employees_left,
    ROUND(SUM(Attrition) * 100.0 / COUNT(*), 2) AS attrition_rate_pct
FROM ibm_hr.HR
GROUP BY OverTime;
-- 4. Attrition by age group
SELECT 
    CASE 
        WHEN Age < 25 THEN 'Under 25'
        WHEN Age BETWEEN 25 AND 34 THEN '25-34'
        WHEN Age BETWEEN 35 AND 44 THEN '35-44'
        WHEN Age BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55+'
    END AS age_group,
    COUNT(*) AS total_employees,
    SUM(Attrition) AS employees_left,
    ROUND(SUM(Attrition) * 100.0 / COUNT(*), 2) AS attrition_rate_pct
FROM ibm_hr.HR
GROUP BY age_group
ORDER BY attrition_rate_pct DESC;
-- 6. Top 10 highest paid employees
SELECT 
    EmployeeNumber,
    JobRole,
    Department,
    MonthlyIncome,
    TotalWorkingYears
FROM ibm_hr.HR
ORDER BY MonthlyIncome DESC
LIMIT 10;
-- 7. Gender pay gap by department
SELECT 
    Department,
    Gender,
    ROUND(AVG(MonthlyIncome), 2) AS avg_income,
    COUNT(*) AS headcount
FROM ibm_hr.HR
GROUP BY Department, Gender
ORDER BY Department, Gender;
-- 8. Years at company vs monthly income correlation
SELECT 
    YearsAtCompany,
    ROUND(AVG(MonthlyIncome), 2) AS avg_income,
    COUNT(*) AS headcount
FROM ibm_hr.HR
GROUP BY YearsAtCompany
ORDER BY YearsAtCompany;
-- 9. High flight risk employees (likely to leave)
SELECT 
    EmployeeNumber,
    Age,
    JobRole,
    Department,
    MonthlyIncome,
    JobSatisfaction,
    YearsAtCompany,
    OverTime
FROM ibm_hr.HR
WHERE Attrition = 1
    AND JobSatisfaction <= 2
    AND OverTime = 1
ORDER BY MonthlyIncome ASC;
-- 10. Department headcount and average tenure
SELECT 
    Department,
    COUNT(*) AS headcount,
    ROUND(AVG(YearsAtCompany), 2) AS avg_tenure_years,
    ROUND(AVG(MonthlyIncome), 2) AS avg_income
FROM ibm_hr.HR
GROUP BY Department
ORDER BY avg_tenure_years DESC;