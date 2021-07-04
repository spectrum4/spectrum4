#!/usr/bin/env bash

# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.


#####################################################################################

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

set -eu
set -o pipefail
export SHELLOPTS

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
    echo "${SPECTRUM4_SCRIPT}: Invalid architecture specified: '${1}'. Must be 'z80' or 'aarch64'. Exiting." >&2
    exit 66
    ;;
  esac
  if ! which "${PREFIX}${3}" >/dev/null; then
    echo "${SPECTRUM4_SCRIPT}: Cannot find '${PREFIX}${3}' in PATH. Have you set ${ENV_VAR} appropriately? Alternatively, to build under docker, run docker.sh script instead. Exiting." >&2
    exit 64
  fi
  verbose "  ${2}  $(which ${PREFIX}${3})" >&2
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
# dist/spectrum4.
function fetch_firmware {
  find dist/spectrum4 -maxdepth 1 -mindepth 1 -type d | while read subdir; do
    if [ -f "${subdir}/${1}" ]; then
      verbose "Keeping cached version of '${subdir}/${1}'. To fetch a newer version, delete it and rerun all.sh."
    else
      echo "Fetching ${subdir}/${1} from github.com/raspberrypi/firmware..."
      curl -# -L "https://github.com/raspberrypi/firmware/blob/master/boot/${1}?raw=true" > "${subdir}/${1}"
    fi
  done
}

function check_dependencies {
  verbose "Checking system dependencies..."
  for command in "${@}"; do
    if ! which "${command}" >/dev/null; then
      echo -e "  \xE2\x9D\x8C ${command}"
      echo "${SPECTRUM4_SCRIPT}: ${command} must be installed and available in your PATH" >&2
      exit 65
    else
      verbose -e "  \x1b\x5b\x33\x32\x6d\xe2\x9c\x93\x1b\x5b\x30\x6d ${command}"
    fi
  done
}

function run_tests {
  local func="${1}"
  local binary="${2}"
  local output_file="${3}"
  local timeoutexitcode="${4}"
  local failuresexitcode="${5}"
  local max_attempts="${6}"

  binary_md5="$(md5sum "${binary}" | sed 's/ .*//')"
  cache_file="cache/${binary_md5}"
  local attempts=0

  if [ -f "${cache_file}" ]; then
    echo "Found cached test results in ${cache_file}:"
  else
    "${func}"
    local pid=$!
    disown

    until [ "$(cat "${output_file}" | sed -n '/All tests completed./p' | wc -l)" -gt 0 ] \
      || [ "$(cat "${output_file}" | sed -n '/Test failures!/p' | wc -l)" -gt 0 ] \
      || [ "$(cat "${output_file}" | sed -n '/No tests to run./p' | wc -l)" -gt 0 ] \
      || [ "$(cat "${output_file}" | sed -n '/FATAL: Out of space/p' | wc -l)" -gt 0 ] \
      || [ "${attempts}" -eq "${max_attempts}" ]; do
      attempts=$((attempts+1))
      sleep 1
    done

    kill -9 "${pid}" >/dev/null 2>&1

    mv "${output_file}" "${cache_file}"
  fi

  failure_count="$(cat "${cache_file}" | sed -n '/^FAIL:/p' | wc -l)"
  local failed='false'
  if [ "${attempts}" -eq "${max_attempts}" ] || \
     [ "${failure_count}" -gt 0 ] || \
     [ "$(cat "${cache_file}" | sed -n '/FATAL: Out of space/p' | wc -l)" -gt 0 ] || \
     [ "$(cat "${cache_file}" | sed -n '/Test failures!/p' | wc -l)" -gt 0 ] || \
     ( \
       [ "$(cat "${cache_file}" | sed -n '/All tests completed./p' | wc -l)" -eq 0 ] && \
       [ "$(cat "${cache_file}" | sed -n '/No tests to run./p' | wc -l)" -eq 0 ] \
     ); then
    failed='true'
  fi

  cat "${cache_file}" | sed -n '1,/All tests completed./p' | sed 's/^/  /'

  if [ "${attempts}" -eq "${max_attempts}" ]; then
    echo "${SPECTRUM4_SCRIPT}:" 'Timed out!' >&2
    exit "${timeoutexitcode}"
  fi

  if "${failed}"; then
    echo "${SPECTRUM4_SCRIPT}: Test failures"
    exit "${failuresexitcode}"
  fi
}

