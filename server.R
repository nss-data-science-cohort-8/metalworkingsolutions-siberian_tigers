#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)

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

  output$selecteddataTable <- renderDataTable(plot_data_func())
  
  
  
  
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


