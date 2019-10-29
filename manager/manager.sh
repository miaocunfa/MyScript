####################################################################################################
#
# Set Parameter
#
####################################################################################################
RunDate=`date +%Y%m%d`
uDate=`date +'%F %T'`
ENVFILE="/etc/profile"
EXITCODE=0

# �����û��б�
uldr_userlogFile=/home/ysyf/log/ysyf_manager/uldrLog-user-$RunDate.log
userDatFile=/home/ysyf/log/ysyf_manager/uldrDat-user-$RunDate.dat
userDatFile_f=/home/ysyf/log/ysyf_manager/formatDat-user-$RunDate.dat

# ����ҽԺ�б�
uldr_hsplogFile=/home/ysyf/log/ysyf_manager/uldrLog-hospital-$RunDate.log
hspDatFile=/home/ysyf/log/ysyf_manager/uldrDat-hospital-$RunDate.dat
hspDatFile_f=/home/ysyf/log/ysyf_manager/formatDat-hospital-$RunDate.dat

# ���������б�
uldr_cityLogFile=/home/ysyf/log/ysyf_manager/uldrLog-city-$RunDate.log
cityDatFile=/home/ysyf/log/ysyf_manager/uldrDat-city-$RunDate.dat
cityDatFile_f=/home/ysyf/log/ysyf_manager/formatDat-city-$RunDate.dat

# sqlplus��־
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
	
	#��־����
	_write_log "log" $LINENO "exit_handler()" "�����˳�!"              #Script ysyf_manager errorLog
	_write_log "end"                                                   #Script ysyf_manager errorLog
	
	echo "�����˳�"     >>  $ysyf_manager_log   #Script ysyf_manager runLog
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
		    prompt_info="��ش�������⣡"
		    prompt_red
	    ;;
	     
	  	3)  
		    prompt_info="�ٴγ��ԣ���ش�������⣡"
		    prompt_red
	    ;;
	     
	  	4)  
		    prompt_info="��Ϊ��ܾ��ش��������...."
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
        echo -e "\tȷ�ϲ���, ��������!"
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
_write_log "sql" $LINENO "sqlplus_select()" "�������ݿ�"              #Script ysyf_manager errorLog
_write_log "sql" $LINENO "sqlplus_select()" "sqlplus��־��$ysyf_manager_log ʱ�����$SQLStamp"              #Script ysyf_manager errorLog

sqlplus ysyf_admin/ysyf_admin << EOF > $sqlplusSelectLog
    set head off;
	$statement
EOF

    #��־����
	echo "SQLStamp: $SQLStamp"       >>   $ysyf_manager_log   #Script ysyf_manager runLog
	echo "SQL��䣺$statement"       >>   $ysyf_manager_log   #Script ysyf_manager runLog
	echo "ִ�н����"                >>   $ysyf_manager_log   #Script ysyf_manager runLog
    cat  $sqlplusSelectLog           >>   $ysyf_manager_log   #Script ysyf_manager runLog        	
    echo                             >>   $ysyf_manager_log   #Script ysyf_manager runLog
}

function sqlplus_insert()
{
	>$sqlplusInsertLog

SQLStamp=$(date +%s)
_write_log "sql" $LINENO "sqlplus_insert()" "�������ݿ�"              #Script ysyf_manager errorLog
_write_log "sql" $LINENO "sqlplus_insert()" "sqlplus��־��$ysyf_manager_log ʱ�����$SQLStamp"              #Script ysyf_manager errorLog

sqlplus ysyf_admin/ysyf_admin << EOF > $sqlplusInsertLog
    set head off;
	$statement
	commit;
EOF
	
	#��־����
	echo "SQLStamp: $SQLStamp"       >>   $ysyf_manager_log   #Script ysyf_manager runLog
	echo "SQL��䣺$statement"       >>   $ysyf_manager_log   #Script ysyf_manager runLog
	echo "ִ�н����"                >>   $ysyf_manager_log   #Script ysyf_manager runLog
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
		prompt_info="ҽԺ�����ѳɹ��޸�Ϊ=$_upd_hospital_name"
		prompt
		echo
		echo -e "\tףС���Խ��Խ�������ټ���"
		exit_handler
	else
		echo
		prompt_info="ҽԺ�����޸�ʧ��! ��ϵϵͳ����Ա!"
		prompt_red
		echo
		echo -e "\tףС���Խ��Խ�������ټ���"
		exit_handler
	fi
}