function generate_unit_tests {
  local srcdir="${1}"
  local ptrunit="${2}"
  local ptralignstr="${3}"
  local routines="${4}"
  local bashflags="${-}"
  set +x
  echo "# This file is part of the Spectrum +4 Project."
  echo "# Licencing information can be found in the LICENCE file"
  echo "# (C) 2021 Spectrum +4 Authors. All rights reserved."
  echo
  echo "# Extrapolated from /${srcdir}/test_*.s files."
  if [ -z "${routines}" ]; then
    routines="$(find "${srcdir}" -maxdepth 1 -name 'test_*.s' | sed 's/.*\/test_//' | sed 's/\.s$//' | sort)"
  fi
  echo
  echo "# This file is auto-generated by ${0##*/}." 'DO NOT EDIT!'
  if [ -n "${routines}" ]; then
    echo
    echo
    echo "${routines}" | while read routine; do
      echo ".include \"test_${routine}.s\""
    done
  fi
  echo
  echo
  echo ".text"
  echo -n "${ptralignstr}"
  echo "all_suites:"
  all_suites=""
  if [ -n "${routines}" ]; then
    all_labels="$(echo "${routines}" | while read routine; do cat "${srcdir}/test_${routine}.s"; done | sed -n 's/^[[:space:]]*\([^#[:space:]]*\):.*/\1/p')"
    all_suites="$({
      echo "${all_labels}" | sed -n 's/_setup$//p'
      echo "${all_labels}" | sed -n 's/_setup_regs$//p'
      echo "${all_labels}" | sed -n 's/_effects$//p'
      echo "${all_labels}" | sed -n 's/_effects_regs$//p'
    } | sort -u)"
  fi
  if [ -n "${all_suites}" ]; then
    echo "  ${ptrunit}" $(echo "${all_suites}" | wc -l)
    echo "${routines//./_}" | sed "s/^/  ${ptrunit} suite_/"
    echo "${routines}" | while read routine; do
      labels="$(cat "${srcdir}/test_${routine}.s" | sed -n 's/^[[:space:]]*\([^#[:space:]]*\):.*/\1/p')"
      tests="$({
        echo "${labels}" | sed -n 's/_setup$//p'
        echo "${labels}" | sed -n 's/_setup_regs$//p'
        echo "${labels}" | sed -n 's/_effects$//p'
        echo "${labels}" | sed -n 's/_effects_regs$//p'
      } | sort -u)"
      echo
      echo
      echo -n "${ptralignstr}"
      echo "suite_${routine//./_}:"
      echo "  ${ptrunit}" $(echo "${tests}" | wc -l)
      echo "  ${ptrunit} ${routine%%.*}"
      echo "${tests}" | while read t; do
        echo "  ${ptrunit} test_${t}"
      done
      echo "${tests}" | while read t; do
        echo
        echo
        echo -n "${ptralignstr}"
        echo "test_${t}:"
        for suffix in _{setup,effects}{,_regs}; do
          if [ -n "$(echo "${labels}" | sed -n "s/^${t}${suffix}$/&/p")" ]; then
            echo "  ${ptrunit} ${t}${suffix}"
          else
            echo "  ${ptrunit} 0"
          fi
        done
        echo "  .asciz \"${t}\""
      done
    done
  else
    echo "  ${ptrunit} 0"
  fi
  if [ "${bashflags/x/-}" != "${bashflags}" ]; then set -x; fi
}

function format-asm {
  local dir="${1}"
  find "${dir}" -type f -name '*.s' | while read asm_file; do
    cat "${asm_file}" | go run utils/asm-format/main.go > "${asm_file}.cleaned"
    if ! cmp "${asm_file}" "${asm_file}.cleaned" >/dev/null; then
      cat "${asm_file}.cleaned" > "${asm_file}"
    fi
    rm "${asm_file}.cleaned"
  done
}

function randomdata-header {
  echo '# This file is part of the Spectrum +4 Project.'
  echo '# Licencing information can be found in the LICENCE file'
  echo '# (C) 2021 Spectrum +4 Authors. All rights reserved.'
  echo ''
  echo "# This file is auto-generated by ${0##*/}." 'DO NOT EDIT!'
  echo ''
  echo '.text'
  echo ''
  echo 'random_data:'
}

