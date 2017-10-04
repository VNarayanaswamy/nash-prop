# ------------------------------------------------------------------------------
# get basic property info

get_li <- function(parsed_card) {
  li <- XML::readHTMLList(parsed_card)
  return(unlist(li[11:15]))
}

li_to_df <- function(li) {
  li <-stringr::str_split(li, ': ', simplify = T)
  df <- data.frame(matrix(NA_character_, nrow = 1, ncol = dim(li)[1]),
                   stringsAsFactors = F)
  names(df) <- li[,1]
  df[1,] <- li[,2]
  return(df)
}

get_lat_lng <- function(parsed_card) {
  lat_lng_href <- unlist(XML::xpathApply(parsed_card,
                                         "//a[@data-maptype]", 
                                         XML::xmlGetAttr, 
                                         "href"))
  lat <- stringr::str_sub(lat_lng_href, -26, -16)
  lng <- stringr::str_sub(lat_lng_href, -12, -1)
  return(c('lat' = lat, 'lng' = lng))
}

append_lat_lng <- function(df, lat_lng) {
  df$lat <- lat_lng[['lat']]
  df$lng <- lat_lng[['lng']]
  return(df)
}

parse_base_card <- function(url) {
  if (RCurl::url.exists(url)) {
    parsed_card <- XML::htmlParse(RCurl::getURL(url))
    df <- li_to_df(get_li(parsed_card))
    lat_lng <- get_lat_lng(parsed_card)
    df <- append_lat_lng(df, lat_lng)
    return(df)
  }
}

# ------------------------------------------------------------------------------
# get interior details

get_interior_li <- function(parsed_card) {
  li <- XML::readHTMLList(parsed_card)
  return(unlist(li[11:14]))
}

parse_interior_card <- function(url) {
  if (RCurl::url.exists(url)) {
    parsed_card <- XML::htmlParse(RCurl::getURL(url))
    df <- li_to_df(get_interior_li(parsed_card))
    return(df)
  }
}

# ------------------------------------------------------------------------------
# get property history

parse_historical_tbls <- function(url) {
  if (RCurl::url.exists(url)) {
    parsed_card <- XML::htmlParse(RCurl::getURL(url))
    tbls <- XML::readHTMLTable(parsed_card)
    return(tbls)
  }
}

# ------------------------------------------------------------------------------
# main function

scrape_property <- function(prop_num) {
  url <- paste0("http://www.padctn.org/prc/property/", prop_num, "/card/1")
  basic <- parse_base_card(url)
  interior <- parse_interior_card(paste0(url, "/interior"))
  hist_tbls <- parse_historical_tbls(paste0(url, "/historical"))
  prop_data <- list(Property = basic,
                    Building = interior, 
                    Sales = hist_tbls[[1]], 
                    Appraisals = hist_tbls[[2]])
  return(jsonlite::toJSON(prop_dat))
}
