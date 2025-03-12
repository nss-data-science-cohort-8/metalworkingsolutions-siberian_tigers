-- Metal working solutions query

SELECT * 
FROM jobs
LIMIT 25;

SELECT *
FROM job_operations_2023
LIMIT 25;

SELECT *
FROM job_operations_2024
LIMIT 25;

SELECT *
FROM parts
LIMIT 25;

SELECT *
FROM part_operations
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


