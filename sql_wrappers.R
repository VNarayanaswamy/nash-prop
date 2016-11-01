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


