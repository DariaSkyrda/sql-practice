SELECT * 
FROM salaries
LIMIT 20;

SELECT
	year
	, job_title
	, salary_in_usd
FROM salaries 
WHERE 
	year = 2023
	AND job_title = 'Data Scientist'
ORDER BY salary_in_usd DESC
LIMIT 5;

--Вивести з/п спеціалістів ML Engineer в 2023 році
SELECT
	year
	, job_title
	, salary_in_usd
FROM salaries 
WHERE 
	year = 2023
	AND job_title = 'ML Engineer'
;

--Назвати країну (comp_location), в якій зафіксована найменша 
--з/п спеціаліста в сфері Data Scientist в 2023 році
SELECT comp_location
FROM salaries
WHERE 
	year = 2023
	AND job_title = 'Data Scientist'
ORDER BY salary_in_usd ASC
LIMIT 1;

--Вивести з/п українців (код країни UA), додати сортування за 
--зростанням з/п
SELECT 
	salary_in_usd 
FROM salaries 
WHERE 
	emp_location = 'UA'
ORDER BY salary_in_usd ASC;

--Вивести топ 5 з/п серед усіх спеціалістів, які працюють повністю
--віддалено (remote_ratio = 100)
SELECT 
	* 
FROM salaries 
WHERE 
	remote_ratio = 100
ORDER BY salary_in_usd DESC
LIMIT 5;

