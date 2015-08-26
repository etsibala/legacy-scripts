
# Please run once with ksh
# Gathers Solaris SVM information before OS patching

dated=`date +%d%m%Y-%X`
echo $dated > `hostname`-patchprep-$dated.info
uname -a >> `hostname`-patchprep-$dated.info

## Gathers disk settings
echo "---------------------------------------------------------" >> `hostname`-patchprep-$dated.info
df -k >> `hostname`-patchprep-$dated.info

echo "---------------------------------------------------------" >> `hostname`-patchprep-$dated.info
metastat >> `hostname`-patchprep-$dated.info

echo "---------------------------------------------------------" >> `hostname`-patchprep-$dated.info
cat /etc/vfstab >> `hostname`-patchprep-$dated.info

echo "---------------------------------------------------------" >> `hostname`-patchprep-$dated.info
metastat -p >> `hostname`-patchprep-$dated.info

echo "---------------------------------------------------------" >> `hostname`-patchprep-$dated.info
echo | format >> `hostname`-patchprep-$dated.info

## Gathers boot settings
echo "---------------------------------------------------------" >> `hostname`-patchprep-$dated.info
prtconf -vp | grep path >> `hostname`-patchprep-$dated.info

echo "---------------------------------------------------------" >> `hostname`-patchprep-$dated.info
eeprom >> `hostname`-patchprep-$dated.info

echo "---------------------------------------------------------" >> `hostname`-patchprep-$dated.info
(echo; echo "### /etc/system:") >> `hostname`-patchprep-$dated.info
nawk '{sub(/^[ \t]+/, ""); print }' /etc/system | sed '/^*/d;/^$/d' >> `hostname`-patchprep-$dated.info
echo  "--- EOF ---"  >> `hostname`-patchprep-$dated.info

if [ -d /etc/lvm ]; then
 ls /etc/lvm/* | while read conf
 do
  (echo; echo "### $conf:") >> `hostname`-patchprep-$dated.info
  nawk '{sub(/^[ \t]+/, ""); print }' $conf | sed '/^#/d;/^$/d' >> `hostname`-patchprep-$dated.info
  echo  "--- EOF ---"  >> `hostname`-patchprep-$dated.info
 done
fi



cat "`hostname`-patchprep-$dated.info"

## Use this to scp the file
#scp "./`hostname`-patchprep-$dated.info" admes@nusbs02:
#rm "`hostname`-patchprep-$dated.info"
