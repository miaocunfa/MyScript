####################################################################################################
#
# Set Parameter
#
####################################################################################################
RunDate=`date +%Y%m%d`
uDate=`date +'%F %T'`
ENVFILE="/etc/profile"
EXITCODE=0

# 导出用户列表
uldr_userlogFile=/home/ysyf/log/ysyf_manager/uldrLog-user-$RunDate.log
userDatFile=/home/ysyf/log/ysyf_manager/uldrDat-user-$RunDate.dat
userDatFile_f=/home/ysyf/log/ysyf_manager/formatDat-user-$RunDate.dat

# 导出医院列表
uldr_hsplogFile=/home/ysyf/log/ysyf_manager/uldrLog-hospital-$RunDate.log
hspDatFile=/home/ysyf/log/ysyf_manager/uldrDat-hospital-$RunDate.dat
hspDatFile_f=/home/ysyf/log/ysyf_manager/formatDat-hospital-$RunDate.dat

# 导出城市列表
uldr_cityLogFile=/home/ysyf/log/ysyf_manager/uldrLog-city-$RunDate.log
cityDatFile=/home/ysyf/log/ysyf_manager/uldrDat-city-$RunDate.dat
cityDatFile_f=/home/ysyf/log/ysyf_manager/formatDat-city-$RunDate.dat

# sqlplus日志
sqlplusSelectLog=/home/ysyf/log/ysyf_manager/sqlplus/select-$RunDate.log
sqlplusUpdateLog=/home/ysyf/log/ysyf_manager/sqlplus/update-$RunDate.log
sqlplusInsertLog=/home/ysyf/log/ysyf_manager/sqlplus/insert-$RunDate.log

ysyf_manager_log=/home/ysyf/log/ysyf_manager/ysyf_manager-$RunDate.log
ysyf_manager_errorLog=/home/ysyf/log/ysyf_manager/ysyf_manager.log
prompt_dat=/home/ysyf/log/ysyf_manager/prompt_dat-$RunDate.log

statement=
default_password="e10adc3949ba59abbe56e057f20f883e"


####################################################################################################
#
# Declare Function()
#
####################################################################################################

#
# Quit Program
#
exit_handler()
{
    echo
    echo -e "\tQuit the Program!"
    echo
	
	#日志部分
	_write_log "log" $LINENO "exit_handler()" "程序退出!"              #Script ysyf_manager errorLog
	_write_log "end"                                                   #Script ysyf_manager errorLog
	
	echo "程序退出"     >>  $ysyf_manager_log   #Script ysyf_manager runLog
	echo                >>  $ysyf_manager_log   #Script ysyf_manager runLog
	echo                >>  $ysyf_manager_log   #Script ysyf_manager runLog
	echo                >>  $ysyf_manager_log   #Script ysyf_manager runLog
	
	exit $EXITCODE
	
} # End of exit_handler function

#
# write_log
#
function _write_log()
{
	echo "$(date "+%Y-%m-%d %H:%M:%S") [$1] $2 $3 $4" >> $ysyf_manager_errorLog
} # End of write_log function


function get_answer()
{

	unset ANSWER
	ASK_COUNT=0

	while [ -z "$ANSWER" ] # While no answer is given, keep asking.
	do 
		echo
		
		ASK_COUNT=$[ $ASK_COUNT + 1 ]
		
	  	case $ASK_COUNT in 
	  	2)  
		    prompt_info="请回答这个问题！"
		    prompt_red
	    ;;
	     
	  	3)  
		    prompt_info="再次尝试！请回答这个问题！"
		    prompt_red
	    ;;
	     
	  	4)  
		    prompt_info="因为你拒绝回答这个问题...."
		    prompt_red
	     	exit_handler                     # function transfer
	   	;;
	  	esac
	  
	  	if [ -n "$LINE2" ]
	  	then 
		    echo -e "\t"$LINE1
	  		echo -e "\t"$LINE2" \c"
	  	else
	    	echo -e "\t"$LINE1" \c"
	  	fi
	  
	  	# allow 30 seconds to answer before time-out 
	    	  read -t 30 ANSWER
	done 
	
	# Do a little variable clean-up 
	unset LINE1
	unset LINE2

} # End of get_answer function


function process_answer()
{
	case $ANSWER in
	
	y|Y|YES|yes|Yes|yEs|yeS|YEs|yES)          # If user answer "yes", do nothing.
        echo
        echo -e "\t确认操作, 继续处理!"
	;;
	
	*)                                        # If user answer anything but "yes", exit script.
		echo
		echo -e "\t"$EXIT_LINE1
		echo -e "\t"$EXIT_LINE2
		exit_handler                          # function transfer
	;;
	  
	esac
	
	# Do a little variable clean-up 
	unset EXIT_LINE1
	unset EXIT_LINE2
	
} # End of process_answer function

function prompt_red()
{			    
	prompt_length=`echo $prompt_info | wc -L`
	
	b="+"
	for ((i=1;$i<=$prompt_length;i+=1))
	do
		b=$b"-"
	done
	b=$b"+"
   
	echo -e "\t"$b
	echo -e "\t|\033[41;30m$prompt_info\033[0m|"
	echo -e "\t"$b
	
	unset prompt_info
	unset prompt_length
}

function prompt()
{	
	prompt_length=`echo $prompt_info | wc -L`
			
	b="+"
	for ((i=1;$i<=$prompt_length;i+=1))
	do
		b=$b"-"
	done
	b=$b"+"
   
	echo -e "\t"$b
	echo -e "\t|$prompt_info|"
	echo -e "\t"$b
	
	unset prompt_info
	unset prompt_length
}

