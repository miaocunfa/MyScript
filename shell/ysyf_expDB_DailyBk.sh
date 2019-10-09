####################################
# Set Parameter
# 设置变量
####################################
ENVFILE="/etc/profile"
EXITCODE=0
uDate=`date +'%Y%m%d'`
Week=`date +'%a'`
dbBackup=/home/ysyf/backup/db_Daily
tarName=ysyf_${uDate}_DB_DailyBk.tar.gz


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
cd $dbBackup

#
# Export Database To File
# 导出数据库
#
exp ysyf_admin/ysyf_admin file=ysyf_${uDate}_DB_DailyBk.dmp 


####################################
# Send The File To Remote Host
# 将备份程序发送到远程主机
####################################
cd $dbBackup
tar -zcvf $tarName ysyf_${uDate}_DB_DailyBk.dmp

#
# Rename Backup For Remote Host
# 为远程主机重命名备份文件
#
cp $tarName ysyf_${Week}_DB_DailyBk.tar.gz 

lftp << EOF
 open sftp://112.74.51.143:1022
 user backup backup!@#
 cd db_Daily
 put ysyf_${Week}_DB_DailyBk.tar.gz
 exit
EOF

#
# Delete Rename Backup
# 删除重命名备份文件
#
rm -f ysyf_${Week}_DB_DailyBk.tar.gz 
rm -f ysyf_${uDate}_DB_DailyBk.dmp

#
# Exit Shell Script
# 退出Shell脚本
#
exit_handler

