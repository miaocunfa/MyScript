#!/bin/bash

# Describe:     Get Image By File 
# Create Date： 2020-08-31 
# Create Time:  23:12
# Update Date： 2020-09-01 
# Update Time:  09:07
# Author:       MiaoCunFa

#---------------------------Variable--------------------------------------

EXITCODE=0
workDir="/home/miaocunfa/MyScript/get-image"
origin_image_dir="${workDir}/origin-image"
sid_image_dir="${workDir}/sid-image"
sid_file="${workDir}/sid.txt"

#---------------------------Function--------------------------------------

__exit_handler()
{
    exit $EXITCODE
}

__getSidImage()
{
    sid_image=$1

    # 判断是否存在该学号的原始图片
    if [ -f "${origin_image_dir}/${sid_image}" ]
    then
        cp ${origin_image_dir}/${sid_image} ${sid_image_dir}/${sid_image}
    else
        echo "${origin_image_dir}/${sid_image}: No such file or directory"
    fi
}

#--------------------------Main Script------------------------------------

if [ ! -d ${sid_image_dir} ]
then
    mkdir ${sid_image_dir}
fi

if [ -f "${sid_file}" ]             # 判断是否存在学号文件
then
    for sid in `cat ${sid_file}`    # 遍历学号文件
    do
        __getSidImage ${sid}        # 根据学号将原始图片存入临时文件夹
    done
else
    echo "${sid_file}: No such file or directory"
    __exit_handler
fi
