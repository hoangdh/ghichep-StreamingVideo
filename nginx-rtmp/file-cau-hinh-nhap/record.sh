_date=`date +"%Y-%m-%k%M"`
mkdir -p /tmp/vod/$1/$_date
echo $1
ffmpeg -re -i rtmp://localhost/live/$1 -map 0 -codec:v libx264 -codec:a copy  -flags -global_header -f ssegment -segment_list /tmp/vod/$1/$_date/index.m3u8 -segment_list_flags +live-cache -segment_time 2 /tmp/vod/$1/$_date/$1-%03d.ts;
