#!/usr/bin/env bash

# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

#########################################################################
# This bash script checks that all required executables are installed for
# building and testing spectrum4 on the host environment.
#########################################################################

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
      echo "${CHECK_ENV_SCRIPT}: Invalid architecture specified: '${1}'. Must be 'z80' or 'aarch64'. Exiting." >&2
      exit 66
      ;;
  esac
  if ! which "${PREFIX}${3}" > /dev/null; then
    echo "${CHECK_ENV_SCRIPT}: Cannot find '${PREFIX}${3}' in PATH. Have you set ${ENV_VAR} appropriately? Alternatively, to build under docker, run tup-under-docker.sh script instead. Exiting." >&2
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

function check_dependencies {
  verbose "Checking system dependencies..."
  local failed=false
  for command in "${@}"; do
    if ! which "${command}" > /dev/null; then
      echo -e "  \xE2\x9D\x8C ${command}"
      echo "${CHECK_ENV_SCRIPT}: ${command} must be installed and available in your PATH" >&2
      failed=true
    else
      verbose -e "  \x1b\x5b\x33\x32\x6d\xe2\x9c\x93\x1b\x5b\x30\x6d ${command}"
    fi
  done
  if $failed; then
    exit 65
  fi
}

function verbose {
  ! "${VERBOSE}" || echo "${@}"
}

################### Entry point ###################

set -eu
set -o pipefail
export SHELLOPTS

# For consistent behaviour of `sort`, etc
if which uname > /dev/null && test "$(uname -s)" == 'Darwin'; then
  export LANG='C'
  export LC_CTYPE='UTF-8'
else
  export LC_ALL='C.UTF-8'
fi

# CHECK_ENV_SCRIPT is the name of the file name of this script
: ${CHECK_ENV_SCRIPT:="${0##*/}"}

# Change into directory containing this script (in case the script is executed
# from a different directory).
cd "$(dirname "${0}")"

# Set default values, that may be overwritten by parameters passed to script
VERBOSE=false

# Read parameters passed to script
while getopts ":dhv" opt; do
  case "${opt}" in
    d)
      set -x
      ;;
    h)
      echo "${CHECK_ENV_SCRIPT} checks that the host environment is suitable for running \`tup\` for the Spectrum +4 project."
      echo "Usage:"
      echo "  ${CHECK_ENV_SCRIPT} [-h]"
      echo "  ${CHECK_ENV_SCRIPT} [-d][-g][-t][-v][-y SP4_TEST_LIST][-z 128K_TEST_LIST]"
      echo "Options:"
      echo "  -d                    Log executed commands (set -x)."
      echo "  -h                    Show help."
      echo "  -v                    Verbose output."
      exit 0
      ;;
    v)
      VERBOSE=true
      ;;
    *)
      echo "${CHECK_ENV_SCRIPT}: Invalid argument specified: '-${OPTARG}'" >&2
      exit 71
      ;;
  esac
done

# Technically, checks for 'bash' and 'env' aren't really needed, since if this
# is running, they are installed - however, in case this list is copied around,
# good to include them as required tools...
check_dependencies bash cat cmp cp curl dirname env find fuse go head hexdump ln md5sum mkdir mv qemu-system-aarch64 rm sed shfmt sleep sort tape2wav tup wc which
verbose

################### Spectrum +4 toolchain ###################

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

################### Spectrum 128k toolchain ###################

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

echo -e "All ok"'!'" \U0001f9d9"
