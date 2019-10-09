####################################
# Set Parameter
# 设置变量
####################################
ENVFILE="/etc/profile"
EXITCODE=0
uDate=`date +'%Y%m%d'`
Week=`date +'%a'`


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
cd /home/hsp

tar -zcvf hsp_${uDate}_DailyBk.tar.gz ./HSPHome
mv hsp_${uDate}_DailyBk.tar.gz /home/hsp/backup


####################################
# Send The File To Remote Host
# 将备份程序发送到远程主机
####################################
cd /home/hsp/backup

# Rename Backup For Remote Host
cp hsp_${uDate}_DailyBk.tar.gz hsp_${Week}_DailyBk.tar.gz

lftp << EOF
 open sftp://112.74.51.143:1022
 user backup backup!@#
 cd hsp_Daily
 put hsp_${Week}_DailyBk.tar.gz
 exit
EOF

# Delete Rename Backup
rm -f hsp_${Week}_DailyBk.tar.gz

# Exit Shell Script
exit_handler
