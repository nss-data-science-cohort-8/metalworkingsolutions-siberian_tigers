


library(shiny)
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
library(shinythemes)
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
  head(9) |>
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


ggplot_object <- LeftJoined_YMDseries_TopNParts |>
  ggplot( aes(x=Production_Due_Date_DateTimeFormat, y=total_quantity_for_manufactured_part)) +
  geom_line(data = LeftJoined_YMDseries_TopNParts |> dplyr::select(-PartID_LongDescription), aes(group=PartID_LongDescription2), color="grey", linewidth=0.5, alpha=0.5) +
  geom_point( aes(color=PartID_LongDescription), color="#69b3a2" ) +
  geom_line( aes(color=PartID_LongDescription), color="#69b3a2", linewidth=0.15 ) +
  scale_color_viridis(discrete = TRUE) +
  theme_ipsum() +
  theme(
    legend.position="none",
    plot.title = element_text(size=14),
    panel.grid = element_blank()
  ) +
  ggtitle("Quantity of Parts Ordered Over Time") +
  facet_wrap(~factor(PartID_LongDescription, levels=c(TopN_Highly_InDemand_Parts_ID_y_LongDescription)))

ggplotly(ggplot_object)



metalworking <- read_csv('data/ms.csv')

revenue_data <- metalworking |> 
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
    mutate(rev_tooltip = paste(
      'Part Id: ', part_id, '\n', 
      'Quantity Shipped: ', comma(total_quantity_shipped), '\n', 
      'Revenue per Est Prod Hour: $', round(estimated_revenue_per_hour, 2), '\n', 
      'Total Revenue: $', comma(total_revenue)
    ))

