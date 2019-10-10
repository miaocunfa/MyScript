####################################################################################################
#
# Set Parameter
#
####################################################################################################
RunDate=`date +'%Y%m%d'`
ENVFILE="/etc/profile"
EXITCODE=0
uldr_userlogFile=/home/ysyf/log/logincheck/uldrLog-user-$RunDate.log
uldr_hsplogFile=/home/ysyf/log/logincheck/uldrLog-hospital-$RunDate.log
userDatFile=/home/ysyf/log/logincheck/uldrDat-user-$RunDate.dat
userDatFile_f=/home/ysyf/log/logincheck/formatDat-user-$RunDate.dat
hspDatFile=/home/ysyf/log/logincheck/uldrDat-hospital-$RunDate.dat
hspDatFile_f=/home/ysyf/log/logincheck/formatDat-hospital-$RunDate.dat

sqlplusDoctorCheckLog=/home/ysyf/log/logincheck/sqlplusDoctorCheckLog.log
sqlplusDoctorAuditLog=/home/ysyf/log/logincheck/sqlplusDoctorAuditLog.log
sqlplusDoctorResetLog=/home/ysyf/log/logincheck/sqlplusDoctorResetLog.log
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
	exit $EXITCODE
	
} # End of exit_handler function


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
            echo -e "\t��ش�������⣡"
	    ;;
	     
	  	3)  
            echo -e "\t�ٴγ��ԣ���ش�������⣡"
	    ;;
	     
	  	4)  
            echo -e "\t��Ϊ��ܾ��ش��������...."
	     	echo -e "\t�����˳���"
	     	exit_handler                     # the function Quit Script
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
		exit_handler                          # the function Quit Script
	;;
	  
	esac
	
	# Do a little variable clean-up 
	unset EXIT_LINE1
	unset EXIT_LINE2
	
} # End of process_answer function



function doctor_check()
{
	>$sqlplusDoctorCheckLog

sqlplus ysyf_admin/ysyf_admin << EOF > $sqlplusDoctorCheckLog
    set head off;
	$statement
EOF
	
	isExist=$(cat $sqlplusDoctorCheckLog | grep -e "no rows selected")
	
	if [ $? -eq 0 ]
	then
	    echo
		echo -e "\t"$ERROR_INFO
		exit_handler
	else
        echo -e "\t$ANSWER, ϵͳ���ɹ�, ��������"
	fi
	
	unset statement
}

function auditConnOracle()
{
	>$sqlplusDoctorAuditLog

sqlplus ysyf_admin/ysyf_admin << EOF > $sqlplusDoctorAuditLog
    set head off;
	$statement
	commit;
EOF
	
	isOK=$(cat $sqlplusDoctorAuditLog | grep -e "1 row updated.")
	
	if [ $? -eq 0 ]
	then
        statement="select * from doctor_info d where d.login_name='$_login_name';"
        userDisplay
		echo
		echo -e "\t�û�$_login_name, �����ͨ����"
		echo -e "\tллʹ�ã��ټ���"
		exit_handler
	else
	    echo
        echo -e "\t�û�$_login_name, ���ʧ�ܣ�"
		echo -e "\t��ʹ�ñ����ߵ��û���ѯ, ����û�$_login_name�Ƿ���ͨ�����!"
		echo -e "\t���û���ȷδ���, ʹ�ñ��������޷����ͨ��, ����ϵϵͳ����Ա!"
		echo -e "\tллʹ�ã��ټ���"
		exit_handler
	fi
	
	unset statement
}

