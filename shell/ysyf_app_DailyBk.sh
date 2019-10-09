####################################
# Set Parameter
# 设置变量
####################################
uDate=`date +'%Y%m%d'`
Week=`date +'%a'`
WEBAPPS=/home/ysyf/apache-tomcat-7.0.21/webapps
appBackup=/home/ysyf/backup/app_Daily
ENVFILE="/etc/profile"
EXITCODE=0


####################################
# Exit Program 
# 退出程序
####################################
exit_handler()
{
	exit $EXITCODE
}


####################################
# Load the environment file 
# 加载环境变量
####################################
if [ -r "$ENVFILE" ]
then
	source $ENVFILE
else
	EXITCODE=-1
	exit_handler
fi


####################################
# Backup Application To Directory
# 备份程序到本地目录
####################################
cd $WEBAPPS

tar -zcvf ysyf_${uDate}_app_DailyBk.tar.gz ./ysyf
mv ysyf_${uDate}_app_DailyBk.tar.gz $appBackup


####################################
# Send The File To Remote Host
# 将备份程序发送到远程主机
####################################
cd $appBackup

#
# Rename Backup For Remote Host
# 为远程主机重命名备份文件
#
cp ysyf_${uDate}_app_DailyBk.tar.gz ysyf_${Week}_app_DailyBk.tar.gz

lftp << EOF
 open sftp://112.74.51.143:1022
 user backup backup!@#
 cd app_Daily
 put ysyf_${Week}_app_DailyBk.tar.gz 
 exit
EOF

#
# Delete Rename Backup
# 删除重命名备份文件
#
rm -f ysyf_${Week}_app_DailyBk.tar.gz 

#
# Exit Shell Script
# 退出Shell脚本
#
exit_handler
