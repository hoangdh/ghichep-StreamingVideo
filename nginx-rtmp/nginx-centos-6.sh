#RTMP using nginx

yum -y install gcc gcc-c++ make zlib-devel pcre-devel openssl-devel git wget
mkdir -p ~/source
cd ~/source
wget http://nginx.org/download/nginx-1.8.0.tar.gz;
tar -xzf nginx-1.8.0.tar.gz
git clone https://github.com/arut/nginx-rtmp-module.git
cd nginx-1.8.0
./configure --user=nginx --group=nginx --add-module=../nginx-rtmp-module/ --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --with-http_ssl_module --with-http_realip_module --with-http_addition_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_stub_status_module --with-mail --with-mail_ssl_module --with-file-aio --with-ipv6
make
make install
useradd -r nginx
#wget -O /etc/init.d/nginx http://pastebin.com/raw.php?i=XhNPr6Y7
cat > /etc/init.d/nginx << H2
#!/bin/sh
#
# nginx        Startup script for nginx
#
# chkconfig: - 85 15
# processname: nginx
# config: /etc/nginx/nginx.conf
# config: /etc/sysconfig/nginx
# pidfile: /var/run/nginx.pid
# description: nginx is an HTTP and reverse proxy server
#
### BEGIN INIT INFO
# Provides: nginx
# Provides: nginx
# Required-Start: \$local_fs \$remote_fs \$network
# Required-Stop: \$local_fs \$remote_fs \$network
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: start and stop nginx
### END INIT INFO

# Source function library.
. /etc/rc.d/init.d/functions

if [ -f /etc/sysconfig/nginx ]; then
    . /etc/sysconfig/nginx
fi

prog=nginx
nginx=\${NGINX-/usr/sbin/nginx}
conffile=\${CONFFILE-/etc/nginx/nginx.conf}
lockfile=\${LOCKFILE-/var/lock/subsys/nginx}
pidfile=\${PIDFILE-/var/run/nginx.pid}
SLEEPMSEC=100000
RETVAL=0

start() {
    echo -n \$"Starting \$prog: "

    daemon --pidfile=\${pidfile} \${nginx} -c \${conffile}
    RETVAL=\$?
    echo
    [ \$RETVAL = 0 ] && touch \${lockfile}
    return \$RETVAL
}

stop() {
    echo -n \$"Stopping \$prog: "
    killproc -p \${pidfile} \${prog}
    RETVAL=\$?
    echo
    [ \$RETVAL = 0 ] && rm -f \${lockfile} \${pidfile}
}

reload() {
    echo -n \$"Reloading \$prog: "
    killproc -p \${pidfile} \${prog} -HUP
    RETVAL=\$?
    echo
}

upgrade() {
    oldbinpidfile=\${pidfile}.oldbin

    configtest -q || return 6
    echo -n \$"Staring new master \$prog: "
    killproc -p \${pidfile} \${prog} -USR2
    RETVAL=\$?
    echo
    /bin/usleep \$SLEEPMSEC
    if [ -f \${oldbinpidfile} -a -f \${pidfile} ]; then
        echo -n \$"Graceful shutdown of old \$prog: "
        killproc -p \${oldbinpidfile} \${prog} -QUIT
        RETVAL=\$?
        echo
    else
        echo \$"Upgrade failed!"
        return 1
    fi
}

configtest() {
    if [ "\$#" -ne 0 ] ; then
        case "\$1" in
            -q)
                FLAG=\$1
                ;;
            *)
                ;;
        esac
        shift
    fi
    \${nginx} -t -c \${conffile} \$FLAG
    RETVAL=\$?
    return \$RETVAL
}

rh_status() {
    status -p \${pidfile} \${nginx}
}

# See how we were called.
case "\$1" in
    start)
        rh_status >/dev/null 2>&1 && exit 0
        start
        ;;
    stop)
        stop
        ;;
    status)
        rh_status
        RETVAL=\$?
        ;;
    restart)
        configtest -q || exit \$RETVAL
        stop
        start
        ;;
    upgrade)
        upgrade
        ;;
    condrestart|try-restart)
        if rh_status >/dev/null 2>&1; then
            stop
            start
        fi
        ;;
    force-reload|reload)
        reload
        ;;
    configtest)
        configtest
        ;;
    *)
        echo \$"Usage: \$prog {start|stop|restart|condrestart|try-restart|force-reload|upgrade|reload|status|help|configtest}"
        RETVAL=2
esac

exit \$RETVAL
H2

chmod a+x /etc/init.d/nginx
chkconfig --add nginx
mkdir -p /var/cache/nginx/client_temp
chown nginx. /var/cache/nginx/client_temp
## Open port 80: nginx and 1935 for rtmp
# iptables -I INPUT -p tcp --dport 80 -j ACCEPT
# iptables -I INPUT -p tcp --dport 1935 -j ACCEPT
service iptables save
service iptables reload
# Add to configure file nginx.conf

# rtmp {
    # server {
            # listen 1935;
            # chunk_size 4096;

            # application live {
                    # live on;
                    # record off;
                    # allow publish 127.0.0.1;
                    # allow publish 0.0.0.0;
                    # deny publish all;
                    # exec ffmpeg -i rtmp://localhost/live/$name -threads 1 -c:v libx264 -profile:v baseline -b:v 350K -s 640x360 -f flv -c:a aac -ac 1 -strict -2 -b:a 56k rtmp://localhost/live360p/$name;
            # }
            # application live360p {
                    # live on;
                    # record off;
                    # allow publish 127.0.0.1;
                    # allow publish 0.0.0.0;
                    # deny publish all;
        # }
    # }
# }