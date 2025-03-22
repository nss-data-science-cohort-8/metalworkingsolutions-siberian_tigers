#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#


# Define server logic required to draw a histogram
function(input, output, session) {
  
  # updateSelectizeInput(
  #   session, 
  #   'Chosen_Firm', 
  #   choices = (Firm_Industry_Random_Effect_Coeff_Desc_StatSig_y_StatInsig$level), 
  #   selected = 'Costco Wholesale Corp', 
  #   server = TRUE)
  
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
 
  #q2a
  
  
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
      scale_y_continuous(name = "number of jobs",labels = scales::comma,sec.axis = sec_axis(~./sf, name="estimated production hours",
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
      ggtitle('Number of Jobs by Production Hours')
  })
  
  
  
  
  
  
  
  
  
#   output$distPlot_Firm <- renderPlot({
#     
#     Tab2_IndustryName <- Closing_Share_Price_Across_Time_DropNA |> 
#       filter(company_name == input$Chosen_Firm) |> pull(Industry) |> unique()
#     
#     title2 <- glue("Changes in Stock Price of {input$Chosen_Firm} vs. Peers in the {Tab2_IndustryName} Industry as a Function of Net COVID Sentiment")
#     
#     select_company = c(input$Chosen_Firm)
#     
#     Closing_Share_Price_Across_Time_DropNA_highlight <- Closing_Share_Price_Across_Time_DropNA |> 
#       mutate(highlight = case_when(company_name %in% select_company ~ TRUE,
#                                    .default = FALSE))
#     
#     formula <- y ~ poly(x, 1, raw = TRUE)     # raw = TRUE calculates the polynomial regression as usual. Leaving this out so default is raw = FALSE would lead to an orthogonal basis being chosen to perform the regression on.
#     
#     industry <- Closing_Share_Price_Across_Time_DropNA_highlight |> filter(company_name == input$Chosen_Firm) |> pull(Industry) |> unique()
#     
#     
#     Closing_Share_Price_Across_Time_DropNA_highlight |> 
#       filter(Industry == industry) |> 
#       ggplot(aes(x = Covid_Net_Sentiment, y = Percent_Change_bt_DayBefore_y_DayAfter)) +
#       geom_point(
#         aes(size = Covid_Exposure*100, color = highlight), 
#         alpha = 0.7, 
#         show.legend = TRUE
#       ) +
#       geom_smooth(method = "lm", formula = formula, se = TRUE) + 
#       scale_color_manual(labels = c("Other Firms in the Industry", "Selected Firm"),
#                          values = c("turquoise", "red")) +
#       # scale_size_manual(values = c(1, 3)) +
#       # geom_label_repel(data = Closing_Share_Price_Across_Time_DropNA_highlight |> filter(highlight == TRUE), aes(label = company_name)) +
#       stat_poly_eq(
#         formula = formula, 
#         parse = TRUE, 
#         use_label(c("eq", "F" ,"adj.R2", "p", "n")), 
#         vstep = 22, 
#         size=6
#       ) +
#       theme(
#         axis.text.y=element_text(size = 17, face = "bold"), 
#         axis.text.x=element_text(size = 17, face = "bold"), 
#         axis.title.x=element_text(size = 20, face = "bold"), 
#         axis.title.y=element_text(size = 20, face = "bold"), 
#         plot.title = element_text(size = 24) 
#       ) +
#       labs(
#         x = "Net COVID Sentiment",
#         y = "% Change in Stock Price from the Day Before Earnings Call to the Day After",
#         title = title2,
#         color = "Firm Selection",
#         size = "COVID Exposure Range: 0.06~13.35 
# Size as described below = Exposure x 100"
#       )  
#   })
#   
#   
#   output$distPlot_Time <- renderPlot({
#     
#     Tab2_IndustryName <- Closing_Share_Price_Across_Time_DropNA |> 
#       filter(company_name == input$Chosen_Firm) |> pull(Industry) |> unique()
#     
#     title2 <- glue("Changes in Stock Price of {input$Chosen_Firm} vs. Peers in the {Tab2_IndustryName} Industry over Time")
#     
#     select_company = c(input$Chosen_Firm)
#     
#     Closing_Share_Price_Across_Time_DropNA_highlight <- Closing_Share_Price_Across_Time_DropNA |> 
#       mutate(highlight = case_when(company_name %in% select_company ~ TRUE,
#                                    .default = FALSE))
#     
#     formula <- y ~ poly(x, 1, raw = TRUE)     # raw = TRUE calculates the polynomial regression as usual. Leaving this out so default is raw = FALSE would lead to an orthogonal basis being chosen to perform the regression on.
#     
#     industry <- Closing_Share_Price_Across_Time_DropNA_highlight |> filter(company_name == input$Chosen_Firm) |> pull(Industry) |> unique()
#     
#     
#     Closing_Share_Price_Across_Time_DropNA_highlight |> 
#       filter(Industry == industry) |> 
#       ggplot(aes(x = Day_of_EarningsCall, y = Percent_Change_bt_DayBefore_y_DayAfter)) +
#       geom_point(
#         aes(size = Covid_Net_Sentiment, color = highlight), 
#         alpha = 0.7, 
#         show.legend = TRUE
#       ) +
#       geom_smooth(method = "lm", formula = formula, se = TRUE) + 
#       scale_color_manual(labels = c("Other Firms in the Industry", "Selected Firm"),
#                          values = c("turquoise", "red")) +
#       # scale_size_manual(values = c(1, 3)) +
#       # geom_label_repel(data = Closing_Share_Price_Across_Time_DropNA_highlight |> filter(highlight == TRUE), aes(label = company_name)) +
#       stat_poly_eq(
#         formula = formula, 
#         parse = TRUE, 
#         use_label(c("eq", "F" ,"adj.R2", "p", "n")), 
#         vstep = 22, 
#         size=6
#       ) +
#       theme(
#         axis.text.y=element_text(size = 17, face = "bold"), 
#         axis.text.x=element_text(size = 17, face = "bold"), 
#         axis.title.x=element_text(size = 20, face = "bold"), 
#         axis.title.y=element_text(size = 20, face = "bold"), 
#         plot.title = element_text(size = 24) 
#       ) +
#       labs(
#         x = "Year / Month",
#         y = "% Change in Stock Price from the Day Before Earnings Call to the Day After",
#         title = title2,
#         color = "Firm Selection",
#         size = "COVID Net Sentiment"
#       )  
#     
#   })
}


