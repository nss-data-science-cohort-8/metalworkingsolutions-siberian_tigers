

# Define UI for application that draws a histogram
fluidPage(
  theme = shinytheme("readable"),
  
  tags$style(HTML("
    .tabbable > .nav > li > a                  {background-color: seashell;  color:blue4}
    .tabbable > .nav > li[class=active]    > a {background-color: dodgerblue; color:white}
  ")),
  
  # Application title
  titlePanel("Data-dderived Insights from Questions 2a~d"),
  
  # Drop down menu to select an industry of interest
  sidebarLayout(
    sidebarPanel(
      
    ),
    # Main Panel's top portion has bar graph; bottom portion has table
    mainPanel(
      tabsetPanel(
        tabPanel(h4('Q2a'),
                 fluidRow(
                   column( 
                     width = 12, 
                     div(class = "dynamic_height"),
                     sliderInput('graph_slide',
                                 'select range of graph',
                                 min = 1, max = 1000,
                                 step = 10, value = 1)
                   )
                 ),
                 fluidRow(
                   column( 
                     width = 12, 
                     div(class = "dynamic_height"),
                     plotOutput("distPlot_Q2a", height = "900px")
                   )
                 ),
                 fluidRow(
                   dataTableOutput("parts_table")
                 )
        ),
        tabPanel(h4('Q2b'),  
                 fluidRow(
                   column( 
                     width = 12, 
                     div(class = "dynamic_height"),
                     plotlyOutput("distPlot_Q2b", height = "900px")
                   )
                 )
        ),
        tabPanel(h4('Q2c'),  
                 fluidRow(
                   column( 
                     width = 12, 
                     div(class = "dynamic_height"),
                     plotOutput("distPlot_Q2c", height = "900px")
                   )
                 )
        ),
        tabPanel(h4('Revenue Per Production Hour'),  
                 fluidRow(
                   column( 
                     width = 12, 
                     tabsetPanel(
                       tabPanel('Scatter Plot', plotlyOutput('rev_scatter')), 
                       tabPanel('Data Table', DTOutput('rev_table'))
                     )
                   )
                 )
        )
      ),
      width = 9
    )
  )
) 