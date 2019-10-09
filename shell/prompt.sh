function prompt()
{
	unset prompt_info
	unset prompt_length
	
	prompt_info="系统检测成功, 继续处理！"
	
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
}

prompt
