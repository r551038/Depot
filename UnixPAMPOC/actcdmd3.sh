clear
getanswer() {
enviro=""
action=""
_rpromtp=$1
echo  $_rpromtp
#printf $_rpromtp
read enviro
read action
export enviro
export action
return 0
}
       
while [ getout != yea ]
do

tput cup 3 30; echo # main menu for Services Access by Environment  
tput clear
tput smso
echo " Access for Services of YourApplication by Environment to exit type 15"
tput rmso
tput cup 3 3; echo "1) Base Services"

tput cup 5 3; echo "2) Web Services"

tput cup 7 3; echo "3) File Delivery"  

tput cup 9 3; echo "4) Afrd"

tput cup 11 3; echo "5) Bsi"

tput cup 13 3; echo "6) Actuate"

tput cup 15 3; echo "7) Webapp"  

tput cup 17 3; echo "8) Cdol App"
# right side of screen menu

tput cup 3 30; echo "9) Cdol WebBase"

tput cup 5 30; echo "10) Websphere"

tput cup 7 30; echo "11) Scheduler Engine"  

tput cup 9 30; echo "12) Balance Mq"

tput cup 11 30; echo "13) EbillingCdol"

tput cup 13 30; echo "14) HostPublisher" 

tput cup 17 30; echo "15) exit"
echo " Please Enter Type of Server"

read answer
clear
                                   
case $answer in
1)
getanswer "Please Enter Environment then enter Service Action" ;
type="basesrv" ; 
;;
2)
getanswer "Please Enter Environment then enter Service Action" ;
type="websrv" ;  
;;
3)
getanswer "Please Enter Environment then enter Service Action" ;
type="filedsrv"; 
;;
4)
getanswer "Please Enter Environment then enter Service Action" ;
type="afrdsrv" ;
;;
5)
getanswer "Please Enter Environment then enter Service Action" ;
type="bsisrv" ;
;;
6)
getanswer "Please Enter Environment then enter Service Action" ;
type="actsrv" ;
;;
7)
getanswer "Please Enter Environment then enter Service Action" ;
type="webapp" ;
;;
8)
getanswer "Please Enter Environment then enter Service Action" ;
type="cdolappsrv" ;
;;
9)
getanswer "Please Enter Environment then enter Service Action" ;
type="cdolwebsrv" ;
;;
10)
getanswer "Please Enter Environment then enter Service Action" ;
type="websphersrv"
;;
11)
getanswer "Please Enter Environment then enter Service Action" ;
type="shedengsrv" ;
;;
12)
getanswer "Please Enter Environment then enter Service Action" ;
type="balmq" ;
;;
13)
getanswer "Please Enter Environment then enter Service Action" ;
type="cnssrv" ;
;;
14)
getanswer "Please Enter Environment then enter Service Action" ;
type="hostpub" ;
;;
15) 
exit
;;
esac
date >> log/cdmenuaudit.log
echo "request by " $USER " of "$action" for "$type" on "$enviro >> log/cdmenuaudit.log
while  [ -f  cdque/testmsg.q ]
 do
   date >> log/cdmenuaudit.log ; 
  echo "waiting on prior request" >> log/cdmenuaudit.log ;
 echo "waiting on prior request"
  sleep 3
 clear
done 

echo $action $type $enviro > cdque/testmsg.q ;
date >> log/cdmenuaudit.log ; 
echo "request of "$action $type $enviro" submitied"  >> log/cdmenuaudit.log ;
done
exit

