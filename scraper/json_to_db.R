# ------------------------------------------------------------------------------

dfs_from_json <- function(json) {
  df_list <- jsonlite::fromJSON(json)
  prop_df <- cbind(df_list$Property, df_list$Building)
  uuid <- uuid::UUIDgenerate()
  prop_df$id <- uuid
  df_list$Sales$id <- uuid
  df_list$Appraisals$id <- uuid
  return(list(prop = prop_df,
              sales = df_list$Sales,
              appr = df_list$Appraisals))
}

combine_props <- function(dfs_list) {
  props <- lapply(dfs_list, '[[', 1)
  return(jsonlite::rbind_pages(props))
}

combine_sales <- function(dfs_list) {
  props <- lapply(dfs_list, '[[', 2)
  return(jsonlite::rbind_pages(props))
}

combine_apprs <- function(dfs_list) {
  props <- lapply(dfs_list, '[[', 3)
  return(jsonlite::rbind_pages(props))
}

simple_colnames <- function(df) {
  df_names <- names(df)
  df_names <- stringr::str_replace_all(df_names, ' & | |\\*', '_')
  df_names <- stringr::str_to_lower(df_names)
  return(df_names)
}

mutate_props <- function(df) {
  names(df) <- simple_colnames(df)
  df <- dplyr::mutate_each(df, 
                           dplyr::funs(stringr::str_replace_all(., 
                                                                '\\$|,', '')),
                           c(10, 13:16, 23))
  
  df <- dplyr::mutate_each(df,
                           dplyr::funs(stringr::str_replace_all(.,
                                                                ' Acres', '')),
                           c(20))
  
  df <- dplyr::mutate_each(df,
                           dplyr::funs(as.numeric),
                           c(10, 13:16, 20, 23, 28:32, 35))
  
  df$sale_date <- as.Date(df$sale_date, "%m/%d/%Y")
  df <- dplyr::mutate(df, zip_code = stringr::str_sub(mailing_address, -5))
  return(df)
}

mutate_sales <- function(df) {
  names(df) <- simple_colnames(df)
  df$sale_date <- as.Date(df$sale_date, "%m/%d/%Y")
  df$sale_price <- stringr::str_replace_all(df$sale_price, '\\$|,', '')
  df$sale_price <- as.numeric(df$sale_price)
  return(df)
}

mutate_apprs <- function(df) {
  df <- dplyr::mutate_each(df,
                           dplyr::funs(stringr::str_replace_all(.,
                                                                '\\$|,', '')),
                           c(3:5,7))
  
  df <- dplyr::mutate_each(df, dplyr::funs(as.numeric), c(3:5,7))
  return(df)
}

write_db <- function(con, sql_tbl, df){
  RPostgreSQL::dbWriteTable(con, sql_tbl, df, row.names=F, append=T)
}
