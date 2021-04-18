#!/usr/bin/env bash
set -eu

# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

# This bash script builds spectrum4 kernel and places all files for SD card
# under 'dist' directory. To specify a custom toolchain for assembling/linking
# etc, export environment variable AARCH64_TOOLCHAIN_PREFIX.

# verify_and_show_tool checks that a given toolchain command is present on the
# filesystem and reports its location.
#
# Inputs:
#   $1: z80 or aarch64
#   $2: Human readable description of the tool, right-padded with spaces to 12 chars
#   $3: Executable name (excluding toolchain prefix, if AARCH64_TOOLCHAIN_PREFIX set)
function verify_and_show_tool {
  case "${1}" in
    z80)
      ENV_VAR='Z80_TOOLCHAIN_PREFIX'
      PREFIX="${Z80_TOOLCHAIN_PREFIX}"
      ;;
    aarch64)
      ENV_VAR='AARCH64_TOOLCHAIN_PREFIX'
      PREFIX="${AARCH64_TOOLCHAIN_PREFIX}"
      ;;
    *)
    echo "ERROR: Invalid architecture specified: '${1}'. Must be 'z80' or 'aarch64'. Exiting." >&2
    exit 66
    ;;
  esac
  if ! which "${PREFIX}${3}" >/dev/null; then
    echo "ERROR: Cannot find '${PREFIX}${3}' in PATH. Have you set ${ENV_VAR} appropriately? Alternatively, to build under docker, run docker.sh script instead. Exiting." >&2
    exit 64
  fi
  echo "  ${2}  $(which ${PREFIX}${3})" >&2
}

# show_active_toolchain verifies that all required toolchain binaries are
# present and logs the file location of each of them.
#
# Inputs:
#   $1: z80 or aarch64
function show_active_toolchain {
  verify_and_show_tool "${1}" "${1} Assembler:  " as
  verify_and_show_tool "${1}" "${1} Linker:     " ld
  verify_and_show_tool "${1}" "${1} Read ELF:   " readelf
  verify_and_show_tool "${1}" "${1} Object copy:" objcopy
  verify_and_show_tool "${1}" "${1} Object dump:" objdump
}

# fetch_firmware downloads standard Raspberry Pi firmware files from the
# Rasperry Pi Foundation github repository into subdirectories under
# dist/aarch64.
function fetch_firmware {
  find dist/aarch64 -maxdepth 1 -mindepth 1 -type d | while read subdir; do
    if [ -f "${subdir}/${1}" ]; then
      echo "Keeping cached version of '${subdir}/${1}'. To fetch a newer version, delete it and rerun all.sh."
    else
      echo "Fetching ${subdir}/${1} from github.com/raspberrypi/firmware..."
      curl -# -L "https://github.com/raspberrypi/firmware/blob/master/boot/${1}?raw=true" > "${subdir}/${1}"
    fi
  done
}

function check_dependencies {
  echo "Checking system dependencies..."
  for command in "${@}"; do
    if ! which "${command}" >/dev/null; then
      echo -e "  \xE2\x9D\x8C ${command}"
      echo "${0} requires ${command} to be installed and available in your PATH - please fix and rerun" >&2
      exit 65
    else
      echo -e "  \xE2\x9C\x94 ${command}"
    fi
  done
}

# Technically, checks for 'bash' and 'env' aren't really needed, since if this
# is running, they are installed - however, in case this list is copied around,
# good to include them as required tools...
check_dependencies bash cat cmp cp curl dirname env find fuse go head hexdump mkdir mv rm sed sleep sort wc which

echo

# Set default aarch64 toolchain prefix to `aarch64-none-elf-` if no
# AARCH64_TOOLCHAIN_PREFIX already set. Note, if no prefix is required,
# AARCH64_TOOLCHAIN_PREFIX should be explicitly set to the empty string before
# calling this script (e.g. using `export AARCH64_TOOLCHAIN_PREFIX=''`).
if [ "${AARCH64_TOOLCHAIN_PREFIX+_}" != '_' ]; then
  AARCH64_TOOLCHAIN_PREFIX=aarch64-none-elf-
  echo "No AARCH64_TOOLCHAIN_PREFIX specified, therefore using default toolchain prefix '${AARCH64_TOOLCHAIN_PREFIX}':" >&2
  show_active_toolchain aarch64
