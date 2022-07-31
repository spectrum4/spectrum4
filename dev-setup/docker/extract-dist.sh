#!/usr/bin/env bash

# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

################################################################################
# This script copies/moves all tools that are needed inside the final docker
# image into /dist in order that a new docker image can be built containing just
# /dist mounted at / and nothing else.
################################################################################

set -eu
set -o pipefail

cd "$(dirname "${0}")"

# add certificates needed by curl to /dist
mkdir -p /dist/etc/ssl/certs
cp -vp /etc/ssl/certs/ca-certificates.crt /dist/etc/ssl/certs/ca-certificates.crt

# add fuse ROMs
mkdir -p /dist/usr/local/share
cp -vpr /usr/local/share/fuse /dist/usr/local/share/fuse

# add qemu keymaps etc
cp -vpr /usr/local/share/qemu /dist/usr/local/share/qemu

# add C.UTF-8 locale
mkdir -p /dist/usr/lib/locale/
cp -vpr /usr/lib/locale/C.UTF-8 /dist/usr/lib/locale/C.UTF-8

# needed for go installation
mkdir -p /dist/tmp
mkdir -p /dist/usr/lib
cp -pr /usr/lib/go /dist/usr/lib/go

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
