#!/bin/bash

# Describe:     Get Image By File 
# Create Date： 2020-08-31 
# Create Time:  23:12
# Update Date： 2020-09-08 
# Update Time:  09:38
# Author:       MiaoCunFa

#---------------------------Variable--------------------------------------

EXITCODE=0
workDir="/home/miaocunfa/MyScript/get-image"
origin_image_dir="${workDir}/origin-image"
sid_image_dir="${workDir}/sid-image"
sid_file="${workDir}/sidReplace.txt"

#---------------------------Function--------------------------------------

__exit_handler()
{
    exit $EXITCODE
}

__getSidImage()
{
    tid_image=$1.JPG
    sid_image=$2.JPG

    # 判断是否存在该学号的原始图片
    if [ -f "${origin_image_dir}/${tid_image}" ]
    then
        cp ${origin_image_dir}/${tid_image} ${sid_image_dir}/${sid_image}
    else
        echo "${origin_image_dir}/${tid_image}: No such file or directory"
        return
    fi
}

#--------------------------Main Script------------------------------------

if [ ! -d ${sid_image_dir} ]
then
    mkdir ${sid_image_dir}
fi

if [ -f "${sid_file}" ]             # 判断是否存在学号文件
then
    while read -r line
    do
        test_id=$(echo $line | awk '{print $1}')
        student_id=$(echo $line | awk '{print $2}')
        __getSidImage ${test_id} ${student_id}       # 根据学号将原始图片存入临时文件夹
    done < $sid_file
else
    echo "${sid_file}: No such file or directory"
    __exit_handler
fi
