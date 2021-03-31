#!/bin/bash
#
#    .   ____          _            __ _ _
#   /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
#  ( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
#   \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
#    '  |____| .__|_| |_|_| |_\__, | / / / /
#   =========|_|==============|___/=/_/_/_/
#   :: Spring Boot Startup Script ::

### BEGIN INIT INFO
# Provides:          
# Required-Start:    $remote_fs $syslog $network
# Required-Stop:     $remote_fs $syslog $network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Spring Boot Application
# Description:       Spring Boot Application
# chkconfig:         2345 90 60
### END INIT INFO

SPB_APP_NAME=project-name
SPB_USER=project-name
SPB_GROUP=project-name
SPB_USER_HOME=/home/project-name
SPB_PID=/data/project-name/project-name_10200_pid
SPB_INIT_LOG_DIR=/data/project-name/10200/log/
SPB_INIT_LOG=/data/project-name/10200/log/spb_init.log
SPB_APP_LOG=/data/project-name/10200/log/spb_app.log
HeapDumpPath=/data/project-name/10200/dump/heap/
SPB_APP_DIR=/data/project-name/10200/deploy/
SPB_JAVA_IO_TMPDIR=/data/project-name/10200/tmp/
port1=10200
port2=11200
port3=12200

###
###JAVA_HOME="/usr/local/java/jdk1.8.0_05/"
JAVA_HOME=/usr/local/java/jdk1.8.0_05

JAVA_OPTS="-server \
-XX:+HeapDumpOnOutOfMemoryError \
-XX:HeapDumpPath=${HeapDumpPath} \
-Djava.io.tmpdir=${SPB_JAVA_IO_TMPDIR} \
-Dserver.port=10200 \
-Dcom.sun.management.jmxremote \
-Dcom.sun.management.jmxremote.port=11200 \
-Dcom.sun.management.jmxremote.rmi.port=12200 \
-Dcom.sun.management.jmxremote.authenticate=false \
-Dcom.sun.management.jmxremote.ssl=false \
-Dcom.sun.management.jmxremote.access.file=${JAVA_HOME}/jre/lib/management/jmxremote.access \
-Xmx2G -Xms2G \
-XX:+DisableExplicitGC \
-verbose:gc \
-Xloggc:${SPB_INIT_LOG_DIR}gc.%t.log \
-XX:+PrintHeapAtGC \
-XX:+PrintTenuringDistribution \
-XX:+PrintGCApplicationStoppedTime \
-XX:+PrintGCTaskTimeStamps \
-XX:+PrintGCDetails \
-XX:+PrintGCDateStamps \
-Dserver.connection-timeout=60000 \
-Dserver.tomcat.accept-count=1000 \
-Dserver.tomcat.max-threads=300 \
-Dserver.tomcat.min-spare-threads=65 \
-Dserver.tomcat.accesslog.enabled=true \
-Dserver.tomcat.accesslog.directory=${SPB_INIT_LOG_DIR} \
-Dserver.tomcat.accesslog.prefix=access_log \
-Dserver.tomcat.accesslog.suffix=.log \
-Dserver.tomcat.accesslog.rotate=true \
-Dserver.tomcat.accesslog.rename-on-rotate=true \
-Dserver.tomcat.accesslog.request-attributes-enabled=true \
-Dserver.tomcat.accesslog.buffered=true \
"

spb_chkport() {
     sleep 1
     chkport1=`/usr/sbin/ss -l -t -n | awk '{print $4}' | grep ":${port1}"`
     chkport2=`/usr/sbin/ss -l -t -n | awk '{print $4}' | grep ":${port2}"`
     chkport3=`/usr/sbin/ss -l -t -n | awk '{print $4}' | grep ":${port3}"`
     if [ -n "$chkport1" ]||[ -n "$chkport2" ]||[ -n "$chkport3" ];then
     echo  "[`date '+%Y-%m-%d %H:%M:%S'`]:[spb_chkport()]:${port1} ${port2} ${port3} has been used!" >> $SPB_INIT_LOG
     exit 1
     fi
}

