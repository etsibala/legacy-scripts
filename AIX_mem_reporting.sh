### Reformats svmon :-p

svmon -P -v  |  awk '{
  if ( $0 ~ /Pid\ Command/ ) {
    stat=1;
  }
  if ( $0 !~ /PageSize/ && stat == 1) {
    print $0
  }
  if ( $0 ~ /PageSize/ && stat == 1) {
    stat=0;
  }
   
 }' | grep -v Pid | sed '/^$/d'
 

