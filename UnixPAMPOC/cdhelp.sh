# help menu for YourApplication

while [ getout != yea ]
do
tput clear
tput smso
echo " Command line Help for YourApplication Press quit to exit help file"
tput rmso
tput cup 3 3; echo "1) Base Services"

tput cup 5 3; echo "2) YourApplication Web Services"

tput cup 7 3; echo "3) File Delivery"  

tput cup 9 3; echo "4) Afrd"

tput cup 11 3; echo "5) Bsi"

tput cup 13 3; echo "6) Actuate"

tput cup 15 3; echo "7) Web"  

tput cup 17 3; echo "8) Cdol App"
# right side of screen menu

tput cup 3 30; echo "9) Cdol WebBase"

tput cup 5 30; echo "10) Websphere"

tput cup 7 30; echo "11) Scheduler Engine"  

tput cup 9 30; echo "12) Balance Mq"

tput cup 11 30; echo "13) Cns-EbillingCdol"

tput cup 13 30; echo "14) HostPublisher" 

tput cup 17 30; echo "15) exit"






echo " Please Enter Command"

read answer
clear                                   
case $answer in
1)
/usr/X/bin/xedit  basesrv&
;;
2)
/usr/X/bin/xedit websrv& 
;;
3)
/usr/X/bin/xedit filedsrv& 
;;
4)
/usr/X/bin/xedit afrdsrv&
;;
5)
/usr/X/bin/xedit bsisrv&
;;
6)
/usr/X/bin/xedit actsrv&
;;
7)
/usr/X/bin/xedit Webapp&
;;
8)
/usr/X/bin/xedit cdolappsrv&
;;
9)
/usr/X/bin/xedit cdolwebsrv&
;;
10)
/usr/X/bin/xedit  websphersrv&
;;
11)
/usr/X/bin/xedit shedengsrv&
;;
12)
/usr/X/bin/xedit balmq&
;;
13)
/usr/X/bin/xedit cnssrv&
;;
14) 
/usr/X/bin/xedit hostpub&
;;
15) 
exit
;;
esac
done
exit
