# -----------------------
# main.R:
# -----------------------
# Main program to process the strategy provided by the modeller 
#
# Note: make sure you are in the directory where the code lives! - use setwd(/path/to/source/files)
#
# install packages:
#
# install.packages("RPostgreSQL")
# install.packages("PerformanceAnalytics")
# install.packages("quantstrat", repos="http://R-Forge.R-project.org")
# install.packages("TTR")
# install.packages("devtools")
# require(devtools)
# install_github("IlyaKipnis/IKTrading")

require(IKTrading)
require(quantstrat)
require(PerformanceAnalytics)
source("testGlobals.R")
source("newUtils.R")
source("testStrategy.R")


# load, convert, select and downsample data
df <- load.fxdata(cpair)
ts <- df2xts(df)
rm(df)
ts <- select.interval(ts, from, to)
ts <- downsample(ts, frequency)              
do.call("<-",list(cpair, ts))  # See: http://stackoverflow.com/questions/18308092/r-blotter-error-in-getsymbol-pos-env-object-not-found

# rm(data)  # BWC - data doesn't exist

# clear the blotter environment (contains all portfolio and account objects.)
rm(list=ls(.blotter), envir=.blotter)

# initialize trading objects (instrument, portfolio, account, order and strategy)
Sys.setenv(TZ="UTC")            # --> attaches correct time zone to Dates in index
init.currencypair(cpair)
strategy.st <- portfolio.st <- account.st <- strat.name
rm.strat(strategy.st)           # --> necessary for rerunning the strategy.
initDate=shift.strdate(from, days = -1)
quote <- get.quote(cpair)
initPortf(portfolio.st, symbols=cpair, initDate=initDate, currency=quote)
initAcct(account.st, portfolios=portfolio.st, initDate=initDate, currency=quote, initEq=initEq)  # returns are computed from initEq
initOrders(portfolio.st, symbol=cpair, initDate=initDate)
strategy(strategy.st, store=TRUE)  # this is where we put all our indicators, signals, and rules. 

# build the strategy according to modeller's specifications in buildstrategy.R
buildstrategy()

# apply strategy
t1 <- Sys.time()
out <- applyStrategy(strategy=strategy.st, portfolios=portfolio.st)
t2 <- Sys.time()
print(t2-t1)

# set up analytics
updatePortf(portfolio.st)
dateRange <- time(getPortfolio(portfolio.st)$summary)[-1]
updateAcct(portfolio.st, dateRange)
updateEndEq(account.st)  # compute final equity

# produce performance stats
ts <- tradeStats(Portfolios = strat.name, Symbols = cpair)
ts.per.trade <- perTradeStats(Portfolio = strat.name, Symbol = cpair)
chart.Posn(Portfolio = strat.name, Symbol = cpair)

# save the strategy name so the scripts can file the results
writeLines(strat.name, "stratName.txt")
writeLines(notify.email, "email.txt")

# for now, just dump the results
# we should build a KPI structure here and write that for pickup by the scripts
save(ts, file="ts.RData")
save(ts.per.trade, file="ts.per.trade.RData")