function load()
{
	b=">"
	echo
	for ((i=0;$i<=100;i+=4))
	do
			printf "\tPleaseWait:[%-25s]%d%%\r" $b $i
			sleep 0.02
			b="="$b
	done
	echo
}

function sqlplus_select()
{
	>$sqlplusSelectLog

SQLStamp=$(date +%s)
_write_log "sql" $LINENO "sqlplus_select()" "连接数据库"              #Script ysyf_manager errorLog
_write_log "sql" $LINENO "sqlplus_select()" "sqlplus日志：$ysyf_manager_log 时间戳：$SQLStamp"              #Script ysyf_manager errorLog

sqlplus ysyf_admin/ysyf_admin << EOF > $sqlplusSelectLog
    set head off;
	$statement
EOF

    #日志部分
	echo "SQLStamp: $SQLStamp"       >>   $ysyf_manager_log   #Script ysyf_manager runLog
	echo "SQL语句：$statement"       >>   $ysyf_manager_log   #Script ysyf_manager runLog
	echo "执行结果："                >>   $ysyf_manager_log   #Script ysyf_manager runLog
    cat  $sqlplusSelectLog           >>   $ysyf_manager_log   #Script ysyf_manager runLog        	
    echo                             >>   $ysyf_manager_log   #Script ysyf_manager runLog
}

function sqlplus_insert()
{
	>$sqlplusInsertLog

SQLStamp=$(date +%s)
_write_log "sql" $LINENO "sqlplus_insert()" "连接数据库"              #Script ysyf_manager errorLog
_write_log "sql" $LINENO "sqlplus_insert()" "sqlplus日志：$ysyf_manager_log 时间戳：$SQLStamp"              #Script ysyf_manager errorLog

sqlplus ysyf_admin/ysyf_admin << EOF > $sqlplusInsertLog
    set head off;
	$statement
	commit;
EOF
	
	#日志部分
	echo "SQLStamp: $SQLStamp"       >>   $ysyf_manager_log   #Script ysyf_manager runLog
	echo "SQL语句：$statement"       >>   $ysyf_manager_log   #Script ysyf_manager runLog
	echo "执行结果："                >>   $ysyf_manager_log   #Script ysyf_manager runLog
    cat  $sqlplusInsertLog           >>   $ysyf_manager_log   #Script ysyf_manager runLog 
	echo                             >>   $ysyf_manager_log   #Script ysyf_manager runLog 

}

function sqlplus_hospitalUpdate()
{
	>$sqlplusUpdateLog

sqlplus ysyf_admin/ysyf_admin << EOF > $sqlplusUpdateLog
    set head off;
	$statement
	commit;
EOF

	isOK=$(cat $sqlplusUpdateLog | grep -e "1 row updated.")
			
	if [ $? -eq 0 ]
	then
		echo
		prompt_info="医院名称已成功修改为=$_upd_hospital_name"
		prompt
		echo
		echo -e "\t祝小姐姐越来越美丽！再见！"
		exit_handler
	else
		echo
		prompt_info="医院名称修改失败! 联系系统管理员!"
		prompt_red
		echo
		echo -e "\t祝小姐姐越来越美丽！再见！"
		exit_handler
	fi
}

function sqlplus_usercheck()
{
	>$sqlplusUpdateLog

SQLStamp=$(date +%s)
_write_log "sql" $LINENO "sqlplus_usercheck()" "连接数据库"              #Script ysyf_manager errorLog
_write_log "sql" $LINENO "sqlplus_usercheck()" "sqlplus日志：$ysyf_manager_log 时间戳：$SQLStamp"   

sqlplus ysyf_admin/ysyf_admin << EOF > $sqlplusUpdateLog
    set head off;
	$statement
	commit;
EOF
	
	#日志部分
	echo "SQLStamp: $SQLStamp"       >>   $ysyf_manager_log   #Script ysyf_manager runLog
	echo "SQL语句：$statement"       >>   $ysyf_manager_log   #Script ysyf_manager runLog
	echo "执行结果："                >>   $ysyf_manager_log   #Script ysyf_manager runLog
    cat  $sqlplusUpdateLog           >>   $ysyf_manager_log   #Script ysyf_manager runLog 
	echo                             >>   $ysyf_manager_log   #Script ysyf_manager runLog
	
	isOK=$(cat $sqlplusUpdateLog | grep -e "1 row updated.")
	
	if [ $? -eq 0 ]
	then
        statement="select * from doctor_info d where d.login_name='$_login_name';"
        userDisplay                       # function transfer
		
		echo
		prompt_info="用户$_login_name, 已审核通过！"
		prompt                            # function transfer
		
		#日志部分
		_write_log "log" $LINENO "sqlplus_usercheck()" "用户$_login_name审核通过！"              #Script ysyf_manager errorLog
		echo "用户$_login_name, 已审核通过！"       >>   $ysyf_manager_log   #Script ysyf_manager runLog
		
		exit_handler                      # function transfer
	else		
		if [ $is_check -eq 1 ]
		then
			echo
			prompt_info="本次审核失败！"
			prompt_red                    # function transfer
			echo
			prompt_info="系统检测到用户login_name=${_login_name}已通过审核！无需审核"
			prompt_red                    # function transfer
			
			#日志部分
			_write_log "err" $LINENO "sqlplus_usercheck()" "审核失败! 用户login_name=${_login_name}已通过审核！"              #Script ysyf_manager errorLog
			echo "本次审核失败！"       >>   $ysyf_manager_log   #Script ysyf_manager runLog
			echo "系统检测到用户login_name=${_login_name}已通过审核！无需审核"       >>   $ysyf_manager_log   #Script ysyf_manager runLog
		fi
		
		if [ $is_check -eq 0 ]
		then
			echo
			prompt_info="本次审核失败！"
			prompt_red                    # function transfer
			echo
			prompt_info="系统检测到用户login_name=fagod已存在并且未通过审核！请联系系统管理员"
			prompt_red                    # function transfer
			
			#日志部分
			_write_log "err" $LINENO "sqlplus_usercheck()" "系统检测到用户login_name=fagod已存在并且未通过审核！"              #Script ysyf_manager errorLog
			_write_log "err" $LINENO "sqlplus_usercheck()" "审核失败! "              #Script ysyf_manager errorLog
			echo "本次审核失败！"       >>   $ysyf_manager_log   #Script ysyf_manager runLog
			echo "系统检测到用户login_name=fagod已存在并且未通过审核！请联系系统管理员"       >>   $ysyf_manager_log   #Script ysyf_manager runLog
		fi
		
		exit_handler                      # function transfer     
	fi
	
	unset statement                       # function transfer
	
}

