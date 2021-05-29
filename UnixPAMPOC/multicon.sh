clear
echo "this script will login to  unix servers concurrently"

uname=$USER
while read uhost
do

echo connecting to $uhost
/usr/X/bin/xterm -T $uhost -e ssh $uhost -l $uname&

done
clear
exit