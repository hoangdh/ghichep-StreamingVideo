# Hướng dẫn cài đặt NIGNX-RTMP

## Nội dung bài viết

[1. Chuẩn bị ](#1)

[2. Cài đặt và cấu hình ](#2)

- [2.1 Biên dịch NIGNX-RTMP ](#2.1)

- [2.2 Cấu hình RTMP ](#2.2)

- [2.3 Cấu hình HTTP Server cho HLS và DASH ](#2.3)
	
- [2.4 Cấu hình HLS ](#2.4)
	
- [2.5 Cấu hình DASH ](#2.5)
	
- [2.6 File cấu hình hoàn chỉnh ](#2.6)
	
[3. Kết luận ](#3)

### 1. Chuẩn bị <a name="1"></a>

**Thông tin về server:**

```
OS: Ubuntu 16.04
RAM: 2GB
Cores: 2
Bandwidth: 1Gb/s
eth0: 192.168.100.197
Gateway: 192.168.100.1
NETWORK: 192.168.100.0/24
```



### 2. Cài đặt và cấu hình <a name="2"></a>

#### 2.1 Biên dịch NIGNX-RTMP <a name="2.1"></a>

**Cài đặt các trình biên dịch:**

```
apt-get update -y
apt-get install build-essential libpcre3 libpcre3-dev libssl-dev git wget dpkg-dev zlib1g-dev unzip  -y
```

**Tải các gói cài đặt cần thiết:**

#### NGINX và giải nén

```
wget http://nginx.org/download/nginx-1.10.1.tar.gz
tar -xf nginx-1.10.1.tar.gz
```

#### Module RTMP

```
git clone https://github.com/arut/nginx-rtmp-module.git
```

**Biên dịch chương trình:**

```
cd nginx-1.10.1
./configure --user=nginx --group=nginx --add-module=../nginx-rtmp-module/ --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --with-http_ssl_module --with-http_realip_module --with-http_addition_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_stub_status_module --with-mail --with-mail_ssl_module --with-file-aio --with-ipv6

make
make install
```

**Tạo User `nginx` và phân quyền cho một số thư mục đặc biệt của `nginx-rtmp`**

```
useradd -r nginx
mkdir -p /var/cache/nginx/client_temp/
mkdir -p /etc/nginx/html/vod/
mkdir -p /etc/nginx/html/dash/
mkdir -p /etc/nginx/html/hls/
chown nginx. /etc/nginx/html/hls/
chown nginx. /etc/nginx/html/vod/
chown nginx. /var/cache/nginx/client_temp/
```

**Tạo file `crossdomain.xml` cho phép client đọc file HLS**

```
vi /etc/nginx/html/crossdomain.xml
```

Với nội dung như sau:

```
<cross-domain-policy>
<allow-access-from domain="*" secure="false"/>
<site-control permitted-cross-domain-policies="all"/>
</cross-domain-policy>
```

#### 2.2 Cấu hình RTMP <a name="2.2"></a>

Băng thông cho RTMP khá nhẹ, push chất lượng HD thì dung lượng ~ 500KB cho một stream.

Mở cấu hình `/etc/nginx/nginx.conf` và thêm block `rtmp` vào file

```
rtmp {
    server {
            listen 1935;
            application vod {
               play /etc/nginx/html/vod;
            }
        
            application live {
                    live on;
                    record off;
            }
            # # Record stream
            # record all;
            # record_path /etc/nginx/html/vod/;
            # record_suffix  -%d-%b-%y-%T.flv;
            # record_notify on;
        
    }
}
```

##### Chú thích:

- `listen 1935;`: Cổng lắng nghe của RTMP, mặc định 1935
- `application live`: Khai báo một app tên là `live`
- `live on;`: Cho phép live. Sử dụng để push và play stream `rtmp://ip-server/live/stream-name`
- `play /path/to/folder;`: Cho phép Play các video ở trong thư mục khai báo theo giao thức RTMP. `rtmp://ip-server/vod/file-name.mp4` 

#### 2.3 Cấu hình HTTP Server cho HLS và DASH <a name="2.3"></a>

Băng thông cho HLS và DASH khá tốn, play một stream chất lượng HD thì dung lượng >= 1MB/s cho một stream.

Thêm block `http` và file cấu hình `nginx.conf`

```
http {
    include       mime.types;
    default_type  application/octet-stream;

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

        access_log /var/log/nginx/access_http_log combined;
        error_log  /var/log/nginx/error_http_log;
        location / {
            root   html;
            index  index.html index.htm;
        }

        #error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
        location /stat {
            rtmp_stat all;
            rtmp_stat_stylesheet stat.xsl;
        }

        location /stat.xsl {
            root html;
        }
    }
```

#### 2.4 Cấu hình HLS <a name="2.4"></a>

Thêm một vài dòng cấu hình sau vào app bạn muốn sử dụng HLS:

```
hls on; # Bat HLS
hls_nested; # Cho cac stream vao trong 1 thu muc co ten ~ stream
hls_path /etc/nginx/html/hls; # Thu muc chua stream
hls_fragment 3; # Do dai cua stream
hls_playlist_length 10; # Do dai cua playlist
```

Ví dụ thêm vào app `live`

```
application live {
                    live on;
                    record off;
                    # # Turn on HLS
                    hls on;
                    hls_nested;
                    hls_path /etc/nginx/html/hls;
                    hls_fragment 3;
                    hls_playlist_length 10;
                }
```

#### 2.5 Cấu hình DASH <a name="2.5"></a>

Thêm một vài dòng cấu hình sau vào app bạn muốn sử dụng DASH:

```
dash on; # Bat dash
dash_nested; # Cho cac stream vao trong 1 thu muc co ten ~ stream
dash_path /etc/nginx/html/dash; # Thu muc chua stream
dash_fragment 3; # Do dai cua stream
dash_playlist_length 10; # Do dai cua playlist
```

Ví dụ thêm vào app `live`

```
application live {
                    live on;
                    record off;
                    # # Turn on DASH
                    dash on;
                    dash_nested;
                    dash_path /etc/nginx/html/dash;
                    dash_fragment 3;
                    dash_playlist_length 10;
                }
```

#### 2.6 File cấu hình hoàn chỉnh <a name="2.6"></a>

```
user  nginx;
worker_processes  auto;

pid /var/run/nginx.pid;

events {
    worker_connections  1024;
}

rtmp {
    server {
            listen 1935;
            access_log /var/log/nginx/access_rtmp_log combined;
            
             application vod {
               play /etc/nginx/html/vod;
            }
        
            application live {
                    live on;
                    record off;
                    # # Turn on HLS
                    hls on;
                    hls_path /etc/nginx/html/hls;
                    hls_fragment 3;
                    hls_playlist_length 10;
                    hls_nested on;
                    # # Turn on DASH
                    dash on;
                    dash_nested on;
                    dash_path /etc/nginx/html/dash;
                    dash_fragment 3;
                    dash_playlist_length 10;
               
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

        access_log /var/log/nginx/access_http_log combined;
        error_log  /var/log/nginx/error_http_log;
        location / {
            root   html;
            index  index.html index.htm;
        }
		
		# # Player get M3U8
        location /hls {
            # Disable cache
            add_header 'Cache-Control' 'no-cache';

            # CORS setup
            add_header 'Access-Control-Allow-Origin' '*' always;
            add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range';
            add_header 'Access-Control-Allow-Headers' 'Range';

            # allow CORS preflight requests
            if ($request_method = 'OPTIONS') {
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
		
        #error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
        location /stat {
            rtmp_stat all;
            rtmp_stat_stylesheet stat.xsl;
        }

        location /stat.xsl {
            root html;
        }
    }
}

```

### 3. Kết luận <a name="3"></a>

Trên đây là một số hướng dẫn về cấu hình một streamming server sử dụng phần mềm mã nguồn mở. Hy vọng có thể giúp các bạn hiểu thêm về công nghệ đang "Hót hòn họt" trên thị trường trong vài năm trở lại đây. Các bạn muốn tìm hiểu sâu hơn về lĩnh vực này vui lòng tìm hiểu trang chủ.

Một vài kỹ thuật nâng cao như Secure stream, HA stream sẽ được cập nhật trong thời gian tới. Cảm ơn các bạn đã quan tâm!

- http://nginx-rtmp.blogspot.com
- https://github.com/arut/nginx-rtmp-module/wiki/Getting-started-with-nginx-rtmp
- Directives:  https://github.com/arut/nginx-rtmp-module/wiki/Directives