function user_check_show()
{
	LINE1="请输入login_name："
	get_answer                            # function transfer 
    _login_name=$ANSWER
	
	echo "获得login_name：$ANSWER"   >>   $ysyf_manager_log   #Script ysyf_manager runLog
	_write_log "log" $LINENO "user_check_show()" "获得login_name：$ANSWER"              #Script ysyf_manager errorLog
    	
		
    #load                                 # function transfer
	statement="select * from doctor_info d where d.login_name ='$_login_name';"
	sqlplus_select                        # function transfer
	
	isExist=$(cat $sqlplusSelectLog | grep -e "no rows selected")
	
	if [ $? -eq 0 ]
	then
	    echo
		prompt_info="未能根据login_name=$ANSWER找到这个用户！"
		prompt_red                        # function transfer
		
		#日志部分
		_write_log "err" $LINENO "user_check_show()" "未能根据login_name=$ANSWER找到这个用户！"              #Script ysyf_manager errorLog
		echo 'isExist=$(cat $sqlplusSelectLog | grep -e "no rows selected")' " 执行结果为：0" >>   $ysyf_manager_log   #Script ysyf_manager runLog
		echo "未能根据login_name=$ANSWER找到这个用户！"        >>   $ysyf_manager_log   #Script ysyf_manager runLog
		echo                                                   >>   $ysyf_manager_log   #Script ysyf_manager runLog
		
		exit_handler                      # function transfer
	else
	    echo
	    prompt_info="用户login_name=$ANSWER, 系统检测成功, 继续处理！"
		prompt                            # function transfer
		
		#日志部分
		_write_log "log" $LINENO "user_check_show()" "用户login_name=$ANSWER, 系统检测成功, 继续处理！"              #Script ysyf_manager errorLog
		echo 'isExist=$(cat $sqlplusSelectLog | grep -e "no rows selected")' " 执行结果为：1"  >>   $ysyf_manager_log   #Script ysyf_manager runLog
		echo "用户login_name=$ANSWER, 系统检测成功, 继续处理！"   >>   $ysyf_manager_log   #Script ysyf_manager runLog
		echo                                                      >>   $ysyf_manager_log   #Script ysyf_manager runLog
		
	fi
		
    statement="select * from doctor_info d where d.login_name='$_login_name';"
    userDisplay                           # function transfer
}

# 用户审核
function user_audit()
{     
	# Make Sure The User is Right
    LINE1="确定是这个用户吗？"
    LINE2="是否通过审核？[y/n]："
    get_answer                            # function transfer
	
	#日志部分
	_write_log "log" $LINENO "user_audit()" "获取是否审核用户：$ANSWER"              #Script ysyf_manager errorLog
	echo "获取是否审核用户：$ANSWER"          >>  $ysyf_manager_log   #Script ysyf_manager runLog
	echo                                  >>  $ysyf_manager_log   #Script ysyf_manager runLog

    EXIT_LINE1="因为你不希望审核通过这个用户！"
    EXIT_LINE2="所以, 退出这个脚本！"
    process_answer                        # function transfer
	
	statement="update ysyf_login set is_check = '1' where login_name = '$_login_name' and is_check = '0';"
	sqlplus_usercheck                     # function transfer
}


function hospital_check()
{
	LINE1="请输入医院名称(支持模糊查找)："
	get_answer                            # function transfer
	_hospital_name=$ANSWER
	
	#日志部分
	_write_log "log" $LINENO "hospital_check()" "获得医院名称：$_hospital_name"              #Script ysyf_manager errorLog
	echo "获得医院名称：$_hospital_name"     >>  $ysyf_manager_log   #Script ysyf_manager runLog
	
	statement="select * from ysyf_hospital_info h where h.hospital_name like '%$_hospital_name%';"
	sqlplus_select                        # function transfer
	
	isExist=$(cat $sqlplusSelectLog | grep -e "no rows selected")

	if [ $? -eq 0 ]
	then
	    echo
		prompt_info="未能根据医院名称找到此医院！"
		prompt_red                        # function transfer
		
		#日志部分
		_write_log "err" $LINENO "hospital_check()" "未能根据医院名称找到此医院！"              #Script ysyf_manager errorLog
		echo 'isExist=$(cat $sqlplusSelectLog | grep -e "no rows selected")' " 执行结果为：0" >>   $ysyf_manager_log   #Script ysyf_manager runLog
		echo "未能根据医院名称找到此医院！"        >>   $ysyf_manager_log   #Script ysyf_manager runLog
		echo                                       >>   $ysyf_manager_log   #Script ysyf_manager runLog
		
		exit_handler                      # function transfer
	else
	    echo
		prompt_info="医院名称=$ANSWER, 系统检测成功, 继续处理！"
		prompt                            # function transfer
		
		#日志部分
		_write_log "log" $LINENO "hospital_check()" "医院名称=$ANSWER, 系统检测成功, 继续处理！"              #Script ysyf_manager errorLog
		echo 'isExist=$(cat $sqlplusSelectLog | grep -e "no rows selected")' " 执行结果为：1" >>   $ysyf_manager_log   #Script ysyf_manager runLog
		echo "医院名称=$ANSWER, 系统检测成功, 继续处理！"        >>   $ysyf_manager_log   #Script ysyf_manager runLog
		echo                                                     >>   $ysyf_manager_log   #Script ysyf_manager runLog
	fi	 		
}