function sqlplus_usercheck()
{
	>$sqlplusUpdateLog

SQLStamp=$(date +%s)
_write_log "sql" $LINENO "sqlplus_usercheck()" "�������ݿ�"              #Script ysyf_manager errorLog
_write_log "sql" $LINENO "sqlplus_usercheck()" "sqlplus��־��$ysyf_manager_log ʱ�����$SQLStamp"   

sqlplus ysyf_admin/ysyf_admin << EOF > $sqlplusUpdateLog
    set head off;
	$statement
	commit;
EOF
	
	#��־����
	echo "SQLStamp: $SQLStamp"       >>   $ysyf_manager_log   #Script ysyf_manager runLog
	echo "SQL��䣺$statement"       >>   $ysyf_manager_log   #Script ysyf_manager runLog
	echo "ִ�н����"                >>   $ysyf_manager_log   #Script ysyf_manager runLog
    cat  $sqlplusUpdateLog           >>   $ysyf_manager_log   #Script ysyf_manager runLog 
	echo                             >>   $ysyf_manager_log   #Script ysyf_manager runLog
	
	isOK=$(cat $sqlplusUpdateLog | grep -e "1 row updated.")
	
	if [ $? -eq 0 ]
	then
        statement="select * from doctor_info d where d.login_name='$_login_name';"
        userDisplay                       # function transfer
		
		echo
		prompt_info="�û�$_login_name, �����ͨ����"
		prompt                            # function transfer
		
		#��־����
		_write_log "log" $LINENO "sqlplus_usercheck()" "�û�$_login_name���ͨ����"              #Script ysyf_manager errorLog
		echo "�û�$_login_name, �����ͨ����"       >>   $ysyf_manager_log   #Script ysyf_manager runLog
		
		exit_handler                      # function transfer
	else		
		if [ $is_check -eq 1 ]
		then
			echo
			prompt_info="�������ʧ�ܣ�"
			prompt_red                    # function transfer
			echo
			prompt_info="ϵͳ��⵽�û�login_name=${_login_name}��ͨ����ˣ��������"
			prompt_red                    # function transfer
			
			#��־����
			_write_log "err" $LINENO "sqlplus_usercheck()" "���ʧ��! �û�login_name=${_login_name}��ͨ����ˣ�"              #Script ysyf_manager errorLog
			echo "�������ʧ�ܣ�"       >>   $ysyf_manager_log   #Script ysyf_manager runLog
			echo "ϵͳ��⵽�û�login_name=${_login_name}��ͨ����ˣ��������"       >>   $ysyf_manager_log   #Script ysyf_manager runLog
		fi
		
		if [ $is_check -eq 0 ]
		then
			echo
			prompt_info="�������ʧ�ܣ�"
			prompt_red                    # function transfer
			echo
			prompt_info="ϵͳ��⵽�û�login_name=fagod�Ѵ��ڲ���δͨ����ˣ�����ϵϵͳ����Ա"
			prompt_red                    # function transfer
			
			#��־����
			_write_log "err" $LINENO "sqlplus_usercheck()" "ϵͳ��⵽�û�login_name=fagod�Ѵ��ڲ���δͨ����ˣ�"              #Script ysyf_manager errorLog
			_write_log "err" $LINENO "sqlplus_usercheck()" "���ʧ��! "              #Script ysyf_manager errorLog
			echo "�������ʧ�ܣ�"       >>   $ysyf_manager_log   #Script ysyf_manager runLog
			echo "ϵͳ��⵽�û�login_name=fagod�Ѵ��ڲ���δͨ����ˣ�����ϵϵͳ����Ա"       >>   $ysyf_manager_log   #Script ysyf_manager runLog
		fi
		
		exit_handler                      # function transfer     
	fi
	
	unset statement                       # function transfer
	
}

function user_check_show()
{
	LINE1="������login_name��"
	get_answer                            # function transfer 
    _login_name=$ANSWER
	
	echo "���login_name��$ANSWER"   >>   $ysyf_manager_log   #Script ysyf_manager runLog
	_write_log "log" $LINENO "user_check_show()" "���login_name��$ANSWER"              #Script ysyf_manager errorLog
    	
		
    #load                                 # function transfer
	statement="select * from doctor_info d where d.login_name ='$_login_name';"
	sqlplus_select                        # function transfer
	
	isExist=$(cat $sqlplusSelectLog | grep -e "no rows selected")
	
	if [ $? -eq 0 ]
	then
	    echo
		prompt_info="δ�ܸ���login_name=$ANSWER�ҵ�����û���"
		prompt_red                        # function transfer
		
		#��־����
		_write_log "err" $LINENO "user_check_show()" "δ�ܸ���login_name=$ANSWER�ҵ�����û���"              #Script ysyf_manager errorLog
		echo 'isExist=$(cat $sqlplusSelectLog | grep -e "no rows selected")' " ִ�н��Ϊ��0" >>   $ysyf_manager_log   #Script ysyf_manager runLog
		echo "δ�ܸ���login_name=$ANSWER�ҵ�����û���"        >>   $ysyf_manager_log   #Script ysyf_manager runLog
		echo                                                   >>   $ysyf_manager_log   #Script ysyf_manager runLog
		
		exit_handler                      # function transfer
	else
	    echo
	    prompt_info="�û�login_name=$ANSWER, ϵͳ���ɹ�, ��������"
		prompt                            # function transfer
		
		#��־����
		_write_log "log" $LINENO "user_check_show()" "�û�login_name=$ANSWER, ϵͳ���ɹ�, ��������"              #Script ysyf_manager errorLog
		echo 'isExist=$(cat $sqlplusSelectLog | grep -e "no rows selected")' " ִ�н��Ϊ��1"  >>   $ysyf_manager_log   #Script ysyf_manager runLog
		echo "�û�login_name=$ANSWER, ϵͳ���ɹ�, ��������"   >>   $ysyf_manager_log   #Script ysyf_manager runLog
		echo                                                      >>   $ysyf_manager_log   #Script ysyf_manager runLog
		
	fi
		
    statement="select * from doctor_info d where d.login_name='$_login_name';"
    userDisplay                           # function transfer
}

