# Check if tmpadmin exist
id tmpadmin > /dev/null 2>&1
if [ "$?" -ne 0 ]; then
 useradd -m tmpadmin
 chage -M 99999 tmpadmin > /dev/null 2>&1
 out=`grep -v "^#" /etc/security/access.conf | grep tmpadmin 2> /dev/null`
 if [ -z "$out" ]; then
  echo “- : tmpadmin : ALL” >> /etc/security/access.conf
 fi
 usermod -e 1980-07-15 -c "NONE" -A unixgrp tmpadmin
fi
 
TMPADM_Year=`chage -l tmpadmin | grep "Account Expires" | awk '{print $5}' | sed 's/,//'`
TMPADM_Day=`chage -l tmpadmin | grep "Account Expires" | awk '{print $4}' | sed 's/,//'`
TMPADM_Mon=`chage -l tmpadmin | grep "Account Expires" | awk '{print $3}' | sed 's/,//'`
case "$TMPADM_Mon" in
Jan) TMPADM_MM=01;;
Feb) TMPADM_MM=02;;
Mar) TMPADM_MM=03;;
Apr) TMPADM_MM=04;;
May) TMPADM_MM=05;;
Jun) TMPADM_MM=06;;
Jul) TMPADM_MM=07;;
Aug) TMPADM_MM=08;;
Sep) TMPADM_MM=09;;
Oct) TMPADM_MM=10;;
Nov) TMPADM_MM=11;;
Dec) TMPADM_MM=12;;
esac
echo -n "Enter Ticket#: "
read req_input1
echo -n "Enter Year of Expiration (YYYY): "
read req_input2
x=0
while [ "$x" -eq 0 ]
do
 echo -n "Enter Day of Expiration (DD): "
 read req_input3
 if [ "$req_input3" -gt 0 -a "$req_input3" -lt 32 ]; then
  x=1
 else echo "Error: Invalid Input"
 fi 
done
x=0
while [ "$x" -eq 0 ]
do
 echo -n "Enter Month of Expiration (MM): "
 read req_input4
 if [ "$req_input4" -gt 0 -a "$req_input4" -lt 13 ]; then
  x=1
 else echo "Error: Invalid Input"
 fi
done
echo
CurDate=`echo "${TMPADM_Year}${TMPADM_MM}${TMPADM_Day}"`
NewDate=`echo "${req_input2}${req_input4}${req_input3}"`
if [ "$CurDate" -eq "$NewDate" -o "$CurDate" -gt "$NewDate" ]; then
 TicketInfo=`finger tmpadmin | grep "Name:" | awk '{print $4}'`
 echo "----------------------------------------"
 echo "Nothing to do... Account is active until ${TMPADM_Year}-${TMPADM_MM}-${TMPADM_Day}." 
 echo "Requested date of expiration is ${req_input2}-${req_input4}-${req_input3}"
 echo "Please check reference ticket: $TicketInfo for details"
 echo -n "Change anyway? (Y/N): "
 read input
 if [ "$input" == "Y" -o "$input" == "y" ]; then
  usermod -e "${req_input2}-${req_input4}-${req_input3}" -c "$req_input1" tmpadmin
  echo "----------------------------------------"
  echo "Account has been changed."
  echo "See below details:"
  finger tmpadmin | grep "^Login" | sed 's/Name:/Ticket:/'
  chage -l tmpadmin | grep "Account Expires"
 fi
fi
if [ "$CurDate" -lt "$NewDate" ]; then
 usermod -e "${req_input2}-${req_input4}-${req_input3}" -c "$req_input1" tmpadmin
 passwd tmpadmin
 echo "----------------------------------------"
 echo "Account has been changed."
 echo "See below details:"
 finger tmpadmin | grep "^Login" | sed 's/Name:/Ticket:/'
 chage -l tmpadmin | grep "Account Expires"
fi

