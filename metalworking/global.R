library(shiny)
library(shinythemes)
library(tidyverse)
library(glue)
library(DT)
library(ggplot2)
library(dplyr)
library(lubridate)
library(corrr)
library(haven)
library(lme4) 
library(broom.mixed) 
library(ggrepel)
library(ggpubr)
library(ggpmisc) 
library(hrbrthemes)
library(viridis)
library(lubridate) 
library(kableExtra)
options(knitr.table.format = "html")
library(viridis) 
library(plotly)
library(nlme)
library(forcats)
library(plotly)
library(scales)


# Q2b


Q2b_Data <- read_csv('./data/data-1741913998693_GroupedByDate_n_PartID.csv')
Q2b_Data <- Q2b_Data |> unite("PartID_LongDescription", jmp_part_id:jmp_part_long_description_text, sep = " Description: ", remove = FALSE)


Q2b_Data <- Q2b_Data |> 
  mutate(Production_Due_Date_DateTimeFormat = as_datetime(Q2b_Data$jmp_production_due_date, tz = "US/Eastern", format = NULL)) |>   
  select(jmp_part_id, PartID_LongDescription, total_quantity_for_manufactured_part, Production_Due_Date_DateTimeFormat) |>      
  arrange(Production_Due_Date_DateTimeFormat, jmp_part_id)


TopN_Highly_InDemand_Parts_ID_y_LongDescription <- Q2b_Data |> 
  group_by(PartID_LongDescription) |> 
  summarise(Sum_of_Total_Quantity_for_Manufactured_Part = sum(total_quantity_for_manufactured_part)) |> 
  arrange(desc(Sum_of_Total_Quantity_for_Manufactured_Part)) |> 
  head(6) |> 
  pull(PartID_LongDescription)


TopN_Highly_InDemand_Parts_ID_y_LongDescription_tibble <- tibble(TopN_Highly_InDemand_Parts_ID_y_LongDescription)


TopN_Highly_InDemand_Parts_data <- Q2b_Data |> filter(PartID_LongDescription %in% c(TopN_Highly_InDemand_Parts_ID_y_LongDescription))  



TopN_Highly_InDemand_Parts_data |>  distinct(Production_Due_Date_DateTimeFormat) |> arrange(Production_Due_Date_DateTimeFormat)



YMD_series <- tibble(date = seq(ymd('2022-02-08'), ymd('2025-02-25'), by='1 day'))


CrossJoined_YMDseries_TopNParts <- cross_join(YMD_series, TopN_Highly_InDemand_Parts_ID_y_LongDescription_tibble) |> 
  rename(Production_Due_Date_DateTimeFormat = date, PartID_LongDescription = TopN_Highly_InDemand_Parts_ID_y_LongDescription)


LeftJoined_YMDseries_TopNParts <- left_join(CrossJoined_YMDseries_TopNParts, TopN_Highly_InDemand_Parts_data, by = c('Production_Due_Date_DateTimeFormat', 'PartID_LongDescription')) |>
  replace_na(list(total_quantity_for_manufactured_part = 0))  |>  
  arrange(Production_Due_Date_DateTimeFormat)  


LeftJoined_YMDseries_TopNParts_withDescription <- left_join(LeftJoined_YMDseries_TopNParts, TopN_Highly_InDemand_Parts_data, by = c('Production_Due_Date_DateTimeFormat', 'PartID_LongDescription'))


LeftJoined_YMDseries_TopNParts <- LeftJoined_YMDseries_TopNParts |>
  mutate(PartID_LongDescription2 = PartID_LongDescription)


# ggplot_object <- LeftJoined_YMDseries_TopNParts |>
#   ggplot( aes(x=Production_Due_Date_DateTimeFormat, y=total_quantity_for_manufactured_part)) +
#   geom_line(data = LeftJoined_YMDseries_TopNParts |> dplyr::select(-PartID_LongDescription), aes(group=PartID_LongDescription2), color="grey", linewidth=0.5, alpha=0.5) +
#   geom_point( aes(color=PartID_LongDescription), color="#69b3a2" ) +
#   geom_line( aes(color=PartID_LongDescription), color="#69b3a2", linewidth=0.15 ) +
#   scale_color_viridis(discrete = TRUE) +
#   theme_ipsum() +
#   theme(
#     legend.position="none",
#     plot.title = element_text(size=14),
#     panel.grid = element_blank()
#   ) +
#   ggtitle("Quantity of Parts Ordered Over Time") +
#   facet_wrap(~factor(PartID_LongDescription, levels=c(TopN_Highly_InDemand_Parts_ID_y_LongDescription)))
# 
# ggplotly(ggplot_object)


# Q2a

# complete_data_CSV <- read_csv('./data/completed_table.csv')
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
  # mutate(rev_tooltip = paste(
  #   'Part Id: ', part_id, '\n', 
  #   'Quantity Shipped: ', comma(total_quantity_shipped), '\n', 
  #   'Revenue per Est Production Hr: ', dollar(round(estimated_revenue_per_hour, 2)), '\n', 
  #   'Total Revenue: ', dollar(round(total_revenue), 2)
  # )) |>  
  arrange(desc(estimated_revenue_per_hour)) 

revenue_data_plot <- revenue_data |> 
  mutate(rev_tooltip = paste(
    'Part Id: ', part_id, '\n', 
    'Quantity Shipped: ', comma(total_quantity_shipped), '\n', 
    'Revenue per Est Production Hr: ', dollar(round(estimated_revenue_per_hour, 2)), '\n', 
    'Total Revenue: ', dollar(round(total_revenue), 2)
  )) |>  
  arrange(desc(estimated_revenue_per_hour)) |> 
  filter(total_revenue > 10000)



job_ops <- read.csv('./data/job_ops_23-24.csv')

job_ops <- job_ops |> 
  mutate(hours_diff = completed_production_hours - reestimated_hours, hours_diff_2 = completed_production_hours - est_hours)

hours_ops <- job_ops |>
  filter(completed_production_hours != 0, est_hours != 0) |> 
  group_by(short_description) |> 
  summarise(num_jobs = n(), total_hours = sum(completed_production_hours), avg_hr = mean(completed_production_hours), avg_hr_diff = mean(hours_diff)) |> 
  mutate_if(is.numeric,~round(.,digits=0)) |> 
  arrange(desc(total_hours))

hours_ops_longer <- hours_ops |> 
  select(-c(num_jobs, total_hours)) |> 
  pivot_longer(!short_description, names_to = "measurement", values_to = "hours")

hours_parts <- job_ops |>
  filter(completed_production_hours != 0, reestimated_hours != 0) |> 
  group_by(part_id) |> 
  summarise(num_parts = n(), total_hours = sum(completed_production_hours), avg_hr = mean(completed_production_hours), avg_hr_diff = mean(hours_diff)) |> 
  mutate_if(is.numeric,~round(.,digits=0)) |> 
  arrange(desc(total_hours))

hours_parts <- hours_parts |> 
  filter(avg_hr_diff != 0, num_parts >2)
