-- Metal working solutions query

SELECT * 
FROM jobs
ORDER BY jmp_job_id
LIMIT 25;

SELECT *
FROM job_operations_2023
LIMIT 25;

SELECT *
FROM job_operations_2024
WHERE jmo_calculated_unit_cost > 0
LIMIT 25;

SELECT *
FROM parts
LIMIT 25;

SELECT *
FROM part_operations
LIMIT 25;

SELECT *
FROM sales_orders
LIMIT 25;

SELECT *
FROM sales_order_job_links
LIMIT 25;


-- metalworkingsolutions.com
-- What do the acronyms stand for?

/* Question 2a:
Break down parts by volume of jobs. 
Which parts are making up the largest volume of jobs? 
Which ones are taking the largest amount of production hours
(based on the jmo_actual_production_hours in the job_operations tables)? */


/* Use distinct count on the job ids and group by the part id.
Then use a sum of hours over() based on the job ids? */

-- Attempt 1
SELECT
	DISTINCT imp_part_id
	,SUM(jmp_quantity_completed) OVER(PARTITION BY imp_part_id) AS volume
	,jmo_job_id AS id
	,imp_long_description_text AS name
	-- ,SUM(jmo_actual_production_hours) AS hours
FROM job_operations_2024 AS a
LEFT JOIN parts AS b
	ON jmo_part_id = imp_part_id
LEFT JOIN jobs AS c
	ON jmo_job_id = jmp_job_id
WHERE imp_part_id IS NOT NULL
-- ORDER BY hours DESC 
LIMIT 25;



-- Attempt 2
WITH jobs_count AS(
SELECT COUNT(DISTINCT jmp_job_id) AS jobs
FROM jobs
),
job_ops_count AS(
SELECT COUNT(DISTINCT jmo_job_id) AS job_ops
FROM job_operations_2024
FULL JOIN job_operations_2023
	USING(jmo_job_id)
),
parts_count AS(
SELECT COUNT(DISTINCT imp_part_id) AS part_jobs
FROM parts
)

SELECT 
	jobs
	,job_ops
FROM jobs_count
JOIN job_ops_count
ON;



-- Attempt 3
SELECT
	imp_short_description AS short
	,jmp_part_id
	,COUNT(jmp_job_id)
FROM jobs a
FULL JOIN parts b
	ON a.jmp_part_id = b.imp_part_id
GROUP BY 1,2
ORDER BY 3 DESC;

-- Answers part 1 of question


-- next part
WITH job_ops_count AS(
SELECT 
	jmo_job_id
	,SUM(a.jmo_actual_production_hours) AS twenty_four
	,SUM(b.jmo_actual_production_hours) AS twenty_three
	,(SUM(a.jmo_actual_production_hours) + SUM(b.jmo_actual_production_hours)) AS total_hours
FROM job_operations_2024 a
FULL JOIN job_operations_2023 b
	USING(jmo_job_id)
GROUP BY jmo_job_id
ORDER BY twenty_four DESC
),
full_hours AS(
SELECT
	jmo_job_id
	,CASE WHEN total_hours IS NOT NULL THEN total_hours 
	WHEN total_hours IS NULL AND twenty_three IS NULL THEN twenty_four
	ELSE twenty_three END AS hours
FROM job_ops_count
ORDER BY 2 DESC
),
next_CTE AS(
SELECT
	jmo_job_id
	,hours
	,jmp_part_id
	,imp_short_description
FROM full_hours a
JOIN jobs b
	ON a.jmo_job_id = b.jmp_job_id
JOIN parts c
	ON b.jmp_part_id = c.imp_part_id
ORDER BY 2 DESC)
SELECT 
	imp_short_description
	,jmp_part_id
	,SUM(hours)
FROM next_CTE
GROUP BY imp_short_description, jmp_part_id
ORDER BY 3 DESC;