# �û����
function user_audit()
{     
	# Make Sure The User is Right
    LINE1="ȷ��������û���"
    LINE2="�Ƿ�ͨ����ˣ�[y/n]��"
    get_answer                            # function transfer
	
	#��־����
	_write_log "log" $LINENO "user_audit()" "��ȡ�Ƿ�����û���$ANSWER"              #Script ysyf_manager errorLog
	echo "��ȡ�Ƿ�����û���$ANSWER"          >>  $ysyf_manager_log   #Script ysyf_manager runLog
	echo                                  >>  $ysyf_manager_log   #Script ysyf_manager runLog

    EXIT_LINE1="��Ϊ�㲻ϣ�����ͨ������û���"
    EXIT_LINE2="����, �˳�����ű���"
    process_answer                        # function transfer
	
	statement="update ysyf_login set is_check = '1' where login_name = '$_login_name' and is_check = '0';"
	sqlplus_usercheck                     # function transfer
}


function hospital_check()
{
	LINE1="������ҽԺ����(֧��ģ������)��"
	get_answer                            # function transfer
	_hospital_name=$ANSWER
	
	#��־����
	_write_log "log" $LINENO "hospital_check()" "���ҽԺ���ƣ�$_hospital_name"              #Script ysyf_manager errorLog
	echo "���ҽԺ���ƣ�$_hospital_name"     >>  $ysyf_manager_log   #Script ysyf_manager runLog
	
	statement="select * from ysyf_hospital_info h where h.hospital_name like '%$_hospital_name%';"
	sqlplus_select                        # function transfer
	
	isExist=$(cat $sqlplusSelectLog | grep -e "no rows selected")

	if [ $? -eq 0 ]
	then
	    echo
		prompt_info="δ�ܸ���ҽԺ�����ҵ���ҽԺ��"
		prompt_red                        # function transfer
		
		#��־����
		_write_log "err" $LINENO "hospital_check()" "δ�ܸ���ҽԺ�����ҵ���ҽԺ��"              #Script ysyf_manager errorLog
		echo 'isExist=$(cat $sqlplusSelectLog | grep -e "no rows selected")' " ִ�н��Ϊ��0" >>   $ysyf_manager_log   #Script ysyf_manager runLog
		echo "δ�ܸ���ҽԺ�����ҵ���ҽԺ��"        >>   $ysyf_manager_log   #Script ysyf_manager runLog
		echo                                       >>   $ysyf_manager_log   #Script ysyf_manager runLog
		
		exit_handler                      # function transfer
	else
	    echo
		prompt_info="ҽԺ����=$ANSWER, ϵͳ���ɹ�, ��������"
		prompt                            # function transfer
		
		#��־����
		_write_log "log" $LINENO "hospital_check()" "ҽԺ����=$ANSWER, ϵͳ���ɹ�, ��������"              #Script ysyf_manager errorLog
		echo 'isExist=$(cat $sqlplusSelectLog | grep -e "no rows selected")' " ִ�н��Ϊ��1" >>   $ysyf_manager_log   #Script ysyf_manager runLog
		echo "ҽԺ����=$ANSWER, ϵͳ���ɹ�, ��������"        >>   $ysyf_manager_log   #Script ysyf_manager runLog
		echo                                                     >>   $ysyf_manager_log   #Script ysyf_manager runLog
	fi	 		
}

function hospital_accurateCheck()
{
	LINE1="�������޸ĺ��ҽԺ���ƣ�"
	get_answer                            # function transfer
	_upd_hospital_name=$ANSWER
	
	#load                                 # function transfer
	statement="select * from ysyf_hospital_info h where h.hospital_name = '$_upd_hospital_name';"
	sqlplus_select                        # function transfer
	
	isExist=$(cat $sqlplusSelectLog | grep -e "no rows selected")

	if [ $? -eq 0 ]
	then
	    echo
		prompt_info="ϵͳ��⵽��ҽԺ��δ��ʹ��, ��������"
		prompt                        # function transfer
	else
	    echo
		prompt_info="ϵͳ��⵽��ҽԺ���ѱ�ʹ��"
		prompt_red                            # function transfer
		hospital_accurateCheck
	fi	 		
}

