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
	     	#echo -e "\tè¯·å›ç­”è¿™ä¸ªé—®é¢˜ï¼"
                echo -e "\tÇë»Ø´ğÕâ¸öÎÊÌâ£¡"
	     	echo
	    ;;
	     
	  	3)  echo
	     	#echo -e "\tå†æ¬¡å°è¯•ï¼è¯·å›ç­”è¿™ä¸ªé—®é¢˜ï¼"
                echo -e "\tÔÙ´Î³¢ÊÔ£¡Çë»Ø´ğÕâ¸öÎÊÌâ£¡"
	     	echo
	    ;;
	     
	  	4)  echo
	     	#echo -e "\tå› ä¸ºä½ æ‹’ç»å›ç­”è¿™ä¸ªé—®é¢˜...."
	     	#echo -e "\tç¨‹åºé€€å‡ºï¼"
                echo -e "\tÒòÎªÄã¾Ü¾ø»Ø´ğÕâ¸öÎÊÌâ...."
	     	echo -e "\t³ÌĞòÍË³ö£¡"
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
		#echo -e "\tç»§ç»­å¤„ç†!"
                echo -e "\t¼ÌĞø´¦Àí!"
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
	#echo -e "\tè¯·è¾“å…¥login_nameï¼š\c"
        echo -e "\tÇëÊäÈëlogin_name£º\c"
	
	if read -t 30 _login_name
	then
    	# Judge the login_name is not null
		if [ ! -z $_login_name ]
		then
      		# Judge the Legality
            #echo -e "\tæ¥æ”¶login_nameæˆåŠŸ, ç»§ç»­å¤„ç†ï¼" $_login_name
             echo -e "\t½ÓÊÕlogin_name³É¹¦, ¼ÌĞø´¦Àí£¡" $_login_name
		else
			#echo -e "\tå¯¹ä¸èµ·,login_nameä¸èƒ½ä¸ºç©º!"
                        echo -e "\t¶Ô²»Æğ,login_name²»ÄÜÎª¿Õ!"

            # get login_name Again
            input_login_name
		fi
	else
		#echo -e "\tå¯¹ä¸èµ·,è¾“å…¥å·²è¶…æ—¶!"
                echo -e "\t¶Ô²»Æğ,ÊäÈëÒÑ³¬Ê±!"
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
	    #echo -e "\tç»§ç»­å¤„ç†"
            echo -e "\t¼ÌĞø´¦Àí"
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
        echo -e "\tÓÃ»§ÉóºËÍ¨¹ı£¡"
}

function userReset()
{
	echo
        echo -e "\tÖØÖÃÃÜÂë³É¹¦£¡"
}

#
# get hospital_name
#
input_hospital_name()
{
    echo
	#echo -e "\tè¯·è¾“å…¥åŒ»é™¢åç§°ï¼š\c"
        echo -e "\tÇëÊäÈëÒ½ÔºÃû³Æ£º\c"
	
	if read -t 30 _hospital_name
	then
    	# Judge the _hospital_name is not null
		if [ ! -z $_hospital_name ]
		then
      		# Judge the Legality
            #echo -e "\tæ¥æ”¶åŒ»é™¢åç§°æˆåŠŸ, ç»§ç»­å¤„ç†ï¼" $_hospital_name
                 echo -e "\t½ÓÊÕÒ½ÔºÃû³Æ³É¹¦, ¼ÌĞø´¦Àí£¡" $_hospital_name
		else
		#	echo -e "\tå¯¹ä¸èµ·,åŒ»é™¢åç§°ä¸èƒ½ä¸ºç©º!"
                echo -e "\t¶Ô²»Æğ,Ò½ÔºÃû³Æ²»ÄÜÎª¿Õ!"
            # get hospital_name Again
            input_hospital_name
		fi
	else
		#echo -e "\tå¯¹ä¸èµ·,è¾“å…¥å·²è¶…æ—¶!"
               echo -e "\t¶Ô²»Æğ,ÊäÈëÒÑ³¬Ê±!"
		exit_handler
	fi
	
} # End of input_hospital_name function

