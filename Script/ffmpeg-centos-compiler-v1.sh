# rpm -Uhv http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
# yum -y update
# yum install glibc gcc gcc-c++ autoconf automake libtool git make nasm pkgconfig -y
# yum install SDL-devel a52dec a52dec-devel alsa-lib-devel faac faac-devel faad2 faad2-devel -y
# yum install freetype-devel giflib gsm gsm-devel imlib2 imlib2-devel lame lame-devel libICE-devel libSM-devel libX11-devel -y
# yum install libXau-devel libXdmcp-devel libXext-devel libXrandr-devel libXrender-devel libXt-devel -y
# yum install libogg libvorbis vorbis-tools mesa-libGL-devel mesa-libGLU-devel xorg-x11-proto-devel zlib-devel -y
# yum install libtheora theora-tools -y
# yum install ncurses-devel -y
# yum install libdc1394 libdc1394-devel -y
# yum install amrnb-devel amrwb-devel opencore-amr-devel -y

# #  xvid
# cd /opt
# wget http://downloads.xvid.org/downloads/xvidcore-1.3.2.tar.gz
# tar xzvf xvidcore-1.3.2.tar.gz
# cd xvidcore/build/generic
# ./configure --prefix="$HOME/ffmpeg_build"
# make
# make install

# #libOgg
# cd /opt
# wget http://downloads.xiph.org/releases/ogg/libogg-1.3.1.tar.gz
# tar xzvf libogg-1.3.1.tar.gz
# cd libogg-1.3.1
# ./configure --prefix="$HOME/ffmpeg_build" --disable-shared
# make
# make install

# #libvorbis
# cd /opt
# wget http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.4.tar.gz
# tar xzvf libvorbis-1.3.4.tar.gz
# cd libvorbis-1.3.4
# ./configure --prefix="$HOME/ffmpeg_build" --with-ogg="$HOME/ffmpeg_build" --disable-shared
# make
# make install

# #libtheora
# cd /opt
# wget http://downloads.xiph.org/releases/theora/libtheora-1.1.1.tar.gz
# tar xzvf libtheora-1.1.1.tar.gz
# cd libtheora-1.1.1
# ./configure --prefix="$HOME/ffmpeg_build" --with-ogg="$HOME/ffmpeg_build" --disable-examples --disable-shared --disable-sdltest --disable-vorbistest
# make
# make install

# #accenc
# cd /opt
# wget http://downloads.sourceforge.net/opencore-amr/vo-aacenc-0.1.2.tar.gz
# tar xzvf vo-aacenc-0.1.2.tar.gz
# cd vo-aacenc-0.1.2
# ./configure --prefix="$HOME/ffmpeg_build" --disable-shared
# make
# make install

# #yasm
# yum remove yasm
# cd /opt
# wget http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz
# tar xzfv yasm-1.2.0.tar.gz
# cd yasm-1.2.0
# ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin"
# make
# make install
# export "PATH=$PATH:$HOME/bin"

# #libvpx
# cd /opt
# git clone https://chromium.googlesource.com/webm/libvpx.git
# cd libvpx
# git checkout tags/v.1.3.0
# ./configure --prefix="$HOME/ffmpeg_build" --disable-examples
# make
# make install

# #x264
# cd /opt
# git clone git://git.videolan.org/x264.git
# cd x264
# ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static 
# make
# make install

# #Configure libraries
# export LD_LIBRARY_PATH=/usr/local/lib/
# echo /usr/local/lib >> /etc/ld.so.conf.d/custom-libs.conf
# ldconfig

# #Compile FFmpeg
# cd /opt
# git clone git://source.ffmpeg.org/ffmpeg.git
# cd ffmpeg
# git checkout release/2.5
# PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig"
# export PKG_CONFIG_PATH
# ./configure --prefix="$HOME/ffmpeg_build" --extra-cflags="-I$HOME/ffmpeg_build/include" --extra-ldflags="-L$HOME/ffmpeg_build/lib" --bindir="$HOME/bin" \
# --extra-libs=-ldl --enable-version3 --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libvpx --enable-libfaac \
# --enable-libmp3lame --enable-libtheora --enable-libvorbis --enable-libx264 --enable-libvo-aacenc --enable-libxvid --disable-ffplay \
# --enable-gpl --enable-postproc --enable-nonfree --enable-avfilter --enable-pthreads
# make
# make install

