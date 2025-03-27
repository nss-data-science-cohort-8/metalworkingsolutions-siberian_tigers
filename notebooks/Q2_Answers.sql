-- EDA:

SELECT table_schema, table_name, column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public'


SELECT *
FROM job_operations_2023;


SELECT *
FROM job_operations_2024;


SELECT *
FROM jobs;



SELECT *
FROM sales_orders;





-- Q2: Analyze parts. The part can be identified by the jmp_part_id from the jobs table or the jmp_part_id from the job_operations_2023/job_operations_2024 tables. Here are some questions to get started:
-- Q2a. Break down parts by volume of jobs. Which parts are making up the largest volume of jobs? Which ones are taking the largest amount of production hours (based on the jmo_actual_production_hours in the job_operations tables)?
-- Q2b. How have the parts produced changed over time? Are there any trends? Are there parts that were prominent in 2023 but are no longer being produced or are being produced at much lower volumes in 2024? Have any new parts become more commonly produced over time?



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



--For Vicki:

SELECT 	
	j.jmp_job_id, 
	jmp_production_due_date, 
	j.jmp_part_id, 
	j.jmp_part_long_description_text, 
	SUM(j.jmp_order_quantity)  AS Total_Quantity_For_Manufactured_Part
FROM jobs AS j
GROUP BY j.jmp_production_due_date, j.jmp_job_id, j.jmp_part_id, j.jmp_part_long_description_text
ORDER BY Total_Quantity_For_Manufactured_Part DESC, j.jmp_part_id ASC, j.jmp_production_due_date ASC
;





-- Q2c. Are there parts that frequently exceed their planned production hours (determined by comparing the jmo_estimated_production_hours to the jmo_actual_production_hours in the job_operations tables)?
-- Q2d. Are the most high-volume parts also ones that are generating the most revenue per production hour?






