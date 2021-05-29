
while [ getout != yea ]
do

clear
tput cup 3 30; echo # main menu for  Multplie Server Access  
tput clear
tput smso
echo "Multi Access for YouApplication Enter Type then Enter Environment to exit type 15"
tput rmso
tput cup 3 3; echo "1) Base Services"

tput cup 5 3; echo "2) YouApplication Web Services"

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

tput cup 11 30; echo "13) Cns-EbillingCdol"

tput cup 13 30; echo "14) HostPublisher" 

tput cup 17 30; echo "15) exit"
echo " Please Enter Type of Server"

read answer
clear
                                   
case $answer in
1)
echo "Please Enter Environment"
 read enviro ;

./multicon.sh < $enviro"basesrv".cdl&
;;
2)
echo "Please Enter Environment"
read enviro ;
./multicon.sh < $enviro"websrv".cdl& 
;;
3)
echo "Please Enter Environment"
read enviro ;
./multicon.sh < $enviro"filedsrv".cdl& 
;;
4)
echo "Please Enter Environment"
read enviro ;
./multicon.sh < $enviro"afrdsrv".cdl&
;;
5)
echo "Please Enter Environment"
read enviro ;
./multicon.sh < $enviro"bsisrv".cdl&
;;
6)
echo "Please Enter Environment"
read enviro ;
./multicon.sh < $enviro"actsrv".cdl&
;;
7)
echo "Please Enter Environment"
read enviro ;
./multicon.sh < $enviro"webapp".cdl&
;;
8)
echo "Please Enter Environment"
read enviro ;
./multicon.sh < $enviro"cdolappsrv".cdl&
;;
9)
echo "Please Enter Environment"
read enviro ;
./multicon.sh < $enviro"cdolwebsrv".cdl&
;;
10)
echo "Please Enter Environment"
read enviro ;
./multicon.sh <  $enviro"websphersrv".cdl&
;;
11)
echo "Please Enter Environment"
read enviro ;
./multicon.sh < $enviro"shedengsrv".cdl&
;;
12)
echo "Please Enter Environment"
read enviro ;
./multicon.sh < $enviro"balmq".cdl&
;;
13)
echo "Please Enter Environment"
read enviro ;
./multicon.sh < $enviro"cnssrv".cdl&
;;
14) 
echo "Please Enter Environment"
read enviro ;
./multicon.sh < $enviro"hostpub".cdl&
;;
15) 
exit
;;
esac
done
exit