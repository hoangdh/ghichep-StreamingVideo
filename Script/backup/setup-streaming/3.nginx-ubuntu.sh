#!/bin/bash

apt-get update -y
apt-get install build-essential libpcre3 libpcre3-dev libssl-dev git wget dpkg-dev zlib1g-dev unzip -y

git clone https://github.com/arut/nginx-rtmp-module.git
wget http://nginx.org/download/nginx-1.10.1.tar.gz
tar -xf nginx-1.10.1.tar.gz
cd nginx-1.10.1

# apt-get update -y
# apt-get install build-essential libpcre3 libpcre3-dev libssl-dev git wget dpkg-dev zlib1g-dev unzip -y

# git clone https://github.com/arut/nginx-rtmp-module.git
# wget http://nginx.org/download/nginx-1.8.1.tar.gz
# tar -xf nginx-1.8.1.tar.gz
# cd nginx-1.8.1

./configure --user=nginx --group=nginx --add-module=../nginx-rtmp-module/ --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --with-http_ssl_module --with-http_realip_module --with-http_addition_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_stub_status_module --with-mail --with-mail_ssl_module --with-file-aio --with-ipv6

make
make install
useradd -r nginx
mkdir -p /var/cache/nginx/client_temp/
mkdir -p /etc/nginx/html/vod/
mkdir -p /etc/nginx/html/live/
chown nginx. /etc/nginx/html/live/
chown nginx. /etc/nginx/html/vod/
chown nginx. /var/cache/nginx/client_temp/

cat > /etc/nginx/html/crossdomain.xml << H2
<cross-domain-policy>
<allow-access-from domain="*" secure="false"/>
<site-control permitted-cross-domain-policies="all"/>
</cross-domain-policy>
H2

cat > /lib/systemd/system/nginx.service <<H2
[Unit]
Description=The NGINX HTTP and reverse proxy server
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/var/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx
ExecReload=/bin/kill -s HUP \$MAINPID
ExecStop=/bin/kill -s QUIT \$MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target
H2

cat > /etc/nginx/nginx.conf  << H2
#user  nobody;
worker_processes  auto;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

pid /var/run/nginx.pid;

events {
    worker_connections  1024;
}

rtmp {
    server {
            listen 1935;
            chunk_size 4096;
            notify_method get;
            
             application vod {
               play /etc/nginx/html/vod;
            }
        
            application live {
                    live on;
                    record off;
                    # on_publish http://localhost/on_publish;
                    # # Turn on HLS
                    hls on;
                    hls_path /etc/nginx/html/live;
                    hls_fragment 3;
                    hls_playlist_length 5;
                    hls_nested on;
                    ## disable consuming the stream from nginx as rtmp
                    # deny play all;
                    # allow publish 127.0.0.1;
                    # allow publish 0.0.0.0;
                    # deny publish all;
            }
            # # Record stream
            # record all;
            # record_path /etc/nginx/html/vod/;
            # record_suffix  -%d-%b-%y-%T.flv;
            # record_notify on;
        
    }
}

http {
    include       mime.types;
    default_type  application/octet-stream;

    #log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
    #                  '$status \$body_bytes_sent "\$http_referer" '
    #                  '"\$http_user_agent" "\$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    gzip  on;

    server {
        listen       80;
        server_name  localhost;
        server_tokens off;
        #charset koi8-r;

        access_log /var/log/nginx/access_log combined;
        error_log  /var/log/nginx/error_log;
        location / {
            root   html;
            index  index.html index.htm;
        }
        location /live {
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
            root html;
        }
        # # Secure VOD
        # location /videos {
            # secure_link_secret livestream;
            # if ($secure_link = "") { return 403; }

            # rewrite ^ /vod/$secure_link;
        # }

        # location /vod {
            # internal;
            # root /etc/nginx/html;
        # }
        # Secure RTMP on publish. (on_play,...)
        location /on_publish {

            # set connection secure link
            secure_link \$arg_st,\$arg_e;
            secure_link_md5 ByHoangDH\$arg_app/\$arg_name\$arg_e;

            # bad hash
            if (\$secure_link = "") {
                return 501;
            }

            # link expired
            if (\$secure_link = "0") {
                return 502;
            }

            return 200;
        }
        #error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }     
    }
}
H2

systemctl enable nginx
systemctl start nginx