function hospital_accurateCheck()
{
	LINE1="请输入修改后的医院名称："
	get_answer                            # function transfer
	_upd_hospital_name=$ANSWER
	
	#load                                 # function transfer
	statement="select * from ysyf_hospital_info h where h.hospital_name = '$_upd_hospital_name';"
	sqlplus_select                        # function transfer
	
	isExist=$(cat $sqlplusSelectLog | grep -e "no rows selected")

	if [ $? -eq 0 ]
	then
	    echo
		prompt_info="系统检测到此医院名未被使用, 继续处理"
		prompt                        # function transfer
	else
	    echo
		prompt_info="系统检测到此医院名已被使用"
		prompt_red                            # function transfer
		hospital_accurateCheck
	fi	 		
}

function doctor_check_show()
{
	LINE1="请输入医生姓名(支持模糊查找)："
	get_answer                            # function transfer
	_doctor_name=$ANSWER
	
	#日志部分
	_write_log "log" $LINENO "doctor_check_show()" "获得医生姓名：$_doctor_name"              #Script ysyf_manager errorLog
	echo "获得医生姓名：$_doctor_name"     >>  $ysyf_manager_log   #Script ysyf_manager runLog
	
	#load                                  # function transfer
	statement="select * from doctor_info d where d.doctor_name like '%$_doctor_name%';"
	sqlplus_select                        # function transfer
	
	isExist=$(cat $sqlplusSelectLog | grep -e "no rows selected")

	if [ $? -eq 0 ]
	then
	    echo
		prompt_info="未能根据医生姓名找到用户！"
		prompt_red                        # function transfer
		
		#日志部分
		_write_log "err" $LINENO "doctor_check_show()" "未能根据医生姓名找到用户！"              #Script ysyf_manager errorLog
		echo 'isExist=$(cat $sqlplusSelectLog | grep -e "no rows selected")' " 执行结果为：0" >>   $ysyf_manager_log   #Script ysyf_manager runLog
		echo "未能根据医生姓名找到用户！"        >>   $ysyf_manager_log   #Script ysyf_manager runLog
		echo                                     >>   $ysyf_manager_log   #Script ysyf_manager runLog
		
		exit_handler                      # function transfer
	else
	    echo
		prompt_info="医生姓名=$ANSWER, 系统检测成功, 继续处理！"
		prompt                            # function transfer
		
		#日志部分
		_write_log "log" $LINENO "doctor_check_show()" "医生姓名=$ANSWER, 系统检测成功, 继续处理！"              #Script ysyf_manager errorLog
		echo 'isExist=$(cat $sqlplusSelectLog | grep -e "no rows selected")' " 执行结果为：1" >>   $ysyf_manager_log   #Script ysyf_manager runLog
		echo "医生姓名=$ANSWER, 系统检测成功, 继续处理！"        >>   $ysyf_manager_log   #Script ysyf_manager runLog
		echo                                                     >>   $ysyf_manager_log   #Script ysyf_manager runLog
	fi
	
	statement="select * from doctor_info d where d.doctor_name like '%$_doctor_name%';"
	userDisplay                           # function transfer
}

function phone_check_show()
{
	LINE1="请输入手机号(支持模糊查找)："
	get_answer                            # function transfer
	_phone_number=$ANSWER
	
	#日志部分
	_write_log "log" $LINENO "phone_check_show()" "获得手机号：$_phone_number"              #Script ysyf_manager errorLog
	echo "获得手机号：$_phone_number"     >>  $ysyf_manager_log   #Script ysyf_manager runLog
	
	statement="select * from doctor_info d where d.doctor_phone like '%$_phone_number%';"
	sqlplus_select                        # function transfer
	
	isExist=$(cat $sqlplusSelectLog | grep -e "no rows selected")

	if [ $? -eq 0 ]
	then
	    echo
		prompt_info="未能根据手机号找到用户！"
		prompt_red                        # function transfer
		
		#日志部分
		_write_log "err" $LINENO "phone_check_show()" "未能根据手机号找到用户！"              #Script ysyf_manager errorLog
		echo 'isExist=$(cat $sqlplusSelectLog | grep -e "no rows selected")' " 执行结果为：0" >>   $ysyf_manager_log   #Script ysyf_manager runLog
		echo "未能根据手机号找到用户！"        >>   $ysyf_manager_log   #Script ysyf_manager runLog
		echo                                   >>   $ysyf_manager_log   #Script ysyf_manager runLog
		
		exit_handler                      # function transfer
	else
	    echo
		prompt_info="手机号=$ANSWER, 系统检测成功, 继续处理！"
		prompt                            # function transfer
		
		#日志部分
		_write_log "log" $LINENO "phone_check_show()" "手机号=$ANSWER, 系统检测成功, 继续处理！"              #Script ysyf_manager errorLog
		echo 'isExist=$(cat $sqlplusSelectLog | grep -e "no rows selected")' " 执行结果为：1" >>   $ysyf_manager_log   #Script ysyf_manager runLog
		echo "手机号=$ANSWER, 系统检测成功, 继续处理！"     >>   $ysyf_manager_log   #Script ysyf_manager runLog
		echo                                                >>   $ysyf_manager_log   #Script ysyf_manager runLog
		
	fi
	
	statement="select * from doctor_info d where d.doctor_phone like '%$_phone_number%';"
	userDisplay                           # function transfer
}



