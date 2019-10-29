b=">"
echo
for ((i=0;$i<=100;i+=4))
do
        printf "\tPleaseWait:[%-25s]%d%%\r" $b $i
        sleep 3 
        b="="$b
done
echo
echo
