#!/usr/bin/env bash

# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

set -eu
set -o pipefail

cd "$(dirname "${0}")"

function retry {
  set +e
  local n=0
  local max=10
  while true; do
    "$@" && break || {
      if [[ $n -lt $max ]]; then
        ((n++))
        echo "Command failed" >&2
        sleep_time=$((2 ** n))
        echo "Sleeping $sleep_time seconds..." >&2
        sleep $sleep_time
        echo "Attempt $n/$max:" >&2
      else
        echo "Failed after $n attempts." >&2
        exit 1
      fi
    }
  done
  set -e
}

case "$(uname -m)" in
  x86_64)
    ARCH=amd64
    ARCH2=amd64
    ;;
  aarch64)
    ARCH=arm64
    ARCH2=aarch64
    ;;
  *)
    echo "Unsupported architecture '$(uname -m)' - currently docker/bootstrap.sh only supports architectures x86_64 and aarch64" >&2
    exit 64
    ;;
esac

export DEBIAN_FRONTEND=noninteractive

mkdir -p /usr/local/bin
export PATH="${PATH}:/usr/local/bin"

retry apt-get update
retry apt-get upgrade -y

# xz-utils is needed by tar command below
# build-essential is needed for building z80 binutils and libspectrum/fuse
# libglib2.0 is needed for building libspectrum
# bsdmainutils contains hexdump
# libpixman-1-dev and meson needed for building qemu
# libaudiofile-dev is required by tape2wav in fuse-utils
retry apt-get install -y wget xz-utils build-essential libglib2.0 bsdmainutils libpixman-1-dev meson libaudiofile-dev fuse3 libfuse3-dev unzip

retry wget -O /usr/local/bin/curl "https://github.com/moparisthebest/static-curl/releases/download/v7.84.0/curl-${ARCH2}"
chmod a+x /usr/local/bin/curl

# install libspectrum (needed by fuse)
# retry curl -L 'https://sourceforge.net/projects/fuse-emulator/files/libspectrum/1.4.4/libspectrum-1.4.4.tar.gz/download' > libspectrum-1.4.4.tar.gz
# tar xvfz libspectrum-1.4.4.tar.gz
# cd libspectrum-1.4.4
# ./configure
# make
# make install
# cd ..
retry apt-get install -y libspectrum-dev

# install (headless) fuse which includes ROMs
retry curl -f -L 'https://sourceforge.net/projects/fuse-emulator/files/fuse/1.5.7/fuse-1.5.7.tar.gz/download' > fuse-1.5.7.tar.gz
tar xvfz fuse-1.5.7.tar.gz
cd fuse-1.5.7
./configure --with-null-ui
make
make install
cd ..

# install fuse-utils to get tape2wav
retry curl -f -L 'https://sourceforge.net/projects/fuse-emulator/files/fuse-utils/1.4.3/fuse-utils-1.4.3.tar.gz/download' > fuse-utils-1.4.3.tar.gz
tar xvfz fuse-utils-1.4.3.tar.gz
cd fuse-utils-1.4.3
./configure
make
make install
cd ..

# install gcc cross-compiler toolchain
retry wget -nv -O "gcc-arm-11.2-2022.02-$(uname -m)-aarch64-none-elf.tar.xz" "https://developer.arm.com/-/media/Files/downloads/gnu/11.2-2022.02/binrel/gcc-arm-11.2-2022.02-$(uname -m)-aarch64-none-elf.tar.xz"
tar xvf "gcc-arm-11.2-2022.02-$(uname -m)-aarch64-none-elf.tar.xz"

# move gcc tools into /usr/local/bin
mv "/gcc-arm-11.2-2022.02-$(uname -m)-aarch64-none-elf/bin"/* /usr/local/bin

# install z80 cross-compiler binutils
retry wget -O binutils.tar.gz https://ftpmirror.gnu.org/binutils/binutils-2.37.tar.gz
tar zvfx binutils.tar.gz
cd binutils-2.37
./configure --target=z80-unknown-elf --disable-werror
make
make install
cd ..

retry curl -f -L 'https://download.qemu-project.org/qemu-5.2.0.tar.xz' > qemu-5.2.0.tar.xz
tar xvf qemu-5.2.0.tar.xz
mkdir qemu-5.2.0/build
cd qemu-5.2.0/build
../configure --target-list=aarch64-softmmu --disable-vnc
make -j4
make install
cd ../..

retry curl -f -L 'https://github.com/gittup/tup/archive/b037d4b211de6025703b77c3287b76159656ef22.zip' > tup.zip
unzip tup.zip
cd tup-*
CFLAGS="-g" ./build.sh
mv build/tup /usr/local/bin
cd ..
# apt-get install -y software-properties-common
# retry apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 486D3664
# apt-add-repository 'deb http://ppa.launchpad.net/anatol/tup/ubuntu precise main'
# retry apt-get update --allow-insecure-repositories
# apt-get install tup

# add certificates needed by curl to /dist
mkdir -p /dist/etc/ssl/certs
cp -vp /etc/ssl/certs/ca-certificates.crt /dist/etc/ssl/certs/ca-certificates.crt

# add fuse ROMs
mkdir -p /dist/usr/local/share
mv /usr/local/share/fuse /dist/usr/local/share/fuse

# add qemu keymaps etc
mv /usr/local/share/qemu /dist/usr/local/share/qemu

# add C.UTF-8 locale
mkdir -p /dist/usr/lib/locale/
mv /usr/lib/locale/C.UTF-8 /dist/usr/lib/locale/C.UTF-8

# install go 1.18.5
mkdir -p /dist/usr/lib
cd /dist/usr/lib
retry curl -f -L "https://golang.org/dl/go1.18.5.linux-${ARCH}.tar.gz" > "go1.18.5.linux-${ARCH}.tar.gz"
tar xvfz "go1.18.5.linux-${ARCH}.tar.gz"
rm "go1.18.5.linux-${ARCH}.tar.gz"
mkdir -p /dist/tmp

# install shfmt
/dist/usr/lib/go/bin/go install mvdan.cc/sh/v3/cmd/shfmt@latest
mv ${HOME}/go/bin/shfmt /usr/local/bin/shfmt

# for all executables required, find their library dependencies (using ldd),
# and copy everything needed into /dist
# LD_LIBRARY_PATH needed for ldd to find libspectrum.so.8
# ENV LD_LIBRARY_PATH /usr/local/lib
for tool in /bin/sh aarch64-none-elf-as aarch64-none-elf-ld aarch64-none-elf-objcopy aarch64-none-elf-objdump aarch64-none-elf-readelf bash cat cmp cp curl dirname env find fuse fusermount3 head hexdump ln md5sum mkdir mv qemu-system-aarch64 rm sed shfmt sleep sort tape2wav tup wc which z80-unknown-elf-as z80-unknown-elf-ld z80-unknown-elf-objcopy z80-unknown-elf-objdump z80-unknown-elf-readelf; do
  file=$(which ${tool})
  ldd $file 2> /dev/null || true
  echo $file
done | sed 's/(.*//' | sed 's/^[^\/]*//' | grep '^/' | sort -u | while read line; do
  echo "${line}"
  mkdir -p "$(dirname "/dist${line}")"
  cp -vp "${line}" "/dist${line}"
done
