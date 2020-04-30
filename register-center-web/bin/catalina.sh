#!/bin/bash
# test
#加载环境变量
. /etc/profile

JAVA_OPTS=" -Djava.awt.headless=true -Djava.net.preferIPv4Stack=true "

#是否开启DEBUG模式
#JAVA_DEBUG_OPTS=" -Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n "

#是否开启JMX监控功能
#JAVA_JMX_OPTS=" -Dcom.sun.management.jmxremote.port=1099 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false "

#JVM内存参数设定
JAVA_MEM_OPTS=""
#BITS= `java -version 2>&1 | grep -i 64-bit`
if [ -n "$BITS" ]; then
    JAVA_MEM_OPTS=" -server -Xmx1g -Xms1g -Xmn256m -XX:PermSize=256m -Xss256k -XX:+DisableExplicitGC -XX:+UseConcMarkSweepGC -XX:+CMSParallelRemarkEnabled -XX:LargePageSizeInBytes=128m -XX:+UseFastAccessorMethods -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=70 "
else
    JAVA_MEM_OPTS=" -server -Xms1g -Xmx1g -XX:PermSize=256m -XX:SurvivorRatio=2 -XX:+UseParallelGC "
fi


cd `dirname $0`
BIN_DIR=`pwd`
cd ..
DEPLOY_DIR=`pwd`
CONF_DIR=$DEPLOY_DIR/conf

. $BIN_DIR/setenv.sh

if [ -z "$SERVER_NAME" ]; then
    SERVER_NAME=`hostname`
fi

LOGS_DIR=""
if [ -n "$LOGS_FILE" ]; then
    LOGS_DIR=`dirname $LOGS_FILE`
else
    LOGS_DIR=$DEPLOY_DIR/log
fi
if [ ! -d $LOGS_DIR ]; then
    mkdir $LOGS_DIR
fi
STDOUT_FILE=$LOGS_DIR/stdout.log

LIB_DIR=$DEPLOY_DIR/lib
LIB_JARS=`ls $LIB_DIR|grep .jar|awk '{print "'$LIB_DIR'/"$0}'|tr "\n" ":"`

if [ -z "$PID_FILE" ] ; then
  PID_FILE=$DEPLOY_DIR/run.pid
fi

if [ "$1" = "start" ]; then
  if [ -s "$PID_FILE" ]; then
    PID=`cat "$PID_FILE"`
    ps -p $PID >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      echo "This service is running! The process number is $PID"
    else
      cd $DEPLOY_DIR
      java $JAVA_OPTS $JAVA_MEM_OPTS $JAVA_DEBUG_OPTS $JAVA_JMX_OPTS -classpath $CONF_DIR:$LIB_JARS $BOOTSTRAPAPI > $STDOUT_FILE 2>&1 &
      if [ ! -z "$PID_FILE" ]; then
        echo $! > $PID_FILE
      fi
    fi
  else
    cd $DEPLOY_DIR
    java $JAVA_OPTS $JAVA_MEM_OPTS $JAVA_DEBUG_OPTS $JAVA_JMX_OPTS -classpath $CONF_DIR:$LIB_JARS $BOOTSTRAPAPI > $STDOUT_FILE 2>&1 &
    if [ ! -z "$PID_FILE" ]; then
      echo $! > $PID_FILE
    fi
  fi

elif [ "$1" = "stop" ]; then
  ps -ef|awk '{print $2}'|grep `cat $PID_FILE` &>/dev/null
  if [ $? -eq 0 ]; then
    #kill -9 `cat $PID_FILE`
    kill `cat $PID_FILE`
  else
    echo "The `cat $PID_FILE` process is not found!"
  fi

elif [ "$1" = "status" ]; then
   if [ -s "$PID_FILE" ]; then
     PID=`cat "$PID_FILE"`
     ps -p $PID >/dev/null 2>&1
     if [ $? -eq 0 ]; then
       echo "This service is running! The process number is $PID"
     else
       echo "This service is not running!"
     fi
   fi
else
  echo "Usage: $0 {start|stop|status}"
  exit 1
fi