function fuse-tests {
  echo -n > printout.txt
  fuse --speed 100000 --machine 128 --no-sound --zxprinter --printer --tape "dist/spectrum128k/runtests-cryptorandom_${routine}.tzx" --auto-load --no-autosave-settings >fuse_log.txt 2>&1 &
}

function qemu-tests {
  qemu-system-aarch64 -M raspi3b -kernel build/spectrum4/kernel8-qemu-debug.elf -serial null -serial stdio >serial.txt 2>&1 &
}

function split {
  if "${REPORT_DURATIONS}"; then
    echo -n "${1}: "
    eval $(go run utils/split/main.go)
  fi
}

function verbose {
  ! "${VERBOSE}" || echo "${@}"
}

function cleanup {
  (cat fuse_log.txt 2>/dev/null || true) | sed 's/^/fuse_log.txt: /'
}

trap cleanup EXIT



################### Entry point ###################

# For consistent behaviour of `sort`, etc
if which uname >/dev/null && test "$(uname -s)" == 'Darwin'; then
  export LANG='C'
  export LC_CTYPE='UTF-8'
else
  export LC_ALL='C.UTF-8'
fi

# SPECTRUM4_SCRIPT is either `all.sh` or `docker.sh` depending on which was called by user.
: ${SPECTRUM4_SCRIPT:="${0##*/}"}

# Change into directory containing this script (in case the script is executed
# from a different directory).
cd "$(dirname "${0}")"

# Set default values, that may be overwritten by parameters passed to script
VERBOSE=false
REPORT_DURATIONS=false
SKIP_GENERATION=false
Z80_TEST_LIST=""
SP4_TEST_LIST=""

# Read parameters passed to script
while getopts ":dghtvy:z:" opt; do
  case "${opt}" in
    d)
      set -x
      ;;
    g) SKIP_GENERATION=true
       ;;
    h)
      echo "${SPECTRUM4_SCRIPT} builds and tests all the code of the Spectrum +4 project."
      echo "Usage:"
      echo "  ${SPECTRUM4_SCRIPT} [-h]"
      echo "  ${SPECTRUM4_SCRIPT} [-d][-g][-t][-v][-y SP4_TEST_LIST][-z 128K_TEST_LIST]"
      echo "Options:"
      echo "  -d                    Log executed commands (set -x)."
      echo "  -g                    Skip code generation and formatting."
      echo "  -h                    Show help."
      echo "  -t                    Report duration that each step takes."
      echo "  -v                    Verbose output."
      echo "  -y SP4_TEST_LIST      Only run Spectrum +4 tests from files"
      echo "                        src/spectrum4/test_<SP4_TEST>.s where"
      echo "                        SP4_TEST_LIST is a comma separated list"
      echo "                        (without spaces) of values for <SP4_TEST>."
      echo "  -z 128K_TEST_LIST     Only run Spectrum 128K tests from files"
      echo "                        src/spectrum128k/test_<128K_TEST>.s where"
      echo "                        128K_TEST_LIST is a comma separated list"
      echo "                        (without spaces) of values for <128K_TEST>."
      exit 0
      ;;
    t)
      REPORT_DURATIONS=true
      ;;
    v)
      VERBOSE=true
      ;;
    y)
      SP4_TEST_LIST="$(echo "${OPTARG}" | sed 'y/,/\n/')"
      ;;
    z)
      Z80_TEST_LIST="$(echo "${OPTARG}" | sed 'y/,/\n/')"
      ;;
    *)
      echo "${SPECTRUM4_SCRIPT}: Invalid argument specified: '-${OPTARG}'" >&2
      exit 71
      ;;
  esac
done

split "Start"

# Technically, checks for 'bash' and 'env' aren't really needed, since if this
# is running, they are installed - however, in case this list is copied around,
# good to include them as required tools...
check_dependencies bash cat cmp cp curl dirname env find fuse go head hexdump md5sum mkdir mv qemu-system-aarch64 rm sed sleep sort tape2wav wc which
verbose

split "Checked dependencies"

# Remove any previous build artifacts, and ensure build directory exists.
rm -rf build



################### Spectrum +4 ###################


mkdir -p build/spectrum4

