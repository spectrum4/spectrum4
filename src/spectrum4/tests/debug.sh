#!/usr/bin/env bash

# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

########################################################################################################################
# Run this script, passing in a test name, to see what commands you can use to debug the test using gdb / qemu.
# This script doesn't execute the commands, it just tells you which commands to use, so you can e.g. copy/paste them.
# Note, the commands it outputs won't run inside the docker container, since gdb isn't included in the docker container.
# These are all things that could be improved at some point.
########################################################################################################################

set -eu
set -o pipefail
export SHELLOPTS

if [ "${AARCH64_TOOLCHAIN_PREFIX+_}" != '_' ]; then
  AARCH64_TOOLCHAIN_PREFIX=aarch64-none-elf-
fi

cd "$(dirname "${0}")"

if [ "${#}" -ne 1 ]; then
  echo "$(basename "${0}"): specify a test to debug, e.g." >&2
  echo "  $ '${0}' po_any_80_f010" >&2
  exit 64
fi

test_name="${1}"
suite="$(grep -l "${test_name}"'\(_setup\|_setup_regs\|_effects\|_effects_regs\)$' ../targets/test_*.symbols | sed 's/\.symbols$//' | sed 's/.*\/test_//')"
routine="$(echo "${suite}" | sed 's/\..*//')"
first_break_command="$(cat "../targets/test_${suite}.symbols" | sed -n "s/${test_name}_//p" | sed 's/_regs$//' | sed 's/ effects$/ setup/' | sed -n 's/^.*: *0*\([^ ]*\).*setup$/b *0x\1/p' | head -1)"
second_break_command="$(cat "../targets/test_${suite}.symbols" | sed -n 's/^.*: *0*\([^ ]*\).* '"${routine}"'$/b *0x\1/p')"
cd ..

echo "Session 1:"
echo "  $ qemu-system-aarch64 -s -S -M raspi3b -kernel $(pwd)/targets/test_${suite}.elf -serial null -serial stdio"
echo "Session 2:"
echo "  $ ${AARCH64_TOOLCHAIN_PREFIX}gdb $(pwd)/targets/test_${suite}.elf"
echo "  (gdb) target extended-remote localhost:1234"
echo "  (gdb) ${first_break_command}"
echo "  (gdb) c"
echo "  (gdb) ${second_break_command}"
echo "  (gdb) c"
echo "  (gdb) disassemble"
echo "  (gdb) i r"
echo "  (gdb) si"
echo "  (gdb) help"
echo "  ..."
echo "  ..."