function userDisplay()
{
    >$userDatFile
	
	sqluldr2linux64.bin user=ysyf_admin/ysyf_admin query="$statement" file=$userDatFile log=+$uldr_hsplogFile
	
    sed -i '1iNO,ҽԺ����,ҽԺID,hspSheetId,ʡ��,ʡ��ID,ҽ������,login_name,ҽ��ID,ҽ�����,ҽ��������,phone,create_time,disable_time,���״̬,�����' $userDatFile
	
	awk 'BEGIN{FS=","; OFS="|"}{n2=30-length($2); n7=12-length($7); printf "%-5s|%-"n2"s|%-"n7"s|%-12s|%-13s|%-21s|%-14s|%-6s\n",$1,$2,$7,$8,$12,$13,$14,$15}' $userDatFile > $userDatFile_f 
	
	#sqluldr2linux64.bin user=ysyf_admin/ysyf_admin query="select * from doctor_info where login_name = 'fagod';" file=/home/ysyf/log/logincheck/1 log=+/home/ysyf/log/logincheck/uldr_user_test.log	
	#awk 'BEGIN{FS=","; OFS="|"}{printf "%13s|%15s|%10s|%13s|%21s|%14s|%14s\n",$1,$2,$6,$11,$12,$13,$14}' /home/ysyf/log/logincheck/1 > 2
	#������ĸ�ʽ��������
	#�����
	#awk 'BEGIN{FS=","; OFS="|"}{n2=30-length($2); n6=12-length($6); printf "%-13s|%-"n2"s|%-"n6"s|%-12s|%-13s|%-21s|%-14s|%-6s\n",$1,$2,$6,$7,$11,$12,$13,$14}' /home/ysyf/log/logincheck/1 > 2
	#�Ҷ���
	#awk 'BEGIN{FS=","; OFS="|"}{n1=10-length($1); n2=25-length($2); n6=10-length($6); printf "%"n1"s|%"n2"s|%"n6"s|%12s|%13s|%21s|%14s|%6s\n",$1,$2,$6,$7,$11,$12,$13,$14}' /home/ysyf/log/logincheck/1 > 2
	
	echo
	echo "--------------------------------------------------------------------------------------------------------------------------"
    cat $userDatFile_f
	echo "--------------------------------------------------------------------------------------------------------------------------"
    echo
}

function userAudit()
{     		
    statement="select * from doctor_info d where d.login_name ='$_login_name';"
    ERROR_INFO="δ�ܸ���$_login_name�ҵ�����û���"
    doctor_check
		
    statement="select * from doctor_info d where d.login_name='$_login_name';"
    userDisplay

	# Make Sure The User is Right
    LINE1="ȷ��������û���"
    LINE2="�Ƿ�ͨ����ˣ�[y/n]��"
    get_answer

    EXIT_LINE1="��Ϊ�㲻ϣ�����ͨ������û���"
    EXIT_LINE2="����, �˳�����ű���"
    process_answer
	
	statement="update ysyf_login set is_check = '1' where login_name = '$_login_name' and is_check = '0';"
	auditConnOracle
}

function resetConnOracle()
{
	>$sqlplusDoctorResetLog

sqlplus ysyf_admin/ysyf_admin << EOF > $sqlplusDoctorResetLog
    set head off;
	$statement
	commit;
EOF
	
	isOK=$(cat $sqlplusDoctorResetLog | grep -e "1 row updated.")
	
	if [ $? -eq 0 ]
	then
		echo
		echo -e "\t�û�$_login_name, �������óɹ�������Ϊ123456"
		echo -e "\tллʹ�ã��ټ���"
		exit_handler
	else
	    echo
        echo -e "\t�û�$_login_name, ��������ʧ�ܣ�"
		echo -e "\t����ϵϵͳ����Ա!"
		echo -e "\tллʹ�ã��ټ���"
		exit_handler
	fi
	
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
	
	#sqluldr2linux64.bin user=ysyf_admin/ysyf_admin query="select h.hospital_no,h.hospital_name,h.hospital_id,r.region_name,h.hospital_city,h.create_time   from ysyf_hospital_info h    left join region r on h.hospital_province = r.region_id   order by h.hospital_no;" file=/home/ysyf/log/logincheck/hsp log=+/home/ysyf/log/logincheck/uldrLog_hsp_test.log	
	#�����
	#awk 'BEGIN{FS=","; OFS="|"}{n2=35-length($2); n4=18-length($4); n5=18-length($5); printf "%-13s|%-"n2"s|%-"n4"s|%-"n5"s|%-21s\n",$1,$2,$4,$5,$6}' /home/ysyf/log/logincheck/hsp > hsp_foramat
	
	echo
	echo "--------------------------------------------------------------------------------------------------------------------------------------"
    cat $hspDatFile_f
	echo "--------------------------------------------------------------------------------------------------------------------------------------"
    echo
}