# Set default aarch64 toolchain prefix to `aarch64-none-elf-` if no
# AARCH64_TOOLCHAIN_PREFIX already set. Note, if no prefix is required,
# AARCH64_TOOLCHAIN_PREFIX should be explicitly set to the empty string before
# calling this script (e.g. using `export AARCH64_TOOLCHAIN_PREFIX=''`).
if [ "${AARCH64_TOOLCHAIN_PREFIX+_}" != '_' ]; then
  AARCH64_TOOLCHAIN_PREFIX=aarch64-none-elf-
  verbose "No AARCH64_TOOLCHAIN_PREFIX specified, therefore using default toolchain prefix '${AARCH64_TOOLCHAIN_PREFIX}':" >&2
  show_active_toolchain aarch64
else
  verbose "AARCH64_TOOLCHAIN_PREFIX specified: '${AARCH64_TOOLCHAIN_PREFIX}':" >&2
  show_active_toolchain aarch64
fi

verbose

split "Found toolchain"

# Generate Spectrum +4 unit tests
# No maxdepth limit to intentionally run passing_tests/test_*.sh files too
if ! "${SKIP_GENERATION}"; then
  find src/spectrum4 -type f -name 'test_*.sh' | while read testgenerator; do
    verbose "Generating Spectrum +4 tests: ${testgenerator}..."
    "${testgenerator}"
  done

  split "Generated +4 tests"

  verbose "Generating src/spectrum4/sysvars.s"
  SYSVARS="$(cat src/spectrum4/all.s | sed -n '/sysvars:/,/sysvars_end:/p' | sed 's/#.*//' | sed -n 's/^ *\([^ ]*\): *\.space \([^ ]*\) .*$/\1 \2/p')"
  SYSVAR_COUNT=$(echo "${SYSVARS}" | wc -l)
  {
  echo "# This file is part of the Spectrum +4 Project.
  # Licencing information can be found in the LICENCE file
  # (C) 2021 Spectrum +4 Authors. All rights reserved.

  # This file is auto-generated by ${0##*/}." 'DO NOT EDIT!

  .set SYSVAR_COUNT, '"$(printf '%-10s' $SYSVAR_COUNT)"'           // number of system variables

  .data


  .align 3
  sysvars_meta:' | sed 's/^  //'
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
  } > src/spectrum4/sysvars.s

  split "Generated sysvars"

  format-asm src/spectrum4

  split "Formatted +4 source code"
fi

echo "Building Spectrum +4..."

# Ensure dist/spectrum4/debug directory exists, leaving in place if already there from previous
# run.
mkdir -p dist/spectrum4/debug
mkdir -p dist/spectrum4/release

if ! "${SKIP_GENERATION}"; then
  # Include _specified tests_ in qemu-debug build that we will test later...
  generate_unit_tests src/spectrum4 .quad ".align 3
" "${SP4_TEST_LIST}" > src/spectrum4/tests.s

  split "Generated specified +4 unit tests"
fi

# Assemble `src/spectrum4/all.s` to `build/spectrum4/qemu-debug.o`
"${AARCH64_TOOLCHAIN_PREFIX}as" --defsym QEMU=1 -I src/spectrum4 -I src/spectrum4/profiles/debug -o "build/spectrum4/qemu-debug.o" "src/spectrum4/all.s"

split "Assembled +4 qemu-debug"


if ! "${SKIP_GENERATION}"; then
  # Include _all tests_ in debug build that doesn't run in QEMU...
  generate_unit_tests src/spectrum4 .quad ".align 3
" "" > src/spectrum4/tests.s

  split "Generated all +4 unit tests"
fi

# Assemble `src/spectrum4/all.s` to `build/spectrum4/{debug,release}.o`
"${AARCH64_TOOLCHAIN_PREFIX}as" -I src/spectrum4 -I src/spectrum4/profiles/debug -o "build/spectrum4/debug.o" "src/spectrum4/all.s"

split "Assembled +4 debug"

"${AARCH64_TOOLCHAIN_PREFIX}as" -I src/spectrum4 -I src/spectrum4/profiles/release -o "build/spectrum4/release.o" "src/spectrum4/all.s"

split "Assembled +4 release"

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
EXTRA_ARGS=""
if "${VERBOSE}"; then
  EXTRA_ARGS="-M"
