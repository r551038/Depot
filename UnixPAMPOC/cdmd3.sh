#!/bin/sh
# cdmd3.sh
# purpose Central control daemon for YourApplication unix services
# created by Ismael Rivera
# creation date March 2005
# notes
# daemon is controlled by cdinterface.sh switches start stop query
# input dependencies
# cdque directory necessary for reading file testmsg.q
# testmsg.q should have the following format action type of server and enviromment
# testmsg.q is created by actcdmd3.sh
# files.cdl
# files.cdl group servers by function and environment
# example uat11websphersrv.cdl should contain all websphere servers for UAT11
# output dependencies
# subdirectory log
# cdmdstatus.log contains pid of daemon
# demontimeaudit.log contains username of of testmsg.q
# and requests posted
# commanddebug3.log contains logs of the actual commands that would be issued
# variables
# action should contain start stop or query
# type should  contain function of server be it filedelivery or bsi etc etc
# cdcommand should contain the actual commandline except for action
# mhost contain actual servers to have action performed on depenedent on files.cdl
#
# variable inits 
action=""
enviro=""
type=""
mhost=""
# post of pid
echo "CD Services Control Daemon is up pid "$$ > log/cdmd3status.log
# endless loop
while [ getout != yea ]
do
trap "rm -f log/cdmd3status.log;exit 2" 1 2 3 14 15
if [ -r  cdque/testmsg.q ]
 then
     chmod a-w cdque/testmsg.q
     read action type enviro < cdque/testmsg.q
     date >> log/demontimeaudit.log
     ls -l cdque/testmsg.q | cut -c 15-22 >> log/demontimeaudit.log
     echo $action "of " $type "on" $enviro >> log/demontimeaudit.log 
     case $type in
          basesrv)
              cdcommand="/etc/init.d/bs "$action
          ;;
          websrv)
              cdcommand="/export/opt/sows/60sp6/https-YourApplication/ "$action
          ;;
          filedsrv)
              cdcommand="/etc/init.d/fd "$action
          ;;
          afrdsrv)
              cdcommand=" /etc/init.d/afrd "$action
          ;;
          bsisrv)
              cdcommand="/etc/init.d/bsi "$action
          ;;
          actsrv)
              cdcommand="/etc/init.d/actuate "$action
          ;;
          webapp)
              cdcommand="/export/opt/YourApplication/scripts/websphere/"$action"_WebService.ksh"
          ;;
          cdolappsrv)
              cdcommand="/export/opt/CDOL/scripts/websphere5/"$action"cdollive_9085.ksh"
          ;;
          cdolwebsrv)
              cdcommand="/etc/init.d/iplanet "$action
          ;;
          websphersrv)
              cdcommand="/etc/init.d/WebSphere.5 "$action
          ;;
          shedengsrv)
              cdcommand="/export/opt/YourApplication/scripts/websphere/"$action"_SchedulerEngine.ksh"
          ;;
          balmq)
              cdcommand="/export/opt/YourApplication/scripts/websphere/"$action"_BalanceMqService.ksh"
          ;;
          cnssrv)
              cdcommand="/etc/rc3.d/S997.appserver_soas65mp1"$action
          ;;
          hostpub)
              cdcommand="/export/opt/YourApplication/scripts/websphere/"$actions"HostPublisher.sh"
          ;;
                *)
                 echo " invalid service request test on " $enviro$type >> log/demontimeaudit.log;
;;
esac
cat $enviro$type.cdl | while read mhost 
do
echo "ssh " $mhost $cdcommand  >> log/commanddebug3.log;
done
clear

fi

if [ -r  cdque/testmsg.q ]
 then 
     chmod a+w cdque/testmsg.q  
     rm cdque/testmsg.q
fi
done
exit
