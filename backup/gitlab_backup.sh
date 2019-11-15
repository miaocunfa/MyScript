#===========================Set Parameter========================================
ENVFILE="/etc/profile"
EXITCODE=0
fileDate=`date +'%Y_%m_%d'`
curDate=`date +'%Y%m%d'`
curTime=`date +'%H%M%S'`
backupDir=/var/opt/gitlab/backups
gitlab_backupLog=/var/opt/gitlab/backups/gitlab_backup.log
gitlab_optLog=gitlab_opt.log
mailContext="邮件内容初始化"

#===========================Function =========================================
function __exit_handler()
{
	exit $EXITCODE
}

function __write_log()
{
  echo "$(date "+%Y-%m-%d %H:%M:%S") [$1] $2" >> $gitlab_backupLog
}

#===========================Load the environment file============================
if [ -r "$ENVFILE" ]
then
	source $ENVFILE
else
	EXITCODE=-1
	__exit_handler
fi

#===========================Backup And Send The File To Remote Host=========================
cd $backupDir

__write_log "log" "gitlab-rake Start!"

gitlab-rake gitlab:backup:create > $gitlab_optLog

__write_log "log" "gitlab-rake Success!"

backupFile=$(cat $gitlab_optLog | grep "Creating backup archive:" | awk '{print $4}')

__write_log "log" "gitlab-backupFile: $backupFile"

scp $backupFile root@gitbackup:/home/gitlab/backup

if [ $? == 0 ]
then
    mailContext="gitlab 备份成功及上传ftp成功"
    __write_log "log" "SCP file Success!"
    
    # Delete BackupFile And OptLog
    rm -f $backupFile
    rm -f $gitlab_optLog
    __write_log "log" "Remove file: $backupFile"
    __write_log "log" "Remove file: $gitlab_optLog"
else
    mailContext="gitlab 备份成功但上传ftp不成功"
    __write_log "log" "SCP file Fail!"

    # Delete OptLog
    rm -f $gitlab_optLog
    __write_log "log" "Remove file: $gitlab_optLog"
fi

# Send Mail to admin
echo $mailContext | mail -s "gitlab $curDate 备份" shu-xian@163.com

__write_log "log" "Mail Send Success!"
__write_log "log" "End of Program!"

# Exit Shell Script
__exit_handler
