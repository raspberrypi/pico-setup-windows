#!/bin/bash

set -euo pipefail

BITNESS=$1
ARCH=$2
OPENOCD_BRANCH="master"

if [ ! -d openocd ]; then
  git clone "https://github.com/openocd-org/openocd.git" -b $OPENOCD_BRANCH --depth=1
else
  git -C openocd checkout -B $OPENOCD_BRANCH
  git -C openocd pull --ff-only
fi

cd openocd
./bootstrap
./configure --enable-picoprobe --enable-cmsis-dap
make clean
make -j4
DESTDIR="$PWD/../openocd-install" make install
