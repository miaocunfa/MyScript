#!/bin/sh

# Set Parameter
_curDate=$(date +'%Y%m%d')
_workDir=/home/wasup/ams
_logFile=${_workDir}/ams.log
_RunDateFile=${_workDir}/bin/RunDate.txt
_RunDate=$(cat ${_RunDateFile})

function _write_log()
{
  echo "$(date "+%Y-%m-%d %H:%M:%S") [$1] $2" >> ${_logFile}
}

_write_log "log" "ams_master.sh execute"

#timeout 1m ${_workDir}/bin/ams_worker.sh
timeout 1430m ${_workDir}/bin/ams_worker.sh

if [ $? -eq 124 ]
then
    _write_log "err" "ams_worker.sh execute timeout!"
	
	# Update date
	_RunDateNext=$(date -d "${_RunDate} 1 days" "+%Y%m%d")
	>${_RunDateFile}
	echo ${_RunDateNext} >> ${_RunDateFile}
	_write_log "log" "RunDate UPDATE: ${_RunDateNext}"
	
else
    _write_log "log" "ams_worker.sh end of execute!"
fi

_write_log "log" "ams_master.sh end of execute!"
