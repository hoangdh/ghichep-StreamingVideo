#!/bin/bash

# yum group install "Development Tools" -yum
# yum install -y wget tar zip
# yum install libgcc_s.so.1 -y
# mkdir -p /opt/sopcast
# cd /opt/sopcast
# wget http://download.sopcast.com/download/sp-auth.tgz
# wget http://www.sopcast.com/download/libstdcpp5.tgz
# cd /opt/sopcast
# tar xzf sp-auth.tgz
# tar xzf libstdcpp5.tgz
# cd /opt/sopcast/usr/lib
# cp -a libstdc++.so.5* /usr/lib
# cp /opt/sopcast/sp-auth/sp-sc-auth /usr/bin/

apt-get update -y
apt-get install gcc vlc wget -y
wget http://ppa.launchpad.net/lyc256/sopcast-player/ubuntu/pool/main/s/sp-auth/sp-auth_3.2.6~ppa1_amd64.deb
wget http://ppa.launchpad.net/lyc256/sopcast-player/ubuntu/pool/main/s/sopcast-player/sopcast-player_0.8.5~ppa1_amd64.deb
dpkg -i sp-auth_3.2.6~ppa1_amd64.deb
dpkg -i sopcast-player_0.8.5~ppa1_amd64.deb
apt-get install -y python
apt-get install -f -y
echo "Test: sp-sc sop://broker.sopcast.com:3912/128789 2222 80"
