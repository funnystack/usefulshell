#!/bin/bash
#此脚本用于自动分割Nginx的日志
#每天00:00执行此脚本 ,重命名前一天的日志，并重新打开日志文件
#Nginx日志文件所在目录
LOG_PATH=/usr/local/nginx/logs
#获取昨天的日期
YESTERDAY=$(date -d "yesterday" +%Y-%m-%d)
#获取pid文件路径
PID=/usr/local/nginx/nginx.pid
#分割日志
for name in `ls ${LOG_PATH}/*.log`;
do mv $name $name.${YESTERDAY}.bak;
done
#向Nginx主进程发送USR1信号，重新打开日志文件
kill -USR1 `cat ${PID}`
#删除7天前的日志
find ${LOG_PATH} -mtime +7 -name '*.log' -exec rm -rf {} \;