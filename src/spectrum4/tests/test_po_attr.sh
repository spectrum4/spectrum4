#!/usr/bin/env bash

# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

cd "$(dirname "${0}")"

# This is identical input data to test_PO_ATTR.sh uses for Spectrum 128K tests.

input='0x02 0x05 0x1d 0x07 0x84 0x41 0xf9 0xce 0x45 0x5c
0x00 0x00 0x04 0x07 0x46 0x2b 0x65 0xb1 0x20 0x30
0x01 0x04 0x05 0x01 0xcb 0x4d 0x41 0x51 0xf8 0x38
0x01 0x05 0x12 0x03 0x35 0xff 0x26 0xd5 0x07 0x00
0x02 0x04 0x08 0x02 0xc0 0x63 0xf2 0x1e 0x60 0x30
0x01 0x06 0x03 0x03 0xd8 0xb5 0xd9 0x74 0xb8 0x38
0x02 0x04 0x0a 0x00 0xf9 0x3a 0x1f 0x5b 0xf8 0x38
0x00 0x07 0x0e 0x07 0x03 0x56 0x67 0x16 0x47 0x04
0x01 0x02 0x19 0x00 0x1b 0x97 0x58 0xe3 0x3b 0x5c
0x00 0x03 0x00 0x03 0xbf 0x51 0x21 0xac 0x9f 0x5c
0x00 0x01 0x0e 0x02 0x5c 0x60 0x87 0xda 0x78 0x38
0x02 0x04 0x04 0x06 0xdf 0x07 0xb8 0x69 0x47 0x5c
0x00 0x03 0x0f 0x02 0xcd 0xb7 0x30 0x4a 0xc5 0x5c
0x00 0x02 0x1c 0x04 0xa8 0x45 0xb2 0x0f 0x08 0x5c
0x00 0x01 0x08 0x06 0x11 0x85 0x45 0x52 0x07 0x00
0x01 0x07 0x06 0x04 0x3f 0x4d 0x6a 0xd5 0x47 0x04
0x01 0x07 0x09 0x04 0x67 0x40 0xef 0xed 0x78 0x5c
0x00 0x02 0x0c 0x03 0xb2 0xd3 0x7e 0x3c 0xd7 0x84
0x02 0x04 0x05 0x00 0x2d 0x90 0x44 0x7c 0x38 0x38
0x02 0x02 0x1e 0x00 0x2d 0x09 0x1c 0x72 0x38 0x38
0x00 0x05 0x1c 0x07 0x2b 0x66 0xe9 0xa2 0x62 0x5c
0x01 0x05 0x1e 0x07 0x73 0xaa 0x20 0xa8 0x73 0x5c
0x01 0x06 0x0b 0x01 0xab 0x48 0x71 0x02 0xca 0x5c
0x02 0x03 0x1c 0x01 0xe1 0x5f 0xdb 0x8a 0x7b 0x5c
0x01 0x02 0x16 0x05 0x72 0xa5 0x92 0x65 0xf8 0x5c
0x00 0x07 0x17 0x03 0x9d 0x93 0x66 0x48 0xbb 0x5c
0x02 0x01 0x05 0x04 0x27 0x3b 0x56 0xda 0x38 0x38
0x00 0x00 0x17 0x07 0xb5 0xa1 0xa2 0x84 0xb5 0x5c
0x01 0x05 0x1a 0x02 0x38 0xbf 0x46 0xb8 0x38 0x38
0x01 0x06 0x19 0x05 0x3c 0x5f 0x57 0x83 0x7f 0x5c
0x00 0x02 0x12 0x04 0xed 0x9e 0x08 0x73 0xc7 0x80
0x02 0x07 0x15 0x02 0x81 0x4d 0x48 0x1a 0xcf 0x8c
0x00 0x06 0x0c 0x07 0x7e 0xb7 0x5f 0x5b 0x07 0x00
0x01 0x07 0x05 0x01 0x75 0xa6 0x98 0xf0 0xc7 0x80
0x01 0x02 0x1d 0x05 0x51 0x1a 0xf1 0x7c 0x38 0x38
0x02 0x07 0x04 0x05 0x68 0x71 0x46 0x8e 0x68 0x5c
0x00 0x03 0x13 0x05 0xe7 0xc8 0xe8 0x98 0xcf 0x8c
0x01 0x03 0x16 0x04 0xe7 0x5a 0x21 0x21 0xc6 0x5c
0x02 0x01 0x1b 0x01 0xe4 0x9a 0x32 0x63 0xc6 0x5c
0x00 0x04 0x16 0x03 0x0f 0xa7 0x0f 0x7f 0x07 0x00
0x01 0x05 0x0c 0x05 0x1f 0x75 0x23 0xc5 0x05 0x5c
0x00 0x03 0x07 0x03 0xbf 0xb4 0x28 0x75 0x87 0x84
0x00 0x05 0x06 0x02 0x63 0x6e 0xb2 0x89 0x63 0x5c
0x02 0x04 0x14 0x07 0xc3 0xe6 0x47 0xe2 0xc6 0x5c
0x02 0x06 0x08 0x02 0x5e 0x61 0xeb 0x2f 0x75 0x5c
0x02 0x01 0x13 0x05 0xa7 0xf2 0x83 0xc3 0x86 0x5c
0x00 0x04 0x19 0x02 0xbb 0x9d 0x81 0x5f 0xb8 0x38
0x02 0x05 0x0a 0x05 0x6d 0x75 0x63 0x0d 0x6d 0x5c
0x02 0x03 0x14 0x02 0x40 0x87 0x62 0x73 0x38 0x38
0x01 0x07 0x0a 0x00 0xdd 0x0f 0x01 0x0f 0xdd 0x5c
0x02 0x04 0x1a 0x00 0x5e 0x8a 0x5f 0x18 0x0f 0x0c
0x00 0x07 0x0f 0x04 0xb4 0xe2 0x84 0x0c 0xb0 0x5c
0x00 0x02 0x17 0x03 0xf6 0x4e 0x8e 0xa8 0x7e 0x5c
0x00 0x03 0x10 0x01 0xc1 0x76 0x4e 0x65 0xc7 0x5c
0x00 0x01 0x0e 0x02 0xc4 0x6d 0x8a 0x99 0x4f 0x08
0x02 0x00 0x1f 0x00 0x3b 0x6d 0xf2 0x0e 0x69 0x5c
0x01 0x01 0x1a 0x04 0x44 0x79 0x6b 0x94 0x68 0x38
0x02 0x02 0x15 0x04 0x5d 0x9c 0xae 0x9f 0xdf 0x88
0x02 0x05 0x0f 0x00 0x99 0xdb 0xb8 0x68 0xb9 0x5c
0x01 0x01 0x11 0x03 0x9d 0xc4 0xf8 0xb6 0xc7 0x80
0x00 0x01 0x01 0x07 0x63 0x16 0xc7 0x2c 0x26 0x5c
0x00 0x05 0x0c 0x05 0xb5 0xde 0xbc 0xbd 0x9f 0x8c
0x00 0x03 0x0f 0x07 0x78 0x50 0xb7 0xac 0x58 0x5c
0x01 0x04 0x07 0x07 0xca 0x1e 0x12 0x92 0xdf 0x88'

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

  i=0
  echo "${input}" | while read section yoffset x pixrow attr_t prevattr mask_t p_flag a f; do
    testname=$(printf "po_attr_%02x" $i)
    i=$((i + 1))
    afoffset=$((section * 108 * 20 + yoffset * 108 + x))
    dfoffset=$((section * 216 * 16 * 20 + yoffset * 216 + x * 2 + pixrow * 20 * 216))
    hexafo=$(printf "0x%08x" $afoffset)
    hexdfo=$(printf "0x%08x" $dfoffset)

    echo
    echo
    echo "${testname}_setup:"
    echo "  _strb   ${attr_t}, ATTR_T"
    echo "  _strb   ${prevattr}, attributes_file + ${hexafo}"
    echo "  _strb   ${mask_t}, MASK_T"
    echo "  _strb   ${p_flag}, P_FLAG"
    echo "  ret"
    echo
    echo "${testname}_setup_regs:"
    echo "  ldr     x0, = display_file + ${hexdfo}"
    echo "  ret"
    echo
    echo "${testname}_effects:"
    echo "  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack."
    echo "  mov     x29, sp                         // Update frame pointer to new stack location."
    echo "  ldr     x0, = attributes_file + ${hexafo}"
    echo "  mov     x1, ${a}"
    echo "  bl      poke_address"
    echo "  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack."
    echo "  ret"
    echo
    echo "${testname}_effects_regs:"
    echo "  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack."
    echo "  mov     x29, sp                         // Update frame pointer to new stack location."
    echo "  ldr     x0, = attributes_file + ${hexafo}"
    echo "  mov     x1, ${a}"
    echo "  bl      poke_address"
    echo "  ldr     x24, = attributes_file"
    echo "  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack."
    echo "  ret"
  done
} | ../../../utils/asm-format/asm-format > "test_po_attr.gen-s"
