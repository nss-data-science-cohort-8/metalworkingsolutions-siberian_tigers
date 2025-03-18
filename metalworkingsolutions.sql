/*
# Metalworking Solutions

Metalworking Solutions is a sheet metal fabricator based in Chattanooga, Tennessee. 
Established in 2006, the company offers laser cutting, punching, bending, welding, finishing, and delivery services and ships over 2 million parts annually. 

You've been provided a dataset of jobs since the beginning of 2023.

A few tips for navigating the database: Each job can have multiple job operations in the job_operations_2023/job_operations_2024 table. 
You can connect the jobs to the job_operations. The jmp_job_id references jmo_job_id in the job_operations_2023/job_operations_2024 tables.  
Jobs can be connected to sales orders through the sales_order_job_links table.  

For your project, your group will be responsible for one of the following sets of questions. Construct an R Shiny app to show your findings.

2. Analyze parts. The part can be identified by the jmp_part_id from the jobs table or the jmp_part_id from the job_operations_2023/job_operations_2024 tables. Here are some questions to get started:    
    a. Break down parts by volume of jobs. Which parts are making up the largest volume of jobs? 
	Which ones are taking the largest amount of production hours (based on the jmo_actual_production_hours in the job_operations tables)?  
    b. How have the parts produced changed over time? Are there any trends? 
	Are there parts that were prominent in 2023 but are no longer being produced or are being produced at much lower volumes in 2024? 
	Have any new parts become more commonly produced over time?  
    c. Are there parts that frequently exceed their planned production hours 
	(determined by comparing the jmo_estimated_production_hours to the jmo_actual_production_hours in the job_operations tables)?  
    d. Are the most high-volume parts also ones that are generating the most revenue per production hour?  
*/

WITH job_ops_parts AS (
	SELECT jmo_part_id, jmo_estimated_production_hours, jmo_completed_production_hours
	FROM job_operations_2023
	WHERE jmo_part_id IS NOT NULL AND jmo_completed_production_hours <> 0 AND jmo_estimated_production_hours <> 0
	UNION ALL
	SELECT jmo_part_id, jmo_estimated_production_hours, jmo_completed_production_hours
	FROM job_operations_2024
	WHERE jmo_part_id IS NOT NULL AND jmo_completed_production_hours <> 0 AND jmo_estimated_production_hours <> 0
	)
SELECT 
	jmo_part_id
	, COUNT(jmo_part_id)
	, ROUND(AVG(jmo_completed_production_hours - jmo_estimated_production_hours)::numeric,2) AS avg_diff
FROM job_ops_parts
WHERE jmo_completed_production_hours - jmo_estimated_production_hours <> 0
GROUP BY jmo_part_id
ORDER BY avg_diff DESC;

-- actual vs completed production hours

-- culling uninteresting columns
SELECT *
FROM job_operations_2023

SELECT jmo_created_date, COUNT(jmo_job_id)
FROM job_operations_2023
GROUP BY jmo_created_date

SELECT 
	jmo_job_id
	, jmo_job_assembly_id
	, jmo_job_operation_id
	, jmo_operation_type
	, jmo_plant_id
	, jmo_work_center_id
	, jmo_process_id
	, jmo_process_short_description
	, jmo_quantity_per_assembly
	, jmo_queue_time
	, jmo_setup_hours
	, jmo_production_standard
	, jmo_standard_factor
	, jmo_setup_rate
	, jmo_production_rate
	, jmo_overhead_rate
	, jmo_operation_quantity
	, jmo_quantity_complete
	, jmo_setup_percent_complete
	, jmo_actual_setup_hours
	, jmo_actual_production_hours
	, jmo_quantity_to_inspect
	, jmo_overlap_operation_id
	, jmo_quantity_to_return
	, jmo_move_time
	, jmo_setup_complete
	, jmo_production_complete
	, jmo_overlap_offset_time
	, jmo_part_revision_id
	, jmo_unit_of_measure --'EA' or null
	, jmo_supplier_organization_id
	, jmo_purchase_order_id
	, jmo_estimated_unit_cost
	, jmo_calculated_unit_cost
	, jmo_start_date
	, jmo_due_date
	, jmo_start_hour -- each department / job is supposed to scan in
	, jmo_due_hour --ditto above
	, jmo_estimated_production_hours
	, jmo_completed_setup_hours
	, jmo_completed_production_hours
--	, jmo_sfemessage_text -- some silly messages in there
	, jmo_created_date
FROM job_operations_2023

SELECT *
FROM job_operations_2023
WHERE jmo_estimated_unit_cost <> jmo_calculated_unit_cost
	AND jmo_estimated_unit_cost > 0
	AND jmo_calculated_unit_cost > 0

--job ops has close date (when finished cutting) but if someone forgets to close jobs, the system will not auto-complete 
--> shipments as ultimate completetion
-- no inventory build-up (ships as completes)
-- jobs >
-- 10 = laser (cut)
-- 20 = wrap/pack (for shipping)
-- production standard number of TH/SP/etc (total hours, seconds per piece)
-- estimated production hours based off of that, so 25 SP * 2500 quant. = 17.36 -> assume used in quotes
-- shipments = revenue
-- jmo_estimated_unit_cost includes machine setup time (.25 = 15mins)
-- operation quantity = what was ordered
-- quantity complete = what was made

WITH all_jobs AS (
	SELECT jmo_job_id, jmo_part_id
	FROM job_operations_2023
	UNION ALL
	SELECT jmo_job_id, jmo_part_id
	FROM job_operations_2024
	)
SELECT *
FROM all_jobs
WHERE jmo_job_id = '1000%'

SELECT *
FROM parts
WHERE imp_part_id = 'M030-0008'

SELECT *
FROM jobs