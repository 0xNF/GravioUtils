#!/bin/bash

STAMP=$(date +%Y%m%d)
TWAGO=$(date --date "14 days ago" +%Y%m%d)
LOGDIR="/var/log/graviohub/diag${STAMP}/"
TWAGODIR="/var/log/graviohub/diag${TWAGO}/"
TOPLOG="${LOGDIR}cpu.log"
NETLOG="${LOGDIR}net.log"
DOCKLOG="${LOGDIR}docker.log"

if [ ! -d $LOGDIR ]; then
	mkdir -p $LOGDIR
fi
top -b -n 1 -o %CPU | head -n 20 >> $TOPLOG
top -b -n 1 -o %MEM | head -n 20 >> $TOPLOG
date >> $NETLOG
netstat -i >> $NETLOG
date >> $DOCKLOG
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.RunningFor}}\t{{.Status}}" >> $DOCKLOG
if [ -d $TWAGODIR ]; then
	rm -rR $TWAGODIR
fi