#!/bin/bash
#Install FFmpeg

yum install autoconf automake gcc gcc-c++ git libtool make nasm pkgconfig zlib-devel -y
mkdir ~/ffmpeg_sources

 

#Yasm
cd ~/ffmpeg_sources
curl -O http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz
tar xzvf yasm-1.2.0.tar.gz
cd yasm-1.2.0
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin"
make
make install
make distclean
export "PATH=$PATH:$HOME/bin"

 

#libx264
cd ~/ffmpeg_sources
git clone --depth 1 git://git.videolan.org/x264
cd x264
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-shared
make
make install
make distclean

 

#libfdk_aac
cd ~/ffmpeg_sources
git clone --depth 1 git://git.code.sf.net/p/opencore-amr/fdk-aac
cd fdk-aac
autoreconf -fiv
./configure --prefix="$HOME/ffmpeg_build" --enable-shared
make
make install
make distclean

 

#libmp3lame
cd ~/ffmpeg_sources
curl -L -O http://downloads.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz
tar xzvf lame-3.99.5.tar.gz
cd lame-3.99.5
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-shared --enable-nasm
make
make install
make distclean

 

#libopus
cd ~/ffmpeg_sources
curl -O http://downloads.xiph.org/releases/opus/opus-1.1.tar.gz
tar xzvf opus-1.1.tar.gz
cd opus-1.1
./configure --prefix="$HOME/ffmpeg_build" --enable-shared
make
make install
make distclean

 

#libogg
cd ~/ffmpeg_sources
curl -O http://downloads.xiph.org/releases/ogg/libogg-1.3.1.tar.gz
tar xzvf libogg-1.3.1.tar.gz
cd libogg-1.3.1
./configure --prefix="$HOME/ffmpeg_build" --enable-shared
make
make install
make distclean

 

#libvorbis
echo "/root/ffmpeg_build/lib" >> /etc/ld.so.conf
ldconfig
cd ~/ffmpeg_sources
curl -O http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.4.tar.gz
tar xzvf libvorbis-1.3.4.tar.gz
cd libvorbis-1.3.4
./configure --prefix="$HOME/ffmpeg_build" --with-ogg="$HOME/ffmpeg_build" --enable-shared
make
make install
make distclean

#libvpx
cd ~/ffmpeg_sources
git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git
cd libvpx
./configure --prefix="$HOME/ffmpeg_build" --disable-examples --disable-unit-tests
make
make install
make clean

#freetype-devel, libspeex
yum install freetype-devel speex-devel -y


#libtheora
cd ~/ffmpeg_sources
curl -O http://downloads.xiph.org/releases/theora/libtheora-1.1.1.tar.gz
tar xzvf libtheora-1.1.1.tar.gz
cd libtheora-1.1.1
./configure --prefix="$HOME/ffmpeg_build" --with-ogg="$HOME/ffmpeg_build" --disable-examples --enable-shared --disable-sdltest --disable-vorbistest
make
make install
make distclean

#FFmpeg
cd ~/ffmpeg_sources
wget http://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2
tar xjvf ffmpeg-snapshot.tar.bz2
cd ffmpeg
PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
  --prefix="$HOME/ffmpeg_build" \
  --pkg-config-flags="--static" \
  --extra-cflags="-I$HOME/ffmpeg_build/include" \
  --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
  --bindir="$HOME/bin" \
  --enable-gpl \
  --enable-libass \
  --enable-libfdk-aac \
  --enable-libfreetype \
  --enable-libmp3lame \
  --enable-libopus \
  --enable-libtheora \
  --enable-libvorbis \
  --enable-libvpx \
  --enable-libx264 \
  --enable-libx265 \
  --enable-nonfree
PATH="$HOME/bin:$PATH" make
make install
make distclean
hash -r
