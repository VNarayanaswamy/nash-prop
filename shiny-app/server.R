library(shiny)
library(ggplot2)
library(ggmap)
library(dplyr)
source("shiny_sql.R")

server <- function(input, output) {
  map_nash <- qmap(c(-86.74866, 36.13875), zoom = 11, color = 'bw')
  output$prop_map <- renderPlot({
  date_range <- c(as.character(min(input$date_input)), as.character(max(input$date)))
  date_range[1] <- paste0("'", date_range[1], "'")
  date_range[2] <- paste0("'", date_range[2], "'")
  
  df <- shiny_get_df_from_RDS(date_range)
  plot_nash <- df[-which(is.na(df$lat) & is.na(df$lng)),]
  map_nash + 
      coord_cartesian() +
      stat_summary_2d(data = filter(plot_nash, sale_price < 1e6 & sale_price > 50000), aes(x = lng, y = lat, z = sale_price), fun = sum_function, binwidth = c(0.01,0.01), alpha = 0.6, geom = 'raster', interpolate = T) +
      scale_fill_gradientn(colours = c('purple', 'red', 'yellow' )) #, limits = c(0, 100))
  })
}