function userDisplay()
{
    >$userDatFile
	
	sqluldr2linux64.bin user=ysyf_admin/ysyf_admin query="$statement" file=$userDatFile log=+$uldr_hsplogFile
	_write_log "log" $LINENO "userDisplay()" "执行sqluldr导出文本至$userDatFile"    #Script ysyf_manager errorLog
	
	is_check=`awk -F',' '{print $16}' $userDatFile`
	
    sed -i '1iNO,医院名称,医院ID,hspSheetId,省份,省份ID,医生姓名,login_name,医生ID,医生编号,医生邀请码,phone,create_time,disable_time,审核状态,审核码' $userDatFile
	
	awk 'BEGIN{FS=","; OFS="|"}{n2=30-length($2); n7=12-length($7); printf "%-5s|%-"n2"s|%-"n7"s|%-12s|%-13s|%-21s|%-14s|%-6s\n",$1,$2,$7,$8,$12,$13,$14,$15}' $userDatFile > $userDatFile_f 
	_write_log "log" $LINENO "userDisplay()" "格式化文本至$userDatFile_f"    #Script ysyf_manager errorLog
	
	echo
	echo  "--------------------------------------------------------------------------------------------------------------------------"
    cat $userDatFile_f
	echo  "--------------------------------------------------------------------------------------------------------------------------"
    echo
	
	#日志部分
	echo "用户信息展示："             >>  $ysyf_manager_log   #Script ysyf_manager runLog
	echo "导出命令：sqluldr2linux64.bin user=ysyf_admin/ysyf_admin query="$statement" file=$userDatFile log=+$uldr_hsplogFile"  >>   $ysyf_manager_log   #Script ysyf_manager runLog
	echo "SQL语句：$statement"        >>  $ysyf_manager_log   #Script ysyf_manager runLog
	echo "日志文件：$uldr_hsplogFile" >>  $ysyf_manager_log   #Script ysyf_manager runLog
	echo                              >>  $ysyf_manager_log   #Script ysyf_manager runLog
	echo "原始文本：$userDatFile"     >>  $ysyf_manager_log   #Script ysyf_manager runLog
	echo "----------------------------------------------------------------"   >>  $ysyf_manager_log   #Script ysyf_manager runLog
	cat  $userDatFile                 >>  $ysyf_manager_log   #Script ysyf_manager runLog
	echo                              >>  $ysyf_manager_log   #Script ysyf_manager runLog
	echo "格式化文本：$userDatFile_f" >>  $ysyf_manager_log   #Script ysyf_manager runLog
	echo "----------------------------------------------------------------"   >>  $ysyf_manager_log   #Script ysyf_manager runLog
	cat  $userDatFile_f               >>  $ysyf_manager_log   #Script ysyf_manager runLog
	echo                              >>  $ysyf_manager_log   #Script ysyf_manager runLog
}

function sqlplus_reset()
{
	>$sqlplusUpdateLog
	
SQLStamp=$(date +%s)
_write_log "sql" $LINENO "sqlplus_reset()" "连接数据库"              #Script ysyf_manager errorLog
_write_log "sql" $LINENO "sqlplus_reset()" "sqlplus日志：$ysyf_manager_log 时间戳：$SQLStamp"  
	

sqlplus ysyf_admin/ysyf_admin << EOF > $sqlplusUpdateLog
    set head off;
	$statement
	commit;
EOF
	
	isOK=$(cat $sqlplusUpdateLog | grep -e "1 row updated.")
	
	if [ $? -eq 0 ]
	then
		echo
		prompt_info="用户$_login_name, 密码重置成功！密码为123456"
		prompt_red
		echo
		echo -e "\t祝小姐姐越来越美丽！再见！"
		exit_handler
	else
	    echo
		prompt_info="用户$_login_name, 密码重置失败！"
		prompt_red
		echo
		prompt_info="请联系系统管理员!"
		prompt_red
		echo
		echo -e "\t祝小姐姐越来越美丽！再见！"
		exit_handler
	fi
	
	echo "SQLStamp: $SQLStamp"       >>   $ysyf_manager_log   #Script ysyf_manager runLog
	
	unset statement
}

function sqlplus_disble()
{
	>$sqlplusUpdateLog
	
SQLStamp=$(date +%s)
_write_log "sql" $LINENO "sqlplus_disble()" "连接数据库"              #Script ysyf_manager errorLog
_write_log "sql" $LINENO "sqlplus_disble()" "sqlplus日志：$ysyf_manager_log 时间戳：$SQLStamp"  
	

sqlplus ysyf_admin/ysyf_admin << EOF > $sqlplusUpdateLog
    set head off;
	$statement
	commit;
EOF
	
	isOK=$(cat $sqlplusUpdateLog | grep -e "1 row updated.")
	
	if [ $? -eq 0 ]
	then
		echo
		prompt_info="用户$_login_name, 账号停用日期:${RunDate}"
		prompt_red
		echo
		echo -e "\t祝小姐姐越来越美丽！再见！"
		exit_handler
	else
	    echo
		prompt_info="用户$_login_name, 账号停用失败!"
		prompt_red
		echo
		prompt_info="请联系系统管理员!"
		prompt_red
		echo
		echo -e "\t祝小姐姐越来越美丽！再见！"
		exit_handler
	fi
	
	echo "SQLStamp: $SQLStamp"       >>   $ysyf_manager_log   #Script ysyf_manager runLog
	
	unset statement
}

