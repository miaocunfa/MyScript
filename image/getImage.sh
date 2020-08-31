#!/bin/bash

# Describe:     Get Photo From Dir
# Create Date： 2020-08-31 
# Create Time:  23:12
# Author:       MiaoCunFa

#-------------------
# GLOBAL VARIABLES
#-------------------

EXITCODE=0
workDir="/home/miaocunfa/MyScript/image"
origin_image_dir="${workDir}/origin-image"
sid_image_dir="${workDir}/sid-image"
sid="${workDir}/sid.txt"

#-------------------
# Function
#-------------------

__exit_handler()
{
    exit $EXITCODE
}

__getImage()
{
    image=$1

    # 判断是否存在该学号的原始图片
    if [ -f "${origin_image_dir}/${image}" ]
    then
        cp ${origin_image_dir}/${image} ${sid_image_dir}/${image}
    else
        echo "${origin_image_dir}/${image}: No such file or directory"
    fi
}

#-----------------------------------------
# Main Script 
#-----------------------------------------

cd ${workDir}

if [ ! -d ${sid_image_dir} ]
then
    mkdir ${sid_image_dir}
fi

# 判断是否存在学号文件
if [ -f "${sid}" ]
then

    # 遍历学号文件
    for id in `cat ${sid}` 
    do
        # 根据学号将原始图片存入临时文件夹
        __getImage ${id}
    done

else
    echo "${sid}: No such file or directory"
    __exit_handler
fi
