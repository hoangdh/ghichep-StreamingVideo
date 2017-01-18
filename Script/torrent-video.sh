#!/bin/bash

sudo apt-get install curl
curl -sL https://deb.nodesource.com/setup_5.x | sudo -E bash -
sudo apt-get install nodejs
sudo npm install -g peerflix

sudo apt-get install vlc xterm python-libtorrent wget
wget https://raw.github.com/hotice/webupd8/master/Torrent-Video-Player -O /tmp/Torrent-Video-Player
sudo install /tmp/Torrent-Video-Player /usr/local/bin/

wget https://raw.github.com/danfolkes/Magnet2Torrent/master/Magnet_To_Torrent2.py -O /tmp/Magnet_To_Torrent2.py
sudo install /tmp/Magnet_To_Torrent2.py /usr/local/bin/
wget https://raw.github.com/hotice/webupd8/master/Magnet-Video-Player -O /tmp/Magnet-Video-Player
sudo install /tmp/Magnet-Video-Player /usr/local/bin/

echo -e "peerflix http://some-torrent/movie.torrent\nPlay: http://ip-addr:8888"