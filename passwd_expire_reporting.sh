#! /bin/bash
# Descripton: This simple script will display output of system accounts and their password expiry details

# Find the epoch time since the user's password was last changed
epoch=`/bin/perl -e 'print int(time/(60*60*24))'`

if [ -f /etc/shadow ]; then
 cat /etc/shadow | while read usr_entry
 do
  usr_name=`echo $usr_entry | cut -d: -f1`
  current_epoch=`echo $usr_entry | grep "$usr_name:" | cut -d: -f3`
  [ -z "$current_epoch" ] && current_epoch=0

  # Compute the age of the user's password
  usr_pwdage=`echo $epoch - $current_epoch | /bin/bc`
  
  # Compute and display the number of days until password expiration
  max=`echo $usr_entry | grep "$usr_name:" | cut -d: -f5`
  [ -z "$max" ] && max=0
  expire=`echo $max - $usr_pwdage | /bin/bc`

  change=`echo $current_epoch + 1 | /bin/bc`
  last_change="`perl -e 'print scalar localtime('$change' * 24 *3600);'`"

  echo "ACCOUNT: $usr_name : LAST CHANGE: $last_change : EXPIRE: $expire"
 done
fi
