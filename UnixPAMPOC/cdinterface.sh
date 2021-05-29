cddlog=/cdinterface/log
case $1 in
          start)
               if [ -f $cddlog/cdmd3status.log ] ; then
                    echo " daemon is already running PID is " ;
                    cat $cddlog/cdmd3status.log | cut -c 38-45 ; 
               else
                     exec  nohup /cdinterface/cdmd3.sh& 
      
                 fi;      
          ;;
          stop)
                if [ -f $cddlog/cdmd3status.log ] ; then
                   cat $cddlog/cdmd3status.log |cut -c 38-45;
                   echo " Will Terminate PID " ;    
                   cat $cddlog/cdmd3status.log |cut -c 38-45 |  xargs kill ;
                   
                else
                   echo " Daemon Already Stopped" ;
                fi; 
          ;;
          query) 
                if [ -f $cddlog/cdmd3status.log ] ; then 
                   cat $cddlog/cdmd3status.log ;
                 else
                    echo "Daemon is Not running" ;
                 fi;
          ;;
          *)
                echo "Invalid Option, Options are start, stop, query"
esac
exit     
