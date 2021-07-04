# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.


.text
.align 2


.set pr_all1_x, 7
.set pr_all1_screenthird, 2
.set pr_all1_yoffset, 3

.set pr_all1_dfaddr, display_file + 216*20*16*pr_all1_screenthird + pr_all1_yoffset*216 + pr_all1_x*2
.set pr_all1_afaddr, attributes_file + 108*20*pr_all1_screenthird + pr_all1_yoffset*108 + pr_all1_x

pr_all_upperscreen_paper9_over1_setup:
  _resbit 1, FLAGS
  _resbit 0, TV_FLAG
  _strb   0x04, DF_SZ                             // lower screen is 4 lines
  _strb   0b01100011, P_FLAG                      // temp OVER 1
                                                  // perm OVER 1
                                                  // perm INK 9
                                                  // temp PAPER 9
  _strh   0b00110001, MASK_T
  _strb   0b01100101, ATTR_T                      // BRIGHT 1
                                                  // PAPER  4
                                                  // INK 5

                                                  // Display file
  _strhbe 0b0000011000111100, pr_all1_dfaddr+20*216*0
  _strhbe 0b1000001010011111, pr_all1_dfaddr+20*216*1
  _strhbe 0b1111101111101110, pr_all1_dfaddr+20*216*2
  _strhbe 0b0011110001010100, pr_all1_dfaddr+20*216*3
  _strhbe 0b0000100000000100, pr_all1_dfaddr+20*216*4
  _strhbe 0b1100100000101011, pr_all1_dfaddr+20*216*5
  _strhbe 0b1010101001001000, pr_all1_dfaddr+20*216*6
  _strhbe 0b0000001100100110, pr_all1_dfaddr+20*216*7
  _strhbe 0b0011000001101101, pr_all1_dfaddr+20*216*8
  _strhbe 0b1011110011011110, pr_all1_dfaddr+20*216*9
  _strhbe 0b0000010011110001, pr_all1_dfaddr+20*216*10
  _strhbe 0b1111111100000000, pr_all1_dfaddr+20*216*11
  _strhbe 0b0101100100101100, pr_all1_dfaddr+20*216*12
  _strhbe 0b1011101001000000, pr_all1_dfaddr+20*216*13
  _strhbe 0b0010101110110110, pr_all1_dfaddr+20*216*14
  _strhbe 0b0011110011000000, pr_all1_dfaddr+20*216*15

  _strb   0b10101110, pr_all1_afaddr              // Attributes file
                                                  //   FLASH 1
                                                  //   PAPER 5
                                                  //   INK 6
  ret

pr_all_upperscreen_paper9_over1_setup_regs:
  mov     w0, (60-20*pr_all1_screenthird-pr_all1_yoffset)
  mov     w1, (109-pr_all1_x)
  ldr     x2, =pr_all1_dfaddr
  adr     x4, char_set+('k'-' ')*32               // char 'k'
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

pr_all_upperscreen_paper9_over1_effects:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.

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
  _strhbe 0b0000011000111100, pr_all1_dfaddr+20*216*0
  _strhbe 0b1000001010011111, pr_all1_dfaddr+20*216*1
  _strhbe 0b1111011111101110, pr_all1_dfaddr+20*216*2
  _strhbe 0b0011000000110100, pr_all1_dfaddr+20*216*3
  _strhbe 0b0000010011100100, pr_all1_dfaddr+20*216*4
  _strhbe 0b1100010111101011, pr_all1_dfaddr+20*216*5
  _strhbe 0b1010010111001000, pr_all1_dfaddr+20*216*6
  _strhbe 0b0000110000100110, pr_all1_dfaddr+20*216*7
  _strhbe 0b0011111101101101, pr_all1_dfaddr+20*216*8
  _strhbe 0b1011001101011110, pr_all1_dfaddr+20*216*9
  _strhbe 0b0000100100110001, pr_all1_dfaddr+20*216*10
  _strhbe 0b1111001111100000, pr_all1_dfaddr+20*216*11
  _strhbe 0b0101010101011100, pr_all1_dfaddr+20*216*12
  _strhbe 0b1011011001110000, pr_all1_dfaddr+20*216*13
  _strhbe 0b0010101110110110, pr_all1_dfaddr+20*216*14
  _strhbe 0b0011110011000000, pr_all1_dfaddr+20*216*15

  ldr     x0, =pr_all1_dfaddr
  bl      po_attr
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret

pr_all_upperscreen_paper9_over1_effects_regs:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  str     x24, [sp, #-16]!
  ldr     x0, =pr_all1_dfaddr
  bl      po_attr
  mov     w0, (60-20*pr_all1_screenthird-pr_all1_yoffset)
  mov     w1, (109-pr_all1_x)-1
  ldr     x2, =pr_all1_dfaddr+1
  ldr     x24, [sp], #0x10
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


.set pr_all2_x, 107
.set pr_all2_screenthird, 2
.set pr_all2_yoffset, 19

.set pr_all2_dfaddr, display_file + 216*20*16*pr_all2_screenthird + pr_all2_yoffset*216 + pr_all2_x*2
.set pr_all2_afaddr, attributes_file + 108*20*pr_all2_screenthird + pr_all2_yoffset*108 + pr_all2_x

pr_all_lowerscreen_ink9_inverse1_setup:
  _resbit 1, FLAGS
  _setbit 0, TV_FLAG
  _strb   0x08, DF_SZ                             // lower screen is 8 lines
  _strb   0b00010100, P_FLAG                      // temp INVERSE 1
                                                  // temo INK 9
  _strb   0b10010010, MASK_T
  _strb   0b00101010, ATTR_T
                                                  // Display file
  _strhbe 0b0000011000111100, pr_all2_dfaddr+20*216*0
  _strhbe 0b1000001010011111, pr_all2_dfaddr+20*216*1
  _strhbe 0b1111101111101110, pr_all2_dfaddr+20*216*2
  _strhbe 0b0011110001010100, pr_all2_dfaddr+20*216*3
  _strhbe 0b0000100000000100, pr_all2_dfaddr+20*216*4
  _strhbe 0b1100100000101011, pr_all2_dfaddr+20*216*5
  _strhbe 0b1010101001001000, pr_all2_dfaddr+20*216*6
  _strhbe 0b0000001100100110, pr_all2_dfaddr+20*216*7
  _strhbe 0b0011000001101101, pr_all2_dfaddr+20*216*8
  _strhbe 0b1011110011011110, pr_all2_dfaddr+20*216*9
  _strhbe 0b0000010011110001, pr_all2_dfaddr+20*216*10
  _strhbe 0b1111111100000000, pr_all2_dfaddr+20*216*11
  _strhbe 0b0101100100101100, pr_all2_dfaddr+20*216*12
  _strhbe 0b1011101001000000, pr_all2_dfaddr+20*216*13
  _strhbe 0b0010101110110110, pr_all2_dfaddr+20*216*14
  _strhbe 0b0011110011000000, pr_all2_dfaddr+20*216*15

  _strb   0b00101011, pr_all2_afaddr              // Attributes file
  ret

pr_all_lowerscreen_ink9_inverse1_setup_regs:
  mov     w0, (120-8-20*pr_all2_screenthird-pr_all2_yoffset)
  mov     w1, (109-pr_all2_x)
  ldr     x2, =pr_all2_dfaddr
  adr     x4, char_set+('k'-' ')*32               // char 'k'
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

pr_all_lowerscreen_ink9_inverse1_effects:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.

                                                  // Display file
  _strhbe 0b1111111111111111, pr_all2_dfaddr+20*216*0
  _strhbe 0b1111111111111111, pr_all2_dfaddr+20*216*1
  _strhbe 0b1111001111111111, pr_all2_dfaddr+20*216*2
  _strhbe 0b1111001110011111, pr_all2_dfaddr+20*216*3
  _strhbe 0b1111001100011111, pr_all2_dfaddr+20*216*4
  _strhbe 0b1111001000111111, pr_all2_dfaddr+20*216*5
  _strhbe 0b1111000001111111, pr_all2_dfaddr+20*216*6
  _strhbe 0b1111000011111111, pr_all2_dfaddr+20*216*7
  _strhbe 0b1111000011111111, pr_all2_dfaddr+20*216*8
  _strhbe 0b1111000001111111, pr_all2_dfaddr+20*216*9
  _strhbe 0b1111001000111111, pr_all2_dfaddr+20*216*10
  _strhbe 0b1111001100011111, pr_all2_dfaddr+20*216*11
  _strhbe 0b1111001110001111, pr_all2_dfaddr+20*216*12
  _strhbe 0b1111001111001111, pr_all2_dfaddr+20*216*13
  _strhbe 0b1111111111111111, pr_all2_dfaddr+20*216*14
  _strhbe 0b1111111111111111, pr_all2_dfaddr+20*216*15

  ldr     x0, =pr_all2_dfaddr
  bl      po_attr
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret

pr_all_lowerscreen_ink9_inverse1_effects_regs:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  str     x24, [sp, #-16]!
  ldr     x0, =pr_all2_dfaddr
  bl      po_attr
  mov     w0, (120-8-20*pr_all2_screenthird-pr_all2_yoffset)
  mov     w1, (109-pr_all2_x)-1
  ldr     x2, =pr_all2_dfaddr+1
  ldr     x24, [sp], #0x10
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


.set pr_all3_x, 108
.set pr_all3_screenthird, 2
.set pr_all3_yoffset, 18

.set pr_all3_dfaddr, display_file + 216*20*16*pr_all3_screenthird + pr_all3_yoffset*216 + pr_all3_x*2
.set pr_all3_afaddr, attributes_file + 108*20*pr_all3_screenthird + pr_all3_yoffset*108 + pr_all3_x

pr_all_lowerscreen_inverse1_over1_endofline_setup:
  _resbit 1, FLAGS
  _setbit 0, TV_FLAG
  _strb   0x02, DF_SZ                             // lower screen is 2 lines
  _strb   0b10100111, P_FLAG                      //   (temp OVER 1)
                                                  //   (perm OVER 1)
                                                  //   (temp INVERSE 1)
                                                  //   (perm INK 9)
                                                  //   (perm PAPER 9)
  _strb   0b00000000, MASK_T
  _strb   0b00100010, ATTR_T

                                                  // Display file
  _strhbe 0b0101010101010101, pr_all3_dfaddr+20*216*0
  _strhbe 0b1010101010101010, pr_all3_dfaddr+20*216*1
  _strhbe 0b0101010101010101, pr_all3_dfaddr+20*216*2
  _strhbe 0b1010101010101010, pr_all3_dfaddr+20*216*3
  _strhbe 0b0101010101010101, pr_all3_dfaddr+20*216*4
  _strhbe 0b1010101010101010, pr_all3_dfaddr+20*216*5
  _strhbe 0b0101010101010101, pr_all3_dfaddr+20*216*6
  _strhbe 0b1010101010101010, pr_all3_dfaddr+20*216*7
  _strhbe 0b0101010101010101, pr_all3_dfaddr+20*216*8
  _strhbe 0b1010101010101010, pr_all3_dfaddr+20*216*9
  _strhbe 0b0101010101010101, pr_all3_dfaddr+20*216*10
  _strhbe 0b1010101010101010, pr_all3_dfaddr+20*216*11
  _strhbe 0b0101010101010101, pr_all3_dfaddr+20*216*12
  _strhbe 0b1010101010101010, pr_all3_dfaddr+20*216*13
  _strhbe 0b0101010101010101, pr_all3_dfaddr+20*216*14
  _strhbe 0b1010101010101010, pr_all3_dfaddr+20*216*15
  ret

pr_all_lowerscreen_inverse1_over1_endofline_setup_regs:
  mov     w0, (120-2-20*pr_all3_screenthird-pr_all3_yoffset)
  mov     w1, (109-pr_all3_x)
  ldr     x2, =pr_all3_dfaddr
  adr     x4, char_set+('k'-' ')*32               // char 'k'
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

pr_all_lowerscreen_inverse1_over1_endofline_effects:
                                                  // Display file
  _strhbe 0b1010101010101010, pr_all3_dfaddr+20*216*0
  _strhbe 0b0101010101010101, pr_all3_dfaddr+20*216*1
  _strhbe 0b1010011010101010, pr_all3_dfaddr+20*216*2
  _strhbe 0b0101100100110101, pr_all3_dfaddr+20*216*3
  _strhbe 0b1010011001001010, pr_all3_dfaddr+20*216*4
  _strhbe 0b0101100010010101, pr_all3_dfaddr+20*216*5
  _strhbe 0b1010010100101010, pr_all3_dfaddr+20*216*6
  _strhbe 0b0101101001010101, pr_all3_dfaddr+20*216*7
  _strhbe 0b1010010110101010, pr_all3_dfaddr+20*216*8
  _strhbe 0b0101101011010101, pr_all3_dfaddr+20*216*9
  _strhbe 0b1010011101101010, pr_all3_dfaddr+20*216*10
  _strhbe 0b0101100110110101, pr_all3_dfaddr+20*216*11
  _strhbe 0b1010011011011010, pr_all3_dfaddr+20*216*12
  _strhbe 0b0101100101100101, pr_all3_dfaddr+20*216*13
  _strhbe 0b1010101010101010, pr_all3_dfaddr+20*216*14
  _strhbe 0b0101010101010101, pr_all3_dfaddr+20*216*15

  _strb   0b00100010, pr_all3_afaddr              // Attributes file

  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0x0, BORDER_TOP + 16*(2*20 + 19) + 0x0
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0x2, BORDER_TOP + 16*(2*20 + 19) + 0x0
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0x4, BORDER_TOP + 16*(2*20 + 19) + 0x0
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0x6, BORDER_TOP + 16*(2*20 + 19) + 0x0
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0x8, BORDER_TOP + 16*(2*20 + 19) + 0x0
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0xa, BORDER_TOP + 16*(2*20 + 19) + 0x0
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0xc, BORDER_TOP + 16*(2*20 + 19) + 0x0
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0xe, BORDER_TOP + 16*(2*20 + 19) + 0x0
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0x0, BORDER_TOP + 16*(2*20 + 19) + 0x1
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0x2, BORDER_TOP + 16*(2*20 + 19) + 0x1
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0x4, BORDER_TOP + 16*(2*20 + 19) + 0x1
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0x6, BORDER_TOP + 16*(2*20 + 19) + 0x1
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0x8, BORDER_TOP + 16*(2*20 + 19) + 0x1
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0xa, BORDER_TOP + 16*(2*20 + 19) + 0x1
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0xc, BORDER_TOP + 16*(2*20 + 19) + 0x1
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0xe, BORDER_TOP + 16*(2*20 + 19) + 0x1
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0x0, BORDER_TOP + 16*(2*20 + 19) + 0x2
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0x2, BORDER_TOP + 16*(2*20 + 19) + 0x2
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0x4, BORDER_TOP + 16*(2*20 + 19) + 0x2
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0x6, BORDER_TOP + 16*(2*20 + 19) + 0x2
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0x8, BORDER_TOP + 16*(2*20 + 19) + 0x2
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0xa, BORDER_TOP + 16*(2*20 + 19) + 0x2
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0xc, BORDER_TOP + 16*(2*20 + 19) + 0x2
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0xe, BORDER_TOP + 16*(2*20 + 19) + 0x2
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0x0, BORDER_TOP + 16*(2*20 + 19) + 0x3
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0x2, BORDER_TOP + 16*(2*20 + 19) + 0x3
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0x4, BORDER_TOP + 16*(2*20 + 19) + 0x3
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0x6, BORDER_TOP + 16*(2*20 + 19) + 0x3
  _pixel  0x0000cc000000cc00, BORDER_LEFT + 16*0 + 0x8, BORDER_TOP + 16*(2*20 + 19) + 0x3
  _pixel  0x00cc000000cc0000, BORDER_LEFT + 16*0 + 0xa, BORDER_TOP + 16*(2*20 + 19) + 0x3
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0xc, BORDER_TOP + 16*(2*20 + 19) + 0x3
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0xe, BORDER_TOP + 16*(2*20 + 19) + 0x3
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0x0, BORDER_TOP + 16*(2*20 + 19) + 0x4
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0x2, BORDER_TOP + 16*(2*20 + 19) + 0x4
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0x4, BORDER_TOP + 16*(2*20 + 19) + 0x4
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0x6, BORDER_TOP + 16*(2*20 + 19) + 0x4
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0x8, BORDER_TOP + 16*(2*20 + 19) + 0x4
  _pixel  0x0000cc000000cc00, BORDER_LEFT + 16*0 + 0xa, BORDER_TOP + 16*(2*20 + 19) + 0x4
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0xc, BORDER_TOP + 16*(2*20 + 19) + 0x4
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0xe, BORDER_TOP + 16*(2*20 + 19) + 0x4
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0x0, BORDER_TOP + 16*(2*20 + 19) + 0x5
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0x2, BORDER_TOP + 16*(2*20 + 19) + 0x5
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0x4, BORDER_TOP + 16*(2*20 + 19) + 0x5
  _pixel  0x0000cc000000cc00, BORDER_LEFT + 16*0 + 0x6, BORDER_TOP + 16*(2*20 + 19) + 0x5
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0x8, BORDER_TOP + 16*(2*20 + 19) + 0x5
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0xa, BORDER_TOP + 16*(2*20 + 19) + 0x5
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0xc, BORDER_TOP + 16*(2*20 + 19) + 0x5
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0xe, BORDER_TOP + 16*(2*20 + 19) + 0x5
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0x0, BORDER_TOP + 16*(2*20 + 19) + 0x6
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0x2, BORDER_TOP + 16*(2*20 + 19) + 0x6
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0x4, BORDER_TOP + 16*(2*20 + 19) + 0x6
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0x6, BORDER_TOP + 16*(2*20 + 19) + 0x6
  _pixel  0x0000cc000000cc00, BORDER_LEFT + 16*0 + 0x8, BORDER_TOP + 16*(2*20 + 19) + 0x6
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0xa, BORDER_TOP + 16*(2*20 + 19) + 0x6
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0xc, BORDER_TOP + 16*(2*20 + 19) + 0x6
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0xe, BORDER_TOP + 16*(2*20 + 19) + 0x6
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0x0, BORDER_TOP + 16*(2*20 + 19) + 0x7
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0x2, BORDER_TOP + 16*(2*20 + 19) + 0x7
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0x4, BORDER_TOP + 16*(2*20 + 19) + 0x7
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0x6, BORDER_TOP + 16*(2*20 + 19) + 0x7
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0x8, BORDER_TOP + 16*(2*20 + 19) + 0x7
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0xa, BORDER_TOP + 16*(2*20 + 19) + 0x7
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0xc, BORDER_TOP + 16*(2*20 + 19) + 0x7
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0xe, BORDER_TOP + 16*(2*20 + 19) + 0x7
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0x0, BORDER_TOP + 16*(2*20 + 19) + 0x8
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0x2, BORDER_TOP + 16*(2*20 + 19) + 0x8
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0x4, BORDER_TOP + 16*(2*20 + 19) + 0x8
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0x6, BORDER_TOP + 16*(2*20 + 19) + 0x8
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0x8, BORDER_TOP + 16*(2*20 + 19) + 0x8
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0xa, BORDER_TOP + 16*(2*20 + 19) + 0x8
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0xc, BORDER_TOP + 16*(2*20 + 19) + 0x8
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0xe, BORDER_TOP + 16*(2*20 + 19) + 0x8
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0x0, BORDER_TOP + 16*(2*20 + 19) + 0x9
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0x2, BORDER_TOP + 16*(2*20 + 19) + 0x9
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0x4, BORDER_TOP + 16*(2*20 + 19) + 0x9
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0x6, BORDER_TOP + 16*(2*20 + 19) + 0x9
  _pixel  0x00cc000000cc0000, BORDER_LEFT + 16*0 + 0x8, BORDER_TOP + 16*(2*20 + 19) + 0x9
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0xa, BORDER_TOP + 16*(2*20 + 19) + 0x9
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0xc, BORDER_TOP + 16*(2*20 + 19) + 0x9
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0xe, BORDER_TOP + 16*(2*20 + 19) + 0x9
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0x0, BORDER_TOP + 16*(2*20 + 19) + 0xa
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0x2, BORDER_TOP + 16*(2*20 + 19) + 0xa
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0x4, BORDER_TOP + 16*(2*20 + 19) + 0xa
  _pixel  0x00cc000000cc0000, BORDER_LEFT + 16*0 + 0x6, BORDER_TOP + 16*(2*20 + 19) + 0xa
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0x8, BORDER_TOP + 16*(2*20 + 19) + 0xa
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0xa, BORDER_TOP + 16*(2*20 + 19) + 0xa
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0xc, BORDER_TOP + 16*(2*20 + 19) + 0xa
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0xe, BORDER_TOP + 16*(2*20 + 19) + 0xa
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0x0, BORDER_TOP + 16*(2*20 + 19) + 0xb
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0x2, BORDER_TOP + 16*(2*20 + 19) + 0xb
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0x4, BORDER_TOP + 16*(2*20 + 19) + 0xb
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0x6, BORDER_TOP + 16*(2*20 + 19) + 0xb
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0x8, BORDER_TOP + 16*(2*20 + 19) + 0xb
  _pixel  0x00cc000000cc0000, BORDER_LEFT + 16*0 + 0xa, BORDER_TOP + 16*(2*20 + 19) + 0xb
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0xc, BORDER_TOP + 16*(2*20 + 19) + 0xb
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0xe, BORDER_TOP + 16*(2*20 + 19) + 0xb
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0x0, BORDER_TOP + 16*(2*20 + 19) + 0xc
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0x2, BORDER_TOP + 16*(2*20 + 19) + 0xc
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0x4, BORDER_TOP + 16*(2*20 + 19) + 0xc
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0x6, BORDER_TOP + 16*(2*20 + 19) + 0xc
  _pixel  0x00cc000000cc0000, BORDER_LEFT + 16*0 + 0x8, BORDER_TOP + 16*(2*20 + 19) + 0xc
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0xa, BORDER_TOP + 16*(2*20 + 19) + 0xc
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0xc, BORDER_TOP + 16*(2*20 + 19) + 0xc
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0xe, BORDER_TOP + 16*(2*20 + 19) + 0xc
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0x0, BORDER_TOP + 16*(2*20 + 19) + 0xd
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0x2, BORDER_TOP + 16*(2*20 + 19) + 0xd
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0x4, BORDER_TOP + 16*(2*20 + 19) + 0xd
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0x6, BORDER_TOP + 16*(2*20 + 19) + 0xd
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0x8, BORDER_TOP + 16*(2*20 + 19) + 0xd
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0xa, BORDER_TOP + 16*(2*20 + 19) + 0xd
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0xc, BORDER_TOP + 16*(2*20 + 19) + 0xd
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0xe, BORDER_TOP + 16*(2*20 + 19) + 0xd
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0x0, BORDER_TOP + 16*(2*20 + 19) + 0xe
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0x2, BORDER_TOP + 16*(2*20 + 19) + 0xe
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0x4, BORDER_TOP + 16*(2*20 + 19) + 0xe
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0x6, BORDER_TOP + 16*(2*20 + 19) + 0xe
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0x8, BORDER_TOP + 16*(2*20 + 19) + 0xe
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0xa, BORDER_TOP + 16*(2*20 + 19) + 0xe
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0xc, BORDER_TOP + 16*(2*20 + 19) + 0xe
  _pixel  0x0000cc0000cc0000, BORDER_LEFT + 16*0 + 0xe, BORDER_TOP + 16*(2*20 + 19) + 0xe
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0x0, BORDER_TOP + 16*(2*20 + 19) + 0xf
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0x2, BORDER_TOP + 16*(2*20 + 19) + 0xf
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0x4, BORDER_TOP + 16*(2*20 + 19) + 0xf
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0x6, BORDER_TOP + 16*(2*20 + 19) + 0xf
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0x8, BORDER_TOP + 16*(2*20 + 19) + 0xf
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0xa, BORDER_TOP + 16*(2*20 + 19) + 0xf
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0xc, BORDER_TOP + 16*(2*20 + 19) + 0xf
  _pixel  0x00cc00000000cc00, BORDER_LEFT + 16*0 + 0xe, BORDER_TOP + 16*(2*20 + 19) + 0xf

  _strb   109, S_POSN_X_L
  _strb   59, S_POSN_Y_L
  _strb   109, ECHO_E_X
  _strb   59, ECHO_E_Y
  _str    pr_all3_dfaddr, DF_CC_L
  ret

pr_all_lowerscreen_inverse1_over1_endofline_effects_regs:
  sub x0, x0, #1
  mov x1, #108
  add x2, x2, #1
  mov x3, #0
  mov x4, #19
  mov x5, #0x00
  mov x6, #0xcc
  mov x7, #0xcc00
  mov x8, #0x0
  adr x9, mbreq
  mov x10, #0x0                                   // x attribute coordinate?
  ldr x11, =0x32929                               // display file offset ?
  mov x12, #108
  mov x13, #0xcc
  mov x14, #0x0
  mov x15, #0xcc0000
  mov x16, #0x18e4                                // attribute file offset?
  mov x17, #0x22                                  // [0-7] attribute value applied / [8-15] [MASK_T] ?
  mov x18, #0x0a                                  // 5 * screen third (0x0 / 0x5 / 0xa) ?
  nzcv 0b0110
  ret