spb_pid() {
     echo `ps -ef | grep $SPB_APP_NAME | grep $SPB_APP_DIR |grep jar | grep -v grep | tr -s " "|cut -d" " -f2`
     echo `ps -ef | grep $SPB_APP_NAME | grep $SPB_APP_DIR |grep jar | grep java | grep -v grep | tr -s " "|cut -d" " -f2` > ${SPB_PID}
}
 
start() {
  pid=$(spb_pid)
  if [ -n "$pid" ]
   then echo  "[`date '+%Y-%m-%d %H:%M:%S'`]:[start()]:$SPB_APP_NAME is already running (pid: $pid) " >> $SPB_INIT_LOG
  else
    echo  "[`date '+%Y-%m-%d %H:%M:%S'`]:[start()]:Starting $SPB_APP_NAME" >> $SPB_INIT_LOG
        if [ `user_exists $SPB_USER` = "1" ];then
            /usr/sbin/start-stop-daemon --start -c $SPB_USER --name spb_${SPB_USER}_$port1 --startas $JAVA_HOME/bin/java -- -jar $JAVA_OPTS $SPB_APP_DIR$SPB_APP_NAME.jar >> $SPB_APP_LOG 2>&1 &
            echo "[`date '+%Y-%m-%d %H:%M:%S'`]:[start()]: $JAVA_HOME/bin/java -jar $JAVA_OPTS $SPB_APP_DIR$SPB_APP_NAME.jar $SPB_USER " >> $SPB_INIT_LOG
        else
            echo -e "[`date '+%Y-%m-%d %H:%M:%S'`]:[start()]:user $SPB_USER does not exists. Starting with $(id)" >> $SPB_INIT_LOG
            exit 1
        fi
        status
  fi
  return 0
}
 
status(){
          pid=$(spb_pid)
          if [ -n "$pid" ]
            then echo -e "[`date '+%Y-%m-%d %H:%M:%S'`]:[status()]:$SPB_APP_NAME is already running (pid: $pid) " >> $SPB_INIT_LOG
          else
            echo -e "[`date '+%Y-%m-%d %H:%M:%S'`]:[status()]:$SPB_APP_NAME is not running" >> $SPB_INIT_LOG
            return 3
          fi
}

terminate() {
        echo -e "[`date '+%Y-%m-%d %H:%M:%S'`]:[terminate()]:Terminating $SPB_APP_NAME" >> $SPB_INIT_LOG
        kill -9 $(spb_pid)
}

stop() {
  pid=$(spb_pid)
  if [ -n "$pid" ]
  then
    echo -e "[`date '+%Y-%m-%d %H:%M:%S'`]:[stop()]:Waiting for $SPB_APP_NAME to stop" >> $SPB_INIT_LOG
    kill -9 $(spb_pid)
    NOT_KILLED=1
    for i in {1..2}; do
      pid=$(spb_pid)
      if [ -n "$pid" ]
      then
        kill -9 $(spb_pid)
        sleep 1
      else
        NOT_KILLED=0
        break 
      fi
    done
    if [ $NOT_KILLED = 1 ]
    then
      echo -e "[`date '+%Y-%m-%d %H:%M:%S'`]:[stop()]:Cannot kill $SPB_APP_NAME " >> $SPB_INIT_LOG
      exit 1
    fi
    echo -e "[`date '+%Y-%m-%d %H:%M:%S'`]:[stop()]:$SPB_APP_NAME was stopped"  >> $SPB_INIT_LOG
  else
    echo -e "[`date '+%Y-%m-%d %H:%M:%S'`]:[stop()]:$SPB_APP_NAME is not running"  >> $SPB_INIT_LOG
  fi
 
  return 0
}

user_exists(){
        if id -u $1 >/dev/null 2>&1; then
        echo "1"
        else
           echo "0"
        fi
}
 
case $1 in
        start)
          spb_chkport
          start
        ;;
        stop)  
          stop
        ;;
        restart)
          stop
          spb_chkport
          start
        ;;
        status)
          status
          exit $?  
        ;;
        kill)
          terminate
        ;;
        *)
          echo "Usage: $0 {start|stop|restart|status|debug}"
        ;;
esac    
exit 0