function doctor_check_show()
{
	LINE1="������ҽ������(֧��ģ������)��"
	get_answer                            # function transfer
	_doctor_name=$ANSWER
	
	#��־����
	_write_log "log" $LINENO "doctor_check_show()" "���ҽ��������$_doctor_name"              #Script ysyf_manager errorLog
	echo "���ҽ��������$_doctor_name"     >>  $ysyf_manager_log   #Script ysyf_manager runLog
	
	#load                                  # function transfer
	statement="select * from doctor_info d where d.doctor_name like '%$_doctor_name%';"
	sqlplus_select                        # function transfer
	
	isExist=$(cat $sqlplusSelectLog | grep -e "no rows selected")

	if [ $? -eq 0 ]
	then
	    echo
		prompt_info="δ�ܸ���ҽ�������ҵ��û���"
		prompt_red                        # function transfer
		
		#��־����
		_write_log "err" $LINENO "doctor_check_show()" "δ�ܸ���ҽ�������ҵ��û���"              #Script ysyf_manager errorLog
		echo 'isExist=$(cat $sqlplusSelectLog | grep -e "no rows selected")' " ִ�н��Ϊ��0" >>   $ysyf_manager_log   #Script ysyf_manager runLog
		echo "δ�ܸ���ҽ�������ҵ��û���"        >>   $ysyf_manager_log   #Script ysyf_manager runLog
		echo                                     >>   $ysyf_manager_log   #Script ysyf_manager runLog
		
		exit_handler                      # function transfer
	else
	    echo
		prompt_info="ҽ������=$ANSWER, ϵͳ���ɹ�, ��������"
		prompt                            # function transfer
		
		#��־����
		_write_log "log" $LINENO "doctor_check_show()" "ҽ������=$ANSWER, ϵͳ���ɹ�, ��������"              #Script ysyf_manager errorLog
		echo 'isExist=$(cat $sqlplusSelectLog | grep -e "no rows selected")' " ִ�н��Ϊ��1" >>   $ysyf_manager_log   #Script ysyf_manager runLog
		echo "ҽ������=$ANSWER, ϵͳ���ɹ�, ��������"        >>   $ysyf_manager_log   #Script ysyf_manager runLog
		echo                                                     >>   $ysyf_manager_log   #Script ysyf_manager runLog
	fi
	
	statement="select * from doctor_info d where d.doctor_name like '%$_doctor_name%';"
	userDisplay                           # function transfer
}

function phone_check_show()
{
	LINE1="�������ֻ���(֧��ģ������)��"
	get_answer                            # function transfer
	_phone_number=$ANSWER
	
	#��־����
	_write_log "log" $LINENO "phone_check_show()" "����ֻ��ţ�$_phone_number"              #Script ysyf_manager errorLog
	echo "����ֻ��ţ�$_phone_number"     >>  $ysyf_manager_log   #Script ysyf_manager runLog
	
	statement="select * from doctor_info d where d.doctor_phone like '%$_phone_number%';"
	sqlplus_select                        # function transfer
	
	isExist=$(cat $sqlplusSelectLog | grep -e "no rows selected")

	if [ $? -eq 0 ]
	then
	    echo
		prompt_info="δ�ܸ����ֻ����ҵ��û���"
		prompt_red                        # function transfer
		
		#��־����
		_write_log "err" $LINENO "phone_check_show()" "δ�ܸ����ֻ����ҵ��û���"              #Script ysyf_manager errorLog
		echo 'isExist=$(cat $sqlplusSelectLog | grep -e "no rows selected")' " ִ�н��Ϊ��0" >>   $ysyf_manager_log   #Script ysyf_manager runLog
		echo "δ�ܸ����ֻ����ҵ��û���"        >>   $ysyf_manager_log   #Script ysyf_manager runLog
		echo                                   >>   $ysyf_manager_log   #Script ysyf_manager runLog
		
		exit_handler                      # function transfer
	else
	    echo
		prompt_info="�ֻ���=$ANSWER, ϵͳ���ɹ�, ��������"
		prompt                            # function transfer
		
		#��־����
		_write_log "log" $LINENO "phone_check_show()" "�ֻ���=$ANSWER, ϵͳ���ɹ�, ��������"              #Script ysyf_manager errorLog
		echo 'isExist=$(cat $sqlplusSelectLog | grep -e "no rows selected")' " ִ�н��Ϊ��1" >>   $ysyf_manager_log   #Script ysyf_manager runLog
		echo "�ֻ���=$ANSWER, ϵͳ���ɹ�, ��������"     >>   $ysyf_manager_log   #Script ysyf_manager runLog
		echo                                                >>   $ysyf_manager_log   #Script ysyf_manager runLog
		
	fi
	
	statement="select * from doctor_info d where d.doctor_phone like '%$_phone_number%';"
	userDisplay                           # function transfer
}



