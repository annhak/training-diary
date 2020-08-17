#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(data.table)
library(DT)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
    
    dimensionFile <- "./dimensions.csv"
    workoutFile <- "./workout.csv"
    
    dimensions <- reactiveValues(
        dim = tryCatch(
        read.csv(dimensionFile, header = TRUE),
        error = function(e) {
            data.frame(
                exercise_name = character(),
                group = character(),
                stringsAsFactors = FALSE)
        })
    )
    
    workouts <<- tryCatch(
        read.csv(workoutFile),
        error = function(e) {
            data.frame(
                datetime = character(),
                exercise_name = character(),
                streaks = numeric(),
                repetitions = numeric(),
                weight = numeric(),
                label = character(), 
                stringsAsFactors = FALSE)
        }
    )
    
    output$dimensionTable <- DT::renderDataTable({
        exercise_names()
        return(dimensions$dim)
    }, selection = 'none',server = TRUE, escape = FALSE, options = list(
        paging = TRUE,
        preDrawCallback = JS('function() {Shiny.unbindAll(this.api().table().node()); }'),
        drawCallback = JS('function() {Shiny.bindAll(this.api().table().node()); } ')
        )
    )
    
    add_to_dims <- reactive({
        dim1 <- dimensions$dim
        increment <- data.frame(
            exercise_name = input$exercise_name,
            group = names(which(group_options == input$group))
        )
        dim_new <- rbind(dim1, increment)
    })
    
    observeEvent(input$save, {
        dimensions$dim <- add_to_dims()
        updateRadioButtons(
            session, 
            "group", 
            "Select the input mode", 
            group_options,
            selected = character(0))
        updateTextInput(
            session, 
            "exercise_name", 
            label = "Give the exercise type to be saved",
            value = "   ")
        saveData()
    })
    
    exercise_names <- reactive({
#        selected_group()
        dimensions$dim$exercise_name
    })
    
    observeEvent(input$tabs, {
        updateSelectInput(session, "new_exercise", choices = exercise_names())
    })
    
    selected_group <- reactive({
        name <- input$new_exercise
        group <- dimensions$dim$group[dimensions$dim$exercise_name == name]
        
        print(length(group))

        # if (identical(group, factor(0))) {
        if (length(group) == 0) {
            g <- -1
        } else if (group == "Sets, reps, weights") {
            g <- TRUE
        } else if (group == "Duration, level") {
            g <- FALSE
        } else {
            g <- -1
        }
        g
    })
    
    output$group <- reactive({
        selected_group()
    })
    outputOptions(output, "group", suspendWhenHidden = FALSE)
#     group <- reactive({
# #        print(input$group)
#         input$group
#     })
    
    saveData <- function() {
        write.csv(dimensions$dim, dimensionFile, row.names = FALSE)
    }
        
    # myValues <- reactiveValues(
    #     # exercise_name = dimensions$exercise_name,
    #     # group = dimensions$group)
    #     a=1)

    # observeEvent(input$save, {
    #     myValues$exercise_name = c(myValues$exercise_name, input$exercise_name)
    #     myValues$group = c(myValues$group, input$group)
    # })
    # 
    output$distPlot <- renderPlot({
    })

})
