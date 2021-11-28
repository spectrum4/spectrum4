# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.


.if ROMS_INCLUDE
.else
  .include "chan_flag.s"
  .include "chan_k.s"
  .include "chan_open.s"
  .include "chan_p.s"
  .include "chan_s.s"
  .include "chn_cd_lu.s"
  .include "cl_addr.s"
  .include "cl_set.s"
  .include "copy_buff.s"
  .include "indexer.s"
  .include "po_attr.s"
  .include "po_char.s"
  .include "po_char_2.s"
  .include "po_msg.s"
  .include "po_scr.s"
  .include "po_search.s"
  .include "po_store.s"
  .include "po_table.s"
  .include "po_table_1.s"
  .include "pr_all.s"
  .include "print_w0.s"
  .include "temps.s"
.endif


.set rejoin_po_t_udg_1_x, 7
.set rejoin_po_t_udg_1_screenthird, 2
.set rejoin_po_t_udg_1_yoffset, 3

.set rejoin_po_t_udg_1_dfaddr, display_file + 216*20*16*rejoin_po_t_udg_1_screenthird + rejoin_po_t_udg_1_yoffset*216 + rejoin_po_t_udg_1_x*2
.set rejoin_po_t_udg_1_afaddr, attributes_file + 108*20*rejoin_po_t_udg_1_screenthird + rejoin_po_t_udg_1_yoffset*108 + rejoin_po_t_udg_1_x


.text
.align 2

rejoin_po_t_udg_1_setup:
  _str    char_set+('f'-' ')*32, UDG
  _resbit 1, FLAGS
  _resbit 0, TV_FLAG
  _strb   0x03, DF_SZ                             // lower screen is 3 lines
  _strb   0b01100011, P_FLAG                      // temp OVER 1
                                                  // perm OVER 1
                                                  // perm INK 9
                                                  // temp PAPER 9
  _strh   0b00110001, MASK_T
  _strb   0b01100101, ATTR_T                      // BRIGHT 1
                                                  // PAPER  4
                                                  // INK 5

                                                  // Display file
  _strhbe 0b0000011000111100, rejoin_po_t_udg_1_dfaddr+20*216*0
  _strhbe 0b1000001010011111, rejoin_po_t_udg_1_dfaddr+20*216*1
  _strhbe 0b1111101111101110, rejoin_po_t_udg_1_dfaddr+20*216*2
  _strhbe 0b0011110001010100, rejoin_po_t_udg_1_dfaddr+20*216*3
  _strhbe 0b0000100000000100, rejoin_po_t_udg_1_dfaddr+20*216*4
  _strhbe 0b1100100000101011, rejoin_po_t_udg_1_dfaddr+20*216*5
  _strhbe 0b1010101001001000, rejoin_po_t_udg_1_dfaddr+20*216*6
  _strhbe 0b0000001100100110, rejoin_po_t_udg_1_dfaddr+20*216*7
  _strhbe 0b0011000001101101, rejoin_po_t_udg_1_dfaddr+20*216*8
  _strhbe 0b1011110011011110, rejoin_po_t_udg_1_dfaddr+20*216*9
  _strhbe 0b0000010011110001, rejoin_po_t_udg_1_dfaddr+20*216*10
  _strhbe 0b1111111100000000, rejoin_po_t_udg_1_dfaddr+20*216*11
  _strhbe 0b0101100100101100, rejoin_po_t_udg_1_dfaddr+20*216*12
  _strhbe 0b1011101001000000, rejoin_po_t_udg_1_dfaddr+20*216*13
  _strhbe 0b0010101110110110, rejoin_po_t_udg_1_dfaddr+20*216*14
  _strhbe 0b0011110011000000, rejoin_po_t_udg_1_dfaddr+20*216*15

  _strb   0b10101110, rejoin_po_t_udg_1_afaddr    // Attributes file
                                                  //   FLASH 1
                                                  //   PAPER 5
                                                  //   INK 6
  ret