function userDisplay()
{
    >$userDatFile
	
	sqluldr2linux64.bin user=ysyf_admin/ysyf_admin query="$statement" file=$userDatFile log=+$uldr_hsplogFile
	_write_log "log" $LINENO "userDisplay()" "ִ��sqluldr�����ı���$userDatFile"    #Script ysyf_manager errorLog
	
	is_check=`awk -F',' '{print $16}' $userDatFile`
	
    sed -i '1iNO,ҽԺ����,ҽԺID,hspSheetId,ʡ��,ʡ��ID,ҽ������,login_name,ҽ��ID,ҽ�����,ҽ��������,phone,create_time,disable_time,���״̬,�����' $userDatFile
	
	awk 'BEGIN{FS=","; OFS="|"}{n2=30-length($2); n7=12-length($7); printf "%-5s|%-"n2"s|%-"n7"s|%-12s|%-13s|%-21s|%-14s|%-6s\n",$1,$2,$7,$8,$12,$13,$14,$15}' $userDatFile > $userDatFile_f 
	_write_log "log" $LINENO "userDisplay()" "��ʽ���ı���$userDatFile_f"    #Script ysyf_manager errorLog
	
	echo
	echo  "--------------------------------------------------------------------------------------------------------------------------"
    cat $userDatFile_f
	echo  "--------------------------------------------------------------------------------------------------------------------------"
    echo
	
	#��־����
	echo "�û���Ϣչʾ��"             >>  $ysyf_manager_log   #Script ysyf_manager runLog
	echo "�������sqluldr2linux64.bin user=ysyf_admin/ysyf_admin query="$statement" file=$userDatFile log=+$uldr_hsplogFile"  >>   $ysyf_manager_log   #Script ysyf_manager runLog
	echo "SQL��䣺$statement"        >>  $ysyf_manager_log   #Script ysyf_manager runLog
	echo "��־�ļ���$uldr_hsplogFile" >>  $ysyf_manager_log   #Script ysyf_manager runLog
	echo                              >>  $ysyf_manager_log   #Script ysyf_manager runLog
	echo "ԭʼ�ı���$userDatFile"     >>  $ysyf_manager_log   #Script ysyf_manager runLog
	echo "----------------------------------------------------------------"   >>  $ysyf_manager_log   #Script ysyf_manager runLog
	cat  $userDatFile                 >>  $ysyf_manager_log   #Script ysyf_manager runLog
	echo                              >>  $ysyf_manager_log   #Script ysyf_manager runLog
	echo "��ʽ���ı���$userDatFile_f" >>  $ysyf_manager_log   #Script ysyf_manager runLog
	echo "----------------------------------------------------------------"   >>  $ysyf_manager_log   #Script ysyf_manager runLog
	cat  $userDatFile_f               >>  $ysyf_manager_log   #Script ysyf_manager runLog
	echo                              >>  $ysyf_manager_log   #Script ysyf_manager runLog
}

function sqlplus_reset()
{
	>$sqlplusUpdateLog
	
SQLStamp=$(date +%s)
_write_log "sql" $LINENO "sqlplus_reset()" "�������ݿ�"              #Script ysyf_manager errorLog
_write_log "sql" $LINENO "sqlplus_reset()" "sqlplus��־��$ysyf_manager_log ʱ�����$SQLStamp"  
	

sqlplus ysyf_admin/ysyf_admin << EOF > $sqlplusUpdateLog
    set head off;
	$statement
	commit;
EOF
	
	isOK=$(cat $sqlplusUpdateLog | grep -e "1 row updated.")
	
	if [ $? -eq 0 ]
	then
		echo
		prompt_info="�û�$_login_name, �������óɹ�������Ϊ123456"
		prompt_red
		echo
		echo -e "\tףС���Խ��Խ�������ټ���"
		exit_handler
	else
	    echo
		prompt_info="�û�$_login_name, ��������ʧ�ܣ�"
		prompt_red
		echo
		prompt_info="����ϵϵͳ����Ա!"
		prompt_red
		echo
		echo -e "\tףС���Խ��Խ�������ټ���"
		exit_handler
	fi
	
	echo "SQLStamp: $SQLStamp"       >>   $ysyf_manager_log   #Script ysyf_manager runLog
	
	unset statement
}

function sqlplus_disble()
{
	>$sqlplusUpdateLog
	
SQLStamp=$(date +%s)
_write_log "sql" $LINENO "sqlplus_disble()" "�������ݿ�"              #Script ysyf_manager errorLog
_write_log "sql" $LINENO "sqlplus_disble()" "sqlplus��־��$ysyf_manager_log ʱ�����$SQLStamp"  
	

sqlplus ysyf_admin/ysyf_admin << EOF > $sqlplusUpdateLog
    set head off;
	$statement
	commit;
EOF
	
	isOK=$(cat $sqlplusUpdateLog | grep -e "1 row updated.")
	
	if [ $? -eq 0 ]
	then
		echo
		prompt_info="�û�$_login_name, �˺�ͣ������:${RunDate}"
		prompt_red
		echo
		echo -e "\tףС���Խ��Խ�������ټ���"
		exit_handler
	else
	    echo
		prompt_info="�û�$_login_name, �˺�ͣ��ʧ��!"
		prompt_red
		echo
		prompt_info="����ϵϵͳ����Ա!"
		prompt_red
		echo
		echo -e "\tףС���Խ��Խ�������ټ���"
		exit_handler
	fi
	
	echo "SQLStamp: $SQLStamp"       >>   $ysyf_manager_log   #Script ysyf_manager runLog
	
	unset statement
}

