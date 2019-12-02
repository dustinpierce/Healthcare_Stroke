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
library(reshape2)
library(RColorBrewer)

#change the file directory as we go -- how to host the csv and models and images on Shiny.io ??
dataset <- read.csv("strokedata.csv")
dataset <- dataset %>% select(-X,-DF)
dataset2 <- read.csv("balanced_stroke.csv")
dataset2 <- dataset2 %>% select(-X)

full_df <- read.csv("full_df.csv")
full_df_plot <- full_df %>% select(-X, -Smoking.Status, -DF)
full_df <- full_df %>% select(-Smoking.Status)

ui <- navbarPage(
        theme = shinythemes::shinytheme("journal"),
        "Stroke Data",
        tabPanel("Background", 
                 fluidRow(
                     column(12,
                            h3("About"),
                            "This app was designed as part of our STAT-613 Data Science final project. The name of the dataset utilized within this app is the Healthcare Dataset Stroke Data which was obtained from Kaggle's website. This dataset contains information on more than 40,000 patients along dimensions such as gender, BMI, smoke history, and more. Explore the different tabs to gain further insight into our data. "),
                     column(6,
                            h4("Data Dictionary"),
                            imageOutput("datadictionary")
                            )
                        )
                    ),
        tabPanel("Data Exploration",
                     tabsetPanel(
                         tabPanel("Summary Statistics",
                                  h4("Take a look into the original dataset and why there was a need to balance the dataset before conducting our analysis:"),
                                  tabsetPanel(
                                      tabPanel("Original",
                                               h1(" "),
                                               dataTableOutput("table"),
                                               h4("Variable Summaries"),
                                               sidebarPanel(
                                                   selectInput('var', 'Variable', names(dataset)),
                                                   width=5),
                                               verbatimTextOutput("summary")
                                      ),
                                      tabPanel("Balanced",
                                               h1(" "), 
                                               dataTableOutput("table2"),
                                               h4("Variable Summaries"),
                                               sidebarPanel(
                                                 selectInput('var2', 'Variable', names(dataset2)),
                                                 width = 5),
                                                 verbatimTextOutput("summary2")
                                               )
                         )
                         ),
                         tabPanel("Plots", 
                                  h4("Plot the variables from the original dataset next to those from the balanced dataset to see how we addressed the class imbalance problem:"),
                                  h1(" "),
                                  sidebarPanel(
                                    selectInput('x', 'Variables', names(full_df_plot)), #use a bin width to create a better distribution of the continuous variables here...
                             #selectInput('fill', 'Fill', full_df$DF), #need to make fill only inlcude the categorical variables
                             
                             # selectInput('facet_row', 'Facet Row', c(None='.', names(dataset))),
                             # selectInput('facet_col', 'Facet Column', c(None='.', names(dataset))),
                                    width=3),
                                    plotOutput("plot"), width = "50%"
                     )
                 )
        ),
        tabPanel("Model Performance", 
                 tabsetPanel(
                     tabPanel("Logistic Regression",
                              fluidRow(
                                column(12,
                                       h4("Model Performance Ranking : "),
                                       h5("Accuracy : "),
                                column(6,
                                       h3(""),
                                       imageOutput("logit")
                                )
                              )
                              )
                              ),
                     tabPanel("Neural Network",
                              fluidRow(
                                column(12,
                                       h4("Model Performance Ranking : "),
                                       h5("Accuracy : "),
                                       column(6,
                                              h3(""),
                                              imageOutput("neural")
                                       )
                                )
                              )
                              ),
                     tabPanel("Random Forest",
                              fluidRow(
                                column(12,
                                       h4("Model Performance Ranking : 1"),
                                       h5("Accuracy : "),
                                       column(6,
                                              h3(""),
                                              imageOutput("rf")
                                       )
                                       )
                                )
                              )
                     )
                     )
        )

server <- function(input, output) {
    
    output$datadictionary <- renderImage({
        return(list(
            src ="datadictionary.jpg",
            contentType = "image/jpeg",
            width = 600
        ))
    }, deleteFile = FALSE)
    
    output$table <- renderDataTable(
        dataset, 
        options = list(rownames = FALSE)
    )
    
    output$table2 <- renderDataTable(
      dataset2,
      options = list(rownames = FALSE)
    )
    
    output$plot <- renderPlot({
        
        p <- ggplot(full_df, aes_string(x=input$x)) + scale_fill_brewer(palette="PuRd") + labs(title = "Original vs. Balanced Class Stroke Data", y = "Count", fill = "Origin of Data") + theme_bw() 
        
        if (input$x %in% c("Gender", "Hypertension", "Heart.Disease", "Ever.Married", "Work.Type", "Residence.Type", "Stroke"))
          p <- p + geom_bar(aes(fill=DF), position = "dodge", stat="count")
        
        if (input$x %in% c("Age", "BMI", "Avg.Glucose.Level"))
          p <- p + geom_histogram(aes(fill=DF), position = "stack", stat="bin")
        
        print(p)
        
    }, width = 800)
    
    data1 <- reactive({
        dataset[input$var]
    })
    
    output$summary <- renderPrint({
        summary(data1())
        
    })
    
    data2 <- reactive({
      dataset2[input$var2]
    })
    
    output$summary2 <- renderPrint({
      summary(data2())
    })
    
    output$logit <- renderImage({
      return(list(
        src ="datadictionary.jpg",
        contentType = "image/jpeg",
        width = 600
      ))
    }, deleteFile = FALSE)
    
    output$neural <- renderImage({
      return(list(
        src ="datadictionary.jpg",
        contentType = "image/jpeg",
        width = 600
      ))
    }, deleteFile = FALSE)
    
    output$rf <- renderImage({
      return(list(
        src ="datadictionary.jpg",
        contentType = "image/jpeg",
        width = 600
      ))
    }, deleteFile = FALSE)

}

shinyApp(ui = ui, server = server)
