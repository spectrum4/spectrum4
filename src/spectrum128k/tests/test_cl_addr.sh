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
  echo '.text'

  flags=(
    "PV_FLAG"           # top screen-third
    "PV_FLAG | X3_FLAG" # middle screen-third
    "0x0"               # bottom screen-third
  )

  for ((i = 0; i < 3; i++)); do
    h=$((80 - 8 * i))
    a=$h
    f=${flags[i]}
    for ((j = 0; j < 8; j++)); do
      b=$((i * 8 + j + 1))
      l=$((224 - 32 * j))
      d=$((24 - b))

      hexa=$(printf "0x%02x" $a)
      hexb=$(printf "0x%02x" $b)
      hexd=$(printf "0x%02x" $d)
      hexhl=$(printf "0x%02x%02x" $h $l)

      testname="cl_addr_${hexb}"

      echo
      echo "${testname}_setup_regs:"
      echo "  ld      b, ${hexb}"
      echo '  ret'
      echo
      echo "${testname}_effects_regs:"
      echo "  ld      a, ${hexa}"
      echo "  ld      d, ${hexd}"
      echo "  ld      hl, ${hexhl}"
      echo "  ldf     ${f}"
      echo '  ret'
    done
  done
} | ../../../utils/asm-format/asm-format > "test_cl_addr.gen-s"