function hospitalDisplay()
{
    >$hspDatFile
	
	sqluldr2linux64.bin user=ysyf_admin/ysyf_admin query="$statement" file=$hspDatFile log=+$uldr_hsplogFile
	
	#��ȡģ������ҽԺ����
	hospital_num=$(sed -n '$=' $hspDatFile)
	
    sed -i '1iNO,ҽԺ����,SheetId,ʡ��,����,create_time' $hspDatFile
	
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
	
	#awk -F"," '{print "\t" NR ")��" $3}' $cityDatFile > $cityDatFile_f
	awk -F"," '{ print $3 }' $cityDatFile > $cityDatFile_f
	
	echo
	echo -e "----------------------------"
    cat $cityDatFile_f
	echo -e "----------------------------"
    echo
	
}

function input_city()
{
	LINE1="������������ƣ�"
	get_answer                            # function transfer
	_city_name=$ANSWER
	
	isExist=$(cat $cityDatFile_f | grep -e "$_city_name")

	if [ $? -eq 0 ]
	then
		_city_name=$(awk "/$_city_name/" $cityDatFile_f)
		#echo "awk '/$_city/' $cityDatFile_f | awk -F"��" '{ print $2 }'"
		echo
		echo -e "\t��������=$_city_name, ���ճɹ�, ��������"
	else
		echo
		prompt_info="����������������, ���������룡"
		prompt_red                        # function transfer
		
		input_city                        # function transfer
	fi
}

function getMenu()
{
    echo                                                                       
    echo                                                                     
	echo -e "\t***********==========���˵�==========***********"             
	echo -e "\t*                                              *"             
	echo -e "\t*      �û���ˣ�                              *"             
	echo -e "\t*      1)�û���¼��       2)ҽԺ����           *"             
	echo -e "\t*      3)ҽ������         4)�ֻ���             *"             
	echo -e "\t*                                              *"             
	echo -e "\t*----------------------------------------------*"             
	echo -e "\t*                                              *"             
	echo -e "\t*      �˺Ź���                              *"             
    echo -e "\t*      5)��������        10)�˺�ͣ��           *"             
	echo -e "\t*                                              *"             
	echo -e "\t*----------------------------------------------*"             
	echo -e "\t*                                              *"             
	echo -e "\t*      ҽԺ����                              *"             
	echo -e "\t*      6)�鿴ҽԺ�б�      7)�鿴ҽ���б�      *"             
	echo -e "\t*      8)����ҽԺ          9)�޸�ҽԺ����      *"             
	echo -e "\t*                                              *"             
	echo -e "\t*----------------------------------------------*"             
    echo -e "\t*                                              *"             
	echo -e "\t*      Q)�˳�����                              *"             
	echo -e "\t*                                              *"             
	echo -e "\t************************************************"             
        
    LINE1="������ѡ������ǰ������ݣ�" 
    get_answer   
    process_Menu	
}

