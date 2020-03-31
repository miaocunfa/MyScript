#!/bin/bash

#===================================================================
ENVFILE="/etc/profile"
EXITCODE=0
curDate=`date +'%Y%m%d'`
curTime=`date +'%H%M%S'`

tcpMessagePort=8555
tcpMessagePortSleep=2
messagelib=info-message-service.jar

deployPath=/home/miaocunfa
workPath=/opt/aihangxunxi
worklibPath=$workPath/lib
full_service_file=$workPath/bin/deploy.service

full_service=${full_service:-default}
service_num=${service_num:-default}
success_num=${success_num:-default}
failed_num=${failed_num:-default}

#===================================================================
cd $deployPath

full_service=`ls *.jar`

>$full_service_file
echo $full_service >> $full_service_file

echo
echo "ls $deployPath"
echo "$full_service"
echo

echo $full_service | grep -wq "$messagelib" && isMessage="0" || isMessage="1"

if [ $isMessage == "0" ]
then
    cd $workPath/bin
    cur_datetime=`date +'%Y%m%d%H%M%S'`

    ./stop.sh $messagelib
    
    mv $worklibPath/$messagelib    $worklibPath/$messagelib.$cur_datetime
    mv $deployPath/$messagelib     $worklibPath/$messagelib


    tcpMessagePortNum=$(ss -an | grep $tcpMessagePort | awk '$1 == "tcp" && $2 == "LISTEN" {print $0}' | wc -l)
    echo
    echo "waiting for message connection close..."
    echo


    while [ $tcpMessagePortNum -ge 1 ]
    do
        sleep $tcpMessagePortSleep
        tcpMessagePortNum=$(ss -an | grep $tcpMessagePort | awk '$1 == "tcp" && $2 == "LISTEN" {print $0}' | wc -l)
    done
    
    ./start.sh $messagelib
fi

full_service=`ls $deployPath`

echo
echo "ls $deployPath"
echo "$full_service"
echo

for i in `ls $deployPath`
do
    cd $workPath/bin
    cur_datetime=`date +'%Y%m%d%H%M%S'`

    ./stop.sh $i

    mv $worklibPath/$i    $worklibPath/$i.$cur_datetime
    mv $deployPath/$i     $worklibPath/$i

    ./start.sh $i
done

for i in `cat $full_service_file`
do

done

ps -ef| grep info-message | grep -v "grep"

service_num=``

echo "Total $service_num Service are Deploy!"
echo "Successfully $success_num    Failed $failed_num"
