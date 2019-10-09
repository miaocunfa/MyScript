#!/bin/bash
# log_path
base_path='/usr/local/nginx-1.12.1/logs'
# get year and month
year_month=$(date -d yesterday +"%Y%m")
# get yesterday
day=$(date -d yesterday +"%d")

# create backup directory
mkdir -p $base_path/$year_month

# copy logfile to backup
mv $base_path/access.log $base_path/$year_month/access_$day.log

# 
echo $base_path/$year_month/access_$day.log
# reload logfile
kill -USR1 `cat /usr/local/nginx-1.12.1/logs/nginx.pid`