fi
"${AARCH64_TOOLCHAIN_PREFIX}ld" --fix-cortex-a53-835769 --fix-cortex-a53-843419 -N -Ttext=0x0 -o build/spectrum4/kernel8-debug.elf build/spectrum4/debug.o
"${AARCH64_TOOLCHAIN_PREFIX}ld" --fix-cortex-a53-835769 --fix-cortex-a53-843419 -N -Ttext=0x0 -o build/spectrum4/kernel8-qemu-debug.elf build/spectrum4/qemu-debug.o
"${AARCH64_TOOLCHAIN_PREFIX}ld" --fix-cortex-a53-835769 --fix-cortex-a53-843419 -N -Ttext=0x0 -o build/spectrum4/kernel8-release.elf ${EXTRA_ARGS} build/spectrum4/release.o

split "Linked +4 release/qemu-debug/debug"

# Copy static files from this repo into subdirectories under aarch64/dist that
# are needed on SD card.
find dist/spectrum4 -mindepth 1 -maxdepth 1 -type d | while read subdir; do
  cp src/spectrum4/config.txt "${subdir}"
  cp LICENCE "${subdir}/LICENCE.spectrum4"
done

split "Copied static files to dist/spectrum4/*/"

# Download required firmware files into dist/spectrum4 subdirectories from
# Raspberry Pi Foundation firmware github repository. Skip files that have
# already been downloaded from previous run. Download the latest version from
# the master branch.
#
# It is safe to remove the `dist/spectrum4` directory if you wish to force downloading
# the firmware files again.
fetch_firmware 'LICENCE.broadcom'
fetch_firmware 'bootcode.bin'
fetch_firmware 'fixup.dat'
fetch_firmware 'start.elf'

split "Fetched firmware"

# Extract the final kernel binaries into dist/spectrum4 subdirectories as
# kernel8.img.
"${AARCH64_TOOLCHAIN_PREFIX}objcopy" --set-start=0x0 build/spectrum4/kernel8-debug.elf -O binary dist/spectrum4/debug/kernel8.img
echo -e "  \x1b\x5b\x33\x32\x6d\xe2\x9c\x93\x1b\x5b\x30\x6d dist/spectrum4/debug/kernel8.img"
"${AARCH64_TOOLCHAIN_PREFIX}objcopy" --set-start=0x0 build/spectrum4/kernel8-release.elf -O binary dist/spectrum4/release/kernel8.img
echo -e "  \x1b\x5b\x33\x32\x6d\xe2\x9c\x93\x1b\x5b\x30\x6d dist/spectrum4/release/kernel8.img"

# Log disassembly of generated raw binary dist/spectrum4/debug/kernel8.img to aid
# sanity checking.
# "${AARCH64_TOOLCHAIN_PREFIX}objdump" -b binary -z --adjust-vma=0x0 -maarch64 -D dist/spectrum4/debug/kernel8.img

if "${VERBOSE}"; then
  # Log disassembly of kernel elf file. This is like above, but additionally
  # contains symbol names, etc.
  "${AARCH64_TOOLCHAIN_PREFIX}objdump" -d build/spectrum4/kernel8-debug.elf

  # Log some useful information about the generated elf file. Options are:
  #   -W: Allow width > 80, i.e. display full symbol names
  "${AARCH64_TOOLCHAIN_PREFIX}readelf" -W -a build/spectrum4/kernel8-debug.elf
fi

split "logged stuff"

if ! "${SKIP_GENERATION}"; then
  bashflags="${-}"
  set +x
  # Keep a record of which functions call other functions to ease writing tests
  ROUTINES_WITHOUT_TESTS=$("${AARCH64_TOOLCHAIN_PREFIX}objdump" -d build/spectrum4/kernel8-release.elf | sed -n '1,${;s/.*[[:space:]]bl*[[:space:]].*/&/p;s/.*<.*>:$/&/p;}' | sed '/msg_/d' | sed '/<test_/d' | sed 's/[^ ].*</</' | sed 's/<//g' | sed 's/>//g' | sed 's/^  */    /' | sed '/+/d')
  while read testroutine; do
    ROUTINES_WITHOUT_TESTS="$(echo "${ROUTINES_WITHOUT_TESTS}" | sed "/^[[:space:]]*${testroutine}:*\$/d")"
  done < <(find src/spectrum4 -name 'test_*.s' | sed -n 's/^.*test_\([^.]*\).*\.s$/\1/p')
  echo "${ROUTINES_WITHOUT_TESTS}" > src/spectrum4/routines_without_tests.txt

  split "Updated src/spectrum4/routines_without_tests.txt"
  if [ "${bashflags/x/-}" != "${bashflags}" ]; then set -x; fi
