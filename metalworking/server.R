



function(input, output, session) {
  
  
  
  plot_data_func <- reactive({
    
    plot_data <- LeftJoined_YMDseries_TopNParts
    
    return(plot_data)    
    
  })
  
  
  output$distPlot_Q2b <- renderPlotly({
    
    title <- glue("Trend in Quantity Ordered for Top 6 Selling Parts")
    
    plot_data_func() |>  
      
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
    
    
  })
  
  output$selecteddataTable <- renderDataTable(plot_data_func())
  
  
  
  
  
  output$rev_scatter <- renderPlotly({
    rev_plot <- ggplot(revenue_data, 
                       aes(
                         x = total_quantity_shipped, 
                         y = estimated_revenue_per_hour, 
                         size = total_revenue, 
                         color = part_name,
                         text = rev_tooltip))+ 
      geom_point() + 
      labs(title = 'Part Volume vs Reveune per Estimated Production Hours', 
           x = 'Volume Shipped', 
           y = 'Revenue per Est Production Hour' 
      ) +
      theme(legend.position = "none")
    
    ggplotly(rev_plot, tooltip = 'text')
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
          )
    )
  })

  
}