#
# get doctor_name
#
input_doctor_name()
{
    echo
	#echo -e "\tè¯·è¾“å…¥åŒ»ç”Ÿå§“åï¼š\c"
        echo -e "\tÇëÊäÈëÒ½ÉúĞÕÃû£º\c"
	
	if read -t 30 _doctor_name
	then
    	# Judge the _doctor_name is not null
		if [ ! -z $_doctor_name ]
		then
      		# Judge the Legality
            #echo -e "\tæ¥æ”¶åŒ»ç”Ÿå§“åæˆåŠŸ, ç»§ç»­å¤„ç†ï¼" $_doctor_name
                echo -e "\t½ÓÊÕÒ½ÉúĞÕÃû³É¹¦, ¼ÌĞø´¦Àí£¡" $_doctor_name
		else
			#echo -e "\tå¯¹ä¸èµ·,åŒ»ç”Ÿå§“åä¸èƒ½ä¸ºç©º!"
                        echo -e "\t¶Ô²»Æğ,Ò½ÉúĞÕÃû²»ÄÜÎª¿Õ!"

            # get doctor_name Again
            input_doctor_name
		fi
	else
		#echo -e "\tå¯¹ä¸èµ·,è¾“å…¥å·²è¶…æ—¶!"
                echo -e "\t¶Ô²»Æğ,ÊäÈëÒÑ³¬Ê±!"
		exit_handler
	fi
	
} # End of input_doctor_name function

function getMenu()
{
       echo
	echo "    Çë¸ù¾İÏÂÁĞÑ¡ÏîÑ¡Ôñ£¡"
	echo -e "\t1)ÓÃ»§µÇÂ¼Ãû(login_name)"
	echo -e "\t2)Ò½ÔºÃû³Æ"
	echo -e "\t3)Ò½ÉúĞÕÃû"
    echo -e "\t4)ÖØÖÃÃÜÂë"
    echo -e "\t5)ÍË³ö³ÌĞò"
        
    LINE1="ÇëÊäÈëÑ¡ÏîÀ¨ºÅÇ°ÃæµÄÊı×Ö£º" 
    get_answer   
    process_Menu	
}

function process_Menu()
{
	case $ANSWER in

	1) 
        input_login_name     
		
		statement="select * from doctor_info d where d.login_name ='$_login_name';"
         ERROR_INFO="ÓÃ»§²»´æÔÚ£¡"
        doctor_check
		
		statement="select * from doctor_info d where d.login_name='$_login_name';"
		userDisplay

	# Make Sure The User is Right
        LINE1="È·¶¨ÊÇÕâ¸öÓÃ»§Âğ£¿"
        LINE2="ÊÇ·ñÍ¨¹ıÉóºË£¿[y/n]£º"
        get_answer

        EXIT_LINE1="ÒòÎªÄã²»Ï£ÍûÉóºËÍ¨¹ıÕâ¸öÓÃ»§£¡"
        EXIT_LINE2="ËùÒÔ, ÍË³öÕâ¸ö½Å±¾£¡"
        process_answer	

		userAudit
		
		exit_handler
	;;
	
	2)  
        input_hospital_name
		
		statement="select * from doctor_info d where d.hospital_name like '%$_hospital_name%';"
                ERROR_INFO="Ò½Ôº²»´æÔÚ£¡"
        doctor_check
		
		statement="select * from doctor_info d where d.hospital_name like '%$_hospital_name%';"
		userDisplay
		
	    exit_handler                          # the function Quit Script
	;;
	  
	3)  
        input_doctor_name
		
		statement="select * from doctor_info d where d.doctor_name like '%$_doctor_name%';"
                ERROR_INFO="Ò½Éú²»´æÔÚ£¡"
        doctor_check
		userDisplay
		
		statement="select * from doctor_info d where d.doctor_name like '%$_doctor_name%';"
		userDisplay
		
	    exit_handler                          # the function Quit Script
	;;

	4)  
        input_login_name
		
        statement="select * from doctor_info d where d.login_name ='$_login_name';"
         ERROR_INFO="ÓÃ»§²»´æÔÚ£¡"
        doctor_check
		
		statement="select * from doctor_info d where d.login_name='$_login_name';"
		userDisplay
		
                # Make Sure The User is Right
        LINE1="È·¶¨ÊÇÕâ¸öÓÃ»§Âğ£¿"
        LINE2="ÊÇ·ñÖØÖÃÃÜÂë£¿[y/n]£º"
        get_answer

        EXIT_LINE1="ÒòÎªÄã²»Ï£Íû¶ÔÕâ¸öÓÃ»§ÖØÖÃÃÜÂë£¡"
        EXIT_LINE2="ËùÒÔ, ÍË³öÕâ¸ö½Å±¾£¡"
        process_answer
		
		userReset
		
		exit_handler
        ;;

	5)  
        echo
            echo -e "\t³ÌĞòÍË³ö£¡"
	    echo
	    exit_handler                          # the function Quit Script
    ;;

    *)
        echo
        echo -e "\tÊäÈëÑ¡Ïî´íÎó£¡"
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
echo -e "\t#     ±¾½Å±¾ÊµÏÖysyf_login±íµÄÓÃ»§ÉóºË     #"
echo -e "\t#                                          #"
echo -e "\t############################################"
echo

getMenu



     