function hospitalDisplay()
{
    >$hspDatFile
	
	sqluldr2linux64.bin user=ysyf_admin/ysyf_admin query="$statement" file=$hspDatFile log=+$uldr_hsplogFile
	
	#获取模糊搜索医院数量
	hospital_num=$(sed -n '$=' $hspDatFile)
	
    sed -i '1iNO,医院名称,SheetId,省份,城市,create_time' $hspDatFile
	
	awk 'BEGIN{FS=","; OFS="|"}{n2=35-length($2); n4=18-length($4); n5=18-length($5); printf "%-5s|%-"n2"s|%-34s|%-"n4"s|%-"n5"s|%-21s\n",$1,$2,$3,$4,$5,$6}' $hspDatFile > $hspDatFile_f 
	
	echo
	echo -e "--------------------------------------------------------------------------------------------------------------------------------------"
    cat $hspDatFile_f
	echo -e "--------------------------------------------------------------------------------------------------------------------------------------"
    echo
}

function cityDisplay()
{
    >$cityDatFile
	
	statement="select * from region where parent_id = '$_province_id'"
	sqluldr2linux64.bin user=ysyf_admin/ysyf_admin query="$statement" file=$cityDatFile log=+$uldr_cityLogFile
	
	#awk -F"," '{print "\t" NR ")、" $3}' $cityDatFile > $cityDatFile_f
	awk -F"," '{ print $3 }' $cityDatFile > $cityDatFile_f
	
	echo
	echo -e "----------------------------"
    cat $cityDatFile_f
	echo -e "----------------------------"
    echo
	
}

function input_city()
{
	LINE1="请输入城市名称："
	get_answer                            # function transfer
	_city_name=$ANSWER
	
	isExist=$(cat $cityDatFile_f | grep -e "$_city_name")

	if [ $? -eq 0 ]
	then
		_city_name=$(awk "/$_city_name/" $cityDatFile_f)
		#echo "awk '/$_city/' $cityDatFile_f | awk -F"、" '{ print $2 }'"
		echo
		echo -e "\t城市名称=$_city_name, 接收成功, 继续处理！"
	else
		echo
		prompt_info="城市名称输入有误, 请重新输入！"
		prompt_red                        # function transfer
		
		input_city                        # function transfer
	fi
}

function getMenu()
{
    echo                                                                       
    echo                                                                     
	echo -e "\t***********==========主菜单==========***********"             
	echo -e "\t*                                              *"             
	echo -e "\t*      用户审核：                              *"             
	echo -e "\t*      1)用户登录名       2)医院名称           *"             
	echo -e "\t*      3)医生姓名         4)手机号             *"             
	echo -e "\t*                                              *"             
	echo -e "\t*----------------------------------------------*"             
	echo -e "\t*                                              *"             
	echo -e "\t*      账号管理：                              *"             
    echo -e "\t*      5)重置密码        10)账号停用           *"             
	echo -e "\t*                                              *"             
	echo -e "\t*----------------------------------------------*"             
	echo -e "\t*                                              *"             
	echo -e "\t*      医院管理：                              *"             
	echo -e "\t*      6)查看医院列表      7)查看医生列表      *"             
	echo -e "\t*      8)新增医院          9)修改医院名称      *"             
	echo -e "\t*                                              *"             
	echo -e "\t*----------------------------------------------*"             
    echo -e "\t*                                              *"             
	echo -e "\t*      Q)退出程序                              *"             
	echo -e "\t*                                              *"             
	echo -e "\t************************************************"             
        
    LINE1="请输入选项括号前面的内容：" 
    get_answer   
    process_Menu	
}

