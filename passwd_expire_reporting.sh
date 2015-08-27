#! /bin/bash
# Descripton: This simple multi-platform script will display output of system accounts and their password expiry details

# Get current epoch time 
current_epoch=`perl -e 'print int(time/(60*60*24))'`

if [ -f /etc/shadow ]; then
 cat /etc/shadow | while read usr_entry
 do
  usr_name=`echo $usr_entry | cut -d: -f1`
  usr_epoch=`echo $usr_entry | grep "$usr_name:" | cut -d: -f3`
  [ -z "$usr_epoch" ] && usr_epoch=0

  # Compute the age of the user's password
  usr_pwdage=`echo $current_epoch - $usr_epoch | bc`
  
  # Compute and display the number of days until password expiration
  max=`echo $usr_entry | grep "$usr_name:" | cut -d: -f5`
  [ -z "$max" ] && max=0
  expire=`echo $max - $usr_pwdage | bc`

  last_change="`perl -e 'print scalar localtime('$usr_epoch' * 24 * 3600);' | sed 's/ ..:..:.. /, /' `"

  change_date=`echo $current_epoch + $expire | bc`
  next_change="`perl -e 'print scalar localtime('$change_date' * 24 * 3600);' | sed 's/ ..:..:.. /, /' `"
  
  echo "ACCOUNT: $usr_name : LAST CHANGE: $last_change : EXPIRE: $next_change"
 done
fi
