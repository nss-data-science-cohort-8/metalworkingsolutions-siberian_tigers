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

SELECT 
	SUM(smp_freight_subtotal)
	,SUM(smp_freight_subtotal_foreign)
	,SUM(smp_freight_total)
	,SUM(smp_freight_total_foreign)
	,SUM(smp_shipment_subtotal)
	,SUM(smp_shipment_subtotal_foreign)
	,SUM(smp_shipment_total)
	,SUM(smp_shipment_total_foreign)
	,SUM(smp_weight_subtotal)
	,SUM(smp_weight_total)
FROM shipments
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

-- Full Answer!!
WITH parts_jobs AS(
SELECT
	imp_long_description_text
	,jmp_part_id
	,COUNT(jmp_job_id) AS n_of_jobs
FROM jobs a
FULL JOIN parts b
	ON a.jmp_part_id = b.imp_part_id
	GROUP BY 1,2),
job_ops_count AS(
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
	,COALESCE(total_hours, twenty_three, twenty_four) AS hours
FROM job_ops_count
ORDER BY 2 DESC
),
join_cte AS(
SELECT
	jmo_job_id
	,hours
	,b.jmp_part_id
	,c.imp_long_description_text
	,n_of_jobs
FROM full_hours a
JOIN jobs b
	ON a.jmo_job_id = b.jmp_job_id
JOIN parts c
	ON b.jmp_part_id = c.imp_part_id
JOIN parts_jobs d
	ON c.imp_part_id = d.jmp_part_id
ORDER BY 2 DESC)
SELECT 
	imp_long_description_text
	,jmp_part_id
	,SUM(hours) AS production_hours
	,n_of_jobs
FROM join_cte
GROUP BY imp_long_description_text, jmp_part_id, n_of_jobs
ORDER BY 3 DESC;


/* Q2b. How have the parts produced changed over time? 
Are there any trends? Are there parts that were prominent in 2023
but are no longer being produced or are being produced at much lower 
volumes in 2024? Have any new parts become more commonly produced 
over time? */

SELECT 
	j.jmp_job_id, 
	j.jmp_production_due_date, 
	j.jmp_part_id, 
	j.jmp_part_short_description, 
	j.jmp_part_long_description_text, 
	j.jmp_order_quantity, 
	SUM(j.jmp_order_quantity) OVER(PARTITION BY j.jmp_part_long_description_text) AS Total_Quantity_For_Manufactured_Part
FROM jobs AS j
ORDER BY Total_Quantity_For_Manufactured_Part DESC, j.jmp_part_id ASC, j.jmp_production_due_date ASC
;

SELECT 	
	j.jmp_production_due_date, 
	j.jmp_part_id, 
	j.jmp_part_long_description_text, 
	SUM(j.jmp_order_quantity)  AS Total_Quantity_For_Manufactured_Part
FROM jobs AS j
GROUP BY j.jmp_production_due_date, j.jmp_part_id, j.jmp_part_long_description_text
ORDER BY Total_Quantity_For_Manufactured_Part DESC, j.jmp_part_id ASC, j.jmp_production_due_date ASC
;