fi

echo
echo "Running Spectrum +4 tests under QEMU..."
# Use the img file for the cache results since the elf file has variations based on the assembler
run_tests qemu-tests "dist/spectrum4/debug/kernel8.img" "serial.txt" 69 70 300

split "Ran +4 tests under QEMU"

################### Spectrum 128k ###################

echo
echo "Building Spectrum 128K ROMs..."

mkdir -p build/spectrum128k

# Set default z80 toolchain prefix to `z80-unknown-elf-` if no
# Z80_TOOLCHAIN_PREFIX already set. Note, if no prefix is required,
# Z80_TOOLCHAIN_PREFIX should be explicitly set to the empty string before
# calling this script (e.g. using `export Z80_TOOLCHAIN_PREFIX=''`).
if [ "${Z80_TOOLCHAIN_PREFIX+_}" != '_' ]; then
  Z80_TOOLCHAIN_PREFIX=z80-unknown-elf-
  verbose "No Z80_TOOLCHAIN_PREFIX specified, therefore using default toolchain prefix '${Z80_TOOLCHAIN_PREFIX}':" >&2
  show_active_toolchain z80
else
  verbose "Z80_TOOLCHAIN_PREFIX specified: '${Z80_TOOLCHAIN_PREFIX}':" >&2
  show_active_toolchain z80
fi

verbose

# Ensure dist/spectrum128k directory exists, leaving in place if already there from previous
# run.
mkdir -p dist/spectrum128k

# Assemble, link and extract Spectrum 128K ROMs

rom_md5s=(b4d2692115a9f2924df92a3cbfb358fb 6e09e5d3c4aef166601669feaaadc01c)

for ROM in 0 1; do
  "${Z80_TOOLCHAIN_PREFIX}as" -I src/spectrum128k -o "build/spectrum128k/rom${ROM}.o" "src/spectrum128k/rom${ROM}.s"
  "${Z80_TOOLCHAIN_PREFIX}ld" -N -Ttext=0x0 --unresolved-symbols=ignore-all -o "build/spectrum128k/rom${ROM}.elf" "build/spectrum128k/rom${ROM}.o"
done

for ROM in 0 1; do
  OTHER_ROM=$((1-ROM))
  "${Z80_TOOLCHAIN_PREFIX}ld" -N -Ttext=0x0 --allow-multiple-definition -R "build/spectrum128k/rom${OTHER_ROM}.elf" -o "build/spectrum128k/rom${ROM}.elf" "build/spectrum128k/rom${ROM}.o"
done

for ROM in 0 1; do
  "${Z80_TOOLCHAIN_PREFIX}objcopy" --set-start=0x0 "build/spectrum128k/rom${ROM}.elf" -O binary "dist/spectrum128k/rom${ROM}.img"
  echo -e "  \x1b\x5b\x33\x32\x6d\xe2\x9c\x93\x1b\x5b\x30\x6d dist/spectrum128k/rom${ROM}.img"

  if [ "$(md5sum dist/spectrum128k/rom${ROM}.img | sed 's/ .*//')" != "${rom_md5s[${ROM}]}" ]; then
    echo "Spectrum 128K ROM ${ROM} build has produced incorrect binary (md5sum dist/spectrum128k/rom${ROM}.img = $(md5sum dist/spectrum128k/rom${ROM}.img | sed 's/ .*//'))" >&2
    exit $((ROM+72))
  fi
done

split "Built 128k roms"

if ! "${SKIP_GENERATION}"; then
  # No maxdepth limit to intentionally run passing_tests/test_*.sh files too
  find src/spectrum128k -type f -name 'test_*.sh' | while read testgenerator; do
    verbose "Generating Spectrum 128K tests: ${testgenerator}..."
    "${testgenerator}"
  done

  split "Generated 128k tests"

  format-asm src/spectrum128k

  split "formatted 128k tests"
