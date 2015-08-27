#!/usr/bin/sh
# Description: Script to gather HP-UX server information/logs
# Author: Eugene Sibala
# Date    : May2009
#
# Usage: ./hpux_admintool.txt < logchk | hpinfo > [ term | email ]
#

HPUX_ADMIN="root@localhost"


#Functions
draw_line()
{
  echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
}

hpinfo()
{

 if [ "$OUTFILE" = "" ]; then
  exit 1; echo "Output file error"
 fi

 # Send find header
 draw_line > $OUTFILE
 uname -a >> $OUTFILE
 date >> $OUTFILE
 
 if [ -f /usr/sbin/sysdef ]; then
   (echo; echo "### KERNEL INFORMATION") >> $OUTFILE
   echo '(Executed: /usr/sbin/sysdef)' >> $OUTFILE
   draw_line >> $OUTFILE
   /usr/sbin/sysdef >> $OUTFILE 2>&1
 else
   echo "KERNEL INFORMATION - SKIPPED"
 fi

 if [ -f /opt/ignite/bin/print_manifest ]; then
     (echo; echo "### HARDWARE and SOFTWARE INFORMATION") >> $OUTFILE
     echo '(Executed: /opt/ignite/bin/print_manifest)' >> $OUTFILE
     draw_line >> $OUTFILE
     /opt/ignite/bin/print_manifest >> $OUTFILE 2>&1
 else
   echo "HARDWARE and SOFTWARE INFORMATION - SKIPPED"
 fi

 if [ -f /usr/sbin/setboot ]; then
   (echo; echo "### SETBOOT INFORMATION") >> $OUTFILE
   echo '(Executed: /usr/sbin/setboot)' >> $OUTFILE
   draw_line >> $OUTFILE
   /usr/sbin/setboot >> $OUTFILE 2>&1
 else
   echo "SETBOOT INFORMATION - SKIPPED"
 fi

 if [ -f /etc/fstab ]; then
   (echo; echo "### FSTAB INFORMATION") >> $OUTFILE
   echo '(Executed: cat /etc/fstab)' >> $OUTFILE
   draw_line >> $OUTFILE
   cat /etc/fstab >> $OUTFILE 2>&1
 else
   echo "FSTAB INFORMATION - SKIPPED"
 fi

 if [ -f /usr/sbin/ioscan ]; then
   (echo; echo "### IOSCAN INFORMATION") >> $OUTFILE
   echo '(Executed: /usr/sbin/ioscan -fn)' >> $OUTFILE
   draw_line >> $OUTFILE
   /usr/sbin/ioscan -fn >> $OUTFILE 2>&1
 else
   echo "IOSCAN INFORMATION - SKIPPED"
 fi

 if [ -f /usr/sbin/vgdisplay ]; then
   (echo; echo "### LVM INFORMATION") >> $OUTFILE
   echo '(Executed: /usr/sbin/vgdisplay -v)' >> $OUTFILE
   draw_line >> $OUTFILE
   /usr/sbin/vgdisplay -v >> $OUTFILE 2>&1
 else
   echo "LVM INFORMATION - SKIPPED"
 fi

 if [ -f /usr/bin/strings ]; then
   (echo; echo "### LVMTAB INFORMATION") >> $OUTFILE
   echo '(Executed: /usr/bin/strings /etc/lvmtab)' >> $OUTFILE
   draw_line >> $OUTFILE
   /usr/bin/strings /etc/lvmtab >> $OUTFILE 2>&1
 else
   echo "LVMTAB INFORMATION - SKIPPED"
 fi 

 if [ -f /usr/bin/bdf ]; then
   (echo; echo "### BDF INFORMATION") >> $OUTFILE
   echo '(Executed: /usr/bin/bdf)' >> $OUTFILE
   draw_line >> $OUTFILE
   /usr/bin/bdf >> $OUTFILE 2>&1
 else
   echo "BDF INFORMATION - SKIPPED"
 fi

 if [ -f /usr/bin/crontab ]; then
   (echo; echo "### ROOT CRONTAB INFORMATION") >> $OUTFILE
   echo '(Executed: /usr/bin/crontab -l root)' >> $OUTFILE
   draw_line >> $OUTFILE
   /usr/bin/crontab -l root >> $OUTFILE 2>&1
 else
   echo "ROOT CRONTAB INFORMATION - SKIPPED"
 fi

 if [ -f /usr/sbin/lanscan ]; then
   (echo; echo "### NETWORK INFORMATION") >> $OUTFILE
   echo '(Executed: /usr/sbin/lanscan -v)' >> $OUTFILE
   draw_line >> $OUTFILE
   /usr/sbin/lanscan -v >> $OUTFILE 2>&1
 else
   echo "LANSCAN - SKIPPED"
 fi

 if [ -f /usr/bin/netstat ]; then
   echo '(Executed: /usr/bin/netstat -rn)' >> $OUTFILE
   /usr/bin/netstat -rn >> $OUTFILE 2>&1
 else
   echo "NETSTAT - SKIPPED"
 fi 

 if [ -f /usr/bin/ps ]; then
   (echo; echo "### PROC INFORMATION") >> $OUTFILE
   echo '(Executed: /usr/bin/ps -ef)' >> $OUTFILE
   draw_line >> $OUTFILE
   /usr/bin/ps -ef >> $OUTFILE 2>&1
 else
   echo "PROC INFORMATION - SKIPPED"
 fi

 echo "" >> $OUTFILE 
 echo '(Reading: /etc/rc.config.d/*)' >> $OUTFILE
 ls /etc/rc.config.d/* | while read conf
 do
  (echo; echo "### $conf:") >> $OUTFILE
  draw_line >> $OUTFILE
  awk '{sub(/^[ \t]+/, ""); print }' $conf | sed '/^#/d;/^$/d' >> $OUTFILE
 done

 if [ -f /etc/inetd.conf ]; then
  (echo; echo "### /etc/inetd.conf:") >> $OUTFILE
  echo '(Reading: /etc/inetd.conf)' >> $OUTFILE
  draw_line >> $OUTFILE
  awk '{sub(/^[ \t]+/, ""); print }' /etc/inetd.conf | sed '/^#/d;/^$/d' >> $OUTFILE  
 fi
}

logchk()
{

 if [ "$OUTFILE" = "" ]; then
  exit 1; echo "Output file error"
 fi

 grep -v sshd /var/adm/syslog/syslog.log | grep -i error | grep "`date +%b\ %e`" > /dev/null 2>&1
 if [ $? -eq 0 ] ; then
   (echo; echo "### SYSLOG ERROR ALERT") >> $OUTFILE 
   grep -v sshd /var/adm/syslog/syslog.log | grep -i error | grep "`date +%b\ %e`" >> $OUTFILE
 fi

 grep -v sshd /var/adm/syslog/syslog.log | grep -i fail | grep "`date +%b\ %e`" > /dev/null 2>&1  
 if [ $? -eq 0 ] ; then
   (echo; echo "### SYSLOG FAIL ALERT") >> $OUTFILE 
   grep -v sshd /var/adm/syslog/syslog.log | grep -i fail | grep "`date +%b\ %e`" >> $OUTFILE
 fi

 grep -v sshd /var/adm/syslog/syslog.log | grep EMS | grep "`date +%b\ %e`" > /dev/null 2>&1
 if [ $? -eq 0 ] ; then
   (echo; echo "### SYSLOG EMS ALERT") >> $OUTFILE 
   grep -v sshd /var/adm/syslog/syslog.log | grep EMS | grep "`date +%b\ %e`" >> $OUTFILE
 fi

 ioscan -fn | egrep 'NO_HW|UNCLAIM|UNKNOWN' > /dev/null 2>&1
 if [ $? -eq 0 ] ; then
   (echo; echo "### IOSCAN ALERT") >> $OUTFILE 
   ioscan -fn | egrep 'NO_HW|UNCLAIM|UNKNOWN' >> $OUTFILE
 fi

}

### BEGIN HERE:

case $1 in

  hpinfo)
      OUTFILE="/tmp/`uname -n`.info"
      hpinfo
      case $2 in
       term)
        if [ -f $OUTFILE ]; then
         cat $OUTFILE
        fi 
        ;;
      email)
       if [ -f $OUTFILE ]; then
        mailx -s "`hostname`: SERVER INFO" "$HPUX_ADMIN" < $OUTFILE
       fi
       ;;
      *)
       if [ -f $OUTFILE ]; then
        cat $OUTFILE
       fi 
       ;;
      esac
      ;;

  logchk)
      OUTFILE="/tmp/`uname -n`.logchk"
      logchk
      case $2 in
       term)
        if [ -f "$OUTFILE" -a -s "$OUTFILE" ] ; then
         cat $OUTFILE
        fi 
        ;;
      email)
       if [ -f "$OUTFILE" -a -s "$OUTFILE" ] ; then
        awk 'BEGIN {print "NOTE: See actual log for more details"} {print $0}'  $OUTFILE | mailx -s "`hostname`: LOG CHECK ALERT" $HPUX_ADMIN 
        > $OUTFILE
       fi
       ;;
      *)
       if [ -f $OUTFILE ]; then
        cat $OUTFILE
       fi 
       ;;
      esac
      ;;

 *)
     echo "Syntax: $0 <hpinfo|logchk> <term|email>"
     ;;

esac

