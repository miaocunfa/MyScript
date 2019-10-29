# Set parameter
uDate=`date +'%Y%m%d'`
#uDate=20170802
upzip=ysyf${uDate}.zip
WEBAPPS=/home/ysyf/apache-tomcat-7.0.21/webapps
BACKUP=/home/ysyf/backup
TOMCAT_HOME=/home/ysyf/apache-tomcat-7.0.21
ENVFILE="/etc/profile"
EXITCODE=0

####################################################################################################
# Quit the programe
exit_handler()
{
	exit $EXITCODE
}

####################################################################################################
# Load the environment file 
if [ -r "$ENVFILE" ]
then
	source $ENVFILE
else
	EXITCODE=-1
	exit_handler
fi

####################################################################################################
#echo "本脚本用来实现tomcat下自动更新程序包的功能"
#echo "1.停止tomcat服务"
#echo "2.将用于更新的程序从00~99编号并重命名"
#echo "3.将被替换的程序备份并按照更新的编号重命名"
#echo "4.启动tomcat服务"
#echo "更新程序和备份程序在同级目录的backup/upd_bk下"

####################################################################################################
#停止tomcat服务
$TOMCAT_HOME/bin/shutdown.sh
sleep 5s

####################################################################################################
cd $BACKUP

#重命名
if [ -f $upzip ]
then
        #根据已有[当天]的更新序号，算出当前的更新序号[00~09]
	SEQ=$((`ls -l ysyf_${uDate}_[00-99]*.zip | wc -l`))
	SEQ_f=`printf '%02d' $SEQ`
	mv $upzip ./upd_bk/ysyf_${uDate}_${SEQ_f}_upd.zip
else
	EXITCODE=-1
	exit_handler
fi

if [ -d $WEBAPPS ]
then
	cp ./upd_bk/ysyf_${uDate}_${SEQ_f}_upd.zip ${WEBAPPS}
fi

####################################################################################################
cd $WEBAPPS

#将原有程序备份，备份序号与更新程序序号一致
tar -cvf ysyf_${uDate}_${SEQ_f}_updBk.tar ./ysyf
mv ysyf_${uDate}_${SEQ_f}_updBk.tar $BACKUP/upd_bk/

#解压新的程序包替换原先的程序，交互运行脚本时需要输入A全部替换
unzip ysyf_${uDate}_${SEQ_f}_upd.zip << EOF
A
EOF

#删除webapp下面的程序更新包
rm -f ysyf_${uDate}_${SEQ_f}_upd.zip

####################################################################################################
#启动tomcat服务
$TOMCAT_HOME/bin/startup.sh
