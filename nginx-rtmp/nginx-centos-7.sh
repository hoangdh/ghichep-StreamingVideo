yum -y install gcc gcc-c++ make zlib-devel pcre-devel openssl-devel git wget
mkdir /opt/source/
cd /opt/source/
wget http://nginx.org/download/nginx-1.10.2.tar.gz
tar -xzf nginx-1.10.2.tar.gz
git clone https://github.com/arut/nginx-rtmp-module.git
cd /opt/source/nginx-1.10.2
./configure --user=nginx --group=nginx --add-module=../nginx-rtmp-module/ --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --with-http_ssl_module --with-http_realip_module --with-http_addition_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_stub_status_module --with-mail --with-mail_ssl_module --with-file-aio --with-ipv6

make
make install
useradd -r nginx
mkdir -p /var/cache/nginx/client_temp/
chown nginx. /var/cache/nginx/client_temp/

cat > /lib/systemd/system/nginx.service << H2
[Unit]
Description=The NGINX HTTP and reverse proxy server
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx
ExecReload=/bin/kill -s HUP \$MAINPID
ExecStop=/bin/kill -s QUIT \$MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target
H2

chmod a+rx /lib/systemd/system/nginx.service
systemctl enable nginx
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bk
mkdir -p /mnt/stream/hls/
mkdir -p /mnt/stream/vod/

cat > /etc/nginx/nginx.conf  << H2
user nginx;
worker_processes  auto;

events {
    worker_connections  1024;
}

# pid       /var/run/nginx.pid;

# RTMP configuration
rtmp {
    
    server {
        listen 1935; # Listen on standard RTMP port
        chunk_size 4096;
        max_connections 2000;
        application live {
            live on;            
            # Turn on HLS
            hls on;
            hls_path /mnt/stream/hls/;
            hls_fragment 2s;
            hls_playlist_length 60;
            hls_nested on;
            # disable consuming the stream from nginx as rtmp
            # deny play all;
            
        }
        # # Record
        # record all;
        # record_path /mnt/stream/vod/;
        # record_suffix  -%d-%b-%y-%T.flv;
        
        
    }
}

http {
    sendfile off;
    tcp_nopush on;
    aio on;
    directio 512;
    default_type application/octet-stream;

    server {
        listen 80;
        access_log /var/log/nginx/access_log combined;
        location / {
            # Disable cache
            add_header 'Cache-Control' 'no-cache';

            # CORS setup
            add_header 'Access-Control-Allow-Origin' '*' always;
            add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range';
            add_header 'Access-Control-Allow-Headers' 'Range';

            # allow CORS preflight requests
            if (\$request_method = 'OPTIONS') {
                add_header 'Access-Control-Allow-Origin' '*';
                add_header 'Access-Control-Allow-Headers' 'Range';
                add_header 'Access-Control-Max-Age' 1728000;
                add_header 'Content-Type' 'text/plain charset=UTF-8';
                add_header 'Content-Length' 0;
                return 204;
            }

            types {
                application/dash+xml mpd;
                application/vnd.apple.mpegurl m3u8;
                video/mp2t ts;
            }

            root /mnt/stream/;
        }
        location /stat {
            rtmp_stat all;
            rtmp_stat_stylesheet stat.xsl;
        }
        location /stat.xsl {
            root /mnt/stream/stat.xsl;
        }
    }
}
H2

ip=`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'`
systemctl start nginx

echo -e "Thuc hien nhu sau:
- Push RTMP: rtmp://$ip/live/<KEY>
- Play HLS: http://$ip/hls/<KEY>/index.m3u8"