

drv <- dbDriver("PostgreSQL")

con <- dbConnect(drv, 
                 dbname = "nashprop", 
                 host=hst,
                 port = prt,
                 user = usr,
                 password = pw)


dbWriteTable(con, "apprs_hist", df, row.names=F)


dbListTables(con)

dbGetQuery(con, "SELECT * FROM properties WHERE id = 'a244b1d6-7e14-4d65-abb3-2d86e4764db9'")

dbRemoveTable(con, "properties")


dbGetRowCount(con, 'properties')

dbListTables(con)


foobar <- dbReadTable(con, 'properties')