function process_Menu()
{
    echo "获得主菜单选项：$ANSWER"   >>   $ysyf_manager_log                #Script ysyf_manager runLog
	_write_log "log" $LINENO "process_Menu()" "获得主菜单选项：$ANSWER"    #Script ysyf_manager errorLog
	
	
 	case $ANSWER in

	1)  #用户审核--用户登录名(login_name)
	    user_check_show                       # function transfer
		user_audit                            # function transfer
		exit_handler                          # function transfer
	;;
	
	2)  #用户审核--医院名称
		hospital_check                        # function transfer
		statement="select * from doctor_info d where d.hospital_name like '%$_hospital_name%';"
	    userDisplay                           # function transfer
		
        user_check_show                       # function transfer
		user_audit                            # function transfer
	    exit_handler                          # function transfer
	;;
	  
	3)  #用户审核--医生姓名
        doctor_check_show                     # function transfer
        user_check_show                       # function transfer
		user_audit                            # function transfer
	    exit_handler                          # function transfer
	;;
	
	4)  #用户审核--手机号
        phone_check_show                      # function transfer
        user_check_show                       # function transfer
		user_audit                            # function transfer
	    exit_handler                          # function transfer
		;;

	5)  #账号管理--重置密码
	
	    user_check_show                       # function transfer
		
		# Make Sure The User is Right
		LINE1="确定是这个用户吗？"
		LINE2="是否重置密码？[y/n]："
		get_answer

		EXIT_LINE1="因为你不希望对这个用户重置密码！"
		EXIT_LINE2="所以, 退出这个脚本！"
		process_answer
		
		statement="update ysyf_login set login_password = '$default_password' where login_name='$_login_name';"
		sqlplus_reset
        ;;
		
	10)  #账号管理--账号停用
	
	    user_check_show                       # function transfer
		
		# Make Sure The User is Right
		LINE1="确定是这个用户吗？"
		LINE2="是否停用账号？[y/n]："
		get_answer

		EXIT_LINE1="因为你不希望停用这个用户！"
		EXIT_LINE2="所以, 退出这个脚本！"
		process_answer
		
		statement="update ysyf_login set is_check = '0',disable_time = '${RunDate}' where login_name='$_login_name' and is_check = '1';"
		sqlplus_disble
        ;;

    6)  #医院管理--查看医院列表	
		statement="select h.hospital_no,h.hospital_name,h.sheetid,r.region_name,h.hospital_city,h.create_time   from ysyf_hospital_info h    left join region r on h.hospital_province = r.region_id   order by h.hospital_no;"
        hospitalDisplay
		
		prompt_info="列表已显示完毕！"
		prompt
		getListMenu
    ;;
	
	7)  #医院管理--查看医生列表
		statement="select * from doctor_info;"
        userDisplay
		
		prompt_info="列表已显示完毕！"
		prompt
		getListMenu
    ;;
	
	8)  #医院管理--新增医院
        LINE1="请输入医院名称："
		get_answer                            # function transfer
		_hospital_name=$ANSWER
		
		#load                                 # function transfer
		statement="select * from ysyf_hospital_info h where h.hospital_name = '$_hospital_name';"
		sqlplus_select                        # function transfer
		
		isExist=$(cat $sqlplusSelectLog | grep -e "no rows selected")

		if [ $? -eq 0 ]
		then
			echo
			prompt_info="系统检测到不存在此医院, 可以添加, 继续处理！"
			prompt                            # function transfer
		else
			echo
			prompt_info="系统检测到此医院已存在, 不可再次添加"
			prompt_red                        # function transfer
			exit_handler                      # function transfer
		fi
		
		getProvMenu                           # function transfer
		
		cityDisplay                           # function transfer
		input_city                            # function transfer
		
		_create_time=`date +'%F %T'`

        statement="insert into ysyf_hospital_info h (sheetid, HOSPITAL_NAME, hospital_id, HOSPITAL_PROVINCE, HOSPITAL_CITY, CREATE_TIME) values (sys_guid(), '$_hospital_name', (select max(h.hospital_id)+1 from ysyf_hospital_info h), '$_province_id', '$_city_name', '$_create_time');"
		sqlplus_insert                        # function transfer
		
		isOK=$(cat $sqlplusInsertLog | grep -e "1 row created.")
	
		if [ $? -eq 0 ]
		then
			echo
			prompt_info="医院名称=$_hospital_name添加成功"
			prompt
			echo
			echo -e "\t祝小姐姐越来越美丽！再见！"
			exit_handler
		else
			echo
			prompt_info="医院添加失败！请联系系统管理员"
			prompt_red
			echo
			echo -e "\t祝小姐姐越来越美丽！再见！"
			exit_handler
		fi
        		
    ;;
	
	9)  #医院管理--修改医院名称
        hospital_check                        # function transfer
		
		statement="select h.hospital_no,h.hospital_name,h.sheetid,r.region_name,h.hospital_city,h.create_time from ysyf_hospital_info h left join region r on h.hospital_province = r.region_id where h.hospital_name like '%$_hospital_name%' order by h.hospital_no;"
        hospitalDisplay                       # function transfer
		
		if [ $hospital_num -gt 1 ]
		then
			echo
			prompt_info="系统根据医院名称--$_hospital_name--检测到$hospital_num家医院, 无法进行精准修改！"
			prompt_red                        # function transfer
			echo
			prompt_info="由于使用模糊查找, 会影响修改的精准性, 请根据已经查出的SheetId进行修改！"
			prompt                            # function transfer
			echo
			
			LINE1="请输入SheetId："
            get_answer                        # function transfer
		    _hspSheetId=$ANSWER
			
			statement="select * from ysyf_hospital_info h where h.hospital_sheetid = '$_hspSheetId';"
            sqlplus_select                    # function transfer
			
			isExist=$(cat $sqlplusSelectLog | grep -e "no rows selected")
	
			if [ $? -eq 0 ]
			then
				echo
				prompt_info="未能根据SheetId找到医院！"
				prompt_red                        # function transfer
				exit_handler                      # function transfer
			else
				echo
				prompt_info="医院SheetId=$ANSWER, 系统检测成功, 继续处理！"
				prompt                            # function transfer
				
				#接收修改后的医院名称
				hospital_accurateCheck            # function transfer
				
				#hospitalNameUpdate
				statement="update ysyf_hospital_info h set h.hospital_name = '$_upd_hospital_name' where h.sheetid = '$_hspSheetId';"
                sqlplus_hospitalUpdate            # function transfer
				exit_handler                      # function transfer
			fi
		else
		    #接收修改后的医院名称
			hospital_accurateCheck            # function transfer
		
			#hospitalNameUpdate
			statement="update ysyf_hospital_info h set h.hospital_name = '$_upd_hospital_name' where h.hospital_name = '$_hospital_name';"
            sqlplus_hospitalUpdate            # function transfer
			exit_handler                      # function transfer
		fi                  
    ;;
	
	Q)  
        echo
		prompt_info="程序退出！"
		prompt
	    exit_handler                          # function transfer
    ;;

    *)
        prompt_info="输入选项错误！"
        prompt_red
        getMenu
    ;;

	esac  
}

function getListMenu()
{
    echo
	echo -e "\t请根据以下选项做出选择："
	echo -e "\t1)回到主菜单"
	echo -e "\t2)退出程序！"
	echo
        
    LINE1="请输入选项括号前面的数字：" 
    get_answer   
    process_ListMenu	
}

