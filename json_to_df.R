# clean scraped text
# combine tables
# create df
# assign each proptery a unique ID
library(uuid)
library(stringr)
library(jsonlite)
library(dplyr)
library(RPostgreSQL)






#gets the values from scrapped text and NA fills missing fields
get_prop_values <- function(records_table) {
  if (length(records_table) < 29) {
    return(rep("NA", 29))
  }
  index <- str_sub(records_table, -1) == ":"
  records_table[index] <- paste(records_table[index], "NA")
  record_values <- unlist(lapply(records_table, function(x) {str_split(x,":")[[1]][2]}))
  record_values <- str_trim(record_values)
  return(record_values)
}

get_sales_values <- function(sales_table) {
  if (nrow(sales_table) ==1){
    sales_table <- rbind(sales_table, rep("NA", ncol(sales_table)))
  }
  col_names <- str_to_lower(str_replace_all(sales_table[1,1:3], " ", "_"))
  if (nrow(sales_table) == 2) {
    vals <- sales_table[2:nrow(sales_table),1:3]
    names(vals) <- col_names
    return(as.data.frame(t(vals)))
  }
  vals <- sales_table[2:nrow(sales_table),1:3]
  colnames(vals) <- col_names
  return(as.data.frame(vals))
}

get_apprs_values <- function(apprs_table) {
  if (nrow(apprs_table) ==1){
    apprs_table <- rbind(apprs_table, rep("NA", ncol(apprs_table)))
  }
  col_names <- str_to_lower(str_replace_all(apprs_table[1,], " ", "_"))
  if (nrow(apprs_table) == 2) {
    vals <- apprs_table[2:nrow(apprs_table),]
    names(vals) <- col_names
    return(as.data.frame(t(vals)))
  }
  vals <- apprs_table[2:nrow(apprs_table),]
  colnames(vals) <- col_names
  return(as.data.frame(vals))
}



get_col_names <- function(records_table) {
  col_names <- unlist(lapply(records_table, function(x) {str_split(x,":")[[1]][1]}))
  col_names <- str_to_lower(str_replace_all(col_names, " ", "_"))
  return(col_names)
}

scrapped_text_to_tables <- function(prop_recs) {
    first_property <- get_prop_records(fromJSON(prop_recs[1]))
    for (i in 2:length(prop_recs)) {
      current_property <- get_prop_records(fromJSON(prop_recs[i]))
      first_property[[1]] <- rbind(first_property[[1]], current_property[[1]])
      first_property[[2]] <- rbind(first_property[[2]], current_property[[2]])
      first_property[[3]] <- rbind(first_property[[3]], current_property[[3]])
    }
    return(first_property)
}

default_prop_names <- c(  "location", "mailing_address", "legal_description", 
                          "assessment_classification*", "sale_date", 
                          "sale_price", "assessment_year", "last_reappraisal_year", 
                          "improvement_value", "land_value", "total_appraisal_value", 
                          "assessed_value", "property_use", "zone",
                          "neighborhood", "land_area", "property_type",
                          "year_built", "square_footage", "exterior_wall",
                          "story_height", "building_condition", "foundation_type",
                          "number_of_rooms", "number_of_beds", "number_of_baths", 
                          "number_of_half_bath", "number_of_fixtures", "lat", "lng"
                        )

get_prop_records <- function(records) {
  prop_table_1 <- fromJSON(records[1])
  #prop_table_2 <- fromJSON(records[2])
  sales_table <- fromJSON(records[3])
  apprs_table <- fromJSON(records[4])
  
  vals_1 <- get_prop_values(prop_table_1)
 
  names_vals_1 <- get_col_names(prop_table_1)
  
  if (length(vals_1) == 29) {
    vals_1 <- c(vals_1[1:12], "NA", vals_1[13:29])
    names_vals_1 <- default_prop_names
  }
  #vals_2 <- get_values(records_table_2)
  #names_vals_2 <- get_col_names(records_table_2)
  #prop_vals <- c(vals_1, vals_2)
  #names(prop_vals) <- c(names_vals_1, names_vals_2)
  prop_vals <- data.frame(t(vals_1))
  colnames(prop_vals) <- names_vals_1
  
  sales_vals <- get_sales_values(sales_table)
  apprs_vals <- get_apprs_values(apprs_table)
  
  unique_id <- UUIDgenerate()
  
  prop_vals$id <- unique_id
  sales_vals$id <- unique_id
  apprs_vals$id <- unique_id
  return(list(prop_vals, sales_vals, apprs_vals))
}




cleaned_records <- scrapped_text_to_tables(prop_records)



write_records_to_database <- function(cleaned_records){
  properties <- cleaned_records[[1]]
  
  df <- mutate_each(properties, funs(as.character))
  df <- mutate_each(df, funs(str_replace_all(., '\\$|,', '')), c(6,9:12,19))
  df <- mutate_each(df, funs(str_replace_all(., ' Acres', '')), c(16))
  df <- mutate_each(df, funs(as.numeric), c(6,9:12, 14:16, 19, 24:30))
  df$sale_date <- as.Date(df$sale_date, "%m/%d/%Y")
  df <- df %>% mutate(zip_code = str_sub(mailing_address, -5))
  
  dbWriteTable(con, "properties", df, row.names=F, append=T)
  
  sales_hist <- cleaned_records[[2]]
  
  df <- mutate_each(sales_hist, funs(as.character))
  df$sale_date <- as.Date(df$sale_date, "%m/%d/%Y")
  df$sale_price <- str_replace_all(df$sale_price, '\\$|,', '')
  df$sale_price <- as.numeric(df$sale_price)
  
  dbWriteTable(con, "sales_hist", df, row.names=F, append=T)
  
  apprs_hist <- cleaned_records[[3]]
  
  df <- mutate_each(apprs_hist, funs(as.character))
  df <- mutate_each(df, funs(str_replace_all(., '\\$|,', '')), c(3:5,7))
  df <- mutate_each(df, funs(as.numeric), c(3:5,7))
  
  dbWriteTable(con, "apprs_hist", df, row.names=F, append=T)

}


### load in all records
for (file in list.files("./")) {
    load(file)
    clean_records <- scrapped_text_to_tables(prop_records)
    write_records_to_database(clean_records)
}