else
  echo "AARCH64_TOOLCHAIN_PREFIX specified: '${AARCH64_TOOLCHAIN_PREFIX}':" >&2
  show_active_toolchain aarch64
fi

echo

# Set default z80 toolchain prefix to `z80-unknown-elf-` if no
# Z80_TOOLCHAIN_PREFIX already set. Note, if no prefix is required,
# Z80_TOOLCHAIN_PREFIX should be explicitly set to the empty string before
# calling this script (e.g. using `export Z80_TOOLCHAIN_PREFIX=''`).
if [ "${Z80_TOOLCHAIN_PREFIX+_}" != '_' ]; then
  Z80_TOOLCHAIN_PREFIX=z80-unknown-elf-
  echo "No Z80_TOOLCHAIN_PREFIX specified, therefore using default toolchain prefix '${Z80_TOOLCHAIN_PREFIX}':" >&2
  show_active_toolchain z80
else
  echo "Z80_TOOLCHAIN_PREFIX specified: '${Z80_TOOLCHAIN_PREFIX}':" >&2
  show_active_toolchain z80
fi

echo

# Change into directory containing this script (in case the script is executed
# from a different directory).
cd "$(dirname "${0}")"

# Remove any previous build artifacts, and ensure build directory exists.
rm -rf build
mkdir -p build/z80
mkdir -p build/aarch64

# Generate src/profiles/debug/sysvars.s
SYSVARS="$(cat src/all.s | sed -n '/sysvars:/,/sysvars_end:/p' | sed 's/#.*//' | sed -n 's/^ *\([^ ]*\): *\.space \([^ ]*\) .*$/\1 \2/p')"
SYSVAR_COUNT=$(echo "${SYSVARS}" | wc -l)
{
echo '# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

# This file is auto-generated by all.sh. DO NOT EDIT!

.set SYSVAR_COUNT, '"$(printf '%-10s' $SYSVAR_COUNT)"'           // number of system variables

.data


.align 3
sysvars_meta:'
echo "${SYSVARS}" | while read sysvar size; do
  echo "  .quad sysvar_${sysvar}"
done

echo "${SYSVARS}" | while read sysvar size; do
  echo ""
  echo ""
  echo ".align 3"
  echo "sysvar_${sysvar}:"
  x="  .quad ${sysvar}-sysvars                            "
  y="  .byte ${size}                                      "
  z="  .asciz \"${sysvar}\"                               "
  echo "${x:0:42}// sysvar address offset"
  echo "${y:0:42}// size in bytes"
  echo "${z:0:42}// name"
done
} > src/profiles/debug/sysvars.s

# Generate unit tests as part of debug profile
{
echo '# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

# This file is auto-generated by all.sh. DO NOT EDIT!

'
routines="$(find src/profiles/debug -maxdepth 1 -name 'test_*.s' | sed 's/.*\/test_//' | sed 's/\.s$//' | sort)"
echo "${routines}" | while read routine; do
  echo ".include \"test_${routine}.s\""
done
all_labels="$(cat src/profiles/debug/test_*.s | sed -n 's/^[[:space:]]*\([^#[:space:]]*\):.*/\1/p')"
all_tests="$({
  echo "${all_labels}" | sed -n 's/_setup$//p'
  echo "${all_labels}" | sed -n 's/_setup_regs$//p'
  echo "${all_labels}" | sed -n 's/_effects$//p'
  echo "${all_labels}" | sed -n 's/_effects_regs$//p'
} | sort -u)"
echo '

.text
.align 3
all_tests:
  .quad' $(echo "${all_tests}" | wc -l)
