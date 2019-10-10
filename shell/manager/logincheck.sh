####################################################################################################
#
# Set Parameter
#
####################################################################################################
RunDate=`date +'%Y%m%d'`
ENVFILE="/etc/profile"
EXITCODE=0
logFile=/home/ysyf/log/logincheck/uldr-login_name-$RunDate.log
userDatFile=/home/ysyf/log/logincheck/logincheck-$RunDate-uldr.dat
userDatFile_f=/home/ysyf/log/logincheck/logincheck-$RunDate-uldr_format.dat

doctorCheckLog=/home/ysyf/log/logincheck/doctorCheckLog.log
statement=


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
		ASK_COUNT=$[ $ASK_COUNT + 1 ]
		
	  	case $ASK_COUNT in 
	  	2)  echo
	     	#echo -e "\t请回答这个问题！"
                echo -e "\t��ش�������⣡"
	     	echo
	    ;;
	     
	  	3)  echo
	     	#echo -e "\t再次尝试！请回答这个问题！"
                echo -e "\t�ٴγ��ԣ���ش�������⣡"
	     	echo
	    ;;
	     
	  	4)  echo
	     	#echo -e "\t因为你拒绝回答这个问题...."
	     	#echo -e "\t程序退出！"
                echo -e "\t��Ϊ��ܾ��ش��������...."
	     	echo -e "\t�����˳���"
	     	echo
	     	exit_handler                     # the function Quit Script
	   	;;
	  	esac
	  
	  	echo
	  
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
	
	y|Y|YES|yes|Yes|yEs|yeS|YEs|yES)      # If user answer "yes", do nothing.
        echo
		#echo -e "\t继续处理!"
                echo -e "\t��������!"
		echo
	;;
	
	*)                                    # If user answer anything but "yes", exit script.
		echo
		echo -e "\t"$EXIT_LINE1
		echo -e "\t"$EXIT_LINE2
		echo
		exit_handler                          # the function Quit Script
	;;
	  
	esac
	
	# Do a little variable clean-up 
	unset EXIT_LINE1
	unset EXIT_LINE2
	
} # End of process_answer function

#
# get login_name
#
input_login_name()
{
    echo
	#echo -e "\t请输入login_name：\c"
        echo -e "\t������login_name��\c"
	
	if read -t 30 _login_name
	then
    	# Judge the login_name is not null
		if [ ! -z $_login_name ]
		then
      		# Judge the Legality
            #echo -e "\t接收login_name成功, 继续处理！" $_login_name
             echo -e "\t����login_name�ɹ�, ��������" $_login_name
		else
			#echo -e "\t对不起,login_name不能为空!"
                        echo -e "\t�Բ���,login_name����Ϊ��!"

            # get login_name Again
            input_login_name
		fi
	else
		#echo -e "\t对不起,输入已超时!"
                echo -e "\t�Բ���,�����ѳ�ʱ!"
		exit_handler
	fi
	
} # End of input_login_name function

function doctor_check()
{
	>$doctorCheckLog

sqlplus ysyf_admin/ysyf_admin << EOF > $doctorCheckLog
    set head off;
	$statement
EOF
	
	isExist=$(cat $doctorCheckLog | grep -e "no rows selected")
	
	if [ $? -eq 0 ]
	then
	    echo
		echo -e "\t"$ERROR_INFO
		echo
		exit_handler
	else
	    #echo -e "\t继续处理"
            echo -e "\t��������"
		#HospitalDisplay
		#exit_handler
	fi
	
	unset statement
}

function userDisplay()
{
	sqluldr2linux64.bin user=ysyf_admin/ysyf_admin query=$statement file=$userDatFile log=+$logFile
    
    awk 'BEGIN{FS=","; OFS="|"}{printf "%13s|%15s|%10s|%13s|%21s|%14s|%14s\n",$1,$2,$6,$11,$12,$13,$14}' $userDatFile > $userDatFile_f 
    cat $userDatFile_f
    echo
}

function userAudit()
{
	echo
        echo -e "\t�û����ͨ����"
}

