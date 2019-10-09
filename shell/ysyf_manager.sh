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
            echo -e "\t请回答这个问题！"
	    ;;
	     
	  	3)  
            echo -e "\t再次尝试！请回答这个问题！"
	    ;;
	     
	  	4)  
            echo -e "\t因为你拒绝回答这个问题...."
	     	echo -e "\t程序退出！"
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
        echo -e "\t确认操作, 继续处理!"
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
        echo -e "\t$ANSWER, 系统检测成功, 继续处理！"
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
		echo -e "\t用户$_login_name, 已审核通过！"
		echo -e "\t谢谢使用！再见！"
		exit_handler
	else
	    echo
        echo -e "\t用户$_login_name, 审核失败！"
		echo -e "\t请使用本工具的用户查询, 检查用户$_login_name是否已通过审核!"
		echo -e "\t若用户的确未审核, 使用本工具又无法审核通过, 请联系系统管理员!"
		echo -e "\t谢谢使用！再见！"
		exit_handler
	fi
	
	unset statement
}

function userDisplay()
{
    >$userDatFile
	
	sqluldr2linux64.bin user=ysyf_admin/ysyf_admin query="$statement" file=$userDatFile log=+$uldr_hsplogFile
	
    sed -i '1iNO,医院名称,医院ID,hspSheetId,省份,省份ID,医生姓名,login_name,医生ID,医生编号,医生邀请码,phone,create_time,disable_time,审核状态,审核码' $userDatFile
	
	awk 'BEGIN{FS=","; OFS="|"}{n2=30-length($2); n7=12-length($7); printf "%-5s|%-"n2"s|%-"n7"s|%-12s|%-13s|%-21s|%-14s|%-6s\n",$1,$2,$7,$8,$12,$13,$14,$15}' $userDatFile > $userDatFile_f 
	
	#sqluldr2linux64.bin user=ysyf_admin/ysyf_admin query="select * from doctor_info where login_name = 'fagod';" file=/home/ysyf/log/logincheck/1 log=+/home/ysyf/log/logincheck/uldr_user_test.log	
	#awk 'BEGIN{FS=","; OFS="|"}{printf "%13s|%15s|%10s|%13s|%21s|%14s|%14s\n",$1,$2,$6,$11,$12,$13,$14}' /home/ysyf/log/logincheck/1 > 2
	#解决中文格式混乱问题
	#左对齐
	#awk 'BEGIN{FS=","; OFS="|"}{n2=30-length($2); n6=12-length($6); printf "%-13s|%-"n2"s|%-"n6"s|%-12s|%-13s|%-21s|%-14s|%-6s\n",$1,$2,$6,$7,$11,$12,$13,$14}' /home/ysyf/log/logincheck/1 > 2
	#右对齐
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
    ERROR_INFO="未能根据$_login_name找到这个用户！"
    doctor_check
		
    statement="select * from doctor_info d where d.login_name='$_login_name';"
    userDisplay

	# Make Sure The User is Right
    LINE1="确定是这个用户吗？"
    LINE2="是否通过审核？[y/n]："
    get_answer

    EXIT_LINE1="因为你不希望审核通过这个用户！"
    EXIT_LINE2="所以, 退出这个脚本！"
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
		echo -e "\t用户$_login_name, 密码重置成功！密码为123456"
		echo -e "\t谢谢使用！再见！"
		exit_handler
	else
	    echo
        echo -e "\t用户$_login_name, 密码重置失败！"
		echo -e "\t请联系系统管理员!"
		echo -e "\t谢谢使用！再见！"
		exit_handler
	fi
	
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
	
	#sqluldr2linux64.bin user=ysyf_admin/ysyf_admin query="select h.hospital_no,h.hospital_name,h.hospital_id,r.region_name,h.hospital_city,h.create_time   from ysyf_hospital_info h    left join region r on h.hospital_province = r.region_id   order by h.hospital_no;" file=/home/ysyf/log/logincheck/hsp log=+/home/ysyf/log/logincheck/uldrLog_hsp_test.log	
	#左对齐
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
	echo -e "\t*    用户审核：                                *"
	echo -e "\t*    1)用户登录名       2)医院名称             *"
	echo -e "\t*    3)医生姓名         4)手机号               *"
	echo -e "\t*                                              *"
	echo -e "\t*----------------------------------------------*"
	echo -e "\t*                                              *"
	echo -e "\t*    账号管理：                                *"
    echo -e "\t*    5)重置密码                                *"
	echo -e "\t*                                              *"
	echo -e "\t*----------------------------------------------*"
	echo -e "\t*                                              *"
	echo -e "\t*    医院管理：                                *"
	echo -e "\t*    6)查看医院列表       7)查看医生列表       *"
	echo -e "\t*    8)新增医院           9)修改医院名称       *"
	echo -e "\t*                                              *"
	echo -e "\t*----------------------------------------------*"
    echo -e "\t*                                              *"
	echo -e "\t*    Q)退出程序                                *"
	echo -e "\t*                                              *"
	echo -e "\t************************************************"
        
    LINE1="请输入选项括号前面的内容：" 
    get_answer   
    process_Menu	
}

