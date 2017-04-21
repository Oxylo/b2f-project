# ---------------
# buildstrategy.R
# ---------------
# In this script the modeller defines the strategy to be tested on the server
#

# describe the hypothesis you want to test including short description of your strategy

# This strategy is a simple trend following strategy (a.k.a. 'luxor').
# The hypothesis to be tested is:
# When markets start trending up (down) they will keep on trending up (down) for a while.
# - Go long (and close all open short postions) when SMA(10) >= SMA(30)
# - GO short (and closs all open long positions) when SMA(10) < SMA(30)


# set up your trading parameters
strat.name <- "luxor" # give your strategy a nice name
#
# all of the following have been moved to Globals but are still
# available for use in strategy
#
# cpair <- 'GBPUSD'     # currency pair 
# from <- "2016-01-01"  # start date data series YYYY-MM-DD
# to <- "2016-02-01"    # end date data series YYYY-MM-DD
# frequency <- "Min30"  # downsampling frequency (Min3, Min5, Min10, Min15, Min30, H, W, M, Y)
# initEq <- 1000000     # initial equity in quote currency
# threshold <- 0.0005   # TO DO: figure out cost loadings
# orderqty <- 1000      # order quantity
# txn.fees <- 0         # transaction fees

# build your strategy by adding indicators, signals and rules

buildstrategy <- function(){
  
  # add indicators
  add.indicator(strategy = strategy.st,
                name = "SMA",
                arguments = list(x=quote(Cl(mktdata)), n=10),
                label = "nFast")
  add.indicator(strategy = strategy.st,
                name = "SMA",
                arguments = list(x=quote(Cl(mktdata)), n=30),
                label = "nSlow")
  
  # add signals
  add.signal(strategy = strategy.st,
             name = 'sigCrossover',
             arguments = list(columns=c("nFast", "nSlow"), relationship="ge"),
             label='long')
  add.signal(strategy = strategy.st,
             name = 'sigCrossover',
             arguments = list(columns=c("nFast", "nSlow"), relationship="lt"),
             label='short')
  
  # add entry rules 
  add.rule(strategy = strategy.st,
           name = 'ruleSignal',
           arguments = list(sigcol='long', sigval=TRUE, orderside='long', ordertype='stoplimit',
                            prefer='High', threshold=threshold, orderqty=+orderqty, replace=FALSE),
           type = 'enter',
           label = 'EnterLONG')
  
  add.rule(strategy = strategy.st,
           name = 'ruleSignal',
           arguments = list(sigcol='short', sigval=TRUE, orderside='short', ordertype='stoplimit',
                            prefer='Low', threshold=threshold, orderqty=-orderqty, replace=FALSE),
           type = 'enter',
           label = 'EnterSHORT')
  
  # add exit rules
  add.rule(strategy.st,
           name='ruleSignal',
           arguments=list(sigcol='long', sigval=TRUE, orderside='short', ordertype='market',
                          orderqty='all', TxnFees=txn.fees, replace=TRUE),
           type='exit',
           label='Exit2LONG')
  
  add.rule(strategy.st,
           name='ruleSignal',
           arguments=list(sigcol='short', sigval=TRUE, orderside='long', ordertype='market',
                          orderqty='all', TxnFees=txn.fees, replace=TRUE),
           type='exit',
           label='Exit2SHORT')
  }
