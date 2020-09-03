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
library(lubridate)

shinyServer(function(input, output, session) {
    
    #### Original files ####
    
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
    
    #### DIM TABLE ####

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
    
    exercise_names <- reactive({
        dimensions$dim$exercise_name
    })
    
    #### COMMON FACTORS ####
    
    observeEvent(input$tabs, {
        updateSelectInput(session, "new_exercise", choices = exercise_names())
    })

    #### FACT TABLE ####
        
    facts <- reactiveValues(
        fact = tryCatch(
            read.csv(workoutFile, header = TRUE, stringsAsFactors = FALSE),
            error = function(e) {
                data.frame(
                    date = character(),
                    exercise_name = character(),
                    sets = numeric(),
                    reps = numeric(),
                    weight = numeric(),
                    duration = numeric(),
                    level = numeric(),
                    stringsAsFactors = FALSE)
            })
    )

    workoutIncrement <- reactive({
        group <- selected_group()
        if (group == TRUE) {
            increment <- data.frame(
                date = input$date,
                exercise_name = input$new_exercise,
                sets = input$sets,
                reps = input$reps,
                weight = input$weights,
                duration = NA,
                level = NA
            )
        } else if (group == FALSE) {
            increment <- data.frame(
                date = input$date,
                exercise_name = input$new_exercise,
                sets = NA,
                reps = NA,
                weight = NA,
                duration = input$duration,
                level = input$level
            )
        }
    })
        
    add_to_facts <- reactive({
        fact <- facts$fact
        increment <- workoutIncrement()
        fact_new <- rbind(fact, increment)
    })
    
    output$factTable <- DT::renderDataTable({
        wholeTable <- facts$fact
        print(wholeTable)
        print(input$date)
        print(wholeTable$date)
        dateTable <- wholeTable[ymd(wholeTable$date) == ymd(input$date),]
        print(dateTable)
        return(dateTable)
    }, selection = 'none',server = TRUE, escape = FALSE, options = list(
        paging = TRUE,
        preDrawCallback = JS('function() {Shiny.unbindAll(this.api().table().node()); }'),
        drawCallback = JS('function() {Shiny.bindAll(this.api().table().node()); } ')
    ))
    
    selected_group <- reactive({
        name <- input$new_exercise
        group <- dimensions$dim$group[dimensions$dim$exercise_name == name]

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

    #### DATA SAVING ####
    
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
    
    saveData <- function() {
        write.csv(dimensions$dim, dimensionFile, row.names = FALSE)
    }

    saveWorkoutData <- function() {
        write.table(workoutIncrement(), workoutFile, col.names = FALSE, row.names = FALSE, append = TRUE, sep = ",")
    }
        
    observeEvent(input$saveWorkout, {
        facts$fact <- add_to_facts()
        saveWorkoutData()
    })
})
