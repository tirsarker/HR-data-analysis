CREATE DATABASE hr;
USE hr;

SELECT * 
FROM hr_data;

SELECT termdate
FROM hr_data
ORDER BY termdate DESC;

UPDATE hr_data
SET termdate = FORMAT(CONVERT(DATETIME,LEFT(termdate,19),120),'yyyy-MM-dd');

ALTER TABLE hr_data
ADD new_termdate DATE;

UPDATE hr_data
SET new_termdate= CASE
WHEN termdate IS NOT NULL AND ISDATE(termdate)=1 THEN CAST(termdate AS DATETIME) ELSE NULL END;

ALTER TABLE hr_data
ADD age nvarchar(50);

UPDATE hr_data
SET age= DATEDIFF(YEAR,birthdate,GETDATE());

-- 1) what's the age distribution in the company
SELECT
 MIN(age) AS youngest,
 MAX(age) AS oldest
FROM hr_data;

--age group by distribution
SELECT age_group,
count(*) AS count
FROM
(SELECT 
 CASE
  WHEN age >=21 AND age <=30 THEN '21 to 30'
  WHEN age >=31 AND age <=40 THEN '31 to 40'
  WHEN age >=41 AND age <=50 THEN '41 to 50'
  ELSE '50+'
  END AS age_group
 FROM hr_data 
 WHERE new_termdate IS NULL
 ) AS subquery
GROUP BY age_group
ORDER BY age_group;

--age group by gender

SELECT age_group,gender,
count(*) AS count
FROM
(SELECT 
 CASE
  WHEN age >=21 AND age <=30 THEN '21 to 30'
  WHEN age >=31 AND age <=40 THEN '31 to 40'
  WHEN age >=41 AND age <=50 THEN '41 to 50'
  ELSE '50+'
  END AS age_group,gender
 FROM hr_data 
 WHERE new_termdate IS NULL
 ) AS subquery
GROUP BY age_group,gender
ORDER BY age_group,gender;

--2) gender breakdown in the company
SELECT gender, count(*) AS count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY gender
ORDER BY gender ASC;

--3) how does gender vary across departments and job titles
SELECT department,gender, count(*) AS count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY department,gender
ORDER BY department,gender ASC;

SELECT department,jobtitle,gender, count(*) AS count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY department,jobtitle,gender
ORDER BY department,jobtitle,gender ASC;

--4)race distributiton in the company
SELECT race, count(*) AS count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY race
ORDER BY count DESC;

--5) avg length of employment in the company
SELECT AVG(DATEDIFF(year,hire_date,new_termdate)) AS tenure
FROM hr_data
WHERE new_termdate IS NOT NULL AND new_termdate <= GETDATE();

--6) Which department has the highest turnover rate
--get total count
--get terminated count
--terminated count/total count
SELECT department,total_count, terminated_count, round((CAST(terminated_count AS FLOAT)/total_count),2)*100 
AS turnover_rate
FROM(
	SELECT 
	 department, count(*) AS total_count,	
	 SUM(CASE
	  WHEN new_termdate IS NOT NULL AND new_termdate <= GETDATE() THEN 1 ELSE 0
	  END
	  ) AS terminated_count
	FROM hr_data
	GROUP BY department
	) AS subquery
ORDER BY turnover_rate DESC;


--7) tenure distribution for each department

SELECT department,AVG(DATEDIFF(year,hire_date,new_termdate)) AS tenure
FROM hr_data
WHERE new_termdate IS NOT NULL AND new_termdate <= GETDATE()
GROUP BY department
ORDER BY tenure DESC;

--8) employees that work remotely for each department
SELECT location, count(*) as count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY location;


--9) distribution of employees across diferrent states
SELECT location_state, count(*) as count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY location_state
ORDER BY count DESC;

--10) job title distribution
SELECT jobtitle, count(*) as count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY jobtitle
ORDER BY count DESC;

--11) how have employee hire counts varied over time?
--calculate hires
--calculate terminations
--(hires-terminations)/hires percent hire change

SELECT hire_year,hires,terminations,round(((CAST(hires AS FLOAT)-terminations)/hires),2)*100 AS hire_change
FROM(
	SELECT 
	 YEAR(hire_date) AS hire_year, 
	 count(*) as hires,
	 SUM(CASE
	  WHEN new_termdate IS NOT NULL AND new_termdate <= GETDATE() THEN 1 ELSE 0
	  END) AS terminations
	FROM hr_data
	GROUP BY YEAR(hire_date)
	) AS subquery
ORDER BY hire_change;