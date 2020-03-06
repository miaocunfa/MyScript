#!/bin/bash

#===================================================================
ENVFILE="/etc/profile"
EXITCODE=0
curDate=`date +'%Y%m%d'`
curTime=`date +'%H%M%S'`
isFrame=${isFrame:-default}

service_frame=(
    info-admin
    info-config
    info-gateway
)

for i in "${service_frame[@]}"; 
do
    echo $JOB_NAME | grep -wq "$i" && isFrame="0" || isFrame="1"

    if [ $isFrame == "0" ];
    then
        pjName=$(echo $JOB_NAME | awk -F '-' '{print $1"-"$2"}')
        echo $pjName
    else
        pjName=$(echo $JOB_NAME | awk -F '-' '{print $1"-"$2"-"$3}')
        echo $pjName
    fi
done

#===================================================================
service_name=${service_name:-default}
dev_env=${dev_env:-default}
test_env=${test_env:-default}
fge_env=${fge_env:-default}
zkv2_env=${zkv2_env:-default}

workspace=/var/lib/jenkins/workspace/$JOB_NAME
jarHome=$workspace/$pjName/target
jarName=$pjName-0.0.1-SNAPSHOT.jar

remote_host=${remote_host:-default}
remote_lib=/opt/aihangxunxi/lib
remote_bin=/opt/aihangxunxi/bin
remote_lib_name=$pjName.jar

#===================================================================
service_deploy=(
    'service-name              dev                test               feature-goods-exchange    zhongku-v2'
    'info-ad-service           192.168.100.214    192.168.100.215    192.168.100.216           192.168.100.222'
    'info-agent-service        192.168.100.214    192.168.100.215    192.168.100.216           192.168.100.222'
    'info-auth-service         192.168.100.214    192.168.100.215    192.168.100.216           192.168.100.222'
    'info-community-service    192.168.100.214    192.168.100.215    192.168.100.216           192.168.100.222'
    'info-groupon-service      192.168.100.214    192.168.100.215    192.168.100.216           192.168.100.222'
    'info-hotel-service        192.168.100.214    192.168.100.215    192.168.100.216           192.168.100.222'
    'info-message-service      192.168.100.214    192.168.100.215    192.168.100.216           192.168.100.222'
    'info-nearby-service       192.168.100.214    192.168.100.215    192.168.100.216           192.168.100.222'
    'info-news-service         192.168.100.214    192.168.100.215    192.168.100.216           192.168.100.222'
    'info-payment-service      192.168.100.214    192.168.100.215    192.168.100.216           192.168.100.222'
    'info-scheduler-service    192.168.100.214    192.168.100.215    192.168.100.216           192.168.100.222'
    'info-store-service        192.168.100.214    192.168.100.215    192.168.100.216           192.168.100.222'
    'info-uc-service           192.168.100.214    192.168.100.215    192.168.100.216           192.168.100.222'
    'info-admin                192.168.100.214    192.168.100.215    192.168.100.216           192.168.100.222'
    'info-config               192.168.100.214    192.168.100.215    192.168.100.216           192.168.100.222'
    'info-gateway              192.168.100.214    192.168.100.215    192.168.100.216           192.168.100.222'
)

for i in "${service_deploy[@]}"; 
do
    sub_array=($i)
    echo $i | grep -wq "$pjName" && isExist="0" || isExist="1"

    if [ $isExist == "0" ];
    then
        service_name=${sub_array[0]}
        dev_env=${sub_array[1]}
        test_env=${sub_array[2]}
        fge_env=${sub_array[3]}
        zkv2_env=${sub_array[4]}
    fi
done

if [ $branch == "dev" ];
then 
    remote_host=$dev_env
elif [ $branch == "test" ];
then
    remote_host=$test_env
elif [ $branch == "feature-goods-exchange" ];
then
    remote_host=$fge_env  
elif [ $branch == "zhongku-v2" ];
then
    remote_host=$zkv2_env
fi

#===================================================================
cd $jarHome
echo $remote_host:$remote_lib:$jarName
/var/lib/jenkins/sshpass -p 'test123' scp -o StrictHostKeyChecking=no ${jarName} root@${remote_host}:${remote_lib}

/var/lib/jenkins/sshpass -p 'test123' ssh -o StrictHostKeyChecking=no root@${remote_host} > /dev/null 2>&1 << EOF
sh ${remote_bin}/stop.sh $remote_lib_name
cd $remote_lib
mv $remote_lib_name $remote_lib_name.$curDate$curTime
mv $jarName $remote_lib_name
sh ${remote_bin}/start.sh $remote_lib_name
exit
EOF
