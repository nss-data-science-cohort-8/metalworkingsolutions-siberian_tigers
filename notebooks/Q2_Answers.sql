-- EDA:


-- Q2: Analyze parts. The part can be identified by the jmp_part_id from the jobs table or the jmp_part_id from the job_operations_2023/job_operations_2024 tables. Here are some questions to get started:
-- Q2a. Break down parts by volume of jobs. Which parts are making up the largest volume of jobs? Which ones are taking the largest amount of production hours (based on the jmo_actual_production_hours in the job_operations tables)?
-- Q2b. How have the parts produced changed over time? Are there any trends? Are there parts that were prominent in 2023 but are no longer being produced or are being produced at much lower volumes in 2024? Have any new parts become more commonly produced over time?
-- Q2c. Are there parts that frequently exceed their planned production hours (determined by comparing the jmo_estimated_production_hours to the jmo_actual_production_hours in the job_operations tables)?
-- Q2d. Are the most high-volume parts also ones that are generating the most revenue per production hour?