ps -ef | grep info | grep -v grep | awk '{print $2}' | xargs kill -9

cd /opt/aihangxunxi/bin
./start.sh info-gateway.jar

echo
echo "Sleep 10s"
echo
sleep 10s

cd /opt/aihangxunxi/lib
for i in `ls info*jar`
do
    if [ $i != "info-gateway.jar" ]
    then
        echo "Startup $i"
        /opt/aihangxunxi/bin/start.sh $i
        echo
        echo
    fi
done
