:
######################
#
# Test B2F strategy and collect results
#
#
# Usage:
#
# test_strat.sh strat_file.R
#
# strat_file.R is a B2F strategy file
#
######################
# Setup
#
# initialize vars
stratfile=$1
if [ ! -f "$stratfile" ]
then
	echo "Usage: $0 strat_file.R"
	exit
fi

homedir=~
gitdir=$homedir/b2f-project
workdir=$homedir/work.$$
mkdir -m777 -p $workdir

# copy files
# git
for i in testGlobals.R testMain.R newUtils.R
do
cp $gitdir/$i $workdir
done

# strategy
cp $stratfile $workdir/testStrategy.R


######################
# Run Strategy
#
cd $workdir

/usr/bin/time --format="%e" --output=time.txt Rscript ./testMain.R


# gather results

elapsedtime=`cat time.txt`
stratname=`cat stratName.txt`
emailaddr=`cat email.txt`
rankperf=`cat rankperf.txt`
results=`cat results.txt`

# post results
mailx -s \"B2F results for $stratname:$rankperf in $elapsedtime\" -r wayneco@dades.ca -c wayneco@dades.ca $emailaddr <results.txt
# insert into postgres


# clean up
cd $homedir
# for now, keep the workdirs for debugging
# rm -r $workdir



