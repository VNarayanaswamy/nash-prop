library(shiny)

ui <- fluidPage(
  dateRangeInput("date_input",
                 "Date_range:",
                 start = "2015-01-01",
                 end = "2015-12-01",
                 format = "mm/dd/yy"),
  plotOutput("prop_map")
)
