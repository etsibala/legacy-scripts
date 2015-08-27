serverPlatform=`uname -a | awk '{print $1}'`
serverName=`uname -n`
awk -F: '{print $1}' /etc/passwd | grep -v kosrika | grep -v marun30 | grep -v wcao756 | grep -v jabelga | grep -v srgovin | grep -v msrunga | while read userLogin
do
	userHome=`grep ^$userLogin: /etc/passwd | awk -F: '{print $6}' | grep "/home"`
	[ -z "$userHome" ] && continue
	
	if [ "$serverPlatform" == "AIX" ]; then
	 userLock=`lsuser -a account_locked $userLogin | awk -F= '{print $2}' | grep false`
	 userLast=`lsuser -a time_last_login $userLogin | awk -F= '{print $2}'`
	 [ -n "$userLast" ] && userLast=`perl -le "print scalar(localtime($userLast))" | awk '{print $2,$3,$4,$5}'`
	elif [ "$serverPlatform" == "Linux" ]; then
	 userLock=`passwd -S $userLogin | grep -v LK`
	 userLast=`lastlog -u $userLogin | head -2| tail -1 | grep -v Never`
	 [ -n "$userLast" ] && userLast=`echo $userLast | awk '{print $4,$5,$6,$8}' `
	fi
	
	[ "$userLast" == "" ] && userLast="Never_LogIn"
	[ -n "$userLock" ] && userLock="Account_Active"	
	[ -z "$userLock" ] && userLock="Account_Locked"
	userGroup=`id -Gn $userLogin`
	
	echo "$serverName,$userLogin,$userLock,$userLast,$userGroup"
done