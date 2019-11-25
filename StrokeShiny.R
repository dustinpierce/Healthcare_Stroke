library(shiny)
library(ggplot2)
library(dplyr)
library(shinythemes)
library(markdown)
library(DT)

#change the file directory as we go -- how to host the csv and models and images on Shiny.io ??
dataset <- read.csv("~/Desktop/Genomics_Project-master/strokedata.csv")
dataset <- dataset %>% select(-X)
#should we use the cleaned model that is used for analysis, or the one that is filtered but still contains the original variables from the data dictionary for the data exploration? 

ui <- navbarPage(
        theme = shinythemes::shinytheme("journal"),
        "Stroke Data",
        tabPanel("Background", 
                 fluidRow(
                     column(12,
                            h3("About"),
                            "This app is designed to investigate results through visualization, summary statistics and model evaluation. We obtained our dataset from Kaggle Healthcare Dataset Stroke Data. This dataset contains information on more than 40,000 patients along dimensions such as gender, BMI, smoke history, and more."),
                     column(6,
                            h4("Data Dictionary"),
                            imageOutput("datadictionary")
                            )
                        )
                    ),
        tabPanel("Data Exploration",
                     tabsetPanel(
                         tabPanel("Summary Statistics",
                                  h4("Stroke Dataset"),
                                  dataTableOutput("table"),
                                  h4("Summary of Variables"),
                                  verbatimTextOutput("summary")#,
                                  # h1("Header 1"),
                                  # h2("Header 2"),
                                  # h3("Header 3"),
                                  # h4("Header 4"),
                                  # h5("Header 5")
                         ),
                         tabPanel("Plots", 
                                  sidebarPanel(
                             # sliderInput('sampleSize', 'Sample Size', min=1, max=nrow(dataset),
                             #    value=min(50, nrow(dataset)), step=1, round=0),
                             selectInput('x', 'Variables', names(dataset)),
                             #selectInput('y', 'Y', names(dataset), names(dataset)[[2]]),
                             selectInput('fill', 'Fill', c('None', names(dataset))),
                             
                             checkboxInput('bar', 'Bar'),
                             checkboxInput('hist', 'Histogram'),
                             
                             # selectInput('facet_row', 'Facet Row', c(None='.', names(dataset))),
                             # selectInput('facet_col', 'Facet Column', c(None='.', names(dataset))),
                             width=3),
                             plotOutput("plot"), width = "50%"
                     )
                 )
        ),
        tabPanel("Models", "This panel is intentionally left blank")
    )

server <- function(input, output) {
    output$datadictionary <- renderImage({
        return(list(
            src ="~/Desktop/Genomics_Project-master/datadictionary.jpg",
            contentType = "image/jpeg",
            width = 600
        ))
    }, deleteFile = FALSE)
    
    output$txtout <- renderText({
        paste(input$txt, input$slider, format(input$date), sep = ", ")
    })
    output$table <- renderDataTable(
        dataset %>% select(-id), 
        options = list(rownames = FALSE)
    )
    output$plot <- renderPlot({
        
        p <- ggplot(dataset, aes_string(x=input$x))#, y=input$y))
        
        if (input$fill != 'None')
            p <- p + aes_string(fill=input$fill)
        
        # facets <- paste(input$facet_row, '~', input$facet_col)
        # if (facets != '. ~ .')
        #     p <- p + facet_wrap(facets)
        
        if (input$bar)
            p <- p + geom_bar() 
        if (input$hist)
            p <- p + geom_histogram()
        
        print(p)
        
    }, width = 800)
    
    output$summary <- renderPrint({
        summary(dataset)
    })
    #output$summary <- renderPrint({
      #  summary(dataset %>% select(-X))
   # })
}

shinyApp(ui = ui, server = server)