rejoin_po_t_udg_1_setup_regs:
  mov     w0, (60-20*rejoin_po_t_udg_1_screenthird-rejoin_po_t_udg_1_yoffset)
  mov     w1, (109-rejoin_po_t_udg_1_x)
  ldr     x2, =rejoin_po_t_udg_1_dfaddr
  mov     w3, 'k'-'f'-21
                                                  //   0b0000000000000000
                                                  //   0b0000000000000000
                                                  //   0b0000110000000000
                                                  //   0b0000110001100000
                                                  //   0b0000110011100000
                                                  //   0b0000110111000000
                                                  //   0b0000111110000000
                                                  //   0b0000111100000000
                                                  //   0b0000111100000000
                                                  //   0b0000111110000000
                                                  //   0b0000110111000000
                                                  //   0b0000110011100000
                                                  //   0b0000110001110000
                                                  //   0b0000110000110000
                                                  //   0b0000000000000000
                                                  //   0b0000000000000000
  ret

rejoin_po_t_udg_1_effects:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  _resbit 0, FLAGS

                                                  // Display file
                                                  // 0b0000011000111100 xor 0b0000000000000000
                                                  // 0b1000001010011111 xor 0b0000000000000000
                                                  // 0b1111101111101110 xor 0b0000110000000000
                                                  // 0b0011110001010100 xor 0b0000110001100000
                                                  // 0b0000100000000100 xor 0b0000110011100000
                                                  // 0b1100100000101011 xor 0b0000110111000000
                                                  // 0b1010101001001000 xor 0b0000111110000000
                                                  // 0b0000001100100110 xor 0b0000111100000000
                                                  // 0b0011000001101101 xor 0b0000111100000000
                                                  // 0b1011110011011110 xor 0b0000111110000000
                                                  // 0b0000010011110001 xor 0b0000110111000000
                                                  // 0b1111111100000000 xor 0b0000110011100000
                                                  // 0b0101100100101100 xor 0b0000110001110000
                                                  // 0b1011101001000000 xor 0b0000110000110000
                                                  // 0b0010101110110110 xor 0b0000000000000000
                                                  // 0b0011110011000000 xor 0b0000000000000000
  _strhbe 0b0000011000111100, rejoin_po_t_udg_1_dfaddr+20*216*0
  _strhbe 0b1000001010011111, rejoin_po_t_udg_1_dfaddr+20*216*1
  _strhbe 0b1111011111101110, rejoin_po_t_udg_1_dfaddr+20*216*2
  _strhbe 0b0011000000110100, rejoin_po_t_udg_1_dfaddr+20*216*3
  _strhbe 0b0000010011100100, rejoin_po_t_udg_1_dfaddr+20*216*4
  _strhbe 0b1100010111101011, rejoin_po_t_udg_1_dfaddr+20*216*5
  _strhbe 0b1010010111001000, rejoin_po_t_udg_1_dfaddr+20*216*6
  _strhbe 0b0000110000100110, rejoin_po_t_udg_1_dfaddr+20*216*7
  _strhbe 0b0011111101101101, rejoin_po_t_udg_1_dfaddr+20*216*8
  _strhbe 0b1011001101011110, rejoin_po_t_udg_1_dfaddr+20*216*9
  _strhbe 0b0000100100110001, rejoin_po_t_udg_1_dfaddr+20*216*10
  _strhbe 0b1111001111100000, rejoin_po_t_udg_1_dfaddr+20*216*11
  _strhbe 0b0101010101011100, rejoin_po_t_udg_1_dfaddr+20*216*12
  _strhbe 0b1011011001110000, rejoin_po_t_udg_1_dfaddr+20*216*13
  _strhbe 0b0010101110110110, rejoin_po_t_udg_1_dfaddr+20*216*14
  _strhbe 0b0011110011000000, rejoin_po_t_udg_1_dfaddr+20*216*15

  ldr     x0, =rejoin_po_t_udg_1_dfaddr
  bl      po_attr
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret

rejoin_po_t_udg_1_effects_regs:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  str     x24, [sp, #-16]!
  ldr     x0, =rejoin_po_t_udg_1_dfaddr
  bl      po_attr
  mov     w0, (60-20*rejoin_po_t_udg_1_screenthird-rejoin_po_t_udg_1_yoffset)
  mov     w1, (109-rejoin_po_t_udg_1_x)-1
  ldr     x2, =rejoin_po_t_udg_1_dfaddr+1
  ldr     x24, [sp], #0x10
  adr     x4, char_set+('k'-' ')*32
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
