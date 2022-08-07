#!/usr/bin/env bash

# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

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

set -eu
set -o pipefail

if [ "$(uname)" != 'Linux' ]; then
  echo "This script is designed to run on ubuntu. The uname utility reports that this host is running '$(uname)', but should be 'Linux'. Exiting." >&2
  exit 66
fi

if [ "${EUID}" -ne 0 ]; then
  echo "Please run as root (sudo ${0})" >&2
  exit 65
fi

PREP_DIR="$(mktemp -t -d spectrum4-toolchains-install.XXXXXXXXXX)"
cd "${PREP_DIR}"

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

# bsdmainutils contains hexdump
# build-essential is needed for building z80 binutils and libspectrum/fuse
# libaudiofile-dev is required by tape2wav in fuse-utils
# libglib2.0 is needed for building libspectrum
# libgmp-dev is required to build aarch64-none-elf-gdb
# libncurses-dev might be useful for building aarch64-none-elf-gdb (not sure)
# libpixman-1-dev and meson needed for building qemu
# xz-utils is needed by tar commands below
retry apt-get install -y bsdmainutils build-essential fuse3 libaudiofile-dev libfuse3-dev libglib2.0 libgmp-dev libncurses-dev libpixman-1-dev meson texinfo unzip wget xz-utils

retry wget -O /usr/local/bin/curl "https://github.com/moparisthebest/static-curl/releases/download/v7.84.0/curl-${ARCH2}"
chmod a+x /usr/local/bin/curl

# install libspectrum (needed by fuse)
# export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu
# Note, libspectrum-dev places library files in /usr/lib/x86_64-linux-gnu:
#   /usr/lib/x86_64-linux-gnu/libspectrum.a
#   /usr/lib/x86_64-linux-gnu/libspectrum.so.8.8.14
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
retry apt-get install -y fuse-emulator-utils
# retry curl -f -L 'https://sourceforge.net/projects/fuse-emulator/files/fuse-utils/1.4.3/fuse-utils-1.4.3.tar.gz/download' > fuse-utils-1.4.3.tar.gz
# tar xvfz fuse-utils-1.4.3.tar.gz
# cd fuse-utils-1.4.3
# ./configure
# make
# make install
# cd ..

# install gcc cross-compiler toolchain
retry curl -f -L "https://developer.arm.com/-/media/Files/downloads/gnu/11.2-2022.02/binrel/gcc-arm-11.2-2022.02-$(uname -m)-aarch64-none-elf.tar.xz" > "gcc-arm-11.2-2022.02-$(uname -m)-aarch64-none-elf.tar.xz"
tar xvf "gcc-arm-11.2-2022.02-$(uname -m)-aarch64-none-elf.tar.xz"

# move gcc tools into /usr/local/bin
mv "gcc-arm-11.2-2022.02-$(uname -m)-aarch64-none-elf/bin"/* /usr/local/bin

# replace arm developer gdb with our own, since theirs seems to depend on
# libpython3.6m.so.1.0 which isn't available, and is from python 3.6, so pretty
# old too.
rm /usr/local/bin/aarch64-none-elf-gdb*
retry curl -f -L 'https://ftp.gnu.org/gnu/gdb/gdb-12.1.tar.gz' > gdb-12.1.tar.gz
tar zvfx gdb-12.1.tar.gz
cd gdb-12.1
./configure --target=aarch64-none-elf # --disable-werror
make
make install
cd ..

# install z80 cross-compiler binutils
retry curl -f -L 'https://ftpmirror.gnu.org/binutils/binutils-2.39.tar.gz' > binutils.tar.gz
tar zvfx binutils.tar.gz
cd binutils-2.39
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
# Note, we don't use ./bootstrap.sh here because it requires privileges which
# are not available during `docker build`. Now I think about it though, maybe
# we could build tup inside a docker container (using `docker run` with
# appropriate privileges), and then copy it into the image that we build with a
# COPY directive in the Dockerfile. For now though, this works and is
# sufficient.
CFLAGS="-g" ./build.sh
mv build/tup /usr/local/bin
cd ..
# apt-get install -y software-properties-common
# retry apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 486D3664
# apt-add-repository 'deb http://ppa.launchpad.net/anatol/tup/ubuntu precise main'
# retry apt-get update --allow-insecure-repositories
# apt-get install tup

# install go 1.19
mkdir -p /usr/lib
cd /usr/lib
retry curl -f -L "https://golang.org/dl/go1.19.linux-${ARCH}.tar.gz" > "go1.19.linux-${ARCH}.tar.gz"
tar xvfz "go1.19.linux-${ARCH}.tar.gz"
rm "go1.19.linux-${ARCH}.tar.gz"

# install shfmt
/usr/lib/go/bin/go install mvdan.cc/sh/v3/cmd/shfmt@latest
mv "${HOME}/go/bin/shfmt" /usr/local/bin/shfmt

cd
echo "Deleting '${PREP_DIR}' ..."
rm -rf "${PREP_DIR}"

echo "Please note the following environment variables need to be set in order for the tools to be available:"
echo "$ export PATH='/usr/lib/go/bin:/bin:/usr/bin:/usr/local/bin'"
echo "$ export GOROOT='/usr/lib/go'"
echo "You may wish to update e.g. ~/.profile or ~/.bash_profile or ~/.bashrc etc to do this for future login shells."