function getMenu()
{
    echo
    echo
	echo -e "\t************************************************"
	echo -e "\t*                                              *"
	echo -e "\t*    �û���ˣ�                                *"
	echo -e "\t*    1)�û���¼��       2)ҽԺ����             *"
	echo -e "\t*    3)ҽ������         4)�ֻ���               *"
	echo -e "\t*                                              *"
	echo -e "\t*----------------------------------------------*"
	echo -e "\t*                                              *"
	echo -e "\t*    �˺Ź���                                *"
    echo -e "\t*    5)��������                                *"
	echo -e "\t*                                              *"
	echo -e "\t*----------------------------------------------*"
	echo -e "\t*                                              *"
	echo -e "\t*    ҽԺ����                                *"
	echo -e "\t*    6)�鿴ҽԺ�б�       7)�鿴ҽ���б�       *"
	echo -e "\t*    8)����ҽԺ           9)�޸�ҽԺ����       *"
	echo -e "\t*                                              *"
	echo -e "\t*----------------------------------------------*"
    echo -e "\t*                                              *"
	echo -e "\t*    Q)�˳�����                                *"
	echo -e "\t*                                              *"
	echo -e "\t************************************************"
        
    LINE1="������ѡ������ǰ������ݣ�" 
    get_answer   
    process_Menu	
}

