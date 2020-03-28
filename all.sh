#!/bin/bash -eu

# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

# This bash script builds spectrum4 kernel and places all files for SD card
# under 'dist' directory. To specify a custom toolchain for assembling/linking
# etc, export environment variable TOOLCHAIN_PREFIX.

# verify_and_show_tool checks that a given toolchain command is present on the
# filesystem and reports its location.
#
# Inputs:
#   $1: Human readable description of the tool, right-padded with spaces to 12 chars
#   $2: Executable name (excluding toolchain prefix, if TOOLCHAIN_PREFIX set)
function verify_and_show_tool {
  if ! which "${TOOLCHAIN_PREFIX}${2}" >/dev/null; then
    echo "ERROR: Cannot find '${TOOLCHAIN_PREFIX}${2}' in PATH. Have you set TOOLCHAIN_PREFIX appropriately? Exiting." >&2
    exit 64
  fi
  echo "  ${1}  $(which ${TOOLCHAIN_PREFIX}${2})" >&2
}

# show_active_toolchain verifies that all required toolchain binaries are
# present and logs the file location of each of them.
function show_active_toolchain {
  verify_and_show_tool "Assembler:  " as
  verify_and_show_tool "Linker:     " ld
  verify_and_show_tool "Read ELF:   " readelf
  verify_and_show_tool "Object copy:" objcopy
  verify_and_show_tool "Object dump:" objdump
}

# fetch_firmware downloads standard Raspberry Pi firmware files from the
# Rasperry Pi Foundation github repository into the dist directory.
function fetch_firmware {
  if [ -f "dist/${1}" ]; then
    echo "Keeping cached version of 'dist/${1}'. To fetch a newer version, delete it and rerun all.sh."
  else
    echo "Fetching dist/${1} from github.com/raspberrypi/firmware..."
    curl -# -L "https://github.com/raspberrypi/firmware/blob/master/boot/${1}?raw=true" > "dist/${1}"
  fi
}

# Set default toolchain prefix to `aarch64-none-elf-` if no TOOLCHAIN_PREFIX
# already set. Note, if no prefix is required, TOOLCHAIN_PREFIX should be
# explicitly set to the empty string before calling this script (e.g. using
# `export TOOLCHAIN_PREFIX=''`).
if [ "${TOOLCHAIN_PREFIX+_}" != '_' ]; then
  TOOLCHAIN_PREFIX=aarch64-none-elf-
  echo "No TOOLCHAIN_PREFIX specified, therefore using default toolchain prefix '${TOOLCHAIN_PREFIX}':" >&2
  show_active_toolchain
else
  echo "TOOLCHAIN_PREFIX specified: '${TOOLCHAIN_PREFIX}':" >&2
  show_active_toolchain
fi

# Change into directory containing this script (in case the script is executed
# from a different directory).
cd "$(dirname "${0}")"

# Remove any previous build artifacts, and ensure build directory exists.
rm -rf build
mkdir build

# Assemble `src/all.s` to `build/all.o`
"${TOOLCHAIN_PREFIX}as" -o "build/all.o" "src/all.s"

# Ensure dist directory exists, leaving in place if already there from previous
# run.
mkdir -p dist

# Copy static files from this repo into dist directory that are needed on SD
# card.
cp src/config.txt dist
cp LICENCE dist/LICENCE.spectrum4

# Download required firmware files into dist directory from Raspberry Pi
# Foundation firmware github repository. Skip files that have already been
# downloaded from previous run. Download the latest version from the master
# branch.
#
# It is safe to remove the `dist` directory if you wish to force downloading
# the firmware files again.
fetch_firmware 'LICENCE.broadcom'
fetch_firmware 'bootcode.bin'
fetch_firmware 'fixup.dat'
fetch_firmware 'start.elf'

# Link binaries that were previously assembled. Options passed to the linker
# are:
#   -n: don't page align sections, to save space in generated elf file. Having
#       sections page aligned is only useful when directly executing the file,
#       but we don't execute the elf file, we extract the kernel binary from
#       it.
#   -M: display kernel map
#   -T: specifies linker script to use
#   -o: elf file to generate
"${TOOLCHAIN_PREFIX}ld" -N -Ttext=0x80000 -M -o build/kernel8.elf  build/*.o

# Log some useful information about the generated elf file.
"${TOOLCHAIN_PREFIX}readelf" -a build/kernel8.elf

# Extract the final kernel raw binary into file dist/kernel8.img
"${TOOLCHAIN_PREFIX}objcopy" --set-start=0x80000 build/kernel8.elf -O binary dist/kernel8.img

# Log disassembly of generated raw binary dist/kernel8.img to aid sanity
# checking.
# "${TOOLCHAIN_PREFIX}objdump" -b binary -z --adjust-vma=0x80000 -maarch64 -D dist/kernel8.img

# Log disassembly of kernel elf file. This is like above, but additionally
# contains symbol names, etc.
"${TOOLCHAIN_PREFIX}objdump" -d build/kernel8.elf

echo
echo "Build successful"
