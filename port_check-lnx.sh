
sourceFile="server.lst"
scanPort="21"
cat $sourceFile | awk '{print $2}' | while read hostIP
do

 hostIP=`echo $hostIP | sed 's/ //g' | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'`
 [ -z "$hostIP" ] && continue
 
 openPorts=""
 hostNAME=`dig -x $hostIP +short | sed 's/.$//'`
 pingOut=`ping -c 1 -q $hostIP 2> /dev/null`
 if [ "$?" -eq 0 ]; then
  for x in $scanPort
  do
    if [ -n "$x" ]; then 
 	scanOut=`echo "\q" | netcat -w 1 $hostIP $x`
     if [ "$?" -eq 0 ];  then
      openPorts="$openPorts $x"
 	 fi
    fi
   echo "HOST:$hostIP,$hostNAME,OPEN_PORT:$openPorts"
  done
 else
   echo "HOST:$hostIP,$hostNAME,ERROR:host_unreachable"
 fi
done