echo "${routines}" | sed 's/^/  .quad test_/'
echo "${routines}" | while read routine; do
  labels="$(cat src/profiles/debug/test_${routine}.s | sed -n 's/^[[:space:]]*\([^#[:space:]]*\):.*/\1/p')"
  tests="$({
    echo "${labels}" | sed -n 's/_setup$//p'
    echo "${labels}" | sed -n 's/_setup_regs$//p'
    echo "${labels}" | sed -n 's/_effects$//p'
    echo "${labels}" | sed -n 's/_effects_regs$//p'
  } | sort -u)"
  echo "

.align 3
test_${routine}:
  .quad" $(echo "${tests}" | wc -l) "
  .quad ${routine}"
  echo "${tests}" | while read t; do
    echo "  .quad ${t}"
  done
  echo "${tests}" | while read t; do
    echo "

.align 3
${t}:"
    for suffix in _{setup,effects}{,_regs}; do
      if [ -n "$(echo "${labels}" | sed -n "s/^${t}${suffix}$/&/p")" ]; then
        echo "  .quad ${t}${suffix}"
      else
        echo "  .quad 0"
      fi
    done
    echo "  .asciz \"${t}\""
  done
done
} > src/profiles/debug/tests.s

# Format assembly source code - for now this just means stripping trailing whitespace from lines
find . \( -name '*.s' -o -name '*.asm' \) | while read sourcefile; do
  cat "${sourcefile}" | sed 's/  *$//' > x
  if ! cmp "${sourcefile}" x >/dev/null; then
    echo "WARNING: Stripping trailing whitespace from lines in ${sourcefile}..."
    cat x > "${sourcefile}"
  fi
  rm x
done

# Ensure dist/aarch64 directory exists, leaving in place if already there from previous
# run.
mkdir -p dist/aarch64

# Assemble `src/all.s` to `build/aarch64/all.o`
"${AARCH64_TOOLCHAIN_PREFIX}as" -I src -I src/profiles/debug -o "build/aarch64/debug.o" "src/all.s"
"${AARCH64_TOOLCHAIN_PREFIX}as" -I src -I src/profiles/release -o "build/aarch64/release.o" "src/all.s"

# Link binaries that were previously assembled. Options passed to the linker
# are:
#   -N: don't page align sections, to save space in generated elf file. Having
#       sections page aligned is only useful when directly executing the file,
#       but we don't execute the elf file, we extract the kernel binary from
#       it. Also do not make text section read only. Not sure why I chose this
#       instead of -n since I guess this effects .elf file but not .img file?
#   -M: display kernel map
#   -Ttext: address of text section
#   -o: elf file to generate
"${AARCH64_TOOLCHAIN_PREFIX}ld" --fix-cortex-a53-835769 --fix-cortex-a53-843419 -N -Ttext=0x0 -o build/aarch64/kernel8-debug.elf  build/aarch64/debug.o
"${AARCH64_TOOLCHAIN_PREFIX}ld" --fix-cortex-a53-835769 --fix-cortex-a53-843419 -N -Ttext=0x0 -M -o build/aarch64/kernel8-release.elf  build/aarch64/release.o

# Copy static files from this repo into subdirectories under aarch64/dist that
# are needed on SD card.
find dist/aarch64 -mindepth 1 -maxdepth 1 -type d | while read subdir; do
  cp src/config.txt "${subdir}"
  cp LICENCE "${subdir}/LICENCE.spectrum4"
done

# Download required firmware files into dist/aarch64 subdirectories from
# Raspberry Pi Foundation firmware github repository. Skip files that have
# already been downloaded from previous run. Download the latest version from
# the master branch.
#
# It is safe to remove the `dist/aarch64` directory if you wish to force downloading
# the firmware files again.
fetch_firmware 'LICENCE.broadcom'
fetch_firmware 'bootcode.bin'
fetch_firmware 'fixup.dat'
fetch_firmware 'start.elf'

