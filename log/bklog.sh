#!/bin/bash

#-------------------
# Function
#-------------------

exit_handler()
{
    exit $EXITCODE
}

bklog()
{
    if [ ! -d $WORKDIR/oldlogs/$logshort/$TODAY ]
    then
        mkdir -p $WORKDIR/oldlogs/$logshort/$TODAY
    fi
                
    SEQ=$((`ls -l ${WORKDIR}/oldlogs/$logshort/$TODAY/$logshort.$TODAY.[0-9]* 2> /dev/null | wc -l`))
    OUTFILE="${WORKDIR}/oldlogs/$logshort/$TODAY/$logshort.$TODAY.$SEQ"
}

#-------------------
# GLOBAL VARIABLES
#-------------------

ENVFILE="$HOME/.bash_profile"

YEAR=`/bin/date +"%Y"`
MONTH=`/bin/date +"%m"`
DAY=`/bin/date +"%d"`

TODAY="${YEAR}${MONTH}${DAY}"

EXITCODE=0

WORKDIR="/opt/aihangxunxi/logs"

#----------------------------
# Load the environment file 
#----------------------------

if [ -r "$ENVFILE" ]
then
    . $ENVFILE
else
    EXITCODE=-1
    exit_handler
fi

#-----------------------------------------
# Reset and save the current log files
#-----------------------------------------

cd $WORKDIR

if [ ! -d oldlogs ]
then
    mkdir oldlogs
fi

filespec=$1

if [ -n "$filespec" ]
then
    if [ -f $filespec ]
    then
        logshort=`echo $filespec | awk -F. '{print $1}'`

        bklog
        cp $filespec $OUTFILE
        >$filespec
        zip -m $OUTFILE.zip $OUTFILE 
    else
        echo "$filespec: No such file or directory"
        exit_handler
    fi
else
    for logfile in `ls info*.log`
    do
        if [ -s $logfile ]
        then
            logshort=`echo $logfile | awk -F. '{print $1}'`

            bklog
            cp $logfile $OUTFILE
            >$logfile
            zip -m $OUTFILE.zip $OUTFILE
        fi
    done
fi

exit_handler
