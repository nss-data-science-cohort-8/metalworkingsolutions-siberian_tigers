#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#


# Define UI for application that draws a histogram
fluidPage(
  theme = shinytheme("readable"),
  
  tags$style(HTML("
    .tabbable > .nav > li > a                  {background-color: seashell;  color:blue4}
    .tabbable > .nav > li[class=active]    > a {background-color: dodgerblue; color:white}
  ")),
  
  # Application title
  titlePanel("Data-derived Insights from Questions 2a~d"),
  
  # Drop down menu to select an industry of interest
  sidebarLayout(
    sidebarPanel(
      # selectInput(
      #   "Industry", 
      #   label = "Select an Industry",  # h3 is level 3 header
      #   choices = c("All", Company_Industry |> distinct(Industry) |>  pull() |> sort()), 
      #   selected = 1
      # ),
      # checkboxGroupInput(
      #   inputId = "Statistical_Significance",
      #   label = "Statistically Significant?",
      #   choices = c("Yes", "No"),
      #   selected = c("Yes", "No")
      # ),
      # selectizeInput(
      #   'Chosen_Firm', 
      #   'Enter Firm Name for Firm vs. Industry Stock Performance Comparison', 
      #   choices = NULL, 
      #   selected = NULL, 
      #   multiple = FALSE,
      #   options = NULL
      # ),
      # width = 3
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
        tabPanel(h4('Q2d'),  
                 fluidRow(
                   column( 
                     width = 12, 
                     div(class = "dynamic_height"),
                     plotOutput("distPlot_Q2d", height = "900px")
                   )
                 )
        )
      ),
      width = 9
    )
  )
) 
