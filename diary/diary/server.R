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
shinyServer(function(input, output) {
    
    print(getwd())
    dimensionFile <- "./dimensions.csv"
    workoutFile <- "./workout.csv"
    
    # dimensions <<- tryCatch(
    #     read.csv(dimensionFile),
    #     error = function(e) {
    #         data.frame(
    #             excercise_name = character(), 
    #             group = character(), 
    #             stringsAsFactors = FALSE)
    #     }
    # )
    # print(dimensions)
    
    dimensions <- read.csv(dimensionFile, header = TRUE, sep = ",")
    print(dimensions)
    
    workouts <<- tryCatch(
        read.csv(workoutFile),
        error = function(e) {
            data.frame(
                datetime = character(),
                excercise_name = character(),
                streaks = numeric(),
                repetitions = numeric(),
                weight = numeric(),
                label = character(), 
                stringsAsFactors = FALSE)
        }
    )
    
    output$dimensionTable <- DT::renderDataTable({
        saveData()
        return(dimensions)
    }, selection = 'none',server = TRUE, escape = FALSE, options = list(
        paging = TRUE,
        preDrawCallback = JS('function() {Shiny.unbindAll(this.api().table().node()); }'),
        drawCallback = JS('function() {Shiny.bindAll(this.api().table().node()); } ')
        )
    )
    
    saveData <- function() {
        # Remove old entries from current break, bind the old and new entries and overwrite the original file with new table
        write.csv(dimensions, dimensionFile, row.names = FALSE)
    }
        

    output$distPlot <- renderPlot({

        # generate bins based on input$bins from ui.R
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)

        # draw the histogram with the specified number of bins
        hist(x, breaks = bins, col = 'darkgray', border = 'white')

    })

})
