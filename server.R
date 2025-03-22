

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
      labs(title = 'Trend in Quantity Ordered', 
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
        axis.text.x=element_text(size = 17, face = "bold"), 
        axis.title.x=element_text(size = 20, face = "bold"), 
        axis.title.y=element_text(size = 20, face = "bold")
      ) +
      ggtitle("Trend in Quantity Ordered") +
      facet_wrap(~factor(PartID_LongDescription, levels=c(TopN_Highly_InDemand_Parts_ID_y_LongDescription)))
    
    
    ggp_build_TopVol_Parts <- plotly_build(TopVol_Parts)
    ggp_build_TopVol_Parts$layout$height = 2200
    ggp_build_TopVol_Parts$layout$width = 2600
    ggp_build_TopVol_Parts
    
  })
  
  #Q2a
  
  
  output$parts_table <- renderDataTable(datatable(complete_data |> 
                                                    group_by(part_id, part_name) |> 
                                                    summarize(jobs = max(number_of_jobs_by_part),
                                                              estimated_hours = sum(estimated_production_hours),
                                                              revenue = sum(total_revenue),
                                                              estimated_job_per_hour = (sum(estimated_production_hours) / min(number_of_jobs_by_part)),             estimated_revenue_per_job = sum(total_revenue) / min(number_of_jobs_by_part),
                                                              revenue_per_hour = mean(estimated_revenue_per_hour)) |> 
                                                    arrange(desc(jobs)), options = list(displayStart = (input$graph_slide[1] - 1))) 
  )
  
  output$distPlot_Q2a <- renderPlot({
    parts_table_top_10 <- complete_data |> 
      group_by(part_id) |>
      summarize(jobs = min(number_of_jobs_by_part),
                estimated_hours = sum(estimated_production_hours),
                revenue = sum(total_revenue),
                estimated_job_per_hour = (sum(estimated_production_hours) / min(number_of_jobs_by_part)),             estimated_revenue_per_job = sum(total_revenue) / min(number_of_jobs_by_part),
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
      scale_fill_manual(values = c("blue", "red")) +
      scale_y_continuous(name = "Number of Jobs",labels = scales::comma,sec.axis = sec_axis(~./sf, name="Estimated Production Hrs",
                                                                                            labels = scales::comma))+
      labs(fill='variable')+
      theme_bw()+
      theme(legend.position = 'top',
            plot.title = element_text(color='black',face='bold',hjust=0.5),
            axis.text = element_text(color='black',face='bold'),
            axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
            axis.title.y.right = element_text(color='red',face='bold'),
            axis.title.y.left = element_text(color='blue',face='bold'),
            legend.text = element_text(color='black',face='bold'),
            legend.title = element_text(color='black',face='bold'))+
      ggtitle('Number of Jobs by Production Hrs')
  })
  
  
  
  
  
  
  
  
  output$rev_scatter <- renderPlotly({
 
    rev_plot <- ggplot(revenue_data, 
                       aes(
                         x = log10(total_quantity_shipped), 
                         y = estimated_revenue_per_hour, 
                         size = total_revenue, 
                         color = part_name,
                         text = rev_tooltip))+ 
      geom_point(
        alpha = 0.5,
        show.legend = TRUE
      ) + 
      labs(title = 'Revenue per Estimated Production Hr in the Context of Volume Shipped and Total Revenue', 
           x = 'Log10 (Total Quantity Shipped)', 
           y = 'Revenue per Est Production Hr (USD/Hr)' 
      ) +
      theme(legend.position = "none")
    
    ggp_build_Rev_Plot <- plotly_build(rev_plot)
    ggp_build_Rev_Plot$layout$height = 2200
    ggp_build_Rev_Plot$layout$width = 2600
    ggp_build_Rev_Plot
  })
  
  
  
  output$rev_table <- renderDT({
    datatable(
      revenue_data |> 
        select(part_id, part_name, total_quantity_shipped, est_prod_hours, total_revenue, estimated_revenue_per_hour, number_of_jobs),
      colnames = c(
        'Part Id',
        'Part Name', 
        'Quantity Shipped', 
        'Total Est Prod Hours', 
        'Total Revenue', 
        'Revenue per Est Prod Hour', 
        'Total Jobs'
      ),
      options = list(
        order = list(list(6, "desc")) 
      )
    )
  })
  
  
}
