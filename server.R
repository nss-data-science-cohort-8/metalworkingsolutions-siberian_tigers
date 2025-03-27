

function(input, output, session) {
  
  # updateSelectizeInput(
  #   session, 
  #   'Chosen_Firm', 
  #   choices = (Firm_Industry_Random_Effect_Coeff_Desc_StatSig_y_StatInsig$level), 
  #   selected = 'Costco Wholesale Corp', 
  #   server = TRUE)
  
  # plot_data_func <- reactive({
  #   
  #   plot_data <- LeftJoined_YMDseries_TopNParts
  #   
  #   return(plot_data)    
  #   
  # })
  
  
  output$distPlot_Q2b <- renderPlotly({
    
    title <- glue("Trend in Quantity Ordered for Most High Volume Parts")
    
    # plot_data_func() |>  
    
      TopVol_Parts <- ggplot(LeftJoined_YMDseries_TopNParts, aes(x=Production_Due_Date_DateTimeFormat, y=total_quantity_for_manufactured_part)) +
      geom_line(data = LeftJoined_YMDseries_TopNParts |> dplyr::select(-PartID_LongDescription), aes(group=PartID_LongDescription2), color="grey", linewidth=0.5, alpha=0.5) +
      geom_point( aes(color=PartID_LongDescription), color="#69b3a2" ) +
      labs(title = 'Seasonal Trend in Quantity Ordered', 
           x = 'Year', 
           y = 'Quantity Ordered per Day') + 
      geom_line( aes(color=PartID_LongDescription), color="#69b3a2", linewidth=0.15 ) +
      scale_color_viridis(discrete = TRUE) +
      theme_ipsum() +
      theme(
        legend.position="none",
        plot.title = element_text(size=24),
        panel.grid = element_blank(),
        axis.text.y=element_text(size = 17, face = "bold"), 
        axis.text.x=element_text(size = 17, face = "bold", angle = 60), 
        axis.title.x=element_blank(), 
        axis.title.y=element_text(size = 20, face = "bold")
      ) +
      ggtitle("Trend in Quantity Ordered") +
      facet_wrap(~factor(PartID_LongDescription, levels=c(TopN_Highly_InDemand_Parts_ID_y_LongDescription)))
    
    
    ggp_build_TopVol_Parts <- plotly_build(TopVol_Parts)
    ggp_build_TopVol_Parts$layout$height = 2200
    ggp_build_TopVol_Parts$layout$width = 2600
    ggp_build_TopVol_Parts
    
  })
  
  output$q2bTable  <-  renderDataTable(TopN_Highly_InDemand_Parts_ID_y_LongDescription_2)
  
  #Q2a
  
  
  output$parts_table <- renderDataTable(datatable(complete_data |> 
                                                    group_by(part_id, part_name) |> 
                                                    summarize(jobs = max(number_of_jobs_by_part),
                                                              `Estimated Hours` = round(sum(estimated_production_hours), 2),
                                                              Revenue = comma(sum(total_revenue), accuracy = 0.01),
                                                              `Estimated Hours Per Job` = round((sum(estimated_production_hours) / min(number_of_jobs_by_part)), 2), 
                                                              `Estimated Revenue per Job` = round(sum(total_revenue) / min(number_of_jobs_by_part), 2),
                                                              `Revenue per Hour` = round(mean(estimated_revenue_per_hour)), 2) |> 
                                                    rename(`Part ID` = part_id, `Part Name` = part_name) |>
                                                    select(-`2`) |> 
                                                    arrange(desc(jobs)), options = list(displayStart = (input$graph_slide[1] - 1))) 
  )
  
  output$distPlot_Q2a <- renderPlot({
    parts_table_top_10 <- complete_data |> 
      group_by(part_id) |>
      summarize(jobs = min(number_of_jobs_by_part),
                estimated_hours = sum(estimated_production_hours),
                revenue = sum(total_revenue),
                estimated_hours_per_job = (sum(estimated_production_hours) / min(number_of_jobs_by_part)), 
                estimated_revenue_per_job = sum(total_revenue) / min(number_of_jobs_by_part),
                revenue_per_hour = mean(estimated_revenue_per_hour)) |>
      arrange(desc(jobs))
    
    sf <- max(parts_table_top_10[input$graph_slide[1]:(input$graph_slide[1] + 9), ]$jobs)/max(parts_table_top_10[input$graph_slide[1]:(input$graph_slide[1] + 9), ]$estimated_hours)
    
    parts_longer <- parts_table_top_10[input$graph_slide[1]:(input$graph_slide[1] + 9), ] |> 
      mutate(estimated_hours = estimated_hours*sf) |> 
      pivot_longer(names_to = 'y_new', values_to = 'val', jobs:estimated_hours) |> 
      mutate(y_new = factor(y_new, levels = c('jobs', 'estimated_hours')))
    
    subset_to_order <- parts_longer |> 
      filter(y_new == 'jobs')
    subset_to_order$part_id = fct_reorder(subset_to_order$part_id, -subset_to_order$val)
    parts_longer$part_id = factor(parts_longer$part_id, levels = levels(subset_to_order$part_id))
    
    ggplot(parts_longer, aes(x=part_id)) +
      geom_col(aes(y = val, fill = y_new, group = y_new), position=position_dodge(),
               color="black", alpha=.6)  +
      scale_fill_manual(values = c("#69b3a2", "grey")) +
      scale_y_continuous(name = "Number of Jobs",labels = scales::comma,sec.axis = sec_axis(~./sf, name="Estimated Production Hours",
                                                                                            labels = scales::comma))+
      labs(fill='variable')+
      theme_bw()+
      theme(legend.position = 'top',
            plot.title = element_text(size = 24, color='black',face='bold',hjust=0.5),
            axis.text = element_text(size = 21.5, color='black',face='bold'),
            axis.text.x = element_text(size = 17, angle = 90, vjust = 0.5, hjust=1),
            axis.title.y.right = element_text(size = 20, color='grey',face='bold'),
            axis.title.y.left = element_text(size = 20, color='#69b3a2',face='bold'),
            axis.title.x = element_text(size = 21.5, color='brown',face='bold'),
            legend.text = element_text(color='black',face='bold'),
            legend.title = element_text(color='black',face='bold')) +
      xlab('Part ID') +
      ggtitle('Total Job Volume vs. Total Estimated Production Hours')
  })
  
  
  
  
  
  
  
  
output$rev_scatter <- renderPlotly({
  
  rev_plot <- ggplot(revenue_data_plot, 
                     aes(
                       x = total_quantity_shipped, 
                       y = estimated_revenue_per_hour, 
                       size = total_revenue, 
                       color = part_name,
                       text = rev_tooltip)) + 
    geom_point(
      alpha = 0.5,
      show.legend = TRUE
    ) + 
    labs(title = 'Revenue per Estimated Production Hours by Volume Shipped (> 1,000 Units)',
         x = 'Total Quantity Shipped (Log Scale)',
         y = 'Revenue per Est Production Hr (USD/Hr)'
    ) +
    scale_x_log10(
      breaks = c(1000, 2500, 5000, 10000, 15000, 30000, 60000, 100000),
      labels = comma
    ) +
    scale_y_continuous(labels = comma) + 
    theme(legend.position = "none")
  
  ggplotly(rev_plot, tooltip = 'text', height = 600, width = 1200)
  
})

output$rev_table <- renderDT({
  datatable(
    revenue_data |>
      mutate(
        total_quantity_shipped = comma(total_quantity_shipped),  
        est_prod_hours = comma(est_prod_hours),                 
        total_revenue = comma(total_revenue, accuracy = 0.01),  
        estimated_revenue_per_hour = comma(estimated_revenue_per_hour, accuracy = 0.01)
      ) |> 
      select(part_id, 
             part_name,
             total_quantity_shipped, 
             est_prod_hours, 
             total_revenue, 
             estimated_revenue_per_hour, 
             number_of_jobs),
    colnames = c(
      'Part Id',
      'Part Name', 
      'Quantity Shipped', 
      'Total Est Prod Hours', 
      'Total Revenue ($)', 
      'Revenue per Est Prod Hour ($)', 
      'Total Jobs'
    ),
    options = list(
      order = list(list(6, "desc")) 
    )
  )
})

#Q2c
custom_theme = theme(
  title = element_text(size = 20),
  axis.title.x = element_text(size = 18),
  axis.text.x = element_text(size = 16),
  axis.title.y = element_text(size = 18))
  

output$opsTable <- DT::renderDT({
  plot_data <- hours_ops
  
  # if (input$process != "ALL"){
  #   
  #   plot_data <- hours_ops |> 
  #     filter(short_description == input$process)
  # }
  plot_data |> 
    DT::datatable(
      colnames = c("Process" = "short_description", 
                   "Number of Jobs" = "num_jobs", 
                   "Total Hours" = "total_hours", 
                   "Average Hours" = "avg_hr",
                   "Average Difference between Estimated and Actual Hours" = 'avg_hr_diff')
    )
})

output$opsChart <- renderPlot ({
  
  title <- "Average Production Hours and Difference in Hours (Est. vs. Actual) by Process"
  
  plot_data <- hours_ops_longer
  
  # if (input$process != "ALL"){
  #   
  #   plot_data <- hours_ops_longer |> 
  #     filter(short_description == input$process)
  # }
  plot_data |> 
    ggplot(aes(x=factor(short_description, level=c('ZINC_PLATE', 
                                                   'POWDER_COAT', 
                                                   'GALVANIZE', 
                                                   'WELD', 
                                                   'PART_TRANSFER',
                                                   'MACHINE',
                                                   'TURRET_PUNCH',
                                                   'OTHER',
                                                   'PRESS_BRAKE',
                                                   'SAW',
                                                   'LASER',
                                                   'PACK',
                                                   'SET_UP')), 
               y = hours, 
               fill = measurement)) +
    geom_col(color="black", alpha=.6, position='dodge') +
    scale_x_discrete(guide = guide_axis(angle = 90)) +
    theme(legend.title = element_blank()) +
    scale_fill_manual(values = c("#69b3a2", "grey"), labels = c("Avg Total Hrs", "Avg Hrs Diff")) +
    labs(
      title = title,
      x = "Process",
      y = 'Hours'
    ) +
    custom_theme
})

output$partsTable <- DT::renderDT({
  hours_parts |>
    DT::datatable(
      colnames = c("Part ID" = "part_id", 
                   "Number of Parts" = "num_parts", 
                   "Total Hours" = "total_hours", 
                   "Average Hours" = "avg_hr",
                   "Average Difference between Estimated and Actual Hours" = 'avg_hr_diff')
    )
})

output$partsChart <- renderPlot ({
  
  title <- "Average Difference between Estimated and Actual Production Hours"
  
  hours_parts |> 
    ggplot(aes(x=factor(part_id, level=c('Y002-0562',
                                         'C057-0000I',
                                         'U013-0001',
                                         'S046-0169',
                                         'F022-0007',
                                         'S046-0156',
                                         'M030-0004')), 
               y=avg_hr_diff)) +
    geom_col(color="black", fill = "#69b3a2", alpha=.6) +
    scale_x_discrete(guide = guide_axis(angle = 90)) +
    labs(
      title = title,
      x = 'Part ID',
      y = 'Difference in Hours'
    ) +
    custom_theme
  
})

}


