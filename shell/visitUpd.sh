####################################################################################################
#
# Set Parameter
#
####################################################################################################
RunDate=`date +'%Y%m%d'`
upd_year=
upd_month=
upd_patient_no=
default_year=
default_month=
sql_format1=
sql_format2=
sql_format3=
sql_format4=
sql_format5=
sql_format6=
sql_format7=
ENVFILE="/etc/profile"
EXITCODE=0


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
  echo "Quit the Program!"
  echo
	exit $EXITCODE
	
} # End of exit_handler function

#
# get Patient_Archive_Num
#
input_patient_archive_num()
{
  echo
	if read -t 30 -p "请输入病历编号：" _patient_archive_num
	then
                # Judge the _patient_archive_num is not null
		if [ ! -z $_patient_archive_num ]
		then
		        pnoNum=$(expr length $_patient_archive_num)

                        # Judge the Legality
			if [ $pnoNum -eq 19 ]
			then
				upd_patient_no=$_patient_archive_num
			else

			  echo "对不起,病历编号长度不正确!请重新输入!"

                          # get Patient_Archive_Num Again
			  input_patient_archive_num
			fi
		else
			echo "对不起,病历编号不能为空!"

                        # get Patient_Archive_Num Again
                        input_patient_archive_num
		fi
	else
		echo "对不起,输入已超时!"
		exit_handler
	fi
	
} # End of input_patient_archive_num function


#
# get Year
#
input_year()
{
        echo
	if read -t 30 -p "请输入修改的年份[YYYY](默认为本年)：" _year
	then
		if [ -z $_year ]
		then
	              # is Null  
                      getUpdateYearForDefault
	              echo "修改年份为默认年份："$upd_year
		else
                      # is Not Null
                      yearNum=$(expr length $_year)

                      if [ $yearNum -eq 4 ]
                      then
                          upd_year=$_year
                          echo "修改年份为接收年份："$upd_year
                      else
                          echo "对不起,年份长度不正确!请重新输入!"
                          # get Year Again
                          input_year
                      fi
		fi
	else
		echo "对不起,输入已超时!"
		exit_handler
	fi
	
} # End of input_year function


#
# get Month
#
input_month()
{
        echo
	if read -t 30 -p "请输入修改的月份[MM](默认为上月)：" _month
	then
    	    if [ -z $_month ]
	    then
	    	# is Null
            	getUpdateMonthForDefault
	    	echo "修改月份为默认月份："$upd_month
	    else
	    	# is Not Null
            	monthNum=$(expr length $_month)

            	if [ $monthNum -eq 2 ]
            	then
	        	upd_month=$_month
	        	echo "修改月份为接收月份："$_month
            	else
               		echo "对不起,月份长度不正确!请重新输入!"
                	# get Month Again
                	input_month
                fi
	    fi
	else
        	echo "对不起,输入已超时!"
		exit_handler
	fi
	
} # End of input_month function


#
# Substr Default_Year And Default_Month
#
default_year_month()
{
        default_year=${upd_patient_no:8:4}
        default_month=${upd_patient_no:12:2}
        echo "复诊年份："$default_year
        echo "复诊月份："$default_month
        
} # End of default_year_month function


#
# get Update_Year From The Default_Year
#
getUpdateYearForDefault()
{
      # Judge the Month is January?
      if [ $default_month -eq 1 ]
        then
            upd_year=$[ $default_year - 1 ]
        else
            upd_year=$default_year
       fi
       
} # End of getUpdateYearForDefault function


#
# get Update_Month From The Default_Month
#
getUpdateMonthForDefault()
{
      # Judge the Month is January?
      if [ $default_month -eq 1 ]
        then
            upd_month=12
        else
            upd_month_f=$[ $default_month - 1 ]

            # Format the Month
            upd_month=$(printf '%02d' $upd_month_f)
      fi
      
} # End of getUpdateMonthForDefault function


