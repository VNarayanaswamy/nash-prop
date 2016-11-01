library(shiny)
library(ggmap)
library(ggplot2)
library(dplyr)
source("shiny_sql.R")

shinyServer(function(input, output) {  
  timespan <- 182
  map_nash <- qmap(c(-86.74866, 36.13875), zoom = 11, color = 'bw' )
 
  output$prop_map <- renderPlot({   
    input$goButton
    sum_function <- isolate(input$sum_func)
    center_date <- isolate(input$selected_date)
    per <- isolate(input$period)
    
    if (per == 'month'){
      timespan <- 15
    }
    
    start_date <- center_date - timespan
    end_date <- center_date + timespan
    
    
    df <- shiny_get_df_from_db(c(paste0("'",start_date,"'"), paste0("'",end_date,"'")))
    plot_nash <- df[-which(is.na(df$lat) & is.na(df$lng)),-1]    
    map_nash + 
      coord_cartesian() +
      stat_summary_2d(data = filter(plot_nash, sale_price < 1e6 & sale_price > 50000), aes(x = lng, y = lat, z = sale_price), fun = sum_function, binwidth = c(0.01,0.01), alpha = 0.6, geom = 'raster', interpolate = T) +
      scale_fill_gradientn(colours = c('purple', 'red', 'yellow' )) #, limits = c(0, 100))
    
  })
  
  
})
