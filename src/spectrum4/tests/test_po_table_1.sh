#!/usr/bin/env bash

# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

set -eu

function output {
  id="${carry}${flagsbit0}_${w5}_$(printf %x "'${lastchar}")"
  hex_w5="$(printf "%02x" "${w5}")"
  leading=''
  if [ "${flagsbit0}" == '0' ] && [ "${carry}" == "set" ]; then
    leading=' '
  fi
  trailing=''
  x0='#0x00'
  nzcv='#0b1000'
  if [ "${w5}" -ge 3 ] && ([ "$(printf %d "'${lastchar}")" -ge 65 ] || [ "${lastchar}" == "$" ]); then
    trailing=' '
    x0="' '"
    nzcv='#0b0010'
    if [ "${w5}" == '3' ]; then
      nzcv='#0b0110'
    fi
  fi
  echo
  echo
  echo '.align 0'
  echo "msg_po_table_1_${id}_in:"
  echo "  .asciz \"abc${lastchar}\""
  echo
  echo '.align 0'
  echo "msg_po_table_1_${id}_out:"
  echo "  .asciz \"${leading}abc${lastchar}${trailing}\""
  echo
  echo '.align 2'
  echo "po_table_1_${id}_setup:"
  echo '  _str    fake_channel_block, CURCHL'
  if [ "${flagsbit0}" == '0' ]; then
    echo '  _resbit 0, FLAGS'
  else
    echo '  _setbit 0, FLAGS'
  fi
  echo '  ret'
  echo
  echo '.align 2'
  echo "po_table_1_${id}_setup_regs:"
  echo "  adr     x4, msg_po_table_1_${id}_in"
  echo "  mov     x5, #${hex_w5}"
  echo "  ${carry}_carry"
  echo '  ret'
  echo
  echo '.align 2'
  echo "po_table_1_${id}_effects:"
  echo '  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.'
  echo '  mov     x29, sp                         // Update frame pointer to new stack location.'
  echo "  adr     x2, msg_po_table_1_${id}_out"
  echo '  bl      print_string                    // Expected output.'
  echo '  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.'
  echo '  ret'
  echo
  echo '.align 2'
  echo "po_table_1_${id}_effects_regs:"
  echo "  mov     x0, ${x0}"
  echo '  adrp    x1, fake_printout'
  echo '  add     x1, x1, :lo12:fake_printout'
  echo "  adr     x4, msg_po_table_1_${id}_out"
  echo "  mov     x6, '${lastchar}'"
  echo "  nzcv    ${nzcv}"
  echo '  ret'
  # echo
  # echo ".ltorg"
}

cd "$(dirname "${0}")"

{
  echo '# This file is part of the Spectrum +4 Project.'
  echo '# Licencing information can be found in the LICENCE file'
  echo '# (C) 2021 Spectrum +4 Authors. All rights reserved.'
  echo
  echo "# This file is auto-generated by ${0##*/}." 'DO NOT EDIT!'
  echo
  echo
  echo '.if ROMS_INCLUDE'
  echo '.else'
  echo '  .include "print_w0.s"'
  echo '.endif'
  echo
  echo '.text'
  echo '.align 2'

  for carry in 'set' 'clear'; do
    for flagsbit0 in 0 1; do
      for w5 in {0..5}; do
        for lastchar in '4' '$' '<' '#' '@' 'A' 'V' '{'; do
          output
        done
      done
    done
  done
} | ../../../utils/asm-format/asm-format > test_po_table_1.gen-s
