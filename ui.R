

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
                     div(class = "dynamic_height"),
                     sliderInput('graph_slide',
                                 'Select Parts as Arranged by Volume of Associated Jobs',
                                 min = 1, max = 1000,
                                 step = 10, value = 1)
                   )
                 ),
                 fluidRow(
                   column(
                     width = 9, 
                     div(class = "dynamic_height"),
                     plotOutput("distPlot_Q2a", height = "900px"),
                   ),
                  column(
                    width = 3,
                    h3(HTML(
                      'Parts with the highest amount of hours per job:<br/>
                      1. C-AL KIT FOR KOHLER<br/>
                      2. MWS-Armored Transport<br/>
                      3. BUY STEEL KIT<br/>
                      4. B-AO & D-AO CUMMINS KIT 84 SQFT<br/>
                      5. NEMA 12 SKID MNT, ENCLOSURE<br/'
                  )),
                  h4(HTML('copy and paste in search bar below for numbers'))
                 )
                ),
                 fluidRow(
                   column(
                     width = 12,
                   dataTableOutput("parts_table")
                   )
                 )
        ),
        tabPanel(h4('Seasonal Trend for Most In Demand Parts'),  
                 fluidRow(
                   column( 
                     width = 12, 
                     div(class = "dynamic_height"),
                     plotlyOutput("distPlot_Q2b", height = "900px")
                   )
                 ),
                 fluidRow(
                   column(
                     width = 12,
                     dataTableOutput("q2b")
                   )
                 )
        ),
        tabPanel(h4('Q2c: Variations in Job Task Duration'),  
                 fluidRow(
                   column( 
                     width = 12, 
                     #div(class = "dynamic_height"),
                     #plotOutput("distPlot_Q2c", height = "900px")
                     tabsetPanel(
                       tabPanel("Processes",
                                mainPanel(
                                  plotOutput(outputId = "opsChart"),
                                  DT::DTOutput(outputId = "opsTable")
                                )
                       ), 
                       tabPanel("Parts",
                                mainPanel(
                                  plotOutput(outputId = "partsChart"),
                                  DT::DTOutput(outputId = "partsTable")
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
                     tabsetPanel(
                       tabPanel('Scatter Plot', 
                                  plotlyOutput('rev_scatter'), 
                                  textInput( 
                                             "Insight_Text", 
                                             "Insight: Parts that generate the largest amount of total revenue tend not to generate large amount of revenue per hour of labor.", 
                                              placeholder = "Take additional notes here"
                                            ) 
                                ), 
                       tabPanel('Data Table', DTOutput('rev_table')) )
                   )
                 )
        )
      ),
      width = 9
    )
  )
) 