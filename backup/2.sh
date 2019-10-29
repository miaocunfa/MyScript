ping 112.74.51.143
echo $0
lftp << EOF
 open sftp://112.74.51.143:1022
 user backup backup!@#
 lcd /home/ysyf/backup/db_Daily
 cd db_Daily
 put a.txt
 exit
EOF
