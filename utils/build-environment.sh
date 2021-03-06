#!/bin/bash

#
# Copyright (c) 2018 TeamWin Recovery | MediaTek
# https://github.com/twrp-mtk
#

GIT_USER_NAME="$1"
GIT_USER_MAIL="$2"
ARG_COUNT="$#"

# Count input arguments
if [ $ARG_COUNT -lt "2" ]; then
  echo "Not enough arguments were specified, run the script again with proper arguments"
  exit 1
fi

clear && clear scrollback

sudo apt-get update && sudo apt-get upgrade -y

sudo apt-get install -y bc \
                        bison \
                        build-essential \
                        ccache \
                        curl \
                        flex \
                        g++-multilib \
                        gcc-multilib \
                        git-core \
                        git \
                        gnupg \
                        gperf \
                        imagemagick \
                        lib32ncurses5-dev \
                        lib32readline-dev \
                        lib32z1-dev \
                        libc6-dev-i386 \
                        libesd0-dev \
                        libgl1-mesa-dev \
                        liblz4-tool \
                        libncurses5-dev \
                        libsdl1.2-dev \
                        libssl-dev \
                        libwxgtk3.0-dev \
                        libx11-dev \
                        libxml2 \
                        libxml2-utils \
                        lzop \
                        openjdk-8-jdk \
                        pngcrush \
                        python \
                        rsync \
                        schedtool \
                        squashfs-tools \
                        x11proto-core-dev \
                        xsltproc \
                        yasm \
                        zip \
                        zlib1g-dev

# Check the 'repo' presence and install 'repo' if it's not there
if [ -d "$HOME/bin" ]; then
  PATH="$HOME/bin:$PATH"
else
  mkdir -p ~/bin
  curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
  chmod a+x ~/bin/repo
  PATH="$HOME/bin:$PATH"
fi

# Initialize Git user information
git config --global user.name ${GIT_USER_NAME}
git config --global user.email ${GIT_USER_MAIL}

# Install and setup ADB & Fastboot
sudo wget -O /etc/udev/rules.d/51-android.rules https://raw.githubusercontent.com/NicolasBernaerts/ubuntu-scripts/master/android/51-android.rules
sudo chmod a+r /etc/udev/rules.d/51-android.rules
sudo service udev restart
sudo apt-get install -y android-tools-adb android-tools-fastboot
wget -O - https://skia.googlesource.com/skia/+archive/cd048d18e0b81338c1a04b9749a00444597df394/platform_tools/android/bin/linux.tar.gz | tar -zxvf - adb
sudo mv adb /usr/bin/adb
sudo chmod +x /usr/bin/adb

# Cleaning up
sudo apt-get clean && sudo apt-get autoclean
