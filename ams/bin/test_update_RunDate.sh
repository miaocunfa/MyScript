_RunDateFile=/home/wasup/ams/bin/RunDate.txt

echo "Update RunDate"
echo "Please input The New RunDate: "
read -t 30 ANSWER

>${_RunDateFile}
echo $ANSWER >> ${_RunDateFile}
