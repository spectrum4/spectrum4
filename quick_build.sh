#!/usr/bin/env bash

# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

################################################################################
# This is a quick way to build, if you don't want to run all the tests...
# Note, you should have run tup (or ./tup-under-docker.sh) at least once before
# calling this, so that needed directories and symbolic links already exist.
################################################################################

set -eu
set -o pipefail
export SHELLOPTS

: ${AARCH64_TOOLCHAIN_PREFIX:=aarch64-none-elf-}

cd "$(dirname "${0}")/src/spectrum4/libextra"

./sysvars.sh > sysvars.gen-s

cd "../targets"

for target in debug tests release; do
  "${AARCH64_TOOLCHAIN_PREFIX}as" -I .. -I ../kernel -I ../roms -I ../tests -I ../demo -I ../libextra -o "${target}.o" "${target}.target"
  "${AARCH64_TOOLCHAIN_PREFIX}ld" --fix-cortex-a53-835769 --fix-cortex-a53-843419 --no-warn-rwx-segments -N -Ttext=0x0000000000000000 -o "${target}.elf" "${target}.o"
  # "${AARCH64_TOOLCHAIN_PREFIX}ld" --fix-cortex-a53-835769 --fix-cortex-a53-843419 --no-warn-rwx-segments -N -Ttext=0xffff000000000000 -o "${target}.elf" "${target}.o"
  "${AARCH64_TOOLCHAIN_PREFIX}objcopy" --set-start=0x0000000000000000 "${target}.elf" -O binary "${target}.img"
  # "${AARCH64_TOOLCHAIN_PREFIX}objcopy" --set-start=0xffff000000000000 "${target}.elf" -O binary "${target}.img"
  "${AARCH64_TOOLCHAIN_PREFIX}objdump" -d "${target}.elf" > "${target}.disassembly"
  "${AARCH64_TOOLCHAIN_PREFIX}readelf" -W -s "${target}.elf" > "${target}.symbols"
done
