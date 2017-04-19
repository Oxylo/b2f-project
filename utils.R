# ----------------------
# utils.R
# ----------------------
# Contains function utilities

shift.strdate <- function(strdate, days=1, fmt="%Y-%m-%d") {
  #' Shift string date 
  #' 
  #' @description This function shifts a string representing a date
  #' by given number of days
  #' 
  #' @param str string. Represents a date
  #' @param days integer. Defaults to -1. If negative date is advanced, else delayed.
  #' @param fmt string. Defaults to ""%Y-%m-%d". Date format.
  #' 
  #' @return string. Represents advanced or delayed date.
  #' 
  #' @examples 
  #' shiftdate("2016-01-01", -1) = "2015-12-31"
  #' shiftdate("2016-01-01", 6) = "2016-01-07"
  date <- as.Date(strdate, fmt) + days
  return(as.character(date))
}


load.fxdata <- function(cpair) {
  #' Load FX data from Amazon database 
  #' 
  #' @description Conncects to AWS RDS database using credentials stored in globals.R 
  #' 
  #' @param cpair string. Currency pair in 6-character format XXXYYY where XXX=base and YYY=quote
  #' 
  #' @return data.frame with OHLC currency prices.
  #' 
  #' @examples 
  #' load.fxdata("EURUSD")
  
  require("RPostgreSQL")
  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv,
                   dbname='b2fdb',
                   user=USERNAME,
                   password=PASSWORD,
                   host='b2fdbinstance3.c1w9pflnbhj8.eu-west-1.rds.amazonaws.com',
                   port='5432')
  
  query <- paste("SELECT dtime, rate_open, rate_high, rate_low, rate_close ",
                 "FROM tbl_forexite ",
                 "INNER JOIN tbl_currency_pair CP ",
                 "ON ticker_id=CP.id ",
                 "WHERE ticker=\'", cpair, "\'", sep="")
  df <- dbGetQuery(con, query)
  dbDisconnect(con)
  return(df)
  }


get.base <- function(cpair){
  #' Get base currency from currency pair 
  #' 
  #' @description None
  #' 
  #' @param cpair string. Currency pair in 6-character format XXXYYY where XXX=base and YYY=quote
  #' 
  #' @return string. 
  #' 
  #' @examples 
  #' get.base("EURUSD") = "EUR"
  base  <- substr(cpair, 1, 3)
}


get.quote <- function(cpair){
  #' Get quote currency from currency pair 
  #' 
  #' @description None
  #' 
  #' @param cpair string. Currency pair in 6-character format XXXYYY where XXX=base and YYY=quote
  #' 
  #' @return string. 
  #' 
  #' @examples 
  #' get.quote("EURUSD") = "USD"
  quote <- substr(cpair, 4, 6)
}


init.currencypair <- function(cpair) {
  #' Initializes currency pair  
  #' 
  #' @description Converts string representing currency pair to instrument object. 
  #' Use getInstrument() to introspect this object. 
  #' 
  #' @param cpair string. Currency pair in 6-character format XXXYYY where XXX=base and YYY=quote
  #' 
  #' @return FinancialInstrument::instrument 
  #' 
  #' @examples 
  #' init.currencypair("EURUSD) 
  #' init.currenctpair("GBPUSD")
  base  <- get.base(cpair)
  quote <- get.quote(cpair) 
  currency(base)        # --> initialize currencies
  currency(quote) 
  exchange_rate(cpair, tick_size = 0.0001)  # --> define instrument
  return(getInstrument(cpair))
}


df2xts <- function(df) {
  #' Converts data.frame object to time series  
  #' 
  #' @description None 
  #' 
  #' @param df data.frame. First column should contain timestamp.
  #' 
  #' @return xts. Timeseries with timestamp as index.
  #' 
  #' @examples 
  #' df2xts(df) 
  xts <- xts(df[,-1], order.by=df[,1])
  return(xts)
  }


select.interval <- function(xts, from, to) {
  #' Select records within given time interval 
  #' 
  #' @description None 
  #' 
  #' @param xts timeseries. Timeseries with timestamp as index.
  #' @param from string. Startdate with format YYYY-MM-DD .
  #' @param to string. Enddate with format YYYY-MM-DD .
  #' 
  #' @return xts. Timeseries with timestamp as index.
  #' 
  #' @examples 
  #' select.interval(df) 
  interval <- paste(from, "::", to, sep="")
  xts <- xts[interval] 
  return(xts)
  }


downsample <- function(xts, freq) {
  #' Select records within given time interval 
  #' 
  #' @description None 
  #' 
  #' @param xts timeseries. Timeseries with timestamp as index.
  #' @param from string. Startdate with format YYYY-MM-DD .
  #' @param to string. Enddate with format YYYY-MM-DD .
  #' 
  #' @return xts. Timeseries with timestamp as index.
  #' 
  #' @examples 
  #' select.interval(df)
  freqs <- c("Min3", "Min5", "Min10", "Min15", "Min30", "H", "W", "M", "Y")
  "%ni%" <- Negate("%in%")
  if (freq %ni% freqs) {
    stop(paste("Frequency should be in", freqs))}
  switch(freq,
         Min3 = to.minutes3(xts),
         Min5 = to.minutes5(xts),
         Min10 = to.minutes10(xts),
         Min15 = to.minutes15(xts),
         Min30 = to.minutes30(xts),
         H = to.hourly(xts),
         W = to.weekly(xts),
         M = to.monthly(xts),
         Y = to.yearly(xts))
}