function process_Menu()
{
	case $ANSWER in

	1)  #用户审核--用户登录名(login_name)
	    
		LINE1="请输入login_name："
        get_answer
		_login_name=$ANSWER
		
		userAudit
		exit_handler
	;;
	
	2)  #用户审核--医院名称
		
		LINE1="请输入医院名称(支持模糊查找)："
        get_answer
		_hospital_name=$ANSWER
		
		statement="select * from doctor_info d where d.hospital_name like '%$_hospital_name%';"
        ERROR_INFO="未能根据医院名称找到用户！"
        doctor_check
		
		statement="select * from doctor_info d where d.hospital_name like '%$_hospital_name%';"
		userDisplay
		
		# Make Sure The User is Right
        LINE1="找到您所查询的医院及医生"
        LINE2="请输入医生的login_name："
		get_answer
        _login_name=$ANSWER
		
        userAudit
	    exit_handler                          # the function Quit Script
	;;
	  
	3)  #用户审核--医生姓名
	
        LINE1="请输入医生姓名(支持模糊查找)："
        get_answer
		_doctor_name=$ANSWER
		
		statement="select * from doctor_info d where d.doctor_name like '%$_doctor_name%';"
        ERROR_INFO="未能根据医生姓名找到用户！"
        doctor_check
		
		statement="select * from doctor_info d where d.doctor_name like '%$_doctor_name%';"
		userDisplay
		
		# Make Sure The User is Right
        LINE1="根据您所查询的医生列表"
        LINE2="请输入医生的login_name："
		get_answer
        _login_name=$ANSWER
		
        userAudit
	    exit_handler                          # the function Quit Script
	;;
	
	4)  #用户审核--手机号
        
		LINE1="请输入手机号(支持模糊查找)："
        get_answer
		_phone_number=$ANSWER
		
		statement="select * from doctor_info d where d.doctor_phone like '%$_phone_number%';"
        ERROR_INFO="未能根据手机号找到用户！"
        doctor_check
		
		statement="select * from doctor_info d where d.doctor_phone like '%$_phone_number%';"
		userDisplay
		
		# Make Sure The User is Right
        LINE1="根据您所查询的医生列表"
        LINE2="请输入医生的login_name："
		get_answer
        _login_name=$ANSWER
		
        userAudit
	    exit_handler                          # the function Quit Script
		;;

	5)  #账号管理--重置密码
	
        LINE1="请输入login_name："
        get_answer
		_login_name=$ANSWER
		
		statement="select * from doctor_info d where d.login_name ='$_login_name';"
		ERROR_INFO="未能根据login_name找到这个用户！"
		doctor_check
		
		statement="select * from doctor_info d where d.login_name='$_login_name';"
		userDisplay
		
		# Make Sure The User is Right
		LINE1="确定是这个用户吗？"
		LINE2="是否重置密码？[y/n]："
		get_answer

		EXIT_LINE1="因为你不希望对这个用户重置密码！"
		EXIT_LINE2="所以, 退出这个脚本！"
		process_answer
		
		statement="update ysyf_login set login_password = '$default_password' where login_name='$_login_name';"
		resetConnOracle
        ;;

    6)  #医院管理--查看医院列表	
		statement="select h.hospital_no,h.hospital_name,h.sheetid,r.region_name,h.hospital_city,h.create_time   from ysyf_hospital_info h    left join region r on h.hospital_province = r.region_id   order by h.hospital_no;"
        hospitalDisplay
		
		echo -e "\t列表已显示完毕！"
		getListMenu
    ;;
	
	7)  #医院管理--查看医生列表
		statement="select * from doctor_info;"
        userDisplay
		
		echo -e "\t列表已显示完毕！"
		getListMenu
    ;;
	
	8)  #医院管理--新增医院
        echo
		echo -e "新增医院功能"
        echo -e "程序员小哥哥正在开发中！敬请期待！"
	    exit_handler                          # the function Quit Script
    ;;
	
	9)  #医院管理--修改医院名称
        LINE1="请输入医院名称(支持模糊查找)："
        get_answer
		_hospital_name=$ANSWER
		
		statement="select * from doctor_info d where d.hospital_name like '%$_hospital_name%';"
        ERROR_INFO="未能根据医院名称找到这个医院！"
        doctor_check
		
		statement="select h.hospital_no,h.hospital_name,h.sheetid,r.region_name,h.hospital_city,h.create_time from ysyf_hospital_info h left join region r on h.hospital_province = r.region_id where h.hospital_name like '%$_hospital_name%' order by h.hospital_no;"
        hospitalDisplay
		
		if [ $hospital_num -gt 1 ]
		then
			echo
			echo -e "\t系统根据医院名称--$_hospital_name--检测到$hospital_num家医院, 无法进行精准修改！"
			echo
			echo -e "\t由于使用模糊查找, 会影响修改的精准性, 请根据已经查出的SheetId进行修改！"
			
			LINE1="请输入SheetId："
            get_answer
		    _hspSheetId=$ANSWER
			
			statement="select * from doctor_info d where d.hospital_sheetid = '$_hspSheetId';"
            ERROR_INFO="未能根据SheetId找到医院！"
            doctor_check
			
			#hospitalNameUpdate
			echo -e "\t修改医院成功!"
			
			exit_handler                      # the function Quit Script
			
		else
			#hospitalNameUpdate
			
			exit_handler                      # the function Quit Script
		fi
			
                        
    ;;
	
	Q)  
        echo
        echo -e "\t程序退出！"
	    exit_handler                          # the function Quit Script
    ;;

    *)
        echo
        echo -e "\t输入选项错误！"
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
        echo -e "\t程序退出！"
	    exit_handler                          # the function Quit Script
    ;;

    *)
        echo
        echo -e "\t输入选项错误！"
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
echo -e "\t*            优膳有方3.0管理工具           *"
echo -e "\t*                                          *"
echo -e "\t********************************************"

getMenu



     
