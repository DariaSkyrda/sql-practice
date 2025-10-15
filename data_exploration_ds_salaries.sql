-- Preview the first 20 rows of the dataset
SELECT * 
FROM salaries 
LIMIT 20;

-- Count total number of records in the table (3755 rows)
SELECT COUNT(*)
FROM salaries;

-- Check for missing values in the salary_in_usd column
SELECT 
	COUNT(*)
	, COUNT(*) - COUNT(salary_in_usd) AS missing_values
FROM salaries;

-- Count how many records exist for each job title
SELECT 
	job_title
	, COUNT(*)
FROM salaries
GROUP BY job_title
ORDER BY amount DESC
--LIMIT 10 			  -- uncomment to see only top 10 job titles
;

-- Calculate min, max, average, and standard deviation of salary per job title and experience level
SELECT 
	job_title
	, exp_level
	, MIN(salary_in_usd)
	, MAX(salary_in_usd)
	, ROUND(AVG(salary_in_usd)) AS avg
	, ROUND(stddev(salary_in_usd)) AS stddev
FROM salaries
GROUP BY job_title, exp_level;

-- Group salaries into ranges
/*SELECT 
	TRUNC(salary_in_usd, -2)
	, COUNT(*)
FROM salaries
GROUP BY salary_in_usd;*/

-- Categorize salaries into custom ranges (A–F)
SELECT 
	CASE 
		WHEN salary_in_usd <= 10000 THEN 'A'
		WHEN salary_in_usd <= 20000 THEN 'B'
		WHEN salary_in_usd <= 50000 THEN 'C'
		WHEN salary_in_usd <= 100000 THEN 'D'
		WHEN salary_in_usd <= 200000 THEN 'E'
		ELSE 'F' END AS salary_category
	, COUNT(*)
FROM salaries
GROUP BY salary_category
ORDER BY salary_category;

-- Check correlation between remote ratio and salary 
-- (result: -0.064, no correlation)
SELECT 
	corr(remote_ratio, salary_in_usd)
FROM salaries;






















