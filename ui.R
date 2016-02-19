# Shiny App Project   
#
# Marcelo Tardelli  -  February 2016
# 
# Minor Stoppages Analysis
#

library(shiny)

shinyUI(pageWithSidebar(
        
        headerPanel("Minor Stoppages Analysis"),
        
        sidebarPanel(
                h4("Data Selection"),
                selectInput("lineSel", "Packaging Line:",
                            list("Line 1" = "1", 
                                 "Line 2" = "2", 
                                 "Line 3" = "3")),
                selectInput("ShiftSel", "Shift:",
                            list("Shift 1 (from 06:00h to 14:00h)"   = "1", 
                                 "Shift 2 (from 14:00h to 22:00h)"   = "2", 
                                 "Shift 3 (from 22:00h to 06:00h+1)" = "3")),
                dateRangeInput(inputId = "dateRange",  
                               label = "Date range", 
                               start = "2015-12-01",
                               max   = "2016-02-10")
                
        ),
        
        mainPanel(
                
                tabsetPanel( 
                        
                        tabPanel("Overview", 
                                 includeMarkdown("Overview.md")
                        ),
                        
                        
                        tabPanel("Time Between Minor Stoppages", 
                                 h4("Data Series - Time Between Minor Stoppages"),
                                 plotOutput("lineGraphTBF"),
                                 
                                 h4("TBF Histogram"),
                                 plotOutput("histWeibull"),
                                 sliderInput(inputId = "graphRangeA",
                                             label = "X Axis Range",
                                             min = 0,
                                             max = 600,
                                             value = 100,
                                             step = 5),
                                 
                                 h4("Weibull Distribution Fitting"),
                                 plotOutput("functWeibull"),
                                 sliderInput(inputId = "graphRangeB",
                                             label = "X Axis Range",
                                             min = 0,
                                             max = 600,
                                             value = 100,
                                             step = 5),
                                 tableOutput("WeibullTable"),
                                 tableOutput("WeibullFit"),
                                 
                                 plotOutput("WeibProb")
                                 
                                 ),
                
               
                        tabPanel("Minor Stoppages Duration", 
                                 h4("Data Series - Minor Stoppages Duration"),
                                 plotOutput("lineGraphMS"),
                                 
                                 h4("Minor Stoppages Duration Histogram"),
                                 plotOutput("histLogNorm"),
                                 sliderInput(inputId = "graphRangeC",
                                             label = "X Axis Range",
                                             min = 0,
                                             max = 600,
                                             value = 100,
                                             step = 5),
                                 
                                 h4("Weibull Distribution Fitting"),
                                 plotOutput("functLogNorm"),
                                 sliderInput(inputId = "graphRangeD",
                                             label = "X Axis Range",
                                             min = 0,
                                             max = 600,
                                             value = 100,
                                             step = 5),
                                 tableOutput("LogNormTable"),
                                 tableOutput("LogNormFit"),
                                 
                                 plotOutput("LogNormProb")
                                 
                        ) 
                )
                
        )
)
)