function process_Menu()
{
    echo "������˵�ѡ�$ANSWER"   >>   $ysyf_manager_log                #Script ysyf_manager runLog
	_write_log "log" $LINENO "process_Menu()" "������˵�ѡ�$ANSWER"    #Script ysyf_manager errorLog
	
	
 	case $ANSWER in

	1)  #�û����--�û���¼��(login_name)
	    user_check_show                       # function transfer
		user_audit                            # function transfer
		exit_handler                          # function transfer
	;;
	
	2)  #�û����--ҽԺ����
		hospital_check                        # function transfer
		statement="select * from doctor_info d where d.hospital_name like '%$_hospital_name%';"
	    userDisplay                           # function transfer
		
        user_check_show                       # function transfer
		user_audit                            # function transfer
	    exit_handler                          # function transfer
	;;
	  
	3)  #�û����--ҽ������
        doctor_check_show                     # function transfer
        user_check_show                       # function transfer
		user_audit                            # function transfer
	    exit_handler                          # function transfer
	;;
	
	4)  #�û����--�ֻ���
        phone_check_show                      # function transfer
        user_check_show                       # function transfer
		user_audit                            # function transfer
	    exit_handler                          # function transfer
		;;

	5)  #�˺Ź���--��������
	
	    user_check_show                       # function transfer
		
		# Make Sure The User is Right
		LINE1="ȷ��������û���"
		LINE2="�Ƿ��������룿[y/n]��"
		get_answer

		EXIT_LINE1="��Ϊ�㲻ϣ��������û��������룡"
		EXIT_LINE2="����, �˳�����ű���"
		process_answer
		
		statement="update ysyf_login set login_password = '$default_password' where login_name='$_login_name';"
		sqlplus_reset
        ;;
		
	10)  #�˺Ź���--�˺�ͣ��
	
	    user_check_show                       # function transfer
		
		# Make Sure The User is Right
		LINE1="ȷ��������û���"
		LINE2="�Ƿ�ͣ���˺ţ�[y/n]��"
		get_answer

		EXIT_LINE1="��Ϊ�㲻ϣ��ͣ������û���"
		EXIT_LINE2="����, �˳�����ű���"
		process_answer
		
		statement="update ysyf_login set is_check = '0',disable_time = '${RunDate}' where login_name='$_login_name' and is_check = '1';"
		sqlplus_disble
        ;;

    6)  #ҽԺ����--�鿴ҽԺ�б�	
		statement="select h.hospital_no,h.hospital_name,h.sheetid,r.region_name,h.hospital_city,h.create_time   from ysyf_hospital_info h    left join region r on h.hospital_province = r.region_id   order by h.hospital_no;"
        hospitalDisplay
		
		prompt_info="�б�����ʾ��ϣ�"
		prompt
		getListMenu
    ;;
	
	7)  #ҽԺ����--�鿴ҽ���б�
		statement="select * from doctor_info;"
        userDisplay
		
		prompt_info="�б�����ʾ��ϣ�"
		prompt
		getListMenu
    ;;
	
	8)  #ҽԺ����--����ҽԺ
        LINE1="������ҽԺ���ƣ�"
		get_answer                            # function transfer
		_hospital_name=$ANSWER
		
		#load                                 # function transfer
		statement="select * from ysyf_hospital_info h where h.hospital_name = '$_hospital_name';"
		sqlplus_select                        # function transfer
		
		isExist=$(cat $sqlplusSelectLog | grep -e "no rows selected")

		if [ $? -eq 0 ]
		then
			echo
			prompt_info="ϵͳ��⵽�����ڴ�ҽԺ, �������, ��������"
			prompt                            # function transfer
		else
			echo
			prompt_info="ϵͳ��⵽��ҽԺ�Ѵ���, �����ٴ����"
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
			prompt_info="ҽԺ����=$_hospital_name��ӳɹ�"
			prompt
			echo
			echo -e "\tףС���Խ��Խ�������ټ���"
			exit_handler
		else
			echo
			prompt_info="ҽԺ���ʧ�ܣ�����ϵϵͳ����Ա"
			prompt_red
			echo
			echo -e "\tףС���Խ��Խ�������ټ���"
			exit_handler
		fi
        		
    ;;
	
	9)  #ҽԺ����--�޸�ҽԺ����
        hospital_check                        # function transfer
		
		statement="select h.hospital_no,h.hospital_name,h.sheetid,r.region_name,h.hospital_city,h.create_time from ysyf_hospital_info h left join region r on h.hospital_province = r.region_id where h.hospital_name like '%$_hospital_name%' order by h.hospital_no;"
        hospitalDisplay                       # function transfer
		
		if [ $hospital_num -gt 1 ]
		then
			echo
			prompt_info="ϵͳ����ҽԺ����--$_hospital_name--��⵽$hospital_num��ҽԺ, �޷����о�׼�޸ģ�"
			prompt_red                        # function transfer
			echo
			prompt_info="����ʹ��ģ������, ��Ӱ���޸ĵľ�׼��, ������Ѿ������SheetId�����޸ģ�"
			prompt                            # function transfer
			echo
			
			LINE1="������SheetId��"
            get_answer                        # function transfer
		    _hspSheetId=$ANSWER
			
			statement="select * from ysyf_hospital_info h where h.hospital_sheetid = '$_hspSheetId';"
            sqlplus_select                    # function transfer
			
			isExist=$(cat $sqlplusSelectLog | grep -e "no rows selected")
	
			if [ $? -eq 0 ]
			then
				echo
				prompt_info="δ�ܸ���SheetId�ҵ�ҽԺ��"
				prompt_red                        # function transfer
				exit_handler                      # function transfer
			else
				echo
				prompt_info="ҽԺSheetId=$ANSWER, ϵͳ���ɹ�, ��������"
				prompt                            # function transfer
				
				#�����޸ĺ��ҽԺ����
				hospital_accurateCheck            # function transfer
				
				#hospitalNameUpdate
				statement="update ysyf_hospital_info h set h.hospital_name = '$_upd_hospital_name' where h.sheetid = '$_hspSheetId';"
                sqlplus_hospitalUpdate            # function transfer
				exit_handler                      # function transfer
			fi
		else
		    #�����޸ĺ��ҽԺ����
			hospital_accurateCheck            # function transfer
		
			#hospitalNameUpdate
			statement="update ysyf_hospital_info h set h.hospital_name = '$_upd_hospital_name' where h.hospital_name = '$_hospital_name';"
            sqlplus_hospitalUpdate            # function transfer
			exit_handler                      # function transfer
		fi                  
    ;;
	
	Q)  
        echo
		prompt_info="�����˳���"
		prompt
	    exit_handler                          # function transfer
    ;;

    *)
        prompt_info="����ѡ�����"
        prompt_red
        getMenu
    ;;

	esac  
}

function getListMenu()
{
    echo
	echo -e "\t���������ѡ������ѡ��"
	echo -e "\t1)�ص����˵�"
	echo -e "\t2)�˳�����"
	echo
        
    LINE1="������ѡ������ǰ������֣�" 
    get_answer   
    process_ListMenu	
}

function process_ListMenu()
{
	case $ANSWER in

	1)  #�ص����˵�
	    getMenu
	;;	
	
	2)  #�˳�����
        echo
		prompt_info="�����˳���"
		prompt
	    exit_handler                          # function transfer
    ;;

    *)
        echo
		prompt_info="����ѡ�����"
		prompt_red
        getListMenu
    ;;

	esac 
}

