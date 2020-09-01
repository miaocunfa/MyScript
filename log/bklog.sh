#!/bin/bash

# Describe:     Log archive
# Create Date： 2020-08-31 
# Create Time:  11:15
# Update Date： 2020-09-01 
# Update Time:  09:38
# Author:       MiaoCunFa
#
# Alias:
# ➜  vim /etc/profile
#    alias bklog='bklog(){ /opt/aihangxunxi/bin/bklog.sh $1; }; bklog';
# Usage:
# ➜  bklog
# ➜  bklog info-ahxx-service.log

#---------------------------Variable--------------------------------------

EXITCODE=0
curDate=$(date +'%Y%m%d')
workDir="/opt/aihangxunxi/logs"

#---------------------------Function--------------------------------------

__exit_handler()
{
    exit $EXITCODE
}

__bklog()
{
    logfile=$1

    # 判断文件大小是否为非0, 若LogFile的大小为0则跳出当前函数, 继续过滤其他LogFile
    if [ -s ${logfile} ]    
    then
        log_prefix=$(echo ${logfile} | awk -F. '{print $1}')
    else
        return
    fi

    # 根据服务名及日期创建归档目录
    if [ ! -d ${workDir}/oldlogs/${log_prefix}/${curDate} ]
    then
        mkdir -p ${workDir}/oldlogs/${log_prefix}/${curDate}
    fi
                
    # 将归档目录文件进行排序, 计算出当前归档的序号
    SEQ=$((`ls -l ${workDir}/oldlogs/${log_prefix}/${curDate}/${log_prefix}.${curDate}.[0-9]* 2> /dev/null | wc -l`))
    OUTFILE="${workDir}/oldlogs/${log_prefix}/${curDate}/${log_prefix}.${curDate}.$SEQ"

    cp $logfile $OUTFILE
    
    # 处理源文件
    >${logfile}
    
    # 处理归档文件
    zip -m $OUTFILE.zip $OUTFILE
}

#--------------------------Main Script------------------------------------

cd ${workDir}

if [ ! -d oldlogs ]
then
    mkdir oldlogs
fi

# 指定Logfile
logFileSpec=$1

if [ -n "${logFileSpec}" ]       # 判断指定Logfile是否为空, 为空则遍历logs文件夹
then
    __bklog ${logFileSpec}
else
    for logfile in `ls *.log`    # 遍历logs文件夹下所有Logfile
    do
        __bklog ${logfile}
    done
fi
