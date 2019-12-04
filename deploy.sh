for i in `ls /home/miaocunfa/`
do
    cur_datetime=`date +'%Y%m%d%H%M%S'`
    
    cd /opt/aihangxunxi/bin

    ./stop.sh $i

    mv /opt/aihangxunxi/lib/$i /opt/aihangxunxi/lib/$i.$cur_datetime
    cp /home/miaocunfa/$i $i

    ./start.sh $i
done
