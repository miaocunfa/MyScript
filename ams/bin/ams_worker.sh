#!/bin/sh

# Set Runtime environment Parameter
export PATH=/usr/lib64/qt-3.3/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin
export ORACLE_BASE=/home/oracle/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/client_1
export PATH=$ORACLE_HOME/bin:$PATH


# Set Parameter
_curDate=$(date +'%Y%m%d')
_workDir=/home/wasup/ams
_pushDir=/data/ODS/FDM/INCR
_logFile=${_workDir}/ams.log
_OK_file=${_workDir}/data/success.ok



########################----Function declaration----####################################
function _exit_handler()
{
  echo "Quit the Program!"
  _write_log "log" "Quit the Program"

  exit $EXITCODE
}

function _write_log()
{
  echo "$(date "+%Y-%m-%d %H:%M:%S") [$1] $2" >> ${_logFile}
}

function _sqlldr_prefix()
{
_prefix=$1
_dataFile=${_workDir}/data/${_prefix}_${_RunDate}.dat
_dataFileXml=${_workDir}/data/${_prefix}_${_RunDate}.dat.xml
_ctlFile=${_workDir}/control/${_prefix}.clt
_sqlldr_log=${_workDir}/data/oldfile/${_RunDate}/${_prefix}.log
_sqlldr_bad=${_workDir}/data/oldfile/${_RunDate}/${_prefix}.bad
_sqlldr_ok=${_workDir}/data/oldfile/${_RunDate}/${_prefix}.ok
_sql_count=$(awk -F '[<>]' '/filerows/ {print $3}' ${_dataFileXml})
_sql_count_success=${_sql_count}" Rows successfully loaded."


_write_log "log" "Import table: ${_prefix}"
_write_log "log" "Import count: ${_sql_count}"

# OK File Check
if [ ! -f ${_sqlldr_ok} ];
then
  _write_log "log" "${_prefix}: ${_sqlldr_ok}: ok file not exists! "
else
  _write_log "log" "${_prefix}: ${_sqlldr_ok}: ok file exists! Importing STOP!"
  _write_log "log" "${_prefix}: skip current function!"
  rm -f ${_dataFile}
  rm -f ${_dataFileXml}
  return 0   # skip function
fi


# move file to ${_dataFileDir}
mv ${_dataFile} ${_dataFileDir}
mv ${_dataFileXml} ${_dataFileDir}
_dataFilePath=${_workDir}/data/oldfile/${_RunDate}/${_prefix}_${_RunDate}.dat
_dataFileXmlPath=${_workDir}/data/oldfile/${_RunDate}/${_prefix}_${_RunDate}.dat.xml


# SQLLDR execute
_write_log "log" "${_prefix} :SQLLDR execute begin"

_COUNT=1
  
while [ ${_COUNT} -lt 4 ] 
do
  _write_log "log" "${_prefix} :SQLLDR execute count ${_COUNT}!"
  
  _COUNT=$[ ${_COUNT} + 1 ]

# ORACLE truncate 
sqlplus ACCOUNTMS/ACCOUNTMS@40.16.2.20:1521/lzgzsc << EOF
truncate table ${_prefix};
commit;
exit;
EOF

  if [ $? -eq 0 ]
  then
    _write_log "log" "${_prefix}: TRUNCATE table success!"
  else
    _write_log "err" "${_prefix} :TRUNCATE table Fail!"
  fi

  
  # SQLLDR execute
  sqlldr ACCOUNTMS/ACCOUNTMS@40.16.2.20:1521/lzgzsc data=${_dataFilePath} control=${_ctlFile} log=${_sqlldr_log} bad=${_sqlldr_bad} direct=true

  # actual Import Count
  _sql_count_actual=$(cat ${_sqlldr_log} | grep "Rows successfully loaded.")
  _write_log "log" "${_prefix}: ${_sql_count_actual}"
   
  # Result check
  isOK=$(cat ${_sqlldr_log} | grep -e "${_sql_count_success}")

  if [ $? -eq 0 ] 
  then
        _write_log "log" "${_prefix}: Import data success!"
	touch ${_sqlldr_ok}
        _write_log "log" "${_prefix}: CREATE OK file: ${_sqlldr_ok}"

	rm -f ${_dataFilePath}
        rm -f ${_dataFileXmlPath}

    # if SQLLDR import data Success break The while loop
    break
  else
    _write_log "err" "${_prefix} :Import data Fail!"
   
    # if SQLLDR import data Fail
    # Sleep 120 second repeat execute
    sleep 120
  fi
  
done

} # End of the _sqlldr_prefix



########################----Main Script----####################################
_write_log "log" "ams_worker.sh execute"
_write_log "log" "Program Start"

