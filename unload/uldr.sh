#!/bin/sh

usage()
{
    echo "uldr - Database unload utility"
    echo "Usage : uldr [ -u <User Name> ] [ -p <Passwd> ] [ -s <Statement> ]"
    echo "             [ -f <File Name> ] [ -g ] [ -h ]"
    echo "        -u   <user name>                  - The database user name"
    echo "        -p   <passwd>                     - The database user passwd"
    echo "        -s   <select statement>(required) - The table name OR select statement"
    echo "        -f   <File name>                  - The export file name"
    echo "        -g                                - Generate SQLLDR control file"
    echo "        -h                                - display this help message and exit"
}

dbUser=$DB_User
dbPwd=$DB_Pwd
workPath=`pwd`
logFile=/home/ysyf/log/uldr.log
rows=50000
charset=uft8
format=sql
quote=0x22
cmd="sqluldr2linux64.bin log=+$logFile rows=$rows charset=$charset format=$format quote=$quote"

szFileName=
szCondition=
szStatement=
filePath=$workPath/uldrdata.1.txt
ctlflag=
uDate=`date +'%F %T'`

while getopts :u:p:s:f:gh opt
do
    case $opt in  
    	u) dbUser=$OPTARG
    	;;
    	
    	p) dbPwd=$OPTARG
    	;;
    	    
    	s) szStatement=$OPTARG 
    	   cmd=$cmd" query=$szStatement"
    	;;
                
    	f) szFileName=$OPTARG
    	   filePath=$workPath/$szFileName.sql
    	   cmd=$cmd" file=$filePath"   
    	;;
                
    	g) ctlflag=1
    	;;
    	
    	h) usage
    	   exit 1
    	;;  
                
    	?) usage
    	   exit 1
    	;;       
    esac
done

echo_para()
{
echo
echo " break while"
echo "dbUser = [$dbUser]"
echo "dbPwd = [$dbPwd]"
echo "szTableName = [$szTableName]"
echo "szCondition = [$szCondition]"
echo "filePath = [$filePath]"
echo "ctlflag = [$ctlflag]"
echo
}

#echo_para

## Check
if [ -z $szStatement ]; then
    echo
    echo "uldr: Invalid option -- 's'"
    echo "      No table name or select statement!"
    echo
    usage
    exit 1;
fi
    
     cmd=$cmd" user=$dbUser/$dbPwd"

     echo >> $logFile
     echo >> $logFile
     echo "           ---------------    $uDate  ----------"  >>  $logFile
     echo "$cmd"  >>  $logFile
     echo "result:"  >>  $logFile

     `$cmd`
     # uldr >> /home/ysyf/log/uldr.log 2>&1

if [ $? == 0 ]; then
        echo 
	echo Success Export Text
        echo filename=$filePath
        echo you can look at the log with :
        echo
        echo "       tail -f $logFile"
        echo
else
	echo Error
fi

