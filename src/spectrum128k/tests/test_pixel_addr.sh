#!/usr/bin/env bash

# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

set -eu
set -o pipefail
export SHELLOPTS

cd "$(dirname "${0}")"

{

  echo '# This file is part of the Spectrum +4 Project.'
  echo '# Licencing information can be found in the LICENCE file'
  echo '# (C) 2021 Spectrum +4 Authors. All rights reserved.'
  echo
  echo "# This file is auto-generated by ${0##*/}." 'DO NOT EDIT!'
  echo
  echo
  echo '.text'

  i=0
  while [ $i -lt 16 ]; do
    x=$((RANDOM % 0x100))
    y=$((RANDOM % 0x100))
    if [ $x -lt 256 ] && [ $y -lt 176 ]; then
      printf '%02x 0x%02x 0x%02x\n' $i $x $y
      i=$((i + 1))
    fi
  done | while read i x y; do
    testname="pixel_addr_${i}"
    df_offset="$(printf '0x%04x\n' $((32 * (8 * (8 * ((175 - y) / 64) + ((175 - y) & 0x07)) + ((175 - y) % 64 >> 3)) + x / 8)))"
    echo
    echo
    echo "${testname}_setup_regs:"
    echo "  ld    b, ${y}"
    echo "  ld    c, ${x}"
    echo "  ret"
    echo
    echo "${testname}_effects_regs:"
    b="$(printf '0x%02x\n' $((175 - y)))"
    echo "  ###########################################"
    echo "  # These two lines set A and F appropriately"
    echo "  ld    a, c"
    echo "  and   0x07"
    echo "  ###########################################"
    echo "  ld    b, ${b}"
    echo "  ld    hl, display_file + ${df_offset}"
    echo "  ret"
  done
} | ../../../utils/asm-format/asm-format > "test_pixel_addr.gen-s"
