

# Define UI for application that draws a histogram
fluidPage(
  theme = shinytheme("readable"),
  
  tags$style(HTML("
    .tabbable > .nav > li > a                  {background-color: seashell;  color:blue4}
    .tabbable > .nav > li[class=active]    > a {background-color: dodgerblue; color:white}
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
        tabPanel(h4('Total Job Volume vs. Total Estimated Production Hours'),
                 fluidRow(
                   column( 
                     width = 12, 
                     div(class = "dynamic_height",
                         style = "display: flex; justify-content: center; align-items: center"),
                     sliderInput('graph_slide',
                                 'Select Parts as Arranged by Volume of Associated Jobs',
                                 min = 1, max = 1000,
                                 step = 10, value = 1)
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
                      2. MWS-Armored Transport<br/>
                      3. BUY STEEL KIT<br/>
                      4. B-AO & D-AO CUMMINS KIT 84 SQFT<br/>
                      5. NEMA 12 SKID MNT, ENCLOSURE<br/'
                     )),
                     h5(HTML('copy and paste in search bar below for numbers'))
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
                     width = 12, 
                     div(class = "dynamic_height",
                         style = "display: flex; justify-content: center; align-items: center"),
                     plotlyOutput("distPlot_Q2b", height = "900px")
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
                                div(class = "dynamic_height",
                                    style = "display: flex; justify-content: center; align-items: center"),
                                plotOutput(outputId = "opsChart"),
                                DT::DTOutput(outputId = "opsTable")
                       ), 
                       tabPanel("Parts",
                                plotOutput(outputId = "partsChart"),
                                DT::DTOutput(outputId = "partsTable")
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