# Extract the final kernel binaries into dist/aarch64 subdirectories as
# kernel8.img.
"${AARCH64_TOOLCHAIN_PREFIX}objcopy" --set-start=0x0 build/aarch64/kernel8-debug.elf -O binary dist/aarch64/debug/kernel8.img
"${AARCH64_TOOLCHAIN_PREFIX}objcopy" --set-start=0x0 build/aarch64/kernel8-release.elf -O binary dist/aarch64/release/kernel8.img

# Log disassembly of generated raw binary dist/aarch64/debug/kernel8.img to aid
# sanity checking.
# "${AARCH64_TOOLCHAIN_PREFIX}objdump" -b binary -z --adjust-vma=0x0 -maarch64 -D dist/aarch64/debug/kernel8.img

# Log disassembly of kernel elf file. This is like above, but additionally
# contains symbol names, etc.
"${AARCH64_TOOLCHAIN_PREFIX}objdump" -d build/aarch64/kernel8-debug.elf

# Log some useful information about the generated elf file. Options are:
#   -W: Allow width > 80, i.e. display full symbol names
"${AARCH64_TOOLCHAIN_PREFIX}readelf" -W -a build/aarch64/kernel8-debug.elf

# Keep a record of which functions call other functions to ease writing tests
# TODO: need to fix this to work with new tests
FN_CALLS=$("${AARCH64_TOOLCHAIN_PREFIX}objdump" -d build/aarch64/kernel8-release.elf | sed -n '1,${;s/.*[[:space:]]bl*[[:space:]].*/&/p;s/.*<.*>:$/&/p;}' | sed '/msg_/d' | sed '/<test_/d' | sed 's/[^ ].*</</' | sed 's/<//g' | sed 's/>//g' | sed 's/^  */    /' | sed '/+/d')
while read ymlfile; do
  FN_CALLS="$(echo "${FN_CALLS}" | sed "/^    ${ymlfile}\$/d" | sed "/^${ymlfile}:\$/d")"
done < <(find test -maxdepth 1 -name '*.yml' | sed -n 's/^test\/\(.*\)\.yml$/\1/p')
echo "${FN_CALLS}" > test/fn_calls.txt

# Ensure dist/z80 directory exists, leaving in place if already there from previous
# run.
mkdir -p dist/z80

# The z80 build process is run twice - the first time with the following static
# "random" data, and then again with random data generated dynamically from
# /dev/urandom. This first build is used for generating the checked in binaries
# (runtests.elf / runtests.img / runtests.tzx). The second version is used for
# running the FUSE tests below.
#
# The idea here is to work around the limitation that the Spectrum 128K has no
# means to generate cryptographically secure random data, and therefore instead
# to inject the random data at build time. However, we don't want to check in
# the binary versions with random data since they would change with every
# build, and thus we check in the version with static data.

{
  echo '# This file is part of the Spectrum +4 Project.'
  echo '# Licencing information can be found in the LICENCE file'
  echo '# (C) 2019 Spectrum +4 Authors. All rights reserved.'
  echo ''
  echo '# This file is auto-generated by all.sh. DO NOT EDIT!'
  echo ''
  echo '.text'
  echo ''
  echo 'random_data:'
  echo '  .byte 0xbc, 0x8d, 0x55, 0xe6, 0xe2, 0x89, 0x26, 0xef, 0xcd, 0xa7, 0x4b, 0xa0, 0x8b, 0x6a, 0x8c, 0x2b'
  echo '  .byte 0x09, 0x14, 0x4d, 0x8d, 0xfe, 0x72, 0x35, 0xb7, 0xdd, 0xfb, 0x1c, 0x52, 0xd4, 0x0d, 0xf2, 0xa4'
  echo '  .byte 0x36, 0xec, 0x51, 0x66, 0xb4, 0x8b, 0x20, 0xbd, 0xe0, 0xc2, 0xcf, 0x57, 0x85, 0x1b, 0x54, 0xe9'
  echo '  .byte 0xfc, 0x28, 0x7a, 0xaf, 0xdb, 0x44, 0x24, 0xcd, 0xd0, 0xed, 0xe7, 0x08, 0x4e, 0xb2, 0xdb, 0x1e'
} > zxtest/randomdata.asm

