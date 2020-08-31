#!/bin/bash

# Describe:     Get Photo From Dir
# Create Date： 2020-08-31 
# Create Time:  23:12
# Author:       MiaoCunFa

#-------------------
# GLOBAL VARIABLES
#-------------------

EXITCODE=0
workDir="/home/miaocunfa/photo"
photoDir="${workDir}/origin-photo"
getDir="${workDir}/get-photo"
sid="${workDir}/sid.txt"

#-------------------
# Function
#-------------------

__exit_handler()
{
    exit $EXITCODE
}

__getPhoto()
{
    photo=$1

    cp ${photoDir}/${photo} ${getDir}/${photo}
}

#-----------------------------------------
# Main Script 
#-----------------------------------------

cd ${workDir}

if [ ! -d ${getDir} ]
then
    mkdir ${getDir}
fi

if [ -f "${sid}" ]
then
    for id in `cat ${sid}` 
    do
        __getPhoto ${id}
    done
else
    echo "${sid}: No such File or directory"
    __exit_handler
fi