#
# SQL Append And Display
# 
function sqlAppendAndDisplay()
{

	update_sql="update ysyf_visit_info v                                      \
	   set v.create_time = '$upd_year-$upd_month' ||                   \
	                       substr(v.create_time,8,12)                  \
       	     where v.patient_id in                                         \
	         (select p.sheetid                                         \
	          from ysyf_patient_info p                                 \
	          where p.patient_archive_num = '$upd_patient_no')          
        	  and v.create_time like '$default_year-$default_month%';"
        

        select_sql="select v.create_time from ysyf_visit_info v            \
                    where v.patient_id in                                  \
                    (select p.sheetid from ysyf_patient_info p             \
                    where p.patient_archive_num = '$upd_patient_no');"


	sql_format1="update ysyf_visit_info v"
	sql_format2="	 set v.create_time = '$upd_year-$upd_month' || substr(v.create_time,8,12)"
        sql_format3="where v.patient_id in"
        sql_format4="	 (select p.sheetid"
        sql_format5="	     from ysyf_patient_info p"
        sql_format6="	     where p.patient_archive_num = '$upd_patient_no')"
        sql_format7="            and v.create_time like '$default_year-$default_month%';"         

	echo
	echo "执行的SQL为($upd_year-$upd_month)："
        #echo "    "$select_sql
        #echo
        #echo "sql format为："
	echo "    "                           $sql_format1
	echo "       "                        $sql_format2
	echo "     "                          $sql_format3
	echo "           "                    $sql_format4
	echo "              "                 $sql_format5
	echo "             "                  $sql_format6
	echo "       "                        $sql_format7
	echo

} # End of sqlAppendAndDisplay function


function get_answer()
{

	unset ANSWER
	ASK_COUNT=0

	while [ -z "$ANSWER" ] # While no answer is given, keep asking.
	do 
		ASK_COUNT=$[ $ASK_COUNT + 1 ]
	  	case $ASK_COUNT in 
	  
	  	2) echo
	     	echo "请回答这个问题！"
	     	echo
	     	;;
	     
	  	3) echo
	     	echo "再次尝试！请回答这个问题！"
	     	echo
	     	;;
	     
	  	4) echo
	     	echo "因为你拒绝回答这个问题...."
	     	echo "程序退出！"
	     	echo
	     	exit_handler                     # the function Quit Script
	   	;;
	     
	  	esac
	  
	  	echo
	  
	  	if [ -n "$LINE2" ]
	  	then 
	  		echo $LINE1
	  		echo -e $LINE2" \c"
	  	else
	    		echo -e $LINE1" \c"
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
        echo "继续处理!"
	;;
	
	*)                                    # If user answer anything but "yes", exit script.
	echo
	echo $EXIT_LINE1
	echo $EXIT_LINE2
	echo
	exit_handler                          # the function Quit Script
	;;
	  
	esac
	
# Do a little variable clean-up 
unset EXIT_LINE1
unset EXIT_LINE2
	
} # End of process_answer function


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
echo "本脚本实现ysyf_visit_info病历复诊时间修改"

#
# get The Variable
#
input_patient_archive_num        # the function get Patiend_Archive_Num     
default_year_month               # the function Substr Default_Year And The Default_Month
input_year                       # the function get Year
input_month                      # the function get Month

#
# Display the SQL
#  
sqlAppendAndDisplay              # the function sqlAppendAndDisplay

#
# Make Sure The SQL is Right
#
LINE1="SQL语句正确吗？"
LINE2="确定是否执行它？[y/n]："
get_answer

EXIT_LINE1="因为你不希望执行这个SQL！"
EXIT_LINE2="所以, 退出这个脚本！"
process_answer

#
# Insert into The Database
#
sqlplus ysyf_admin/ysyf_admin << EOF
    set head off;
    $select_sql
    $update_sql
    commit;
    $select_sql
    exit
EOF

if [ $? -eq 0 ]
then
    echo
    echo "连接数据库成功！"
    echo
else
    echo
    echo "连接数据库失败！请检查错误！"
    echo
fi

#
# Quit The Script
#
exit_handler
