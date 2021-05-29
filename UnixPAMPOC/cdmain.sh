while [ getout != yea ]
do

clear
# main menu for citidirect
tput clear
tput smso
echo " Main Yourapplication SA Access Screen"
tput rmso
tput cup 10 25; echo "1) Access Servers"

tput cup 12 25; echo "2) Edit Server Lists"

tput cup 14 25; echo "3) exit" 

echo " Please Enter Command"

read answer                                   
case $answer in
1)
./servacc.sh
;;
2)
./editcd.sh
;;
3)
exit
;;
esac
done

