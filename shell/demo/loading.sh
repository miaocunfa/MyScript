b=">"
echo
for ((i=0;$i<=100;i+=2))
do
        printf "    Loading:[%-50s]%d%%\r" $b $i
        sleep 0.01 
        b="="$b
done
echo
echo
