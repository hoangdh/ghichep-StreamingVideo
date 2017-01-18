#!/bin/bash
clear
# Mau chu
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
echo -e "${GREEN}Powered by MediTech JSC,.. & LongVan IDC\n${NC}Script tu dong chuyen doi cac file co cac dinh dang *.mp4, *.mkv, *.flv, *.webm, *.mov, *.avi thanh cac file .ts (Streaming).\n${RED}Luu y: Khi chuyen doi xong, file goc se bi xoa.${NC}\nBam [Enter] de tiep tuc...\nBam [CTRL] + [C] de huy bo."

# Tim DocumentRoot cua Webserver
if [ -e /etc/httpd/conf/httpd.conf ]; then
	DOC_ROOT=`grep -i 'DocumentRoot' /etc/httpd/conf/httpd.conf | sed '/^#/ d' | awk {'print $2'} | sed -r 's/"//g'`
	echo -e "${GREEN}Ban dang su dung Apache. ${NC}"
	if [ -z $DOC_ROOT ]; then
	  echo "Khong tim duoc thu muc DocumentRoot trong file cau hinh."
	  return DOC_ROOT=/opt/videos
	 fi
elif [ -e /etc/nginx/nginx.conf ]; then
	 DOC_ROOT=`grep -v '^$\|^\s*\#' /etc/nginx/conf.d/*.conf |grep root | awk '!a[$0]++'  |  cut -d' ' -f2-20 | tr ';' ' ' | xargs | awk '{print $2}'`
	 if [ -z $DOC_ROOT ]; then
	  echo "Khong tim duoc thu muc DocumentRoot trong file cau hinh."
	  DOC_ROOT=/opt/videos
	 fi
	 echo -e "${GREEN}Ban dang su dung NGINX. ${NC}"
else
	 echo -e "${RED}Ban chua cai Webserver. ${NC}"
	 DOC_ROOT=/opt/videos
fi

read -e -i $DOC_ROOT -p "Nhap dia chi DocumentRoot cua Webserver: " DOC_ROOT
read -e -i /opt/videos -p "Nhap thu muc video cua ban: " VIDEO
cd $VIDEO
# Doi ten file chua dau " " va dau cham (.)
for fname in *\.*; 
	do
		name="${fname%\.*}"
		extension="${fname#$name}"
   	    newname="${name//./_}"
		newfname="$newname""$extension"
		if [ "$fname" != "$newfname" ]; then
			mv "$fname" "$newfname"
		fi
done
for f in *\ *
	do 
		mv "$f" "${f// /_}"
	done

# Tao thu muc theo thang/nam
year=`date +%Y`
month=`date +%m`
cd $VIDEO
# Liet ke cac file video co trong thu muc hien tai
list=`ls $VIDEO | egrep '*.mp4|*.mkv|*.flv|*.webm|*.mov|*.avi'`
echo -e "Danh sach video co trong tu muc: \n" $list
if [ -z "$list" ]; then
	for x in {5..1}
		do
			clear
			echo -e "Powered by MediTech JSC,.. & LongVan IDC\n${RED}Khong co file trong thu muc, script se tu dong thoat sau $x.${NC}\n"
			sleep 1
		done
	clear
	exit
	else
		read -p 'Bam [Enter]...'
		date >> /opt/list-stream.txt
		for file in $list
		do
			eval $(ffprobe -v error -of flat=s=_ -select_streams v:0 -show_entries stream=height,width $file)
			size=${streams_stream_0_width}x${streams_stream_0_height}
			folder=`echo $file | tr '.' ' ' | awk {'print $1'}`
			REPO=$DOC_ROOT/upload/$year/$month/$folder
			mkdir -p $REPO
			ffmpeg -y -i $file -r 25 -g 25 -c:a libfdk_aac -b:a 128k -c:v libx264 -preset veryfast -s $size -c:a libfdk_aac -vbsf h264_mp4toannexb -flags -global_header -f ssegment -segment_list $REPO/index.m3u8 -segment_list_flags +live-cache -segment_time 5 $REPO/$file-%04d.ts
			ip=`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'`
			#rm -rf $file
			echo "http://$ip/upload/$year/$month/$folder/index.m3u8" >> /opt/list-stream.txt
			echo -e "${GREEN}Danh sach stream duoc luu tai:${NC} /opt/list-stream.txt"	
		done 
fi
