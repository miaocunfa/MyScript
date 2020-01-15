full_service=`ls /home/miaocunfa/`

echo $full_service | grep -wq "info-config.jar" && isConfig="0" || isConfig="1"
echo $full_service | grep -wq "info-gateway.jar" && isGateway="0" || isGateway="1"
echo $full_service | grep -wq "info-message-service.jar" && isMessage="0" || isMessage="1"

if [ $isConfig == "0" ]
then
    ps -ef | grep info | awk '{print $2}' | xargs kill

    cd /opt/aihangxunxi/bin
    cur_datetime=`date +'%Y%m%d%H%M%S'`

    mv /opt/aihangxunxi/lib/info-config.jar /opt/aihangxunxi/lib/info-config.jar.$cur_datetime
    mv /home/miaocunfa/info-config.jar /opt/aihangxunxi/lib/info-config.jar
    echo "Startup info-config.jar!"
    ./start.sh info-config.jar

    echo
    echo "sleep 10s"
    echo
    sleep 10s
fi

if [ $isGateway == "0" ]
then
    cd /opt/aihangxunxi/bin
    cur_datetime=`date +'%Y%m%d%H%M%S'`

    ./stop.sh info-gateway.jar
    mv /opt/aihangxunxi/lib/info-gateway.jar /opt/aihangxunxi/lib/info-gateway.jar.$cur_datetime
    mv /home/miaocunfa/info-gateway.jar /opt/aihangxunxi/lib/info-gateway.jar
    echo "Startup info-gateway.jar!"
    ./start.sh info-gateway.jar

    echo
    echo "sleep 10s"
    echo
    sleep 10s
fi

if [ $isMessage == "0" ]
then
    cd /opt/aihangxunxi/bin
    cur_datetime=`date +'%Y%m%d%H%M%S'`

    ./stop.sh info-message-service.jar
    mv /opt/aihangxunxi/lib/info-message-service.jar /opt/aihangxunxi/lib/info-message-service.jar.$cur_datetime
    mv /home/miaocunfa/info-message-service.jar /opt/aihangxunxi/lib/info-message-service.jar

    echo
    echo "sleep 10s"
    echo
    sleep 10s
    
    ./start.sh info-message-service.jar
fi

for i in `ls /home/miaocunfa/`
do
    cd /opt/aihangxunxi/bin
    cur_datetime=`date +'%Y%m%d%H%M%S'`

    ./stop.sh $i
    mv /opt/aihangxunxi/lib/$i /opt/aihangxunxi/lib/$i.$cur_datetime
    mv /home/miaocunfa/$i /opt/aihangxunxi/lib/$i
    ./start.sh $i
done
