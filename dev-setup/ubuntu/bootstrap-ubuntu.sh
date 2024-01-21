#!/usr/bin/env bash

# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

###################################################################################
# This script is an attempt to bootstrap an ubuntu environment with all the tools #
# needed for building/testing Spectrum +4 natively (i.e. outside of docker).      #
###################################################################################

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
        exit 67
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
echo "Preparing installation inside temp directory: '${PREP_DIR}' ..."
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
export PATH="${PATH}:/usr/local/bin:/usr/lib/go/bin"

retry apt-get update
retry apt-get upgrade -y

# autoconf is needed for running autogen.sh when building libspectrum and fuse
# bison is needed for building fuse
# bsdmainutils contains hexdump
# build-essential is needed for building z80 binutils, aarch64 binutils and fuse
# flex is needed for building fuse
# fuse-emulator-utils contains tape2wav
# fuse3 is needed by tup
# git is needed to fetch fuse/libspectrum sources
# libfuse3-dev is needed by fuse
# libglib2.0 is needed for building fuse-1.5.7 (seems to fix a pkg-config issue, might be overkill)
# libgmp-dev is required to build aarch64-none-elf-gdb
# libncurses-dev might be useful for building aarch64-none-elf-gdb (not sure)
# libpixman-1-dev is needed for building qemu
# libtool is needed by autogen.sh when building libspectrum and fuse
# meson is needed for building qemu
# texinfo is needed for building z80 binutils and aarch64 binutils
# unzip is needed for unzipping tup
# wget is needed for downloading curl
# xz-utils is needed by tar commands below
retry apt-get install -y autoconf bison bsdmainutils build-essential flex fuse-emulator-utils fuse3 git libfuse3-dev libglib2.0 libgmp-dev libncurses-dev libpixman-1-dev libtool meson texinfo unzip wget xz-utils

if ! hash curl 2> /dev/null; then
  retry wget -O /usr/local/bin/curl "https://github.com/moparisthebest/static-curl/releases/download/v7.84.0/curl-${ARCH2}"
  chmod a+x /usr/local/bin/curl
fi

if ! hash fuse 2> /dev/null; then

  # Install (headless) fuse which includes ROMs.
  # Note, we build from source since we need to specify --with-null-ui so that
  # windows aren't displayed when unit tests run. This also picks up newer
  # fixes which were missing from the previous release, e.g.
  #   * https://github.com/spectrum4/spectrum4/issues/10#issuecomment-1902378210

  # libspectrum
  retry git clone https://git.code.sf.net/p/fuse-emulator/libspectrum
  cd libspectrum
  git checkout e85c934f585cb8caff5eeab55899617b606abfeb
  ./autogen.sh
  ./configure
  gmake -j4
  gmake install
  cd ..

  # fuse
  retry git clone https://git.code.sf.net/p/fuse-emulator/fuse
  cd fuse
  git checkout 54bb53145a42f054dd7b5e5aa0bfa2d41020e265
  ./autogen.sh
  ./configure --with-null-ui
  gmake -j4
  gmake install
  cd ..
fi

# install binutils for targets z80-unknown-elf and aarch64-none-elf
z80_tools_absent=false
aarch64_tools_absent=false
for tool in as ld readelf objcopy objdump; do
  hash "z80-unknown-elf-${tool}" 2> /dev/null || z80_tools_absent=true
  hash "aarch64-none-elf-${tool}" 2> /dev/null || aarch64_tools_absent=true
done

if ${z80_tools_absent} || ${aarch64_tools_absent}; then
  retry curl -fsSL 'https://ftp.gnu.org/gnu/binutils/binutils-2.41.tar.gz' > binutils-2.41.tar.gz
  tar xfz binutils-2.41.tar.gz

  if ${z80_tools_absent}; then
    mkdir binutils-z80-build
    cd binutils-z80-build
    ../binutils-2.41/configure \
      --target=z80-unknown-elf \
      --disable-werror
    make -j4
    make install
    cd ..
  fi

  if ${aarch64_tools_absent}; then
    mkdir binutils-aarch64-build
    cd binutils-aarch64-build
    ../binutils-2.41/configure \
      --target=aarch64-none-elf
    make -j4
    make install
    cd ..
  fi
fi

if ! hash aarch64-none-elf-gdb 2> /dev/null; then
  retry curl -fsSL 'https://ftp.gnu.org/gnu/gdb/gdb-12.1.tar.gz' > gdb-12.1.tar.gz
  tar zvfx gdb-12.1.tar.gz
  cd gdb-12.1
  ./configure --target=aarch64-none-elf
  make -j4
  make install
  cd ..
fi

if ! hash qemu-system-aarch64 2> /dev/null; then
  retry curl -fsSL 'https://download.qemu.org/qemu-7.1.0.tar.xz' > qemu-7.1.0.tar.xz
  tar xvf qemu-7.1.0.tar.xz
  mkdir qemu-7.1.0/build
  cd qemu-7.1.0/build
  ../configure --target-list=aarch64-softmmu --disable-vnc
  make -j4
  make install
  cd ../..
fi

if ! hash tup 2> /dev/null; then
  retry curl -fsSL 'https://github.com/gittup/tup/archive/b037d4b211de6025703b77c3287b76159656ef22.zip' > tup.zip
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
fi

if ! hash go 2> /dev/null; then
  # install go 1.19.3
  mkdir -p /usr/lib
  cd /usr/lib
  retry curl -fsSL "https://golang.org/dl/go1.19.3.linux-${ARCH}.tar.gz" > "go1.19.3.linux-${ARCH}.tar.gz"
  tar xvfz "go1.19.3.linux-${ARCH}.tar.gz"
  rm "go1.19.3.linux-${ARCH}.tar.gz"
fi

# install shfmt
if ! hash shfmt 2> /dev/null; then
  # install shfmt
  /usr/lib/go/bin/go install mvdan.cc/sh/v3/cmd/shfmt@latest
  mv "${HOME}/go/bin/shfmt" /usr/local/bin/shfmt
fi

cd
echo "Deleting '${PREP_DIR}' ..."
rm -r "${PREP_DIR}"

echo "Please note the following environment variables need to be set in order for the tools to be available:"
echo "$ export PATH='/usr/lib/go/bin:/bin:/usr/bin:/usr/local/bin'"
echo "$ export GOROOT='/usr/lib/go'"
echo "You may wish to update e.g. ~/.profile or ~/.bash_profile or ~/.bashrc etc to do this for future login shells."
