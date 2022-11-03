FROM node:16.3-alpine3.12

RUN apk update && apk add ffmpeg --no-cache && \
    npm install -g npm@latest && \
    npm install -g hls-vod-too && \
    npm cache clean --force && \
    rm -rf /tmp/* 

EXPOSE 4040

CMD hls-vod-too --debug --root-path /opt/videos