function getProvMenu()
{
    echo
	echo -e "\t*******************===============ʡ���б�===============*******************"
	echo -e "\t*                                                                          *"
    echo -e "\t*    2)��������    3)�������    4)���ӱ�ʡ    5)��ɽ��ʡ    6)�����ɹ�    *"
    echo -e "\t*    7)������ʡ    8)������ʡ    9)��������   10)���Ϻ���   11)������ʡ    *"
    echo -e "\t*   12)���㽭ʡ   13)������ʡ   14)������ʡ   15)������ʡ   16)��ɽ��ʡ    *"
    echo -e "\t*   17)������ʡ   18)������ʡ   19)������ʡ   20)���㶫ʡ   21)������      *"
    echo -e "\t*   22)������ʡ   23)��������   24)���Ĵ�ʡ   25)������ʡ   26)������ʡ    *"
    echo -e "\t*   27)������     28)������ʡ   29)������ʡ   30)���ຣʡ   31)������      *"
    echo -e "\t*   32)���½�     33)�����     34)������     35)��̨��ʡ                  *"           
	echo -e "\t*                                                                          *"
	echo -e "\t*--------------------------------------------------------------------------*"
	echo -e "\t*                                                                          *"
	echo -e "\t*   Q)���˳�                                                               *"
	echo -e "\t*                                                                          *"
	echo -e "\t****************************************************************************"
        
    LINE1="��������Ż���ʡ������" 
    get_answer   
    process_provMenu	
}

function process_provMenu()
{
	case $ANSWER in

	2|��|����|������)  #2��������
	    _province_id=2
	;;	
	
	3|��|���|�����)  #3�������
		_province_id=3
    ;;
	
	4|�ӱ�|�ӱ�ʡ)  #4���ӱ�ʡ
		_province_id=4
    ;;
	
	5|ɽ��|ɽ��ʡ)  #5��ɽ��ʡ
		_province_id=5
    ;;
	
	6|����|���ɹ�|���ɹ�������)  #6�����ɹ�
		_province_id=6
    ;;
	
	7|��|����|����ʡ)  #7������ʡ
		_province_id=7
    ;;

	8|����|����ʡ)  #8������ʡ
        _province_id=8
    ;;

    9|������|������ʡ)  #9��������
        _province_id=9
    ;;
	
	10|�Ϻ�|�Ϻ���)  #10���Ϻ���
        _province_id=10
    ;;
	
	11|����|����ʡ)  #11������ʡ
        _province_id=11
    ;;
	
	12|�㽭|�㽭ʡ)  #12���㽭ʡ
        _province_id=12
    ;;
	
	13|����|����ʡ)  #13������ʡ
        _province_id=13
    ;;
	
	14|����|����ʡ)  #14������ʡ
        _province_id=14
    ;;
	
	15|����|����ʡ)  #15������ʡ
        _province_id=15
    ;;
	
	16|³|ɽ��|ɽ��ʡ)  #16��ɽ��ʡ
        _province_id=16
    ;;
	
	17|����|����ʡ)  #t17������ʡ
        _province_id=17
    ;;
	
	18|����|����ʡ)  #18������ʡ
        _province_id=18
    ;;
	
	19|����|����ʡ)  #19������ʡ
        _province_id=19
    ;;
	
	20|�㶫|�㶫ʡ)  #20���㶫ʡ
        _province_id=20
    ;;
	
	21|����|����׳��������)    #21������׳��������
        _province_id=21
    ;;
	
	22|����|����ʡ)  #22������ʡ
        _province_id=22
    ;;
	
	23|����|������)  #23��������
        _province_id=23
    ;;
	
	24|�Ĵ�|�Ĵ�ʡ)    #24���Ĵ�ʡ
        _province_id=24
    ;;
	
	25|����|����ʡ)    #25������ʡ
        _province_id=25
    ;;
	
	26|����|����ʡ)    #26������ʡ
        _province_id=26
    ;;
	
	27|��|����|����������)    #27������
        _province_id=27
    ;;
	
	28|��|����|����ʡ)    #28������ʡ
        _province_id=28
    ;;
	
	29|��|����|����ʡ)    #29������ʡ
        _province_id=29
    ;;
	
	30|�ຣ|�ຣʡ)    #30���ຣʡ
        _province_id=30
    ;;
	
	31|����|���Ļ���������)    #31������
        _province_id=31
    ;;
	
	32|��|�½�|�½�ά���������)    #32���½�
        _province_id=32
    ;;
	
	33|��|���|����ر�������)    #33�����
        _province_id=33
    ;;
	
	34|��|����|�����ر�������)    #34������
        _province_id=34
    ;;
	
	35|̨|̨��|̨��ʡ)    #35��̨��ʡ
        _province_id=35
    ;;
	
	Q|q|quit) #�˳�����
		echo
		prompt_info="�����˳���"
		prompt
	    exit_handler                          # function transfer
	;;
	
    *)
        echo
		prompt_info="����ѡ�����"
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



     

