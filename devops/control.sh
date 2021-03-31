#!/bin/bash
chown -R project /data/spb_project/
chgrp -R project /data/spb-project/
case $1 in
        start)
          sh /etc/init.d/test_10200.sh start
        ;;
        stop)  
          sh /etc/init.d/test_10200.sh stop
        ;;
        restart)
          sh /etc/init.d/test_10200.sh restart
        ;;
        status)
          sh /etc/init.d/test_10200.sh status
          exit $?  
        ;;
        *)
          echo "Usage: $0 {start|stop|restart|status}"
        ;;
esac    
exit 0
