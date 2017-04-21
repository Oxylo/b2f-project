# ------------------------
# globals.R
# -----------------------
# Contains global varaibles (constants)
#
# These are used by team in building models.
# The test platform uses its own version

# credential to access AWS database
#
# Change These!
USERNAME <- 'wayneco'
PASSWORD <- ''

# You might want to change these for model building
# but the test platform will set these during testing
cpair <- 'GBPUSD'     # currency pair
from <- "2016-01-01"  # start date data series YYYY-MM-DD
to <- "2016-02-01"    # end date data series YYYY-MM-DD
frequency <- "Min30"  # downsampling frequency (Min3, Min5, Min10, Min15, Min30, H, W, M, Y)
initEq <- 1000000     # initial equity in quote currency
threshold <- 0.0005   # TO DO: figure out cost loadings
orderqty <- 1000      # order quantity
txn.fees <- 0         # transaction fees

# these shouldn't have to be changed
# the test platform will set these to different values
pg.dbname <- "b2fdb"  # postgres db name
pg.dbhost <- "localhost"
pg.dbport <- "5432"   # postgres db port
