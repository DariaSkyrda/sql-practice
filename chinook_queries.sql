SELECT 'Customer' AS role, Email
FROM Customer c 
UNION --ALL
SELECT 'Employee' AS role, Email
FROM Employee e;


SELECT BillingCountry AS Country
FROM Invoice i  
EXCEPT 
--UNION ALL 
--INTERSECT 
SELECT Country 
FROM Customer c;


--Compare artists by total number of tracks sold and total sales amount
SELECT 
	art.Name
	, COALESCE(SUM(il.Quantity), 0) AS total_amount              
	, COALESCE(SUM(il.Quantity * il.UnitPrice), 0) AS total_sum
FROM Artist art 
LEFT JOIN Album a ON art.ArtistId = a.ArtistId 
LEFT JOIN Track t ON a.AlbumId = t.AlbumId 
LEFT JOIN InvoiceLine il ON t.TrackId = il.TrackId 
GROUP BY art.ArtistId, art.Name 
ORDER BY total_amount DESC, total_sum DESC;


--Top 3 employees by total sales for each year
SELECT 
	e.EmployeeId 
	, CONCAT(e.LastName, ' ', e.FirstName ) AS full_name
	, SUM(i.Total) AS total
FROM Employee e
LEFT JOIN Customer c ON e.EmployeeId = c.SupportRepId 
LEFT JOIN Invoice i ON c.CustomerId  = i.CustomerId
WHERE strftime('%Y', i.InvoiceDate) = '2009' --'2010', '2011'..
GROUP BY e.EmployeeId
ORDER BY total DESC
LIMIT 3;

WITH all_employees AS (
	SELECT 
		strftime('%Y', i.InvoiceDate) AS year
		, CONCAT(e.LastName, ' ', e.FirstName ) AS full_name
		, COALESCE(SUM(i.Total), 0) AS total
		, ROW_NUMBER() OVER (PARTITION BY strftime('%Y', i.InvoiceDate) ORDER BY SUM(i.Total) DESC) AS row_num
	FROM Employee e
	JOIN Customer c ON e.EmployeeId = c.SupportRepId  -- not a left join because if employee not a Sales Support Agent then he/she dont have any customers  
	JOIN Invoice i ON c.CustomerId  = i.CustomerId
	GROUP BY year, e.EmployeeId
)
SELECT *
FROM all_employees
WHERE row_num <= 3
ORDER BY year, row_num;


--Provide information about customers who purchased music tracks within 4 different genres 
SELECT 
	c.CustomerId
	, CONCAT(c.LastName, ' ', c.FirstName ) AS full_name
	, COUNT(DISTINCT g.GenreId) AS amount_genres
FROM InvoiceLine il 
JOIN Track t ON il.TrackId = t.TrackId 
JOIN Genre g ON t.GenreId = g.GenreId
JOIN Invoice i ON il.InvoiceId = i.InvoiceId 
JOIN Customer c ON i.CustomerId = c.CustomerId
GROUP BY c.CustomerId
HAVING amount_genres >= 4;


--Create a list of customers who, as of the last month of sales, have not purchased anything for 1 month, 2 months, or 3 months.
WITH max_date AS (
	SELECT 
		CAST(strftime('%Y', MAX(i.InvoiceDate)) AS INTEGER) AS max_year
		, CAST(strftime('%m', MAX(i.InvoiceDate)) AS INTEGER) AS max_month
	FROM Invoice i
), 
last_purchase AS (
	SELECT 
		c.CustomerId 
		, c.FirstName || ' ' || c.LastName AS full_name
		, MAX(i.InvoiceDate) AS last_date
	FROM Customer c 
	JOIN Invoice i ON c.CustomerId = i.CustomerId 
	GROUP BY c.CustomerId 
),
inactive AS (
	SELECT   
		lp.CustomerId 
		, lp.full_name 
		, (m.max_year - CAST(strftime('%Y', lp.last_date) AS INTEGER)) * 12 + (m.max_month - CAST(strftime('%m', lp.last_date) AS INTEGER)) AS month_inactive
	FROM last_purchase lp
	CROSS JOIN max_date m
)
SELECT *
FROM inactive
WHERE month_inactive IN (1,2,3)
ORDER BY month_inactive DESC, CustomerId;


--Form the most popular genre from among customers' first purchases 
WITH first_buy AS (
	SELECT i.InvoiceId  AS id_first_invoice
	FROM Invoice i 
	GROUP BY i.CustomerId 
	HAVING i.InvoiceDate = MIN(i.InvoiceDate)
)
SELECT g.Name
FROM first_buy fb 
JOIN InvoiceLine il ON fb.id_first_invoice = il.InvoiceId 
JOIN Track t ON il.TrackId = t.TrackId 
JOIN Genre g ON t.GenreId = g.GenreId
GROUP BY g.GenreId 
ORDER BY COUNT(*) DESC
LIMIT 1;


--Show the sales dynamics of music tracks over the last 3 years 
/*general analysis of sales dynamics – the volume of goods sold or 
 * services rendered during the reporting period is divided by the total sales volume for the previous period; 
 * if the indicator is greater than 1, sales dynamics are considered positive, 
 * less than 1 – negative;*/
WITH years AS(
	SELECT 
		STRFTIME('%Y', i.InvoiceDate ) AS year
		, SUM(i.Total) AS total_sum
		, SUM(il.Quantity) AS total_amount
	FROM Invoice i 
	JOIN InvoiceLine il ON il.InvoiceId = i.InvoiceId 
	GROUP BY year	
)
SELECT
	y1.year
	, COALESCE (ROUND(y1.total_sum / y2.total_sum, 3), 0) AS sum_koff 
	, COALESCE (ROUND((y1.total_amount * 1.0) / y2.total_amount, 3), 0) AS amount_koff 
