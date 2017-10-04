#-------------------------------------------------------------------------------

get_connection_settings <- function() {
  con_settings <- Sys.getenv(c(drv = 'DB_DRIVER',
                               dbname = 'DB_NAME',
                               host = 'DB_HOST', 
                               port = 'DB_PORT', 
                               user = 'DB_USER', 
                               password = 'DB_USER_PASS'))
  return(con_settings)
}

get_connection <- function(con_settings){
  connection <- RPostgreSQL::dbConnect(drv = con_settings[['drv']],
                                       dbname = con_settings[['dbname']],
                                       host = con_settings[['host']],
                                       port = con_settings[['port']],
                                       user = con_settings[['user']],
                                       password = con_settings[['password']])
  return(connection)
}


