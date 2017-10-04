library(shiny)

shinyUI(fluidPage(
  titlePanel("Historical Davidson County Property Data"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("selected_date",
                  "Date:",
                  min=as.Date("1990-01-01"),
                  max=as.Date("2015-01-01"),
                  value=as.Date("2005-01-01"),
                  step=1),
      radioButtons("period", "Window:", c("Year" = "year", "Month" = "month")),
      p(strwrap("Choosing Year will get all sales over a year 
                long window with the selected date in the middle.")),
      p(strwrap("Choosing Month will get all sales over a 31 day 
                window with the selected date in the middle.")),
      selectInput("sum_func", "Summary Stat:",
                 c("Number of Sales" = 'length',
                   "Total Sale Amount" = 'sum',
                   "Average Sale Price" = 'mean',
                   "Median Sale Price" = 'median')),
      p("Generate the plot"),
      actionButton("goButton", "Ok")),
    mainPanel(plotOutput("prop_map", width = '500px')))
))