function process_ListMenu()
{
	case $ANSWER in

	1)  #回到主菜单
	    getMenu
	;;	
	
	2)  #退出程序
        echo
		prompt_info="程序退出！"
		prompt
	    exit_handler                          # function transfer
    ;;

    *)
        echo
		prompt_info="输入选项错误！"
		prompt_red
        getListMenu
    ;;

	esac 
}

function getProvMenu()
{
    echo
	echo -e "\t*******************===============省份列表===============*******************"
	echo -e "\t*                                                                          *"
    echo -e "\t*    2)、北京市    3)、天津市    4)、河北省    5)、山西省    6)、内蒙古    *"
    echo -e "\t*    7)、辽宁省    8)、吉林省    9)、黑龙江   10)、上海市   11)、江苏省    *"
    echo -e "\t*   12)、浙江省   13)、安徽省   14)、福建省   15)、江西省   16)、山东省    *"
    echo -e "\t*   17)、河南省   18)、湖北省   19)、湖南省   20)、广东省   21)、广西      *"
    echo -e "\t*   22)、海南省   23)、重庆市   24)、四川省   25)、贵州省   26)、云南省    *"
    echo -e "\t*   27)、西藏     28)、陕西省   29)、甘肃省   30)、青海省   31)、宁夏      *"
    echo -e "\t*   32)、新疆     33)、香港     34)、澳门     35)、台湾省                  *"           
	echo -e "\t*                                                                          *"
	echo -e "\t*--------------------------------------------------------------------------*"
	echo -e "\t*                                                                          *"
	echo -e "\t*   Q)、退出                                                               *"
	echo -e "\t*                                                                          *"
	echo -e "\t****************************************************************************"
        
    LINE1="请输入序号或者省份名：" 
    get_answer   
    process_provMenu	
}

function process_provMenu()
{
	case $ANSWER in

	2|京|北京|北京市)  #2、北京市
	    _province_id=2
	;;	
	
	3|津|天津|天津市)  #3、天津市
		_province_id=3
    ;;
	
	4|河北|河北省)  #4、河北省
		_province_id=4
    ;;
	
	5|山西|山西省)  #5、山西省
		_province_id=5
    ;;
	
	6|内蒙|内蒙古|内蒙古自治区)  #6、内蒙古
		_province_id=6
    ;;
	
	7|辽|辽宁|辽宁省)  #7、辽宁省
		_province_id=7
    ;;

	8|吉林|吉林省)  #8、吉林省
        _province_id=8
    ;;

    9|黑龙江|黑龙江省)  #9、黑龙江
        _province_id=9
    ;;
	
	10|上海|上海市)  #10、上海市
        _province_id=10
    ;;
	
	11|江苏|江苏省)  #11、江苏省
        _province_id=11
    ;;
	
	12|浙江|浙江省)  #12、浙江省
        _province_id=12
    ;;
	
	13|安徽|安徽省)  #13、安徽省
        _province_id=13
    ;;
	
	14|福建|福建省)  #14、福建省
        _province_id=14
    ;;
	
	15|江西|江西省)  #15、江西省
        _province_id=15
    ;;
	
	16|鲁|山东|山东省)  #16、山东省
        _province_id=16
    ;;
	
	17|河南|河南省)  #t17、河南省
        _province_id=17
    ;;
	
	18|湖北|湖北省)  #18、湖北省
        _province_id=18
    ;;
	
	19|湖南|湖南省)  #19、湖南省
        _province_id=19
    ;;
	
	20|广东|广东省)  #20、广东省
        _province_id=20
    ;;
	
	21|广西|广西壮族自治区)    #21、广西壮族自治区
        _province_id=21
    ;;
	
	22|海南|海南省)  #22、海南省
        _province_id=22
    ;;
	
	23|重庆|重庆市)  #23、重庆市
        _province_id=23
    ;;
	
	24|四川|四川省)    #24、四川省
        _province_id=24
    ;;
	
	25|贵州|贵州省)    #25、贵州省
        _province_id=25
    ;;
	
	26|云南|云南省)    #26、云南省
        _province_id=26
    ;;
	
	27|藏|西藏|西藏自治区)    #27、西藏
        _province_id=27
    ;;
	
	28|陕|陕西|陕西省)    #28、陕西省
        _province_id=28
    ;;
	
	29|甘|甘肃|甘肃省)    #29、甘肃省
        _province_id=29
    ;;
	
	30|青海|青海省)    #30、青海省
        _province_id=30
    ;;
	
	31|宁夏|宁夏回族自治区)    #31、宁夏
        _province_id=31
    ;;
	
	32|疆|新疆|新疆维吾尔自治区)    #32、新疆
        _province_id=32
    ;;
	
	33|港|香港|香港特别行政区)    #33、香港
        _province_id=33
    ;;
	
	34|澳|澳门|澳门特别行政区)    #34、澳门
        _province_id=34
    ;;
	
	35|台|台湾|台湾省)    #35、台湾省
        _province_id=35
    ;;
	
	Q|q|quit) #退出程序
		echo
		prompt_info="程序退出！"
		prompt
	    exit_handler                          # function transfer
	;;
	
    *)
        echo
		prompt_info="输入选项错误！"
		prompt_red
        getProvMenu
    ;;

	esac 
	
}


####################################################################################################
#
# Main Script
#
####################################################################################################

#
# Load The Environment File 
#
if [ -r "$ENVFILE" ]
then
	source $ENVFILE
else
	EXITCODE=-1
	exit_handler
fi

echo -e "\t           ---------------    $uDate  ----------"  >>  $ysyf_manager_log   #Script ysyf_manager runLog

_write_log "begin"  #Script ysyf_manager errorLog
         
getMenu



     

