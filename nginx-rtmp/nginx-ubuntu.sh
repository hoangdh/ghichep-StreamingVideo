#!/bin/bash

apt-get update -y
apt-get upgrade -y
apt-get install build-essential libpcre3 libpcre3-dev libssl-dev git wget dpkg-dev zlib1g-dev unzip  -y

git clone https://github.com/arut/nginx-rtmp-module.git
wget http://nginx.org/download/nginx-1.10.1.tar.gz
tar -xf nginx-1.10.1.tar.gz
cd nginx-1.10.1

./configure --user=nginx --group=nginx --add-module=../nginx-rtmp-module/ --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --with-http_ssl_module --with-http_realip_module --with-http_addition_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_stub_status_module --with-mail --with-mail_ssl_module --with-file-aio --with-ipv6

make
make install
useradd -r nginx
mkdir -p /var/cache/nginx/client_temp/
chown nginx. /var/cache/nginx/client_temp/
