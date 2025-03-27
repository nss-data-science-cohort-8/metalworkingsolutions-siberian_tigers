

# Define UI for application that draws a histogram
fluidPage(
  theme = shinytheme("readable"),
  
  tags$style(HTML("
    .nav-tabs > li > a { color: white; }
    .tabbable > .nav > li > a                  {background-color: grey}
    .tabbable > .nav > li[class=active]    > a {background-color: #69b3a2}
    .js-irs-0 .irs-single, .js-irs-0 .irs-bar-edge, .js-irs-0 .irs-bar {background: #69b3a2}
  ")),
  
  # Application title
  titlePanel("Data-derived Insights for MetalWorking Solutions' Production, Labor, and Revenue"),
  
  # Drop down menu to select an industry of interest
  sidebarLayout(
    sidebarPanel(
    ),
    # Main Panel's top portion has bar graph; bottom portion has table
    mainPanel(
      tabsetPanel(
        tabPanel(
          h4('Total Job Volume vs. Total Estimated Production Hours'),
          fluidRow(
            column( 
              width = 12, 
              div(class = "dynamic_height; slider-custom",
                  style = "display: flex; justify-content: center; align-items: center"),
              sliderInput('graph_slide',
                          'Select Parts as Arranged by Volume of Associated Jobs',
                          min = 0, max = 1000,
                          step = 10, value = 0,
                          width = '70%')
            )
          ),
          fluidRow(
            column(
              width = 9, 
              div(class = "dynamic_height",
                  style = "display: flex; justify-content: left; align-items: left"),
              plotOutput("distPlot_Q2a", height = "900px"),
            ),
            column(
              width = 3,
              div(class = "dynamic_height",
                  style = "display: flex; justify-content: right; align-items: right"),
              h4(HTML(
                'Parts with the highest amount of hours per job:<br/>
                      1. C-AL KIT FOR KOHLER<br/>
                      2. MWS-Armored Transport 6x8<br/>
                      3. BUY STEEL KIT<br/>
                      4. B-AO & D-AO CUMMINS KIT 84 SQFT<br/>
                      5. NEMA 12 SKID MNT, ENCLOSURE<br/>
                      6. MWS-Armored Transport 8x8<br/>
                      7. YT449800B-C-AO CUMMINS KIT 84 SQFT<br/>
                      8. EN 1978 SKY WHITE PEEL<br/>
                      9. A49149-81-824 46.125 X 23.938<br/>
                      10. DRIVER CAGE 2 SIDES RH & LH 8 FT X 6 FT W/ DOCUMENT PASS THROUGH<br/>'
              )),
              h4(HTML('It appears that parts that are quite large in nature
                             (vehicles, large steel kits, etc.) tend to take up the most production hours.
                             There is a low correlation (0.24) between the amount of jobs and production hours<br/>')),
              h5(HTML('copy and paste the names above in  the search bar below for numbers'))
            )
          ),
          fluidRow(
            column(
              width = 12,
              div(class = "dynamic_height",
                  style = "display: flex; justify-content: center; align-items: center"),
              dataTableOutput("parts_table")
            )
          )
        ),
        tabPanel(h4('Seasonal Trend for Most In Demand Parts'),  
                 fluidRow(
                   column( 
                     width = 10, 
                     div(class = "dynamic_height",
                         style = "display: flex; justify-content: center; align-items: center"),
                     plotlyOutput("distPlot_Q2b", height = "900px")
                   ),
                   column( 
                     width = 2, 
                     div(class = "dynamic_height",
                         style = "display: flex; justify-content: center; align-items: center"),
                     h4(HTML(
                       'Insight: The most in demand parts tend to be household items (e.g. mounting bracket for wall shelves), automotive suspension parts, and house renovation items (e.g. bottom plate for foundational jack). Some seasonal trends can be observed here, e.g. season(s) for building and renovating houses.'
                     )),
                     h5('The top six parts are displayed in this chart and are listed in the table below.')
                   )
                 ),
                 fluidRow(
                   column(
                     width = 12,
                     div(class = "dynamic_height",
                         style = "display: flex; justify-content: center; align-items: center"),
                     dataTableOutput("q2bTable")
                   )
                 )
        ),
        tabPanel(h4('Variations in Job Task Duration'),  
                 fluidRow(
                   column( 
                     width = 12,
                     div(class = "dynamic_height",
                         style = "display: flex; justify-content: center; align-items: center"),
                     tabsetPanel(
                       tabPanel("Processes",
                                fluidRow(
                                  column( 
                                    width = 9,
                                    div(class = "dynamic_height",
                                        style = "display: flex; justify-content: center; align-items: center"),
                                    plotOutput(outputId = "opsChart"),
                                    DT::DTOutput(outputId = "opsTable")
                                  ),
                                  column( 
                                    width = 3, 
                                    div(class = "dynamic_height",
                                        style = "display: flex; justify-content: center; align-items: center"),
                                    h4(HTML(
                                      'Based on the data, it appears that coating or galvanizing are the jobs that take the most amount of time. Additionally, it appears that most jobs complete on schedule.'
                                    )
                                    )
                                  )
                                )
                       ), 
                       tabPanel("Parts",
                                fluidRow(
                                  column( 
                                    width = 9,
                                    div(class = "dynamic_height",
                                        style = "display: flex; justify-content: left; align-items: left"),
                                    plotOutput(outputId = "partsChart"),
                                    DT::DTOutput(outputId = "partsTable")
                                  ),
                                  column(
                                    width = 3,
                                    div(class = "dynamic_height",
                                        style = "display: flex; justify-content: right; align-items: right"),
                                    h4(HTML(
                                      'Overall, it appears that most parts are prepared on schedule, with only the highlighted handful deviating from that.'
                                    ))
                                  )
                                )
                       ) 
                     )
                   )
                 )
        ),
        tabPanel(h4('Revenue per Production Hr'),  
                 fluidRow(
                   column( 
                     width = 12,
                     div(class = "dynamic_height",
                         style = "display: flex; justify-content: center; align-items: center"),
                     tabsetPanel(
                       tabPanel('Scatter Plot',
                                fluidRow(
                                  column( 
                                    width = 9,
                                    div(class = "dynamic_height",
                                        style = "display: flex; justify-content: left; align-items: left"),
                                    plotlyOutput('rev_scatter')
                                  ),
                                  column( 
                                    width = 3,
                                    div(class = "dynamic_height",
                                        style = "display: flex; justify-content: right; align-items: right"),
                                    h4(HTML( 
                                      'High volume parts typically do not generate the most revenue per hour compared to estimated production hours.<br><br> 
                                      Most high-volume parts fall below the average revenue per hour. <br><br>
                                      Parts that generate the highest total revenue often have lower revenue per hour.' 
                                    )
                                    )
                                  )
                                )
                       ), 
                       tabPanel('Data Table', DTOutput('rev_table')
                       )
                     )
                   )
                 )
        )
      ),
      width = 12
    )
  )
) 

