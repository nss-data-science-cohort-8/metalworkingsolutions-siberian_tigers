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


SELECT jmp_job_id, COUNT(DISTINCT jmp_part_id) FROM jobs
GROUP BY 1
HAVING COUNT(DISTINCT jmp_part_id) > 1;

-- metalworkingsolutions.com
-- What do the acronyms stand for?

/* Question 2a:
Break down parts by volume of jobs. 
Which parts are making up the largest volume of jobs? 
Which ones are taking the largest amount of production hours
(based on the jmo_actual_production_hours in the job_operations tables)? */

-- Complete Query

WITH parts_jobs AS(
SELECT
	b.imp_created_date
	,imp_long_description_text
	,jmp_part_id
	,COUNT(jmp_job_id) AS n_of_jobs
FROM jobs a
FULL JOIN parts b
	ON a.jmp_part_id = b.imp_part_id
	GROUP BY 1,2,3),
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
	c.imp_created_date
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
ORDER BY 2 DESC),
join_2 AS( 
SELECT
	imp_long_description_text
	,jmp_part_id
	,SUM(hours) AS production_hours
	,n_of_jobs
FROM join_cte
GROUP BY 1,2,4
ORDER BY 3 DESC
), 
revenue_cte AS (
SELECT
	sml_part_id AS part_id,
	SUM(sml_extended_price_base) AS revenue
FROM shipment_lines
GROUP BY 1
),
job_dates_quantity AS(
SELECT 
	j.jmp_created_date,
	j.jmp_closed_date,
	j.jmp_production_due_date,
	j.jmp_job_id,
	j.jmp_part_id, 
	j.jmp_part_long_description_text, 
	j.jmp_order_quantity
FROM jobs j
ORDER BY j.jmp_part_id ASC, j.jmp_production_due_date ASC
)
SELECT
	c.imp_created_date AS part_created,
	j.jmp_created_date AS job_created,
	j.jmp_closed_date AS job_finished,
	j.jmp_production_due_date AS job_due_date,
  a.imp_long_description_text AS part_name,
  a.jmp_part_id AS part_id,
  j.jmp_job_id AS job_id,
  a.production_hours,
  a.n_of_jobs AS number_of_jobs_by_part,
  CASE
    WHEN a.production_hours = 0 THEN a.production_hours + a.n_of_jobs 
    ELSE a.production_hours
  END AS hours_used_for_rev,
  COALESCE(b.revenue, 0) AS total_revenue,
  CASE
    WHEN a.production_hours = 0 THEN COALESCE(b.revenue, 0) / (a.production_hours+ a.n_of_jobs)
	WHEN a.production_hours < 1 THEN COALESCE(b.revenue, 0) * a.production_hours
    ELSE COALESCE(b.revenue, 0) / a.production_hours
  END AS revenue_per_hour,
  j.jmp_order_quantity AS quantity_of_part
FROM join_2 AS a
LEFT JOIN revenue_cte AS b
  ON a.jmp_part_id = b.part_id
INNER JOIN parts c
	ON a.jmp_part_id = c.imp_part_id
INNER JOIN job_dates_quantity j
	ON c.imp_part_id = j.jmp_part_id
ORDER BY part_id;









/* Q2b. How have the parts produced changed over time? 
Are there any trends? Are there parts that were prominent in 2023
but are no longer being produced or are being produced at much lower 
volumes in 2024? Have any new parts become more commonly produced 
over time? */

SELECT 
	j.jmp_job_id, 
	j.jmp_production_due_date, 
	j.jmp_part_id,  
	j.jmp_part_long_description_text, 
	j.jmp_order_quantity, 
	SUM(j.jmp_order_quantity) OVER(PARTITION BY j.jmp_part_long_description_text) AS Total_Quantity_For_Manufactured_Part
FROM jobs AS j
ORDER BY Total_Quantity_For_Manufactured_Part DESC, j.jmp_part_id ASC, j.jmp_production_due_date ASC
;

SELECT 
	j.jmp_created_date,
	j.jmp_closed_date,
	j.jmp_production_due_date,
	j.jmp_job_id,
	j.jmp_part_id, 
	j.jmp_part_long_description_text, 
	j.jmp_order_quantity
FROM jobs AS j
ORDER BY j.jmp_part_id ASC, j.jmp_production_due_date ASC
;

