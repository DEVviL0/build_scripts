#!/bin/bash

#
# Copyright (c) 2017 - 2018 TeamWin Recovery | MediaTek
# https://github.com/twrp-mtk
#

# Don't touch this
DEVICE="$1"
LOG="$2"
CLEAN="$3"
CCACHE="$4"
ARG_COUNT="$#"

if [ $ARG_COUNT -lt "4" ]
then
  echo "Not enough arguments were specified, run the script again with proper arguments"
  exit 1
fi

export OUT_LOG="rom-${DEVICE}-$(date +%Y%m%d).log"
export OUT_PATH="out/target/product/${DEVICE}"
export OUT_ZIP=$(find ${OUT_PATH} -name *${DEVICE}*.zip)
export OUT_MD5=$(find ${OUT_PATH} -name *${DEVICE}*.md5sum)

# Check the 'repo' presence
if [ -d "$HOME/bin" ]
then
  PATH="$HOME/bin:$PATH"
else
  mkdir -p ~/bin
  curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
  chmod a+x ~/bin/repo
  PATH="$HOME/bin:$PATH"
fi

# Allocate sufficient RAM amount for Jack compiler
# In our case it's 8GB
export ANDROID_JACK_VM_ARGS="-Dfile.encoding=UTF-8 -XX:+TieredCompilation -Xmx8G"
./prebuilts/sdk/tools/jack-admin kill-server
./prebuilts/sdk/tools/jack-admin start-server

# Clean build
if [ "$CLEAN" == "--clean" ]
then
  make clean
fi

# Setting up the environment
source build/envsetup.sh

# Setting up the CCache
if [ "$CCACHE" == "--ccache" ]
then
  export USE_CCACHE=1
  ${PWD}/prebuilts/misc/linux-x86/ccache/ccache -M 50G
fi

# Setting the device
breakfast ${DEVICE}

# Building the ROM
if [ "$LOG" == "--log" ]
then
  brunch ${DEVICE} 2>&1 | tee ${OUT_LOG}
else
  brunch ${DEVICE}
fi

# Checking if the build was successful
if [ -f ${OUT_ZIP} ]
then
  echo ""
  echo "******************************************************************************"
  echo ""
  echo " The ROM has been successfuly built for device ${DEVICE}!"
  echo ""
  echo " ROM path     : ${OUT_ZIP}"
  echo " ROM Md5 path : ${OUT_MD5}"

  if [ "$LOG" == "--log" ]
  then
    echo " Build log    : ${OUT_LOG}"
  fi
  
  echo ""
  echo "******************************************************************************"
  echo ""
else
  rm ${OUT_LOG}
  make clean
  echo ""
  echo "********************************************************************************"
  echo " Something went wrong during the build process, try checking your device tree."
  echo " After that, run the script again and see if you messed up something new or not."
  echo "********************************************************************************"
  echo ""
fi

# Kill Java
pkill java

# Unsetting variables
unset DEVICE
unset OUT_PATH
unset OUT_LOG
unset OUT_ZIP
unset OUT_MD5
unset LOG
unset CLEAN
unset CCACHE
unset ARG_COUNT
