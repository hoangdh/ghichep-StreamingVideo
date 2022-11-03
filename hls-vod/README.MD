## Dockerfile for hls-vod-too

### Build:

```
docker build -t hls-vod-too:v1 .
```

### Run:

```
docker run -d --name hls-vod-too -p 4040:4040 -v /data/videos:/opt/videos hls-vod-too:v1
```

- `/data/videos`: Your directory video

Ref: https://github.com/kmxz/hls-vod-too