fi

# Calculate default Z80_TEST_LIST now that all tests have been generated...
if [ -z "${Z80_TEST_LIST}" ]; then
  Z80_TEST_LIST="$(find src/spectrum128k -maxdepth 1 -type f -name 'test_*.s' | sed 's/.*\/test_//' | sed 's/\.s$//' | sort)"
fi

echo
if [ -z "${Z80_TEST_LIST}" ]; then
  echo "No Spectrum 128K tests to run under Fuse emulator."
else
  echo "Running Spectrum 128K tests under Fuse emulator..."

  echo "${Z80_TEST_LIST}" | sort | while read routine; do

    r="${routine%%.*}"

    {
      randomdata-header
      head -c 64 /dev/urandom | hexdump -v -e '"  .byte " 16/1 "0x%02x, " "\n"' | sed 's/,$//'
    } > src/spectrum128k/randomdata.s

    generate_unit_tests src/spectrum128k .hword "" "${routine}" > src/spectrum128k/tests.s
    split "Generated 128k ${routine} unit tests"

    "${Z80_TOOLCHAIN_PREFIX}as" -I src/spectrum128k -o "build/spectrum128k/runtests-cryptorandom_${routine}.o" "src/spectrum128k/runtests.s"
    "${Z80_TOOLCHAIN_PREFIX}ld" -N -Ttext=0x8100 --allow-multiple-definition -R "build/spectrum128k/rom0.elf" -R "build/spectrum128k/rom1.elf" -o "build/spectrum128k/runtests-cryptorandom_${routine}.elf"  "build/spectrum128k/runtests-cryptorandom_${routine}.o"

    # Determine which address holds the Spectrum output channel number for the test output.
    channel_address=$((0x$("${Z80_TOOLCHAIN_PREFIX}readelf" -W -a "build/spectrum128k/runtests-cryptorandom_${routine}.elf" | sed -n '/ channel_assign$/s/.*: \([0-9a-f]*\).*/\1/p') + 1))

    "${Z80_TOOLCHAIN_PREFIX}objcopy" --set-start=0x8100 "build/spectrum128k/runtests-cryptorandom_${routine}.elf" -O binary "build/spectrum128k/runtests-cryptorandom_${routine}.img"
    (cd utils; go run tzx-code-loader/main.go "../build/spectrum128k/runtests-cryptorandom_${routine}.img" "../dist/spectrum128k/runtests-cryptorandom_${routine}.tzx" 33024 "${channel_address}" 3 runtests.b "${r:0:10}" 1000)

    verbose
    verbose -e "  \x1b\x5b\x33\x32\x6d\xe2\x9c\x93\x1b\x5b\x30\x6d dist/spectrum128k/runtests-cryptorandom_${routine}.tzx"

    if ! "${SKIP_GENERATION}"; then

      # The z80 build process is run twice - the first time with random data generated
      # dynamically from /dev/urandom, and then again with the following static
      # "random" data. The first build is used for running the FUSE tests below. The
      # second version is used for generating the checked in binaries (runtests.elf /
      # runtests.img / runtests.tzx).
      #
      # The idea here is to work around the limitation that the Spectrum 128K has no
      # means to generate unique random data, and therefore instead to inject the
      # random data at build time. However, we don't want to check in the binary
      # versions with random data since they would change with every build, and thus
      # we check in the version with static "random" data.

      tape2wav "dist/spectrum128k/runtests-cryptorandom_${routine}.tzx" "dist/spectrum128k/runtests-cryptorandom_${routine}.wav"

      split "Generated crypto-random ${routine} tzx/wav files"

      {
        randomdata-header
        echo '  .byte 0xbc, 0x8d, 0x55, 0xe6, 0xe2, 0x89, 0x26, 0xef, 0xcd, 0xa7, 0x4b, 0xa0, 0x8b, 0x6a, 0x8c, 0x2b'
        echo '  .byte 0x09, 0x14, 0x4d, 0x8d, 0xfe, 0x72, 0x35, 0xb7, 0xdd, 0xfb, 0x1c, 0x52, 0xd4, 0x0d, 0xf2, 0xa4'
        echo '  .byte 0x36, 0xec, 0x51, 0x66, 0xb4, 0x8b, 0x20, 0xbd, 0xe0, 0xc2, 0xcf, 0x57, 0x85, 0x1b, 0x54, 0xe9'
        echo '  .byte 0xfc, 0x28, 0x7a, 0xaf, 0xdb, 0x44, 0x24, 0xcd, 0xd0, 0xed, 0xe7, 0x08, 0x4e, 0xb2, 0xdb, 0x1e'
      } > src/spectrum128k/randomdata.s

      # Assemble and link Spectrum 128K unit tests for running under FUSE.
      "${Z80_TOOLCHAIN_PREFIX}as" -I src/spectrum128k -o "build/spectrum128k/runtests_${routine}.o" "src/spectrum128k/runtests.s"
      "${Z80_TOOLCHAIN_PREFIX}ld" -N -Ttext=0x8100 --allow-multiple-definition -R "build/spectrum128k/rom0.elf" -R "build/spectrum128k/rom1.elf" -o "build/spectrum128k/runtests_${routine}.elf" "build/spectrum128k/runtests_${routine}.o"

      # Extract Spectrum 128K unit tests from ELF binary
      "${Z80_TOOLCHAIN_PREFIX}objcopy" --set-start=0x8100 "build/spectrum128k/runtests_${routine}.elf" -O binary "build/spectrum128k/runtests_${routine}.img"

      if "${VERBOSE}"; then
        # Log disassembly of kernel elf file.
        "${Z80_TOOLCHAIN_PREFIX}objdump" -d "build/spectrum128k/runtests_${routine}.elf"

        # Log some useful information about the generated elf file. Options are:
        #   -W: Allow width > 80, i.e. display full symbol names
        "${Z80_TOOLCHAIN_PREFIX}readelf" -W -a "build/spectrum128k/runtests_${routine}.elf"
      fi

      # Create tzx file for running Spectrum 128K ROM tests under FUSE.
      #
      # See:
      #   * http://k1.spdns.de/Develop/Projects/zasm/Info/TZX%20format.html
      #   * https://faqwiki.zxnet.co.uk/wiki/Spectrum_tape_interface
      #   * https://github.com/shred/tzxtools/blob/b4ad524c82f60100b7e06d74194eeb068adb859e/tzxlib/convert.py
      (cd utils; go run tzx-code-loader/main.go "../build/spectrum128k/runtests_${routine}.img" "../dist/spectrum128k/runtests_${routine}.tzx" 33024 "${channel_address}" 2 runtests.b "${r:0:10}" 1000)
      verbose -e "  \x1b\x5b\x33\x32\x6d\xe2\x9c\x93\x1b\x5b\x30\x6d dist/spectrum128k/runtests_${routine}.tzx"
      tape2wav "dist/spectrum128k/runtests_${routine}.tzx" "dist/spectrum128k/runtests_${routine}.wav"

      split "Generated static ${routine} tzx/wav files"
    fi

    # Note, we pass the non-cryptorandom binary for the cached results argument, in order to get cached results if possible
    run_tests fuse-tests "dist/spectrum128k/runtests_${routine}.tzx" "printout.txt" 67 68 30

    split "Ran ${routine} 128k tests"
  done
fi


################### Cleanup ###################

if ! "${SKIP_GENERATION}"; then
  # Format shell scripts - for now this just means stripping trailing
  # whitespace from lines and replacing tabs with spaces.
  find . -name '*.sh' | while read sourcefile; do
    cat "${sourcefile}" | sed 's/  *$//' | sed $'s/\t/    /g' > "${sourcefile}.cleaned"
    if ! cmp "${sourcefile}" "${sourcefile}.cleaned" >/dev/null; then
      verbose "WARNING: Cleaning up whitespace in ${sourcefile}..."
      cat "${sourcefile}.cleaned" > "${sourcefile}"
    fi
    rm "${sourcefile}.cleaned"
  done

  split "Cleaned up shell files"
fi

md5s="$(md5sum dist/spectrum128k/runtests_*.tzx dist/spectrum4/debug/kernel8.img | sed 's/ .*//')"
find cache -type f | sed 's/^cache\///' | while read file; do
  if [ "${md5s/${file}/-}" == "${md5s}" ]; then
    echo "Removing cache file cache/${file}..."
    rm "cache/${file}"
  fi
done

echo
echo -e "All ok"'!'" \U0001f9d9"
