#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("Old Faithful Geyser Data"),

    # Show a plot of the generated distribution
    tabsetPanel(
        tabPanel(
            "Exercise",     
            sidebarLayout(
                sidebarPanel(
                    textInput(
                        "exercise_name", 
                        "Give the exercise type to be saved"),
                    radioButtons(
                        "group", 
                        "Select the input mode", 
                        group_options,
                        selected = character(0)),
                    actionButton("save", "Save the new exercise type")
                    ),
                mainPanel(
                    dataTableOutput("dimensionTable")
                    )
                )
            ),
        tabPanel("Add workout"),
        tabPanel("Reports", plotOutput("distPlot"))
    )
))
