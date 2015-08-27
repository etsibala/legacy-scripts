
#!/usr/bin/sh
# Description: Script to gather SUSE server information/logs
# Author: etsibala
# Date    : May2015
#
# Usage: ./admintool-sles.sh < log | info > [ term | email ]
#

ADMIN_EMAIL="root@localhost"

uname -o | grep -qi 'linux'
if [ "$?" != 0 ]; then
 echo "Platform is not supported."; exit 1
fi

#Functions
draw_line()
{
  echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
}
header1 ()
{
 echo; echo "### $1 [pid:$$] "
}
header2 ()
{
 echo; echo " - $1 [pid:$$]"
}

info()
{
 if [ "$OUTFILE" = "" ]; then
  exit 1; echo "Output file error"
 fi
 # Send find header
 header1 "SERVER INFORMATION"
 draw_line > $OUTFILE
 uname -a >> $OUTFILE
 date >> $OUTFILE

 if [ -f /bin/rpm ]; then
   header1 "KERNEL INFORMATION" >> $OUTFILE
   echo '(Executed: rpm -qa | grep kernel)' >> $OUTFILE
   draw_line >> $OUTFILE
   rpm -qa | grep kernel >> $OUTFILE 2>&1
 else
   header1 "KERNEL INFORMATION - SKIPPED"
 fi

 echo "" >> $OUTFILE 
 confpath="/etc/"
 if [ -d "$confpath" ]; then
  find $confpath -type f -name "*release*" | while read conf
  do
	header2 "$conf:" >> $OUTFILE
	draw_line >> $OUTFILE
	awk '{sub(/^[ \t]+/, ""); print }' "$conf" | sed '/^#/d;/^$/d' >> $OUTFILE
  done
 else
   header1 "$confpath INFORMATION - SKIPPED"
 fi
 
 if [ -f /usr/sbin/dmidecode ]; then
    header1 "HARDWARE INFORMATION" >> $OUTFILE
    echo '(Executed: /usr/sbin/dmidecode)' >> $OUTFILE
    draw_line >> $OUTFILE
    /usr/sbin/dmidecode >> $OUTFILE 2>&1
	draw_line >> $OUTFILE
 else
   header1 "HARDWARE INFORMATION - SKIPPED"
 fi

 if [ -f /bin/rpm ]; then
    header1 "SOFTWARE INFORMATION" >> $OUTFILE
    echo '(Executed: /bin/rpm -qa)' >> $OUTFILE
    draw_line >> $OUTFILE
    /bin/rpm -qa >> $OUTFILE 2>&1
	draw_line >> $OUTFILE
    echo '(Executed: /sbin/chkconfig --list)' >> $OUTFILE
    draw_line >> $OUTFILE
    /sbin/chkconfig --list >> $OUTFILE 2>&1
	draw_line >> $OUTFILE

 else
   header1 "SOFTWARE INFORMATION - SKIPPED"
 fi
 
 if [ -f /boot/grub/menu.lst ]; then
   header1 "GRUB INFORMATION" >> $OUTFILE
   echo '(Executed: grep -v "^#" /boot/grub/menu.lst)' >> $OUTFILE
   draw_line >> $OUTFILE
   grep -v "^#" /boot/grub/menu.lst >> $OUTFILE 2>&1
 else
   header1 "GRUB INFORMATION - SKIPPED"
 fi

 if [ -f /etc/fstab ]; then
   header1 "FSTAB INFORMATION" >> $OUTFILE
   echo '(Executed: cat /etc/fstab)' >> $OUTFILE
   draw_line >> $OUTFILE
   cat /etc/fstab >> $OUTFILE 2>&1
 else
   header1 "FSTAB INFORMATION - SKIPPED"
 fi

 if [ -f /bin/mount ]; then
   header1 "MOUNT INFORMATION" >> $OUTFILE
   echo '(Executed: /bin/mount)' >> $OUTFILE
   draw_line >> $OUTFILE
   /bin/mount >> $OUTFILE 2>&1
 else
   header1 "MOUNT INFORMATION - SKIPPED"
 fi
 
 if [ -f /sbin/lspci ]; then
   header1 "LSPCI INFORMATION" >> $OUTFILE
   echo '(Executed: /sbin/lspci)' >> $OUTFILE
   draw_line >> $OUTFILE
   /sbin/lspci >> $OUTFILE 2>&1
 else
   header1 "LSPCI INFORMATION - SKIPPED"
 fi
 
 if [ -f /usr/bin/lsscsi ]; then
   header1 "LSSCSI INFORMATION" >> $OUTFILE
   echo '(Executed: /usr/bin/lsscsi)' >> $OUTFILE
   draw_line >> $OUTFILE
   /usr/bin/lsscsi >> $OUTFILE 2>&1
 else
   header1 "LSSCSI INFORMATION - SKIPPED"
 fi

 if [ -f /sbin/vgdisplay ]; then
   header1 "LVM INFORMATION" >> $OUTFILE
   echo '(Executed: /sbin/vgdisplay -v)' >> $OUTFILE
   draw_line >> $OUTFILE
   /sbin/vgdisplay -v >> $OUTFILE 2>&1
 else
   header1 "LVM INFORMATION - SKIPPED"
 fi

 if [ -f /bin/df ]; then
   header1 "DF INFORMATION" >> $OUTFILE
   echo '(Executed: /bin/df)' >> $OUTFILE
   draw_line >> $OUTFILE
   /bin/df >> $OUTFILE 2>&1
 else
   header1 "DF INFORMATION - SKIPPED"
 fi

 if [ -d /var/spool/cron/tabs ]; then
   header1 "CRONTAB INFORMATION" >> $OUTFILE
  ls /var/spool/cron/tabs/* | while read conf
  do
   header2 "$conf:" >> $OUTFILE
   draw_line >> $OUTFILE
   awk '{sub(/^[ \t]+/, ""); print }' "$conf" | sed '/^#/d;/^$/d' >> $OUTFILE
  done
 else
   header1 "CRONTAB INFORMATION - SKIPPED"
 fi

 if [ -f /bin/ip ]; then
   header1 "NETWORK INFORMATION" >> $OUTFILE
   echo '(Executed: /bin/ip addr)' >> $OUTFILE
   draw_line >> $OUTFILE
   /bin/ip addr >> $OUTFILE 2>&1
 else
   header1 "NETWORK INFORMATION - SKIPPED"
 fi

 if [ -f /bin/netstat ]; then
   echo '(Executed: /bin/netstat -rn)' >> $OUTFILE
   /bin/netstat -rn >> $OUTFILE 2>&1
 else
   header1 'NETSTAT (routing)- SKIPPED'
 fi 

  if [ -f /bin/netstat ]; then
   echo '(Executed: /bin/netstat -ln)' >> $OUTFILE
   /bin/netstat -an >> $OUTFILE 2>&1
 else
   header1 'NETSTAT (states) - SKIPPED'
 fi 
 
 if [ -f /bin/ps ]; then
   header1 "PROC INFORMATION" >> $OUTFILE
   echo '(Executed: /bin/ps -aux)' >> $OUTFILE
   draw_line >> $OUTFILE
   /bin/ps -aux >> $OUTFILE 2>&1
 else
   header1 "PROC INFORMATION - SKIPPED"
 fi

 echo "" >> $OUTFILE 
 confpath="/etc/lvm/"
 if [ -d "$confpath" ]; then
  header1 "$confpath*" >> $OUTFILE
  find $confpath -type f | while read conf
  do
	header2 "$conf:" >> $OUTFILE
	draw_line >> $OUTFILE
	awk '{sub(/^[ \t]+/, ""); print }' "$conf" | sed '/^#/d;/^$/d' >> $OUTFILE
  done
 else
   header1 "$confpath INFORMATION - SKIPPED"
 fi

 echo "" >> $OUTFILE 
 confpath="/etc/pam.d/"
 if [ -d "$confpath" ]; then
  header1 "$confpath*" >> $OUTFILE
  find $confpath -type f | while read conf
  do
	header2 "$conf:" >> $OUTFILE
	draw_line >> $OUTFILE
	awk '{sub(/^[ \t]+/, ""); print }' "$conf" | sed '/^#/d;/^$/d' >> $OUTFILE
  done
 else
   header1 "$confpath INFORMATION - SKIPPED"
 fi

 echo "" >> $OUTFILE 
 confpath="/etc/init.d/"
 if [ -d "$confpath" ]; then
  header1 "$confpath*" >> $OUTFILE
  find $confpath -type f | while read conf
  do
	header2 "$conf:" >> $OUTFILE
	draw_line >> $OUTFILE
	awk '{sub(/^[ \t]+/, ""); print }' "$conf" | sed '/^#/d;/^$/d' >> $OUTFILE
  done
 else
   header1 "$confpath INFORMATION - SKIPPED"
 fi

 echo "" >> $OUTFILE 
 confpath="/etc/sysconfig/"
 if [ -d "$confpath" ]; then
  header1 "$confpath*" >> $OUTFILE
  find $confpath -type f | while read conf
  do
	header2 "$conf:" >> $OUTFILE
	draw_line >> $OUTFILE
	awk '{sub(/^[ \t]+/, ""); print }' "$conf" | sed '/^#/d;/^$/d' >> $OUTFILE
  done
 else
   header1 "$confpath INFORMATION - SKIPPED"
 fi

 echo "" >> $OUTFILE 
 confpath="/etc/"
 if [ -d "$confpath" ]; then
  header1 "$confpath*" >> $OUTFILE
  find $confpath -maxdepth 1 -type f | while read conf
  do
	[[ "$conf" =~ /etc/shadow.* ]] && continue
	header2 "$conf:" >> $OUTFILE
	draw_line >> $OUTFILE
	awk '{sub(/^[ \t]+/, ""); print }' "$conf" | sed '/^#/d;/^$/d' >> $OUTFILE
  done
 else
   header1 "$confpath INFORMATION - SKIPPED"
 fi

 echo "" >> $OUTFILE 
 confpath="/etc/syslog-ng"
 if [ -d "$confpath" ]; then
  header1 "$confpath*" >> $OUTFILE
  find $confpath -type f | while read conf
  do
	header2 "$conf:" >> $OUTFILE
	draw_line >> $OUTFILE
	awk '{sub(/^[ \t]+/, ""); print }' $conf | sed '/^#/d;/^$/d' >> $OUTFILE
  done
 else
   header1 "$confpath INFORMATION - SKIPPED"
 fi
 
 if [ -f /etc/xinetd.conf ]; then
  header1 "/etc/xinetd.conf:" >> $OUTFILE
  header2 "/etc/xinetd.conf" >> $OUTFILE
  draw_line >> $OUTFILE
  awk '{sub(/^[ \t]+/, ""); print }' /etc/xinetd.conf | sed '/^#/d;/^$/d' >> $OUTFILE  
 fi

 header1 "SERVICE SPECIFIC" >> $OUTFILE  

 echo "" >> $OUTFILE 
 confpath="/etc/apache2/"
 if [ -d "$confpath" ]; then
  header1 "$confpath*" >> $OUTFILE
  find $confpath -type f | while read conf
  do
	header2 "$conf:" >> $OUTFILE
	draw_line >> $OUTFILE
	awk '{sub(/^[ \t]+/, ""); print }' "$conf" | sed '/^#/d;/^$/d' >> $OUTFILE
  done
 else
   header1 "$confpath INFORMATION - SKIPPED"
 fi 
 
 echo "" >> $OUTFILE
 confpath="/etc/samba/"
 if [ -d "$confpath" ]; then
  header1 "$confpath*" >> $OUTFILE
  find $confpath -type f | while read conf
  do
	header2 "$conf:" >> $OUTFILE
	draw_line >> $OUTFILE
	awk '{sub(/^[ \t]+/, ""); print }' "$conf" | sed '/^#/d;/^$/d' >> $OUTFILE
  done
 else
   header1 "$confpath INFORMATION - SKIPPED"
 fi 

 echo "" >> $OUTFILE
 confpath="/etc/ssh/"
 if [ -d "$confpath" ]; then
  header1 "$confpath*" >> $OUTFILE
  find $confpath -type f | while read conf
  do
	header2 "$conf:" >> $OUTFILE
	draw_line >> $OUTFILE
	awk '{sub(/^[ \t]+/, ""); print }' "$conf" | sed '/^#/d;/^$/d' >> $OUTFILE
  done
 else
   header1 "$confpath INFORMATION - SKIPPED"
 fi 
  
 echo "" >> $OUTFILE
 confpath="/etc/zypp/"
 if [ -d "$confpath" ]; then
  header1 "$confpath*" >> $OUTFILE
  find $confpath -type f | while read conf
  do
	header2 "$conf:" >> $OUTFILE
	draw_line >> $OUTFILE
	awk '{sub(/^[ \t]+/, ""); print }' "$conf" | sed '/^#/d;/^$/d' >> $OUTFILE
  done
 else
   header1 "$confpath INFORMATION - SKIPPED"
 fi 
 
}

log()
{
 if [ "$OUTFILE" = "" ]; then
  exit 1; echo "Output file error"
 fi
 conffile="/var/log/messages"
 for issue in error fail
 do
	if [ -f "$conffile" ]; then
		grep -v sshd "$conffile" | grep "`date +%b\ %e`" | grep -qi $issue 
		if [ "$?" -eq 0 ] ; then
		 header1 "SYSLOG $issue ALERT" >> $OUTFILE 
		 grep -v sshd "$conffile" | grep "`date +%b\ %e`" | grep -i $issue >> $OUTFILE
		fi
	fi
 done

 /bin/dmesg | egrep -qi 'error|fail' 
 if [ "$?" -eq 0 ] ; then
   header1 "DMESG ALERT" >> $OUTFILE 
   /bin/dmesg | egrep -i 'error|fail' >> $OUTFILE
 fi
}

### BEGIN HERE:
case $1 in
  info)
      OUTFILE="/tmp/`uname -n`.info"
	  if [ -f "$OUTFILE" ]; then
		echo "You need to manually remove old file: $OUTFILE"
	  fi
      info
      case $2 in
       term)
        if [ -f $OUTFILE ]; then
         cat $OUTFILE
		 rm  -f $OUTFILE
        fi 
        ;;
      email)
       if [ -f $OUTFILE ]; then
        mailx -s "`hostname`: SERVER INFO" "$ADMIN_EMAIL" < $OUTFILE
       fi
       ;;
      *)
       if [ -f $OUTFILE ]; then
        cat $OUTFILE
		rm  -f $OUTFILE
       fi 
       ;;
      esac
      ;;

  log)
      OUTFILE="/tmp/`uname -n`.logchk"
	  if [ -f "$OUTFILE" ]; then
		echo "You need to manually remove old file: $OUTFILE"
	  fi
      log
      case $2 in
       term)
        if [ -f "$OUTFILE" -a -s "$OUTFILE" ] ; then
         cat $OUTFILE
		 rm  -f $OUTFILE
        fi 
        ;;
       email)
        if [ -f "$OUTFILE" -a -s "$OUTFILE" ] ; then
         awk 'BEGIN {print "NOTE: See actual log for more details"} {print $0}'  $OUTFILE | mailx -s "`hostname`: LOG CHECK ALERT" $ADMIN_EMAIL 
         > $OUTFILE
		 rm  -f $OUTFILE
        fi
        ;;
		*)
         if [ -f $OUTFILE ]; then
          cat $OUTFILE
		  rm  -f $OUTFILE
         fi 
         ;;
      esac
      ;;

  *)
     echo "Syntax: $0 <info|log> <term|email>"
     ;;
esac


