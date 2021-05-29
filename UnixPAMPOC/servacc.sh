clear
# main menu server access and services for YourApplication

while [ getout != yea ]
do
tput clear
tput smso
echo " Server and Services Access for YourApplication"
tput rmso
tput cup 14 35; echo "1) One Server"

tput cup 16 35; echo "2) many servers"

tput cup 18 35; echo "3) help" 

tput cup 20 35; echo "4) view last service query log"

tput cup 22 35; echo "5) Service commands by enviroment"

tput cup 24 35; echo "6) exit"

echo " Please Enter Command"

read answer                                   
case $answer in
1)
./oneserv.sh
;;
2)
./manyserv.sh
;;
3)
./cdhelp.sh
;;
4) /usr/X/bin/xedit status.log&
;;
5)
./actcdmd3.sh
;;
6) 
exit
;;
esac
clear
done
exit