#!/bin/bash
VIDSOURCE="$1"
RESOLUTION1="1280x720"
RESOLUTION2="720x480"
RESOLUTION3="480x360"

AUDIO_OPTS="-c:a libfdk_aac -b:a 128k -ac 2"

VIDEO_OPTS1="-s $RESOLUTION1 -c:v libx264 -vprofile baseline -preset medium -x264opts level=41"
VIDEO_OPTS2="-s $RESOLUTION2 -c:v libx264 -vprofile baseline -preset medium -x264opts level=41"
VIDEO_OPTS3="-s $RESOLUTION3 -c:v libx264 -vprofile baseline -preset medium -x264opts level=41"
OUTPUT_HLS="-start_number 0 -hls_time 10 -hls_list_size 0 -f hls"

ffmpeg -i "$VIDSOURCE" -y -threads 4 $AUDIO_OPTS $VIDEO_OPTS1 $OUTPUT_HLS stream_hi.m3u8 $AUDIO_OPTS $VIDEO_OPTS2 $OUTPUT_HLS stream_med.m3u8 $AUDIO_OPTS $VIDEO_OPTS3 $OUTPUT_HLS stream_low.m3u8


#Playlist
cat > index.m3u8 << 123
#EXTM3U
#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=500000, RESOLUTION=480x360
stream_low.m3u8
#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=700000, RESOLUTION=720x480
stream_med.m3u8
#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=900000, RESOLUTION=1280x720
stream_hi.m3u8
123