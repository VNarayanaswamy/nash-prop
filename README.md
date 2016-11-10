## What's happening to Nashville? 

Ask any Nashvillian how the city is changing and they will tell you that it is growing at a breakneck speed. The skyline is peppered with cranes and entire blocks are being knocked down and rebuilt.  My friends who are trying to buy houses speak with the despondent tone of hardened war vets. To have your offer even glanced at you better make it on the first day of listing and be over asking by at least $10K.  Don't even bother with East Nashville or Sylvan Park...  I wanted to see if the hype matches reality and if this really is a time like nothing the city has seen before.  

## tl;dr

Finished product [here](http://ec2-52-87-236-113.compute-1.amazonaws.com:3838/nash_prop)
![alt text](https://github.com/davidcearl/nash-prop/raw/master/example_screenshot.png "example screenshot")

## To the Data!

Zillow can tell you what they think your property will be worth next year and lots of other cool stats to brag about to your homeless friends, but I wanted the raw data.  Public property assessor [records](http://padctn.org/) to the rescue! If you have a list of address you can search one property at a time, but I don't have such a list and that will take far too long.  Conveniently the results pages follow a simple format.  Each property is simply indexed by number and has a few associated pages. So I can dynamically generate the links and scrape the data I want using html tags. At this point I'm not exactly sure how I'll use the data so I'll store the scraped records as json.  The R package jsonlite makes this super simple.

## Setting up AWS

I decided to spin up an ec2 instance to run my scrapper and develop the rest of the project using rstudio server. I also will store data as I go in an s3 bucket. The AWS CLI tool makes managing AWS resources quick and easy.  

```
sudo pip install awscli
#set credentials and region
aws configure
# make the s3 bucket
aws s3 mb s3://nash-prop/ 
#create a security group for the ec2 instance
aws ec2 create-security-group --group-name dev-nash --description "security group for development environment for nash-prop"
#enable ports for ssh, rstuido
aws ec2 authorize-security-group-ingress --group-name dev-nash --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-name dev-nash --protocol tcp --port 8787 --cidr 0.0.0.0/0
#create key pair
aws ec2 create-key-pair --key-name nash-prop-key --query 'KeyMaterial' --output text > nash-prop-key.pem
#launch instance
aws ec2 run-instances --image-id ami-c481fad3 --security-group-ids <security_group_id> --count 1 --instance-type t2.medium --key-name nash-prop-key --query 'Instances[0].InstanceId'
#get the public ip
aws ec2 describe-instances --instance-ids <instance_id> --query 'Reservations[0].Instances[0].PublicIpAddress'
```

Now after setting the correct permissions on the new .pem key I can ssh into the instance and install rstudio.

```
#ssh into ec2 instance
ssh -i <path_to_key> ec2-user@<public_ip>
#install R
sudo yum -y R
#install rstudio
wget https://download2.rstudio.org/rstudio-server-rhel-0.99.903-x86_64.rpm
sudo yum install --nogpgcheck rstudio-server-rhel-0.99.903-x86_64.rpm
#add rstudio user
sudo useradd rstudio
sudo passwd rstudio
#install dependencies for r packages 
sudo yum install libcur*
sudo yum install libxml*
sudo yum install openssl
sudo yum install libpng-devel
sudo yum install libjpeg-devel
```

# Time to scrape
Now I can run my scrapping [function](https://github.com/davidcearl/nash-prop/blob/master/prop_scraper.R) on the 250,000+ properties in Davidson County
```r
#takes a range of numbers and returns a nested json of property records
#each property has three associated pages
#records of interest are located by html tags 
get_prop_rec <- function(num_val) {
  prop_records <- c()
  for (prop_num in num_val) {
    
    # get prop summary
    address <- paste0("http://www.padctn.org/prc/property/", prop_num, "/card/1")
    property_search <- getURL(address)
    search_page <- htmlParse(property_search)
    t_page <- paste(capture.output(search_page, file = NULL), collapse = "\n")
    lat_long <- unlist(str_split(str_sub(unlist(str_extract_all(t_page, '/lat.*>')), 6, 33), '/lng/'))
    lat <- paste('LAT:', lat_long[1])
    long <- paste('LNG:', lat_long[2])
    prop_sum <- str_extract_all(t_page, '<strong>.*</li>')
    sum_vec <- unlist(prop_sum)
    tag_rem_sum <- str_trim(str_replace_all(sum_vec, "<.*?>", ""))
    prop_summary <- toJSON(c(tag_rem_sum, lat, long))
    
    # get prop details
    address <- paste0("http://www.padctn.org/prc/property/", prop_num, "/card/1/interior")
    property_details <- getURL(address)
    details_page <- htmlParse(property_details)
    t_details <- paste(capture.output(details_page, file = NULL), collapse = "\n")
    juciy_deats <- str_extract_all(t_details, '<strong>.*</li>')
    deats_vec <- unlist(juciy_deats)
    tag_rem_deats <- str_trim(str_replace_all(deats_vec, "<.*?>", ""))
    details_summary <- toJSON(tag_rem_deats)
        
    # get prop history
    address <- paste0("http://www.padctn.org/prc/property/", prop_num, "/card/1/historical")
    property_history <- getURL(address)
    history_page <- htmlParse(property_history)
    t_history <- paste(capture.output(history_page, file = NULL), collapse = "\n")
    prop_hist  <- str_extract_all(t_history, '<table|<th>.*</th>|<td>.*</td>')
    hist_vec <- unlist(prop_hist)
    tag_rem_hist <- str_trim(str_replace_all(hist_vec, "<.*?>", ""))
    table_starts <- which(match(tag_rem_hist, "<table") == 1)
    sales_hist <- toJSON(t(matrix(tag_rem_hist[(table_starts[1]+1):(table_starts[2]-1)], nrow = 4)))
    app_hist <- toJSON(t(matrix(tag_rem_hist[(table_starts[2]+1):length(tag_rem_hist)], nrow = 7)))
    
    # combine into single json obj
    property_record <- toJSON(list(prop_summary, details_summary, sales_hist, app_hist))
    prop_records <- c(prop_records, property_record)
    
  }
  return(prop_records)
}
```

# Getting the data into a usable format

I ultimately want to interactively plot the data through time.  Each property has records of every sale with some going back to the 1800s! After [cleaning up](https://github.com/davidcearl/nash-prop/blob/master/json_to_df.R) the data I decided to split things up into three tables.  One will be a table with general info about property such as location and square feet.  Then I'll have a table for sales history and one for appraisal history. Since the property assessors hasn't assingned robust ids to the properties I had to generate them so I can reliably link tables.  I also decided to store the cleaned data in a postgresql database hosted on AWS RDS

# Building an interactive web app with shiny

Shiny lets you quickly build interactive apps and offers [hosting](http://www.shinyapps.io/) services or you can run your own shiny server.  The two required parts of a shiny app are the ui function and the server function, but in this case I also needed to write a few [functions](https://github.com/davidcearl/nash-prop/blob/master/shiny-app/shiny_sql.R) so my shiny app can connect and query my database.  I want to be able to select a date range and view basic statistics for different parts of the city and view the results on a map of the county. The ui function can handle getting the user input and the server function will query the database based on the input and render the plot with ggplot

```r
shinyUI(fluidPage(
  titlePanel("Historical Davidson County Property Data"),
  
  sidebarLayout(sidebarPanel(sliderInput("selected_date", "Date:", min=as.Date("1990-01-01"), max=as.Date("2015-01-01"), value=as.Date("2005-01-01"), step=1),
                             radioButtons("period", "Window:", c("Year" = "year", "Month" = "month")),
                             p("Choosing Year will get all sales over a year long window with the selected date in the middle."),
                             p("Choosing Month will get all sales over a 31 day window with the selected date in the middle."),
                             selectInput("sum_func", "Summary Stat:",
                                         c("Number of Sales" = 'length',
                                           "Total Sale Amount" = 'sum',
                                           "Average Sale Price" = 'mean',
                                           "Median Sale Price" = 'median')),
                             p("Generate the plot"),
                             actionButton("goButton", "Ok")),
                mainPanel(plotOutput("prop_map", width = '500px')))
))
```

```r
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
      scale_fill_gradientn(colours = c('purple', 'red', 'yellow' ))
  })
})
```

## Time to explore!

When did the number of sales in East Nashville start to explode?  Are the most expensive parts of town in 2014 the same as the ones in 1994? What neighborhoods were most affected by the 2008 bubble? Take a look for [yourself!](http://ec2-52-87-236-113.compute-1.amazonaws.com:3838/nash_prop) 
