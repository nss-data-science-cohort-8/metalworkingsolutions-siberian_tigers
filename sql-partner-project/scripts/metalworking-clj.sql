-- Metal working solutions query

SELECT * 
FROM jobs
ORDER BY jmp_job_id

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

SELECT omp_created_date, omp_order_date
FROM sales_orders
INNER JOIN jobs
	ON ;

SELECT *
FROM sales_order_job_links
LIMIT 25;

SELECT smp_created_date, smp_ship_date
FROM shipments
WHERE smp_created_date < smp_ship_date;

SELECT 
	smp_created_date
	,smp_ship_date
	,sml_created_date
	,sml_job_id
FROM shipment_lines
INNER JOIN shipments
	ON sml_shipment_id = smp_shipment_id
INNER JOIN jobs
	ON jmp_job_id = sml_job_id;

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

SELECT 
	sml_job_quantity_shipped
	,jmp_order_quantity
	,sml_job_id
	,sml_extended_price_base
	,jmp_part_id
	,sml_created_date
	,jmp_created_date
	,sml_shipped_complete
FROM shipment_lines
INNER JOIN jobs
	ON sml_part_id = jmp_part_id
	AND sml_job_id = jmp_job_id
ORDER BY jmp_job_id, jmp_part_id, sml_created_date;

SELECT *
FROM shipment_lines;

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
	,SUM(a.jmo_estimated_production_hours) AS twenty_four
	,SUM(b.jmo_estimated_production_hours) AS twenty_three
	,(SUM(a.jmo_estimated_production_hours) + SUM(b.jmo_estimated_production_hours)) AS total_estimated_hours
	,SUM(a.jmo_completed_production_hours) AS four_complete
	,SUM(b.jmo_completed_production_hours) AS three_complete
	,(SUM(a.jmo_completed_production_hours) + SUM(b.jmo_completed_production_hours)) AS total_complete_hours
FROM job_operations_2024 a
FULL JOIN job_operations_2023 b
	USING(jmo_job_id)
GROUP BY jmo_job_id
),
full_hours AS(
SELECT
	jmo_job_id
	,COALESCE(total_estimated_hours, twenty_three, twenty_four) AS estimated_hours
	,COALESCE(total_complete_hours, four_complete, three_complete) AS completed_hours
FROM job_ops_count
),
join_cte AS(
SELECT
	b.jmp_created_date
	,c.imp_created_date
	,jmo_job_id
	,a.estimated_hours
	,a.completed_hours
	,b.jmp_part_id
	,c.imp_long_description_text
	,n_of_jobs
	,b.jmp_closed_date
	,b.jmp_production_due_date
	,b.jmp_order_quantity
FROM full_hours a
JOIN jobs b
	ON a.jmo_job_id = b.jmp_job_id
JOIN parts c
	ON b.jmp_part_id = c.imp_part_id
JOIN parts_jobs d
	ON c.imp_part_id = d.jmp_part_id
),
join_2 AS( 
SELECT
	jmp_created_date
	,jmo_job_id
	,imp_long_description_text
	,jmp_part_id
	,n_of_jobs
	,jmp_closed_date
	,jmp_production_due_date
	,jmp_order_quantity
	,estimated_hours AS estimated_production_hours
	,completed_hours AS completed_production_hours
FROM join_cte
), 
revenue_cte AS (
SELECT
	sml_shipment_id,
	sml_job_id,
	sml_extended_price_base AS revenue,
	SUM(sml_job_quantity_shipped) AS total_quantity_shipped,
	MAX(sml_created_date) AS created_shipment
FROM shipment_lines
GROUP BY 1,2,3
),
another_cte AS (
SELECT
	c.imp_created_date AS part_created,
	a.jmp_created_date AS job_created,
	a.jmp_closed_date AS job_finished,
	b.created_shipment,
	a.jmp_production_due_date AS job_due_date,
	a.estimated_production_hours,
	a.completed_production_hours,
  a.imp_long_description_text AS part_name,
  a.jmp_part_id AS part_id,
  b.sml_job_id AS job_id,
  b.sml_shipment_id,
  a.n_of_jobs AS number_of_jobs_by_part,
  COALESCE(b.revenue, 0) AS total_revenue,
  CASE
	WHEN a.completed_production_hours = 0 THEN 0
	WHEN a.completed_production_hours < 1 THEN COALESCE(b.revenue, 0) * a.completed_production_hours
	ELSE COALESCE(b.revenue, 0) / a.completed_production_hours
	END AS completed_revenue_per_hour,
  CASE
	WHEN a.estimated_production_hours = 0 THEN 0
	WHEN a.estimated_production_hours < 1 THEN COALESCE(b.revenue, 0) * a.estimated_production_hours
	ELSE COALESCE(b.revenue, 0) / a.estimated_production_hours
	END AS estimated_revenue_per_hour,
  a.jmp_order_quantity AS quantity_of_part,
  total_quantity_shipped
FROM join_2 AS a
LEFT JOIN revenue_cte AS b
  ON a.jmo_job_id = b.sml_job_id
INNER JOIN parts c
	ON a.jmp_part_id = c.imp_part_id)
SELECT *
FROM another_cte
WHERE total_quantity_shipped != 0
	AND estimated_revenue_per_hour != 0
	AND completed_revenue_per_hour != 0
ORDER BY job_id;









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

