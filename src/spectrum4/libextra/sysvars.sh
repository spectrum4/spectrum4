#!/usr/bin/env bash

# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

set -eu
set -o pipefail
export SHELLOPTS

cd "$(dirname "${0}")"

SYSVARS="$(cat ../roms/bss.s | sed -n '/sysvars:/,/sysvars_end:/p' | sed 's/#.*//' | sed -n 's/^ *\([^ ]*\): *\.space \([^ ]*\) .*$/\1 \2/p')"
SYSVAR_COUNT=$(echo "${SYSVARS}" | wc -l)

echo "# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

# This file is auto-generated by ${0##*/}." 'DO NOT EDIT!'"

.set SYSVAR_COUNT, ${SYSVAR_COUNT}

.align 3
.text
sysvars_meta:" | sed 's/^  //'
echo "${SYSVARS}" | while read sysvar size; do
  echo "  .quad sysvar_${sysvar}"
done

echo "${SYSVARS}" | while read sysvar size; do
  echo
  echo
  echo ".align 3"
  echo "sysvar_${sysvar}:"
  echo "  .quad ${sysvar}-sysvars"
  echo "  .byte ${size}"
  echo "  .asciz \"${sysvar}\""
done