# Assemble and link Spectrum 128K unit tests for running under FUSE.
"${Z80_TOOLCHAIN_PREFIX}as" -I zxtest -o "build/z80/runtests.o" "zxtest/runtests.asm"
"${Z80_TOOLCHAIN_PREFIX}ld" -N -Ttext=0x8000 -o build/z80/runtests.elf  build/z80/runtests.o

# Extract Spectrum 128K unit tests from ELF binary
"${Z80_TOOLCHAIN_PREFIX}objcopy" --set-start=0x8000 build/z80/runtests.elf -O binary build/z80/runtests.img

# Log disassembly of kernel elf file.
"${Z80_TOOLCHAIN_PREFIX}objdump" -d build/z80/runtests.elf

# Log some useful information about the generated elf file. Options are:
#   -W: Allow width > 80, i.e. display full symbol names
"${Z80_TOOLCHAIN_PREFIX}readelf" -W -a build/z80/runtests.elf

# Determine which address holds the Spectrum output channel number for the test output.
channel_address=$((0x$("${Z80_TOOLCHAIN_PREFIX}readelf" -W -a build/z80/runtests.elf | sed -n '/ channel_assign$/s/.*: \([0-9a-f]*\).*/\1/p') + 1))

# Create tzx file for running Spectrum 128K ROM tests under FUSE.
#
# See:
#   * http://k1.spdns.de/Develop/Projects/zasm/Info/TZX%20format.html
#   * https://faqwiki.zxnet.co.uk/wiki/Spectrum_tape_interface
#   * https://github.com/shred/tzxtools/blob/b4ad524c82f60100b7e06d74194eeb068adb859e/tzxlib/convert.py
go run test/tzx-code-loader/main.go build/z80/runtests.img dist/z80/runtests.tzx 32768 "${channel_address}" 2 runtests.b tests 1000

# Do everything again, but this time with real random data (see comments above).
{
  cat zxtest/randomdata.asm | sed -n '1,/^random_data:$/p'
  head -c 64 /dev/urandom | hexdump -v -e '"  .byte " 16/1 "0x%02x, " "\n"' | sed 's/,$//'
} > tmp.randomdata.asm
mv tmp.randomdata.asm zxtest/randomdata.asm
"${Z80_TOOLCHAIN_PREFIX}as" -I zxtest -o "build/z80/tmp.runtests.o" "zxtest/runtests.asm"
"${Z80_TOOLCHAIN_PREFIX}ld" -N -Ttext=0x8000 -o build/z80/tmp.runtests.elf  build/z80/tmp.runtests.o
"${Z80_TOOLCHAIN_PREFIX}objcopy" --set-start=0x8000 build/z80/tmp.runtests.elf -O binary build/z80/tmp.runtests.img
go run test/tzx-code-loader/main.go build/z80/tmp.runtests.img dist/z80/tmp.runtests.tzx 32768 "${channel_address}" 3 runtests.b tmp.tests 1000

echo
echo "Build successful - see dist directory for results"


# Run tests

echo > printout.txt

fuse --machine 128 --no-sound --zxprinter --printer --tape dist/z80/tmp.runtests.tzx --auto-load --no-autosave-settings >/dev/null 2>&1 &

fuse_pid=$!
disown
max_attempts=3
attempts=0

until [ "$(cat printout.txt | sed -n '/All tests completed./p' | wc -l)" -gt 0 ] || [ "${attempts}" -eq "${max_attempts}" ]; do
  attempts=$((attempts+1))
  sleep 1
done

kill -9 "${fuse_pid}" >/dev/null 2>&1
cat printout.txt
rm printout.txt

if [ "${attempts}" -eq "${max_attempts}" ]; then
  echo 'Timed out!' >&2
  exit 64
fi