--Згенерувати .csv файл з таблицею даних всіх спеціалістів, 
--які в 2023 році мали з/п більшу за $100,000 і працювали в компаніях 
--середнього розміру (comp_size = 'M'
SELECT 
	* 
FROM salaries 
WHERE 
	year = 2023
	AND comp_size = 'M'
	AND salary_in_usd > 100000
;
--------------------------------------------------------------------------
--2 lesson 
--------------------------------------------------------------------------
SELECT * FROM salaries LIMIT 20;

--Вивести кількість унікальних значень для кожної колонки, 
--що містить текстові значення.
SELECT 
	COUNT(DISTINCT exp_level)
	, COUNT(DISTINCT emp_type)
	, COUNT(DISTINCT job_title)
FROM salaries

--Вивести унікальні значення для кожної колонки, що містить текстові значення. 
SELECT 
	DISTINCT comp_location
FROM salaries;

--Вивести середню, мінімальну та максимальну з/п (salary_in_usd) для кожного 
--року (окремими запитами, в кожному з яких впроваджено фільтр відповідного року)
SELECT 
	ROUND(AVG(salary_in_usd), 2) AS avg_salary
	, MIN(salary_in_usd) AS min_salary
	, MAX(salary_in_usd) AS max_salary
FROM salaries
WHERE 
	year = 2023;

--Вивести середню з/п (salary_in_usd) для 2023 року по кожному рівню досвіду 
--працівників (окремими запитами, в кожному з яких впроваджено фільтр року 
--та досвіду).
SELECT 
	 exp_level
	, ROUND(AVG(salary_in_usd)) AS avg_salary 
FROM salaries
WHERE 
	year = 2023
GROUP BY exp_level;

--Вивести 5 найвищих заробітних плат в 2023 році для представників 
--спеціальності ML Engineer. Заробітні плати перевести в гривні
SELECT 
	year
	, job_title
	, (salary_in_usd * 41) AS salary_in_hryvna 
FROM salaries
WHERE 
	year = 2023
	AND job_title = 'ML Engineer'
ORDER BY salary_in_usd DESC
LIMIT 5;

--Вивести Унікальні значення колонки remote_ratio, формат даних має бути дробовим 
--з двома знаками після коми, приклад: значення 50 має відображатись в форматі 0.50
SELECT 
	DISTINCT ROUND(remote_ratio/100.0, 2) AS remote_frac
FROM salaries

--Вивести дані таблиці, додавши колонку 'exp_level_full' з повною назвою рівнів 
--досвіду працівників відповідно до колонки exp_level. Визначення: Entry-level 
--(EN), Mid-level (MI), Senior-level (SE), Executive-level (EX)
SELECT 
	year
	, exp_level
	, job_title
	, CASE 
	WHEN exp_level = 'EN' THEN 'Entry-level'
	WHEN exp_level = 'MI' THEN 'Mid-level'
	WHEN exp_level = 'SE' THEN 'Senior-level'
	WHEN exp_level = 'EX' THEN 'Executive-level'
	END AS exp_level_full
FROM salaries
LIMIT 20;

--Додати колонку "salary_category', яка буде відображати різні категорії 
--заробітних плат відповідно до їх значення в колонці 'salary_in_usd'. 
--Визначення: з/п менша за 20 000 - Категорія 1, з/п менша за 50 000 - 
--Категорія 2, з/п менша за 100 000 - Категорія 3, з/п більша за 100 000 - 
--Категорія 4
SELECT 
	year
	, job_title
	, salary_in_usd
	, CASE 
	WHEN salary_in_usd < 20000 THEN 'Category 1'
	WHEN salary_in_usd < 50000 THEN 'Category 2'
	WHEN salary_in_usd < 100000 THEN 'Category 3'
	ELSE 'Category 4'
	END AS salary_category
FROM salaries
LIMIT 20;

--Дослідити всі колонки на наявність відсутніх значень, порівнявши кількість рядків
--таблиці з кількістю значень відповідної колонки
SELECT 
	COUNT(*)
	, COUNT(salary_in_usd)
	, COUNT(emp_location)
	, COUNT(remote_ratio)
	, COUNT(comp_location)
	, COUNT(comp_size)
FROM salaries;

--------------------------------------------------------------------------
-- 3 lesson 
--------------------------------------------------------------------------
--Порахувати кількість працівників в таблиці, які в 2023 році працюють на 
--компанії розміру "М" і отримують з/п вищу за $100 000
SELECT
	COUNT(*)
FROM salaries
WHERE 
	year = 2023
	AND comp_size = 'M'
	AND salary_in_usd > 100000
;

--Вивести всіх співробітників, які в 2023 отримували з/п більшу за $300тис
SELECT
	exp_level
	, job_title
	, salary_in_usd
	, emp_location
FROM salaries
WHERE 
	year = 2023
	AND salary_in_usd > 300000
;

--Вивести всіх співробітників, які в 2023 отримували з/п більшу за $300тис. 
--та не працювали в великих компаніях
SELECT
	exp_level
	, job_title
	, salary_in_usd
	, comp_size
FROM salaries
WHERE 
	year = 2023
	AND salary_in_usd > 300000
	AND comp_size <> 'L'
;

--Чи є співробітники, які працювали на Українську компанію повністю віддалено?
SELECT
	  job_title
	, remote_ratio
	, emp_location
	, comp_location
FROM salaries
WHERE 
	comp_location = 'UA'
	AND remote_ratio = 100
;

--Вивести всіх співробітників, які в 2023 році працюючи в Німеччині 
--(comp_location = 'DE') отримували з/п більшу за $100тис
SELECT
	  job_title
	, salary_in_usd
	, comp_location
FROM salaries
WHERE 
	year = 2023
	AND comp_location = 'DE'
	AND salary_in_usd > 100000
;

--Доопрацювати попередній запит: Вивести з результатів тільки ТОП 5 співробітників 
--за рівнем з/п
SELECT
	  job_title
	, salary_in_usd
	, comp_location
FROM salaries
WHERE 
	year = 2023
	AND comp_location = 'DE'
	AND salary_in_usd > 100000
ORDER BY salary_in_usd DESC
LIMIT 5;

--Додати в попередню таблицю окрім спеціалістів з Німеччини спеціалістів з Канади (CA)
SELECT
	  job_title
	, salary_in_usd
	, comp_location
FROM salaries
WHERE 
	year = 2023
	AND comp_location IN ('DE', 'CA')
	AND salary_in_usd > 100000
ORDER BY salary_in_usd DESC
LIMIT 5;

--Надати перелік країн, в яких в 2021 році спеціалісти "ML Engineer" та "Data Scientist"
--отримувати з/п в діапазоні між $50тис і $100тис
SELECT
	 comp_location
	 , year
	 , job_title
	 , salary_in_usd
FROM salaries
WHERE 
	year = 2021
	AND job_title IN ('ML Engineer', 'Data Scientist')
	AND salary_in_usd BETWEEN 50000 AND 100000
;

/* Порахувати кількість спеціалістів, які працюючи в середніх компаніях (comp_size = M) 
та в великих компаніях (comp_size = L) працювали віддалено (remote_ratio=100 або '
remote_ratio=50)*/ 
SELECT
	 COUNT(*)
FROM salaries
WHERE 
	comp_size IN ('M', 'L')
	AND remote_ratio <> 0
;

--Вивести кількість країн, які починаються на "С"
SELECT 
	 COUNT(DISTINCT comp_location)
FROM salaries 
WHERE 
	comp_location LIKE ('C%')
;

--Вивести професії, назва яких не складається з трьох слів
/*SELECT 
	DISTINCT job_title         working wrong for 4+ words in job title
FROM salaries 
WHERE 
	job_title NOT LIKE ('% % %')
;*/

SELECT 
	DISTINCT job_title 
FROM salaries
WHERE 
	LENGTH (job_title) - LENGTH(REPLACE(job_title,' ','')) != 2
GROUP BY 1;

/* Для кожного року навести дані щодо середньої заробітної плати та кількості 
спеціалістів. Результат експортувати в .csv файл, імпортувати файл в Power BI 
і побудувати доречну візуалізацію отриманих даних */
SELECT 
	year
	, ROUND(AVG(salary_in_usd), 2) AS avg_salary
	, COUNT(*)
FROM salaries 
GROUP BY year;

/* Для кожної професії та відповідного рівня досвіду навести:
- кількість в таблиці
- середню заробітну плату */
SELECT 
	job_title
	, COUNT(*) AS job_title_count
	, ROUND(AVG(salary_in_usd), 2) AS avg_salary
FROM salaries
GROUP BY job_title;

--Для професій, зо зустрічаються лише 1 (або 2) раз, навести заробітну плату
SELECT 
	job_title
	, COUNT(*) AS job_title_count
	, ROUND(AVG(salary_in_usd), 2) AS avg_salary
FROM salaries
GROUP BY job_title
HAVING COUNT(*) <= 2;

--Вивести всіх спеціалістів, в яких з/п вище середньої в таблиці
SELECT 
	 job_title
	, salary_in_usd
	, (SELECT ROUND(AVG(salary_in_usd)) FROM salaries) AS avg_salary
FROM salaries
WHERE 
	salary_in_usd > (SELECT AVG(salary_in_usd) FROM salaries);

/* Вивести всіх спеціалістів, які живуть в країнах, де середня з/п вища 
за середню серед усіх країн.*/
SELECT 
	 job_title
	, emp_location
FROM salaries
WHERE 
	emp_location IN (
		SELECT 
			 comp_location
		FROM salaries
		GROUP BY comp_location
		HAVING AVG(salary_in_usd) > (SELECT AVG(salary_in_usd) FROM salaries)
	);

--Знайти мінімальну заробітну плату серед максимальних з/п по країнах
-- 1. максимальних з/п по країнах в 2023 році
-- 2. Знайти мінімальну з/п
SELECT MIN(t.max_salary) AS min_max_salary
FROM (
	SELECT MAX(salary_in_usd) as max_salary
	FROM salaries 
	WHERE year = 2023
	GROUP BY comp_location
) AS t;

SELECT 
	MAX(salary_in_usd) AS min_max_salary
FROM salaries
WHERE
	year = 2023
GROUP BY comp_location
ORDER BY min_max_salary ASC
LIMIT 1;

/* По кожній професії вивести різницю між середньою з/п та максимальною з/п 
усіх спеціалістів */т
SELECT 
	job_title
	, ROUND(AVG(salary_in_usd)) -
	(
		SELECT MAX(salary_in_usd) 
		FROM salaries
	) AS diff
FROM salaries
GROUP BY job_title;

--Вивести дані по співробітнику, який отримує другу по розміру з/п в таблиці
SELECT *  
FROM salaries 
WHERE salary_in_usd <>  
	(	
		SELECT MAX(salary_in_usd) 
		FROM salaries
	)
ORDER BY salary_in_usd DESC 
LIMIT 1;

SELECT *  
FROM salaries 
ORDER BY salary_in_usd DESC
LIMIT 1 OFFSET 1;


