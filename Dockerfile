FROM nginx:1.16.1-alpine

LABEL maintainer="HoangDH - <github.com/hoangdh>"

ENV NGINX_VER 1.16.1
ENV DEP git build-base

RUN apk update && \
	apk --no-cache add ${DEP} openssl-dev pcre-dev zlib-dev && \
	mkdir /work && \
	cd /work && \
	git clone git://github.com/arut/nginx-rtmp-module.git && \
	wget http://nginx.org/download/nginx-${NGINX_VER}.tar.gz && \
	tar -xzf nginx-${NGINX_VER}.tar.gz && \
	cd nginx-${NGINX_VER} && \
	./configure --with-http_ssl_module --add-dynamic-module=../nginx-rtmp-module --with-cc-opt="-Werror=implicit-fallthrough=0" --with-compat && \
	make modules && \
	cp objs/ngx_rtmp_module.so /etc/nginx/modules/ && \
	sed -i '7iload_module modules/ngx_rtmp_module.so;' /etc/nginx/nginx.conf && \
	mkdir -p /var/cache/nginx/client_temp /var/www/hls \
	&& chown -R nginx:nginx /var/cache/nginx/ /var/www/hls \
	&& apk del ${DEP} \
	&& rm -rf /work /var/cache/apk/*
	
COPY nginx-rtmp/nginx.conf /etc/nginx/

EXPOSE 80 443 1935

WORKDIR /var/www

CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
