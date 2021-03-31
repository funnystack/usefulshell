#!/bin/bash
#此脚本用于自动分割tomcat的日志catalina.out和gc.log
#每天00:00执行此脚本
LOG_PATH=/home/user/tomcat7.0.90/logs/
#获取昨天的日期
YESTERDAY=$(date -d "yesterday" +%Y-%m-%d)
#分割日志
cp ${LOG_PATH}catalina.out ${LOG_PATH}catalina.${YESTERDAY}.out
cp ${LOG_PATH}gc.log ${LOG_PATH}gc.${YESTERDAY}.log
#清空已有日志文件
echo ""> ${LOG_PATH}catalina.out
echo ""> ${LOG_PATH}gc.log
#删除15天前的日志
find ${LOG_PATH} -mtime +15 -name '*.*' -exec rm -rf {} \;