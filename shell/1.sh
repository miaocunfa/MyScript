sftp -oPort=1022 backup@112.74.51.143 << EOF
backup!@#
lcd /home/ysyf/backup/db_Daily
cd db_Daily
put a.txt
EOF
