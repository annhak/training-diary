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
    titlePanel("Training diary"),

    # Show a plot of the generated distribution
    tabsetPanel(id = "tabs",
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
        tabPanel(
            "Add workout", 
            sidebarLayout(
                sidebarPanel(
                    dateInput(
                        "date",
                        label = "Date of the new training"
                        ),
                    selectInput(
                        "new_exercise",
                        label = "Select the exercise to be added",
                        choices = NULL
                    ),
                    conditionalPanel(
                        condition = "output.group",
                        numericInput("sets", "How many sets were done", 0),
                        numericInput("reps", "How many repetitions were done", 0),
                        numericInput("weights", "What was the maximum weight", 0)),
                    conditionalPanel(
                        condition = "!output.group",
                        numericInput("duration", "How long exercise was done", 0),
                        numericInput("level", "What was the max level", 0)),
                    actionButton("saveWorkout", "Save the new workout")
            ),

                mainPanel(dataTableOutput("factTable"))
                )
            ),
        tabPanel("Reports")#, tableOutput("factTable"))
    )
))
