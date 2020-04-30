#!/bin/bash

PRG="$0"

while [ -h "$PRG" ]; do
  ls=`ls -ld "$PRG"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '/.*' > /dev/null; then
    PRG="$link"
  else
    PRG=`dirname "$PRG"`/"$link"
  fi
done

# Get standard environment variables
PRGDIR=`dirname "$PRG"`
BASEPATH=$(cd $PRGDIR;pwd)
EXECUTABLE=catalina.sh

start() {
   sh $BASEPATH/$EXECUTABLE start
}

stop() {
   sh $BASEPATH/$EXECUTABLE stop
}

status() {
   sh $BASEPATH/$EXECUTABLE status
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    stop
    sleep 2
    start
    ;;
  status)
    status
    ;;
  *)
    echo "Usage: $0 {start|stop|status|restart}"
    exit 1
  ;;
esac