FROM years y1
LEFT JOIN years y2 ON CAST(y1.year AS INTEGER) - 1 = CAST(y2.year AS INTEGER)
ORDER BY y1.year DESC
LIMIT 3;


--Investigate the cumulative sales amount for each customer 
SELECT 
	i.InvoiceDate 
	, i.CustomerId 
	, i.Total 
	, SUM(i.Total) OVER(PARTITION BY i.CustomerId ORDER BY i.InvoiceDate) AS cum_sum
FROM Invoice i; 


--Calculate the average invoice 
SELECT ROUND(SUM(i.Total)/COUNT(*), 2) AS avg_sum FROM Invoice i;

SELECT ROUND(AVG(i.Total), 2) AS avg_sum FROM Invoice i;

SELECT 
    strftime('%Y', InvoiceDate) AS year,
    ROUND(AVG(Total), 2) AS avg_sum
FROM Invoice
GROUP BY year
ORDER BY year;


--Calculate the average total sales amount per customer 
SELECT ROUND(AVG(customer_total), 2) AS avg_sales_per_customer
FROM (
SELECT 
	i.CustomerId, SUM(i.Total) AS customer_total
	FROM Invoice i
	GROUP BY i.CustomerId 
) AS customer_totals;


--Calculate the average length of time between the first purchase and the second purchase
--first
WITH first_buy AS (
	SELECT i.InvoiceDate AS first_date, i.CustomerId AS customerId
	FROM Invoice i 
	GROUP BY i.CustomerId 
	HAVING i.InvoiceDate = MIN(i.InvoiceDate)
)
, second_buy AS (
	SELECT sb.InvoiceDate AS second_date, sb.CustomerId AS customerId
	FROM first_buy fb
	LEFT JOIN Invoice sb ON sb.CustomerId = fb.CustomerId
	AND sb.InvoiceDate <> fb.first_date
	GROUP BY sb.CustomerId 
	HAVING sb.InvoiceDate = MIN(sb.InvoiceDate)
)
SELECT ROUND(AVG(julianday(sb.second_date) - julianday(fb.first_date))) AS avg_first_second_inv
FROM first_buy fb
JOIN second_buy sb ON sb.customerId = fb.customerId;

--second
WITH cte AS (
	SELECT
		i.CustomerId 
		, i.InvoiceDate
		, ROW_NUMBER() OVER(PARTITION BY i.CustomerId ORDER BY i.InvoiceDate) AS day_nmb
	FROM Invoice i
)
SELECT ROUND(AVG(julianday(s_day.InvoiceDate) - julianday(f_day.InvoiceDate))) AS avg_first_second_inv
FROM cte f_day
JOIN cte s_day ON f_day.CustomerId = s_day.CustomerId AND f_day.day_nmb = 1 AND s_day.day_nmb = 2;

--third
WITH cte_d AS (
	SELECT 
		i.InvoiceId 
		, i.CustomerId 
		, i.InvoiceDate 
		, LAG(i.InvoiceDate , 1) OVER(PARTITION BY i.CustomerId ORDER BY i.InvoiceDate) AS date_before
		, ROW_NUMBER() OVER(PARTITION BY i.CustomerId ORDER BY i.InvoiceDate) AS day_nmb
	FROM Invoice i
)
SELECT ROUND(AVG(julianday(InvoiceDate) - julianday(date_before))) AS avg_first_second_inv
FROM cte_d 
WHERE day_nmb = 2;


--table ranking (for each customer, invoice rating by Total)
SELECT 
	i.CustomerId 
	, i.InvoiceId 
	, ROW_NUMBER() OVER(PARTITION BY i.CustomerId ORDER BY i.Total DESC) AS row_nmb
	, RANK() OVER(PARTITION BY i.CustomerId ORDER BY i.Total DESC) AS rank
	, DENSE_RANK() OVER (PARTITION BY i.CustomerId ORDER BY i.Total DESC) AS dense_rank
FROM Invoice i;


--offset relative to the current row
SELECT 
	i.InvoiceId 
	, i.CustomerId 
	, i.InvoiceDate 
	, i.Total 
	, LAG(i.Total, 1) OVER(PARTITION BY i.CustomerId ORDER BY i.InvoiceDate) AS lag_total
	, LAG(i.InvoiceDate , 1) OVER(PARTITION BY i.CustomerId ORDER BY i.InvoiceDate) AS lag_date
	, JULIANDAY(i.InvoiceDate) - JULIANDAY(LAG(i.InvoiceDate , 1) OVER(PARTITION BY i.CustomerId ORDER BY i.InvoiceDate)) AS diff_in_days
	, LEAD(i.Total, 1) OVER(PARTITION BY i.CustomerId ORDER BY i.InvoiceDate) AS lead_total
FROM Invoice i
ORDER BY i.CustomerId;

SELECT 
	InvoiceId
	, CustomerId
	, InvoiceDate 
	, Total
	, FIRST_VALUE(Total) OVER(PARTITION BY CustomerId ORDER BY InvoiceDate ASC) AS first_total
	, LAST_VALUE(Total) OVER(PARTITION BY CustomerId ORDER BY InvoiceDate DESC) AS last_total
FROM Invoice;





