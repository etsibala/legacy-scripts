#!/bin/ksh
# Script to gather NUS HP-UX server information/logs
# Author: Eugene Sibala
# Date    : Aug2008
# Use to show the process owner of a listening port
#
# Usage: ./SOLARIS_get_proc_port.txt 
#


line='---------------------------------------------'
#pids=$(/usr/bin/ps -ef -o pid=)
pids=$(ps -ef -o pid=)

if [ $# -eq 0 ]; then
read ans?"Enter port number: "
else
ans=$1
fi

for f in $pids
do
/usr/proc/bin/pfiles $f 2>/dev/null | /usr/xpg4/bin/grep -q "port: $ans"
if [ $? -eq 0 ]; then
echo $line
echo "Port: $ans is being used by PID:\c"
pargs -l $f
#/usr/bin/ps -o pid,args -p $f
fi
done
exit 0