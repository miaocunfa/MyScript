#!/bin/bash

exit_handler()
{
    exit $EXITCODE
}

##############
# Main
##############

##################
# GLOBAL VARIABLES
##################
ENVFILE="$HOME/.bash_profile"

YEAR=`/bin/date +"%Y"`
MONTH=`/bin/date +"%m"`
DAY=`/bin/date +"%d"`

TODAY="${YEAR}${MONTH}${DAY}"

EXITCODE=0

WORKDIR="/opt/aihangxunxi/logs"

####################################
# Load the environment file 
####################################

if [ -r "$ENVFILE" ]
then
    . $ENVFILE
else
    EXITCODE=-1
    exit_handler
fi

########################################
# Reset and save the current trace files
########################################

cd $WORKDIR

if [ ! -d oldlogs ]
then
    mkdir oldlogs
fi

for logfile in `ls info*.log`
do
    if [ -s $logfile ]
	then
        logshort=`echo $logfile | awk -F. '{print $1}'`

        if [ ! -d $WORKDIR/oldlogs/$logshort/$TODAY ]
        then
            mkdir -p $WORKDIR/oldlogs/$logshort/$TODAY
        fi
        
        SEQ=$((`ls -l ${WORKDIR}/oldlogs/$logshort/$TODAY/$logshort.$TODAY.[0-9]* 2> /dev/null | wc -l`))
        OUTFILE="${WORKDIR}/oldlogs/$logshort/$TODAY/$logshort.$TODAY.$SEQ"

        mv $logfile $OUTFILE
        zip -m $OUTFILE.zip $OUTFILE
    fi
done

exit_handler
