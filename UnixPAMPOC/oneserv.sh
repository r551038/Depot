clear
echo Please Enter ServerName
read uhost
echo connecting to $uhost
/usr/X/bin/xterm -e  ssh $uhost -l $USER& 
exit
