#!/bin/bash

ports=`netstat -npl | awk {'print $4'} | awk -F ':' {'print $2'} | sed '/^\s*$/d'`
port1=`awk 'BEGIN{srand();print int(rand()*(5500-2000))+2000 }'`
port2=$((port1+69))

#echo "Usage: sp-stream sop://<server>:3092/29393 <port-in> <port-play>"
#echo "Cac port dang duoc su dung: " $ports

read -p "Nhap link Sopcast: " link
read -p "Nhap ten Stream: " stream
if [ -n $link ]
then
  sp-sc $link $port1 $port2 > /dev/null &
  nohup ffmpeg -re -i "http://localhost:$port2" -c:v copy -c:a:0 libfdk_aac -b:a:0 480k -f flv rtmp://localhost/live/$stream &
fi

ip=`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'`
echo "Link: rtmp://$ip/live/$stream"