# Get date
_binHome=${_workDir}/bin
_dataHome=${_workDir}/data
_RunDateFile=${_workDir}/bin/RunDate.txt
_RunDate=$(cat ${_RunDateFile})
_RunDateDir=${_pushDir}/${_RunDate}
_dataFileDir=${_workDir}/data/oldfile/${_RunDate}
_datafileFlag=
_dateFilePrefixList="F_PT_ENT_KCFB_CFDGDL
F_PT_ENT_KCFB_CFDGDZ
F_PT_ENT_KCFB_CFDGZJ
F_PT_ENT_KCFB_CFDGJC
F_PT_ORG_KBRP_JGCSHU
F_AG_DP_KDPA_KEHUZH
F_AG_DP_KDPA_ZHBCXX
F_AG_DP_KDPA_ZHXINX
F_PT_IND_KCFB_CFTYZJ
F_PT_IND_KCFB_CFTYJC
F_PT_IND_KCFB_CFTYDZ
F_PT_IND_KCFB_CFTYDL
F_CM_KTLP_GYCSHU
F_PT_ORG_KBRP_JGGXII"


# datafile RunDate Directory Check
while [ -z "${_datafileFlag}" ] # if Flag is null value, while loop Start
do
  _write_log "log" "datafile RunDate Directory Check"
  if [ ! -d ${_RunDateDir} ];
  then
    _write_log "log" "${_RunDateDir}: Directory Not Found!"
  
    sleep 10s     # Sleep 10 Second
    continue      # skip to execute while loop
  else
    _write_log "log" "${_RunDateDir}: Directory Check Success!"
	_datafileFlag=exists
  fi
done


# datafile RunDate File Check
# datafile.xml RunDate File Check
_datafileFlag=
while [ -z "${_datafileFlag}" ] # if Flag is null value, while loop Start
do
  _write_log "log" "datafile and datafile.xml RunDate File Check"
  for _datafilePrefix in ${_dateFilePrefixList}
  do
  
    #datafile
    _datafileName=${_datafilePrefix}_${_RunDate}.dat
	_datafilePathAndFile=${_RunDateDir}/${_datafileName}
	_write_log "log" "${_datafilePathAndFile}: datafile Check"
	if [ ! -f ${_datafilePathAndFile} ];
	then
	  _write_log "err" "${_datafilePathAndFile}: File Not Found!"

	  sleep 600s  # Sleep 600 Second
	  continue 2 # skip the for loop, execute while loop
	else
	  _write_log "log" "${_datafilePathAndFile}: File exists!"
	fi
		
	#datafile.xml
	_datafileXmlName=${_datafilePrefix}_${_RunDate}.dat.xml
	_datafileXmlPathAndFile=${_RunDateDir}/${_datafileXmlName}
	_write_log "log" "${_datafileXmlPathAndFile}: datafile.xml Check"
	if [ ! -f ${_datafileXmlPathAndFile} ];
	then
	  _write_log "err" "${_datafileXmlPathAndFile}: File Not Found!"

	  sleep 10s  # Sleep 10 Second
	  continue 2 # skip the for loop, execute while loop
	else
	  _write_log "log" "${_datafileXmlPathAndFile}: File exists!"
	fi
  done

  # Flag is not null, break the while loop
  _datafileFlag=ok
  
  cp ${_RunDateDir}/* ${_dataHome}
  _write_log "log" "Copy datafile RunDate File: ${_RunDateDir} to ${_dataHome}"
 
done

# Directory Check 
_write_log "log" "datafile oldfile Directory Check"
if [ ! -d ${_dataFileDir} ];
then
  mkdir -p ${_dataFileDir}
  
  _write_log "log" "MKDIR ${_dataFileDir}!"
else
  _write_log "log" "Directory Check Success!"
fi

# Function tuning. 
_sqlldr_prefix "F_PT_ENT_KCFB_CFDGDL"
_sqlldr_prefix "F_PT_ENT_KCFB_CFDGDZ"
_sqlldr_prefix "F_PT_ENT_KCFB_CFDGZJ"
_sqlldr_prefix "F_PT_ENT_KCFB_CFDGJC"
_sqlldr_prefix "F_PT_ORG_KBRP_JGCSHU"
_sqlldr_prefix "F_AG_DP_KDPA_KEHUZH"
_sqlldr_prefix "F_AG_DP_KDPA_ZHBCXX"
_sqlldr_prefix "F_AG_DP_KDPA_ZHXINX"
_sqlldr_prefix "F_PT_IND_KCFB_CFTYZJ"
_sqlldr_prefix "F_PT_IND_KCFB_CFTYJC"
_sqlldr_prefix "F_PT_IND_KCFB_CFTYDZ"
_sqlldr_prefix "F_PT_IND_KCFB_CFTYDL"
_sqlldr_prefix "F_CM_KTLP_GYCSHU"
_sqlldr_prefix "F_PT_ORG_KBRP_JGGXII"

# Update date
_RunDateNext=$(date -d "${_RunDate} 1 days" "+%Y%m%d")
>${_RunDateFile}
echo ${_RunDateNext} >> ${_RunDateFile}
_write_log "log" "RunDate UPDATE: ${_RunDateNext}"
 
_write_log "log" "End of Program"



