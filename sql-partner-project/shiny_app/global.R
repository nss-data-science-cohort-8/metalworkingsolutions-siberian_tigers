library(shiny)
library(shinythemes)
library(tidyverse)
library(glue)
library(DT)
library(lubridate)
library(hrbrthemes)
library(kableExtra)
options(knitr.table.format = "html")
library(viridis) 
library(plotly)
library(forcats)
library(plotly)
library(scales)


# Q2b

TopN_Highly_InDemand_Parts_ID_y_LongDescription <- readRDS('./data/TopN_Highly_InDemand_Parts_ID_y_LongDescription.rds')

TopN_Highly_InDemand_Parts_ID_y_LongDescription_2 <- readRDS('./data/TopN_Highly_InDemand_Parts_ID_y_LongDescription_2.rds')

LeftJoined_YMDseries_TopNParts <- readRDS('./data/LeftJoined_YMDseries_TopNParts.rds')


# Q2a

parts_table <- readRDS('./data/parts_table.Rds')

parts_table_top_10 <- readRDS('./data/parts_table_top_10.Rds')


#Q2d

revenue_data_table <- readRDS('./data/revenue_data.Rds')

complete_data <- readRDS("./data/completed_table.Rds")

revenue_data <- complete_data |> 
  # filter(!part_id %in% c('Y002-0604', 'Y002-0605', 'Y002-0631', 'Y002-0647')) |> 
  group_by(part_id, part_name) |> 
  summarize(
    total_quantity_shipped = sum(total_quantity_shipped, na.rm = TRUE),
    est_prod_hours = sum(estimated_production_hours, na.rm = TRUE),
    total_revenue = sum(total_revenue, na.rm = TRUE),
    estimated_revenue_per_hour = ifelse(
      est_prod_hours == 0 | total_revenue == 0, 0,  
      ifelse(est_prod_hours < 1, est_prod_hours * total_revenue, 
             total_revenue / est_prod_hours) 
    ),
    number_of_jobs = min(number_of_jobs_by_part, na.rm = TRUE)
  )

revenue_data <- revenue_data |> 
  arrange(desc(estimated_revenue_per_hour)) 

revenue_data_plot <- revenue_data |> 
  mutate(rev_tooltip = paste(
    'Part Id: ', part_id, '\n', 
    'Quantity Shipped: ', comma(total_quantity_shipped), '\n', 
    'Total Revenue: ', dollar(round(total_revenue), 2), '\n',  
    'Est Prod Hours:', comma(est_prod_hours, accuracy = 0.01), '\n', 
    'Revenue per Est Production Hr: ', dollar(round(estimated_revenue_per_hour, 2))
  )) |>  
  arrange(desc(estimated_revenue_per_hour)) |> 
  filter(total_quantity_shipped > 1000)
#Q2c

hours_ops <- readRDS('./data/hours_ops.Rds')

hours_ops_longer <- readRDS('./data/hours_ops_longer.Rds')

hours_parts <- readRDS('./data/hours_parts.Rds')



#for Vicki's graph

my_colors <- c("#2F4942", 
               "#42675D", 
               '#548377',
               '#669F91',
               '#78BBAA',
               '#8AD7C4')

repeated_colors <- rep(my_colors, 52)