function userReset()
{
	echo
        echo -e "\t��������ɹ���"
}

#
# get hospital_name
#
input_hospital_name()
{
    echo
	#echo -e "\t请输入医院名称：\c"
        echo -e "\t������ҽԺ���ƣ�\c"
	
	if read -t 30 _hospital_name
	then
    	# Judge the _hospital_name is not null
		if [ ! -z $_hospital_name ]
		then
      		# Judge the Legality
            #echo -e "\t接收医院名称成功, 继续处理！" $_hospital_name
                 echo -e "\t����ҽԺ���Ƴɹ�, ��������" $_hospital_name
		else
		#	echo -e "\t对不起,医院名称不能为空!"
                echo -e "\t�Բ���,ҽԺ���Ʋ���Ϊ��!"
            # get hospital_name Again
            input_hospital_name
		fi
	else
		#echo -e "\t对不起,输入已超时!"
               echo -e "\t�Բ���,�����ѳ�ʱ!"
		exit_handler
	fi
	
} # End of input_hospital_name function

#
# get doctor_name
#
input_doctor_name()
{
    echo
	#echo -e "\t请输入医生姓名：\c"
        echo -e "\t������ҽ��������\c"
	
	if read -t 30 _doctor_name
	then
    	# Judge the _doctor_name is not null
		if [ ! -z $_doctor_name ]
		then
      		# Judge the Legality
            #echo -e "\t接收医生姓名成功, 继续处理！" $_doctor_name
                echo -e "\t����ҽ�������ɹ�, ��������" $_doctor_name
		else
			#echo -e "\t对不起,医生姓名不能为空!"
                        echo -e "\t�Բ���,ҽ����������Ϊ��!"

            # get doctor_name Again
            input_doctor_name
		fi
	else
		#echo -e "\t对不起,输入已超时!"
                echo -e "\t�Բ���,�����ѳ�ʱ!"
		exit_handler
	fi
	
} # End of input_doctor_name function

function getMenu()
{
       echo
	echo "    ���������ѡ��ѡ��"
	echo -e "\t1)�û���¼��(login_name)"
	echo -e "\t2)ҽԺ����"
	echo -e "\t3)ҽ������"
    echo -e "\t4)��������"
    echo -e "\t5)�˳�����"
        
    LINE1="������ѡ������ǰ������֣�" 
    get_answer   
    process_Menu	
}

function process_Menu()
{
	case $ANSWER in

	1) 
        input_login_name     
		
		statement="select * from doctor_info d where d.login_name ='$_login_name';"
         ERROR_INFO="�û������ڣ�"
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

		userAudit
		
		exit_handler
	;;
	
	2)  
        input_hospital_name
		
		statement="select * from doctor_info d where d.hospital_name like '%$_hospital_name%';"
                ERROR_INFO="ҽԺ�����ڣ�"
        doctor_check
		
		statement="select * from doctor_info d where d.hospital_name like '%$_hospital_name%';"
		userDisplay
		
	    exit_handler                          # the function Quit Script
	;;
	  
	3)  
        input_doctor_name
		
		statement="select * from doctor_info d where d.doctor_name like '%$_doctor_name%';"
                ERROR_INFO="ҽ�������ڣ�"
        doctor_check
		userDisplay
		
		statement="select * from doctor_info d where d.doctor_name like '%$_doctor_name%';"
		userDisplay
		
	    exit_handler                          # the function Quit Script
	;;

	4)  
        input_login_name
		
        statement="select * from doctor_info d where d.login_name ='$_login_name';"
         ERROR_INFO="�û������ڣ�"
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
		
		userReset
		
		exit_handler
        ;;

	5)  
        echo
            echo -e "\t�����˳���"
	    echo
	    exit_handler                          # the function Quit Script
    ;;

    *)
        echo
        echo -e "\t����ѡ�����"
        getMenu
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
echo -e "\t############################################"
echo -e "\t#                                          #"
echo -e "\t#     ���ű�ʵ��ysyf_login����û����     #"
echo -e "\t#                                          #"
echo -e "\t############################################"
echo

getMenu



     
