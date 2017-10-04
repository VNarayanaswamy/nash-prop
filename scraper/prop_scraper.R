library(stringr)
library(RCurl)
library(XML)
library(jsonlite)

#takes a range of numbers and returns a nested json of property records
#each property has three associated pages
#record types of interest are located by html tags 
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