function process_Menu()
{
	case $ANSWER in

	1)  #�û����--�û���¼��(login_name)
	    
		LINE1="������login_name��"
        get_answer
		_login_name=$ANSWER
		
		userAudit
		exit_handler
	;;
	
	2)  #�û����--ҽԺ����
		
		LINE1="������ҽԺ����(֧��ģ������)��"
        get_answer
		_hospital_name=$ANSWER
		
		statement="select * from doctor_info d where d.hospital_name like '%$_hospital_name%';"
        ERROR_INFO="δ�ܸ���ҽԺ�����ҵ��û���"
        doctor_check
		
		statement="select * from doctor_info d where d.hospital_name like '%$_hospital_name%';"
		userDisplay
		
		# Make Sure The User is Right
        LINE1="�ҵ�������ѯ��ҽԺ��ҽ��"
        LINE2="������ҽ����login_name��"
		get_answer
        _login_name=$ANSWER
		
        userAudit
	    exit_handler                          # the function Quit Script
	;;
	  
	3)  #�û����--ҽ������
	
        LINE1="������ҽ������(֧��ģ������)��"
        get_answer
		_doctor_name=$ANSWER
		
		statement="select * from doctor_info d where d.doctor_name like '%$_doctor_name%';"
        ERROR_INFO="δ�ܸ���ҽ�������ҵ��û���"
        doctor_check
		
		statement="select * from doctor_info d where d.doctor_name like '%$_doctor_name%';"
		userDisplay
		
		# Make Sure The User is Right
        LINE1="����������ѯ��ҽ���б�"
        LINE2="������ҽ����login_name��"
		get_answer
        _login_name=$ANSWER
		
        userAudit
	    exit_handler                          # the function Quit Script
	;;
	
	4)  #�û����--�ֻ���
        
		LINE1="�������ֻ���(֧��ģ������)��"
        get_answer
		_phone_number=$ANSWER
		
		statement="select * from doctor_info d where d.doctor_phone like '%$_phone_number%';"
        ERROR_INFO="δ�ܸ����ֻ����ҵ��û���"
        doctor_check
		
		statement="select * from doctor_info d where d.doctor_phone like '%$_phone_number%';"
		userDisplay
		
		# Make Sure The User is Right
        LINE1="����������ѯ��ҽ���б�"
        LINE2="������ҽ����login_name��"
		get_answer
        _login_name=$ANSWER
		
        userAudit
	    exit_handler                          # the function Quit Script
		;;

	5)  #�˺Ź���--��������
	
        LINE1="������login_name��"
        get_answer
		_login_name=$ANSWER
		
		statement="select * from doctor_info d where d.login_name ='$_login_name';"
		ERROR_INFO="δ�ܸ���login_name�ҵ�����û���"
		doctor_check
		
		statement="select * from doctor_info d where d.login_name='$_login_name';"
		userDisplay
		
		# Make Sure The User is Right
		LINE1="ȷ��������û���"
		LINE2="�Ƿ��������룿[y/n]��"
		get_answer

		EXIT_LINE1="��Ϊ�㲻ϣ��������û��������룡"
		EXIT_LINE2="����, �˳�����ű���"
		process_answer
		
		statement="update ysyf_login set login_password = '$default_password' where login_name='$_login_name';"
		resetConnOracle
        ;;

    6)  #ҽԺ����--�鿴ҽԺ�б�	
		statement="select h.hospital_no,h.hospital_name,h.sheetid,r.region_name,h.hospital_city,h.create_time   from ysyf_hospital_info h    left join region r on h.hospital_province = r.region_id   order by h.hospital_no;"
        hospitalDisplay
		
		echo -e "\t�б�����ʾ��ϣ�"
		getListMenu
    ;;
	
	7)  #ҽԺ����--�鿴ҽ���б�
		statement="select * from doctor_info;"
        userDisplay
		
		echo -e "\t�б�����ʾ��ϣ�"
		getListMenu
    ;;
	
	8)  #ҽԺ����--����ҽԺ
        echo
		echo -e "����ҽԺ����"
        echo -e "����ԱС������ڿ����У������ڴ���"
	    exit_handler                          # the function Quit Script
    ;;
	
	9)  #ҽԺ����--�޸�ҽԺ����
        LINE1="������ҽԺ����(֧��ģ������)��"
        get_answer
		_hospital_name=$ANSWER
		
		statement="select * from doctor_info d where d.hospital_name like '%$_hospital_name%';"
        ERROR_INFO="δ�ܸ���ҽԺ�����ҵ����ҽԺ��"
        doctor_check
		
		statement="select h.hospital_no,h.hospital_name,h.sheetid,r.region_name,h.hospital_city,h.create_time from ysyf_hospital_info h left join region r on h.hospital_province = r.region_id where h.hospital_name like '%$_hospital_name%' order by h.hospital_no;"
        hospitalDisplay
		
		if [ $hospital_num -gt 1 ]
		then
			echo
			echo -e "\tϵͳ����ҽԺ����--$_hospital_name--��⵽$hospital_num��ҽԺ, �޷����о�׼�޸ģ�"
			echo
			echo -e "\t����ʹ��ģ������, ��Ӱ���޸ĵľ�׼��, ������Ѿ������SheetId�����޸ģ�"
			
			LINE1="������SheetId��"
            get_answer
		    _hspSheetId=$ANSWER
			
			statement="select * from doctor_info d where d.hospital_sheetid = '$_hspSheetId';"
            ERROR_INFO="δ�ܸ���SheetId�ҵ�ҽԺ��"
            doctor_check
			
			#hospitalNameUpdate
			echo -e "\t�޸�ҽԺ�ɹ�!"
			
			exit_handler                      # the function Quit Script
			
		else
			#hospitalNameUpdate
			
			exit_handler                      # the function Quit Script
		fi
			
                        
    ;;
	
	Q)  
        echo
        echo -e "\t�����˳���"
	    exit_handler                          # the function Quit Script
    ;;

    *)
        echo
        echo -e "\t����ѡ�����"
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
        echo -e "\t�����˳���"
	    exit_handler                          # the function Quit Script
    ;;

    *)
        echo
        echo -e "\t����ѡ�����"
        getListMenu
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

echo
echo -e "\t********************************************"
echo -e "\t*                                          *"
echo -e "\t*            �����з�3.0������           *"
echo -e "\t*                                          *"
echo -e "\t********************************************"

getMenu



     
