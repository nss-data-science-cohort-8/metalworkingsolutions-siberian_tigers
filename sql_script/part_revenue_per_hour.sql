

-- cavins code to find hours
WITH parts_jobs AS(
SELECT
	imp_short_description
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
	,c.imp_short_description
	,n_of_jobs
FROM full_hours a
JOIN jobs b
	ON a.jmo_job_id = b.jmp_job_id
JOIN parts c
	ON b.jmp_part_id = c.imp_part_id
JOIN parts_jobs d
	ON c.imp_part_id = d.jmp_part_id
ORDER BY 2 DESC
), join_2 AS (
  SELECT 
    imp_short_description
    ,jmp_part_id
    ,SUM(hours) AS production_hours
    ,n_of_jobs
  FROM join_cte
  GROUP BY imp_short_description, jmp_part_id, n_of_jobs
  ORDER BY 3 DESC
  -- revenue code
), revenue_cte AS (
  SELECT
    oml_part_id AS part_id,
    -- using oml_extended_price_base, slightly less than oml_full_extended_price_base for two sales_order_ids, but figured the order had a discount
    SUM(oml_extended_price_base) AS revenue
  FROM sales_order_lines
  GROUP BY 1
)
SELECT 
  a.imp_short_description,
  a.jmp_part_id,
  a.production_hours,
  a.n_of_jobs,
  -- using production_hours, number of jobs to be able to determine revenue per hour. Since multiple ones have no production hours using the number of jobs
  CASE
    WHEN a.production_hours = 0 THEN a.production_hours + a.n_of_jobs 
    ELSE a.production_hours
  END AS hours_used_for_rev,
  COALESCE(b.revenue, 0) AS total_revenue,
  CASE
    WHEN a.production_hours = 0 THEN COALESCE(b.revenue, 0) / (a.production_hours+ a.n_of_jobs)
    ELSE COALESCE(b.revenue, 0) / a.production_hours
  END AS revenue_per_hour
FROM join_2 AS a
LEFT JOIN revenue_cte AS b
  ON a.jmp_part_id = b.part_id
GROUP BY 1, 2, 3, 4, 5, 6
;







