require(RPostgreSQL)


get_connection_settings <- function() {
  con_settings <- Sys.getenv(c('DB_DRIVER',
                               'DB_NAME',
                               'DB_HOST', 
                               'DB_PORT', 
                               'DB_USER', 
                               'DB_USER_PASS'))
  return(con_settings)
}

get_connection <- function(con_settings){
  connection <- dbConnect(drv = con_settings[[1]],
                          dbname = con_settings[[2]],
                          host = con_settings[[3]],
                          port = con_settings[[4]],
                          user = con_settings[[5]],
                          password = con_settings[[6]])
  return(connection)
}

shiny_sql_date_range_query <- function(connection, date_range) {
  start_date <- date_range[1]
  end_date <- date_range[2]
  query <- paste("SELECT id
                  INTO TEMP dates_t
                  FROM sales_hist
                  WHERE sale_date >=", start_date, "AND sale_date <", end_date)
  dbSendQuery(connection, query)
}

shiny_sql_get_query <- function(connection) {
  query <- "SELECT * 
            FROM dates_t
            INNER JOIN properties ON dates_t.id = properties.id"
  result <- dbGetQuery(connection, query)
  return(result)
}

#
shiny_get_df_from_RDS <- function(date_range){
  con_settings <- get_connection_settings()
  connection <- get_connection(con_settings)
  shiny_sql_date_range_query(connection, date_range)
  df <- shiny_sql_get_query(connection)
  dbDisconnect(connection)
  return(df)
}

