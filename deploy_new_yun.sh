#!/bin/bash

#-------------------
# Function
#-------------------

exit_handler()
{
    exit $EXITCODE
}

#-------------------
# GLOBAL VARIABLES
#-------------------

ENVFILE="$HOME/.bash_profile"

curDate=`date +'%Y%m%d'`
curTime=`date +'%H%M%S'`

EXITCODE=0

DeployDIR=(
    /home/miaocunfa
    /home/ahzll
)

WorkDIR=/ahdata/www
Zipfile=aihangyun-offical.zip
Unzipfile=aihangyun-offical
CurRelease=www.aihangyun.com

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
# Deploy new release and backup
#-----------------------------------------

cd $WorkDIR

if [ ! -d Release ]
then
    mkdir Release
fi

for i in "${DeployDIR[@]}";
do
    if [ -f $i/$Zipfile ]
    then
        mv $i/$Zipfile $WorkDIR
        unzip -o $Zipfile
        rm -rf __MACOSX

        mv $WorkDIR/$CurRelease Release/$CurRelease.bak$curDate$curTime
        mv $Unzipfile $CurRelease

        echo "Deploy Successfully!"

        exit_handler
    else
        echo
        echo "$i/$Zipfile        is not found!"
    fi
done

echo
exit_handler
