#!/bin/bash

#===================================================================
ENVFILE="/etc/profile"
EXITCODE=0
curDate=$(date +'%Y%m%d')
curTime=$(date +'%H%M%S')

workPath=/opt/aihangxunxi
worklibPath=$workPath/lib

tcpMessageSleep=1
tcpMessagePort=8555
tcpMessageSock=9666
tcpMessagePortNum=1
tcpMessageSocktNum=1
messagelib=info-message-service.jar

deployPath=/home/miaocunfa
deploy_ps_sleep=1
deploy_ps_num=1
deploy_ps_file=$workPath/bin/.deploy.ps.service

total_service_file=$workPath/bin/.total.service
total_service_ps_file=$workPath/bin/.total.service.ps
total_service=${total_service:-default}
service_num=0
success_num=0
failed_num=0

#===================================================================
cd $deployPath

total_service=$(ls *.jar)
echo $total_service >> $total_service_file

echo
echo "ls $deployPath"
echo "$total_service"
echo

echo $total_service | grep -wq "$messagelib" && isMessage="0" || isMessage="1"

if [ $isMessage == "0" ]
then
    cd $workPath/bin
    cur_datetime=$(date +'%Y%m%d%H%M%S')

    ./stop.sh $messagelib
    
    mv $worklibPath/$messagelib    $worklibPath/$messagelib.$cur_datetime
    mv $deployPath/$messagelib     $worklibPath/$messagelib

    echo
    echo "Waiting for MessageService Port Connection Close!"
    echo

    while ( [ $tcpMessagePortNum -ge 1 ] || [ $tcpMessageSocktNum -ge 1 ] )
    do
        sleep $tcpMessageSleep
        tcpMessagePortNum=$(ss -an | grep $tcpMessagePort | awk '$1 == "tcp" && $2 == "LISTEN" {print $0}' | wc -l)
        tcpMessageSocktNum=$(ss -an | grep $tcpMessageSock | awk '$1 == "tcp" && $2 == "LISTEN" {print $0}' | wc -l)
    done
    
    sleep 2
    ./start.sh $messagelib
fi

total_service=$(ls $deployPath)

echo
echo "ls $deployPath"
echo "$total_service"
echo

for i in $(ls $deployPath)
do
    cd $workPath/bin
    cur_datetime=$(date +'%Y%m%d%H%M%S')

    ./stop.sh $i

    mv $worklibPath/$i    $worklibPath/$i.$cur_datetime
    mv $deployPath/$i     $worklibPath/$i

    while [ $deploy_ps_num -ge 1 ]
    do
        sleep $deploy_ps_sleep
        deploy_ps_num=$(ps -ef | grep $i | grep -v "grep" | wc -l)
    done

    sleep 2
    ./start.sh $i
done

for i in $(cat $total_service_file)
do
    ps -ef| grep $i | grep -v "grep" >> $total_service_ps_file

    if [ -s $total_service_ps_file ]
    then
        success_num=$(( $success_num + 1 ))
    else
        failed_num=$(( $failed_num + 1 ))
    fi

    cat $total_service_ps_file
    echo
    >$total_service_ps_file
done

service_num=$(awk '{print NF}' $total_service_file)

echo
printf "\tTotal [%02i] Service are Deploy\n" $service_num
printf "\tSuccessfully [%02i], Failed [%02i]\n" $success_num $failed_num
echo
printf "\tHave a good Day, see you later"
echo

>$total_service_ps_file
>$total_service_file
>$deploy_ps_file
