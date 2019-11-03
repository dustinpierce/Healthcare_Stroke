#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
library(dplyr)
library(shinythemes)
library(markdown)
library(DT)

dataset <- iris %>% rename("Sepal_Length"=Sepal.Length, "Sepal_Width"=Sepal.Width, "Petal_Length"=Petal.Length, "Petal_Width"=Petal.Width)

ui <- tagList(
    shinythemes::themeSelector(),
    navbarPage(
        # theme = "cerulean",  # <--- To use a theme, uncomment this
        "Stroke Data",
        tabPanel("Data Exploration",
                 sidebarPanel(
                     
                     sliderInput('sampleSize', 'Sample Size', min=1, max=nrow(dataset),
                                 value=min(50, nrow(dataset)), step=1, round=0),
                     
                     selectInput('x', 'X', names(dataset)),
                     selectInput('y', 'Y', names(dataset), names(dataset)[[2]]),
                     selectInput('color', 'Color', c('None', names(dataset))),
                     
                     checkboxInput('jitter', 'Jitter'),
                     checkboxInput('reg', 'Regression'),
                     
                     selectInput('facet_row', 'Facet Row', c(None='.', names(dataset))),
                     selectInput('facet_col', 'Facet Column', c(None='.', names(dataset)))
                 ),
                 mainPanel(
                     tabsetPanel(
                         tabPanel("Summary Stats",
                                  h4("Table"),
                                  tableOutput("table"),
                                  h4("Verbatim text output"),
                                  verbatimTextOutput("txtout"),
                                  h1("Header 1"),
                                  h2("Header 2"),
                                  h3("Header 3"),
                                  h4("Header 4"),
                                  h5("Header 5")
                         ),
                         tabPanel("Plots", "This panel is intentionally left blank"),
                         tabPanel("Analysis", "This panel is intentionally left blank")
                     )
                 )
        ),
        tabPanel("Models", "This panel is intentionally left blank"),
        tabPanel("Background", "This panel is intentionally left blank")
    )
)

server <- function(input, output) {
    output$txtout <- renderText({
        paste(input$txt, input$slider, format(input$date), sep = ", ")
    })
    output$table <- renderTable({
        head(cars, 4)
    })
}

shinyApp(ui = ui, server = server)