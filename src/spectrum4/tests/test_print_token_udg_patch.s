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
  .include "rejoin_po_t_udg.s"
  .include "po_tokens.s"
  .include "po_fetch.s"
  .include "new_tokens.s"
  .include "tkn_table.s"
.endif

# This first test tests printing character 0x9a (154), which is UDG 'K'. [UDG]
# is set so that this maps to the standard 'k' character in char_set. The
# display file and attributes file are first prepared, and various system
# variables are updated that affect the printing, in order to test as many
# parameters as possible of the rendering process.  Prints to upper screen.


.set print_token_udg_patch_01_x,11
.set print_token_udg_patch_01_screenthird, 0
.set print_token_udg_patch_01_yoffset, 5

.set print_token_udg_patch_01_dfaddr, display_file + 216*20*16*print_token_udg_patch_01_screenthird + print_token_udg_patch_01_yoffset*216 + print_token_udg_patch_01_x*2
.set print_token_udg_patch_01_afaddr, attributes_file + 108*20*print_token_udg_patch_01_screenthird + print_token_udg_patch_01_yoffset*108 + print_token_udg_patch_01_x


.text
.align 2
print_token_udg_patch_01_setup:
  _str    char_set+('a'-' ')*32, UDG
  _resbit 1, FLAGS                                // print to screen (not printer)
  _resbit 0, TV_FLAG                              // print to upper screen
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
  _strhbe 0b0000011000111100, print_token_udg_patch_01_dfaddr+20*216*0
  _strhbe 0b1000001010011111, print_token_udg_patch_01_dfaddr+20*216*1
  _strhbe 0b1111101111101110, print_token_udg_patch_01_dfaddr+20*216*2
  _strhbe 0b0011110001010100, print_token_udg_patch_01_dfaddr+20*216*3
  _strhbe 0b0000100000000100, print_token_udg_patch_01_dfaddr+20*216*4
  _strhbe 0b1100100000101011, print_token_udg_patch_01_dfaddr+20*216*5
  _strhbe 0b1010101001001000, print_token_udg_patch_01_dfaddr+20*216*6
  _strhbe 0b0000001100100110, print_token_udg_patch_01_dfaddr+20*216*7
  _strhbe 0b0011000001101101, print_token_udg_patch_01_dfaddr+20*216*8
  _strhbe 0b1011110011011110, print_token_udg_patch_01_dfaddr+20*216*9
  _strhbe 0b0000010011110001, print_token_udg_patch_01_dfaddr+20*216*10
  _strhbe 0b1111111100000000, print_token_udg_patch_01_dfaddr+20*216*11
  _strhbe 0b0101100100101100, print_token_udg_patch_01_dfaddr+20*216*12
  _strhbe 0b1011101001000000, print_token_udg_patch_01_dfaddr+20*216*13
  _strhbe 0b0010101110110110, print_token_udg_patch_01_dfaddr+20*216*14
  _strhbe 0b0011110011000000, print_token_udg_patch_01_dfaddr+20*216*15

  _strb   0b10101110, print_token_udg_patch_01_afaddr
                                                  // Attributes file
                                                  //   FLASH 1
                                                  //   PAPER 5
                                                  //   INK 6
  ret

print_token_udg_patch_01_setup_regs:
  mov     x0, (60-20*print_token_udg_patch_01_screenthird-print_token_udg_patch_01_yoffset)
  mov     x1, (109-print_token_udg_patch_01_x)
  ldr     x2, =print_token_udg_patch_01_dfaddr
  mov     x3, #0x9a                               // UDG K = 'k' (since [UDG] = address of 'a' in test)
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

print_token_udg_patch_01_effects:
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
  _strhbe 0b0000011000111100, print_token_udg_patch_01_dfaddr+20*216*0
  _strhbe 0b1000001010011111, print_token_udg_patch_01_dfaddr+20*216*1
  _strhbe 0b1111011111101110, print_token_udg_patch_01_dfaddr+20*216*2
  _strhbe 0b0011000000110100, print_token_udg_patch_01_dfaddr+20*216*3
  _strhbe 0b0000010011100100, print_token_udg_patch_01_dfaddr+20*216*4
  _strhbe 0b1100010111101011, print_token_udg_patch_01_dfaddr+20*216*5
  _strhbe 0b1010010111001000, print_token_udg_patch_01_dfaddr+20*216*6
  _strhbe 0b0000110000100110, print_token_udg_patch_01_dfaddr+20*216*7
  _strhbe 0b0011111101101101, print_token_udg_patch_01_dfaddr+20*216*8
  _strhbe 0b1011001101011110, print_token_udg_patch_01_dfaddr+20*216*9
  _strhbe 0b0000100100110001, print_token_udg_patch_01_dfaddr+20*216*10
  _strhbe 0b1111001111100000, print_token_udg_patch_01_dfaddr+20*216*11
  _strhbe 0b0101010101011100, print_token_udg_patch_01_dfaddr+20*216*12
  _strhbe 0b1011011001110000, print_token_udg_patch_01_dfaddr+20*216*13
  _strhbe 0b0010101110110110, print_token_udg_patch_01_dfaddr+20*216*14
  _strhbe 0b0011110011000000, print_token_udg_patch_01_dfaddr+20*216*15

  ldr     x0, =print_token_udg_patch_01_dfaddr
  bl      po_attr
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret

print_token_udg_patch_01_effects_regs:
  mov     x0, (60-20*print_token_udg_patch_01_screenthird-print_token_udg_patch_01_yoffset)
  mov     x1, (109-print_token_udg_patch_01_x)-1
  add     x2, x2, 1
  mov     x3, 0x0000000000000000
  adr     x4, char_set+('k'-' ')*32
  mov     x5, 0x0000000000000000
  mov     x6, 0x0000000000000000
  mov     x7, 0x0000000000000000
  mov     x8, 0x0000000000000000
  ldr     x9, =mbreq
  mov     x10, 0x000000000000000b
  ldr     x11, =0x000000000001016f
  mov     x12, 0x000000000000006c
  mov     x13, 0x0000000000000000
  mov     x14, 0x00000000000000ff
  mov     x15, 0x000000000000ff00
  mov     x16, 0x0000000000000227
  mov     x17, 0x0000000000000044
  mov     x18, 0x0000000000000000
  nzcv    0b0110

  ret



# This test prints char 0xfd (BASIC keyword "CLEAR") to printer with bit 0 of
# [FLAGS] set to 0 (leading space _not_ suppressed) using a mock print-out
# routine that doesn't disturb any registers. Expected output is " CLEAR ".


.align 2
print_token_udg_patch_02_setup:
  _str    fake_channel_block, CURCHL              // [CURCHL] = fake_channel_block
  _resbit 0, FLAGS                                // leading space _not_ suppressed
  _setbit 1, FLAGS                                // printer in use

.align 2
print_token_udg_patch_02_setup_regs:
  mov     w3, 0xfd
  ret

.align 2
print_token_udg_patch_02_effects:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  adr     x2, msg_print_token_udg_patch_02
  bl      print_string                            // Expect output " CLEAR "
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret

.align 2
print_token_udg_patch_02_effects_regs:
  ldrb    w0, [x28, FLAGS-sysvars]
  ldrb    w1, [x28, P_POSN_X-sysvars]
  ldr     x2, [x28, PR_CC-sysvars]
  sub     x3, x3, #0xa5
  adr     x4, tkn_table+448
  mov     x5, x3
  mov     x6, 'R'
  nzcv    0b0010
  ret

.align 0
msg_print_token_udg_patch_02: .asciz " CLEAR "




# This test prints char 0xa3 (BASIC keyword "SPECTRUM" when in 128K mode) to
# printer with bit 0 of [FLAGS] set to 0 (leading space _not_ suppressed) using a
# mock print-out routine that doesn't disturb any registers. Expected output is
# " SPECTRUM ".


.align 2
print_token_udg_patch_03_setup:
  _str    fake_channel_block, CURCHL              // [CURCHL] = fake_channel_block
  _resbit 0, FLAGS                                // leading space _not_ suppressed
  _setbit 1, FLAGS                                // printer in use
  _setbit 4, FLAGS                                // 128K mode - SPECTRUM keyword not UDG 'T'

.align 2
print_token_udg_patch_03_setup_regs:
  mov     w3, 0xa3
  ret

.align 2
print_token_udg_patch_03_effects:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  adr     x2, msg_print_token_udg_patch_03
  bl      print_string                            // Expect output " SPECTRUM "
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret

.align 2
print_token_udg_patch_03_effects_regs:
  mov     x0, ' '
  ldr     x1, =fake_printout
  mov     x3, #0
  ldrb    w4, [x28, FLAGS-sysvars]                // w4 = [FLAGS]
  mov     x5, #4
  mov     x6, 'M'
  nzcv    0b0010
  ret

.align 0
msg_print_token_udg_patch_03: .asciz " SPECTRUM "


# This test prints char 0xa4 (BASIC keyword "PLAY" when in 128K mode) to printer
# with bit 0 of [FLAGS] set to 1 (leading space suppressed) using a mock
# print-out routine that doesn't disturb any registers. Expected output is
# "PLAY ".

.align 2
print_token_udg_patch_04_setup:
  _str    fake_channel_block, CURCHL              // [CURCHL] = fake_channel_block
  _setbit 0, FLAGS                                // leading space suppressed
  _setbit 1, FLAGS                                // printer in use
  _setbit 4, FLAGS                                // 128K mode - PLAY keyword not UDG 'U'

.align 2
print_token_udg_patch_04_setup_regs:
  mov     w3, 0xa4
  ret

.align 2
print_token_udg_patch_04_effects:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  adr     x2, msg_print_token_udg_patch_04
  bl      print_string                            // Expect output "PLAY "
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret

.align 2
print_token_udg_patch_04_effects_regs:
  mov     x0, ' '
  ldr     x1, =fake_printout
  mov     x3, #1
  ldrb    w4, [x28, FLAGS-sysvars]                // w4 = [FLAGS]
  mov     x5, #4
  mov     x6, 'Y'
  nzcv    0b0010
  ret

.align 0
msg_print_token_udg_patch_04: .asciz "PLAY "




# This test tests printing character 0xa4 (164), which is UDG 'U'. [UDG] is set
# so that this maps to the standard 'k' character in char_set. The display file
# and attributes file are first prepared, and various system variables are
# updated that affect the printing, in order to test as many parameters as
# possible of the rendering process. Prints to upper screen.


# Choose an arbitrary location on screen to print to
.set print_token_udg_patch_05_x,11
.set print_token_udg_patch_05_screenthird, 0
.set print_token_udg_patch_05_yoffset, 5

# Calculate display file and attributes file addresses for the above character cell location
.set print_token_udg_patch_05_dfaddr, display_file + 216*20*16*print_token_udg_patch_05_screenthird + print_token_udg_patch_05_yoffset*216 + print_token_udg_patch_05_x*2
.set print_token_udg_patch_05_afaddr, attributes_file + 108*20*print_token_udg_patch_05_screenthird + print_token_udg_patch_05_yoffset*108 + print_token_udg_patch_05_x


.text
.align 2
print_token_udg_patch_05_setup:
  _str    char_set+('A'-'U'+'k'-' ')*32, UDG      // set [UDG] such that UDG 'U' uses the char_set 'k' bitmap
  _resbit 1, FLAGS                                // print to screen (not printer)
  _resbit 4, FLAGS                                // 128K mode (to ensure UDG 'U' and not PLAY keyword)
  _resbit 0, TV_FLAG                              // print to upper screen
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
  _strhbe 0b0000011000111100, print_token_udg_patch_05_dfaddr+20*216*0
  _strhbe 0b1000001010011111, print_token_udg_patch_05_dfaddr+20*216*1
  _strhbe 0b1111101111101110, print_token_udg_patch_05_dfaddr+20*216*2
  _strhbe 0b0011110001010100, print_token_udg_patch_05_dfaddr+20*216*3
  _strhbe 0b0000100000000100, print_token_udg_patch_05_dfaddr+20*216*4
  _strhbe 0b1100100000101011, print_token_udg_patch_05_dfaddr+20*216*5
  _strhbe 0b1010101001001000, print_token_udg_patch_05_dfaddr+20*216*6
  _strhbe 0b0000001100100110, print_token_udg_patch_05_dfaddr+20*216*7
  _strhbe 0b0011000001101101, print_token_udg_patch_05_dfaddr+20*216*8
  _strhbe 0b1011110011011110, print_token_udg_patch_05_dfaddr+20*216*9
  _strhbe 0b0000010011110001, print_token_udg_patch_05_dfaddr+20*216*10
  _strhbe 0b1111111100000000, print_token_udg_patch_05_dfaddr+20*216*11
  _strhbe 0b0101100100101100, print_token_udg_patch_05_dfaddr+20*216*12
  _strhbe 0b1011101001000000, print_token_udg_patch_05_dfaddr+20*216*13
  _strhbe 0b0010101110110110, print_token_udg_patch_05_dfaddr+20*216*14
  _strhbe 0b0011110011000000, print_token_udg_patch_05_dfaddr+20*216*15

  _strb   0b10101110, print_token_udg_patch_05_afaddr
                                                  // Attributes file
                                                  //   FLASH 1
                                                  //   PAPER 5
                                                  //   INK 6
  ret

print_token_udg_patch_05_setup_regs:
  mov     w0, (60-20*print_token_udg_patch_05_screenthird-print_token_udg_patch_05_yoffset)
  mov     w1, (109-print_token_udg_patch_05_x)
  ldr     x2, =print_token_udg_patch_05_dfaddr
  mov     w3, #0xa4                               // UDG U = 'k' bitmap (due to value in sysvar UDG used in this test)
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

print_token_udg_patch_05_effects:
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
  _strhbe 0b0000011000111100, print_token_udg_patch_05_dfaddr+20*216*0
  _strhbe 0b1000001010011111, print_token_udg_patch_05_dfaddr+20*216*1
  _strhbe 0b1111011111101110, print_token_udg_patch_05_dfaddr+20*216*2
  _strhbe 0b0011000000110100, print_token_udg_patch_05_dfaddr+20*216*3
  _strhbe 0b0000010011100100, print_token_udg_patch_05_dfaddr+20*216*4
  _strhbe 0b1100010111101011, print_token_udg_patch_05_dfaddr+20*216*5
  _strhbe 0b1010010111001000, print_token_udg_patch_05_dfaddr+20*216*6
  _strhbe 0b0000110000100110, print_token_udg_patch_05_dfaddr+20*216*7
  _strhbe 0b0011111101101101, print_token_udg_patch_05_dfaddr+20*216*8
  _strhbe 0b1011001101011110, print_token_udg_patch_05_dfaddr+20*216*9
  _strhbe 0b0000100100110001, print_token_udg_patch_05_dfaddr+20*216*10
  _strhbe 0b1111001111100000, print_token_udg_patch_05_dfaddr+20*216*11
  _strhbe 0b0101010101011100, print_token_udg_patch_05_dfaddr+20*216*12
  _strhbe 0b1011011001110000, print_token_udg_patch_05_dfaddr+20*216*13
  _strhbe 0b0010101110110110, print_token_udg_patch_05_dfaddr+20*216*14
  _strhbe 0b0011110011000000, print_token_udg_patch_05_dfaddr+20*216*15

  ldr     x0, =print_token_udg_patch_05_dfaddr
  bl      po_attr
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret

print_token_udg_patch_05_effects_regs:
  mov     w0, (60-20*print_token_udg_patch_05_screenthird-print_token_udg_patch_05_yoffset)
  mov     w1, (109-print_token_udg_patch_05_x)-1
  add     x2, x2, 1

  mov     x3, 0x0000000000000000
  mov     x5, 0x0000000000000000
  mov     x6, 0x0000000000000000
  mov     x7, 0x0000000000000000
  mov     x8, 0x0000000000000000
  ldr     x9, =mbreq
  mov     x10, 0x000000000000000b
  ldr     x11, =0x000000000001016f
  mov     x12, 0x000000000000006c
  mov     x13, 0x0000000000000000
  mov     x14, 0x00000000000000ff
  mov     x15, 0x000000000000ff00
  mov     x16, 0x0000000000000227
  mov     x17, 0x0000000000000044
  mov     x18, 0x0000000000000000
  nzcv    0b0110

  adr     x4, char_set+('k'-' ')*32
  ret



# This is the same as print_token_udg_patch_01 but prints at end-of-line
# (entry x1=1). This results in [S_POSN_X], [S_POSN_Y], [DF_CC] getting
# updated.


.set print_token_udg_patch_06_x, 0
.set print_token_udg_patch_06_screenthird, 0
.set print_token_udg_patch_06_yoffset, 5

.set print_token_udg_patch_06_dfaddr, display_file + 216*20*16*print_token_udg_patch_06_screenthird + print_token_udg_patch_06_yoffset*216 + print_token_udg_patch_06_x*2
.set print_token_udg_patch_06_afaddr, attributes_file + 108*20*print_token_udg_patch_06_screenthird + print_token_udg_patch_06_yoffset*108 + print_token_udg_patch_06_x


.text
.align 2
print_token_udg_patch_06_setup:
  _str    char_set+('a'-' ')*32, UDG
  _resbit 1, FLAGS                                // print to screen (not printer)
  _resbit 0, TV_FLAG                              // print to upper screen
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
  _strhbe 0b0000011000111100, print_token_udg_patch_06_dfaddr+20*216*0
  _strhbe 0b1000001010011111, print_token_udg_patch_06_dfaddr+20*216*1
  _strhbe 0b1111101111101110, print_token_udg_patch_06_dfaddr+20*216*2
  _strhbe 0b0011110001010100, print_token_udg_patch_06_dfaddr+20*216*3
  _strhbe 0b0000100000000100, print_token_udg_patch_06_dfaddr+20*216*4
  _strhbe 0b1100100000101011, print_token_udg_patch_06_dfaddr+20*216*5
  _strhbe 0b1010101001001000, print_token_udg_patch_06_dfaddr+20*216*6
  _strhbe 0b0000001100100110, print_token_udg_patch_06_dfaddr+20*216*7
  _strhbe 0b0011000001101101, print_token_udg_patch_06_dfaddr+20*216*8
  _strhbe 0b1011110011011110, print_token_udg_patch_06_dfaddr+20*216*9
  _strhbe 0b0000010011110001, print_token_udg_patch_06_dfaddr+20*216*10
  _strhbe 0b1111111100000000, print_token_udg_patch_06_dfaddr+20*216*11
  _strhbe 0b0101100100101100, print_token_udg_patch_06_dfaddr+20*216*12
  _strhbe 0b1011101001000000, print_token_udg_patch_06_dfaddr+20*216*13
  _strhbe 0b0010101110110110, print_token_udg_patch_06_dfaddr+20*216*14
  _strhbe 0b0011110011000000, print_token_udg_patch_06_dfaddr+20*216*15

  _strb   0b10101110, print_token_udg_patch_06_afaddr
                                                  // Attributes file
                                                  //   FLASH 1
                                                  //   PAPER 5
                                                  //   INK 6
  ret

print_token_udg_patch_06_setup_regs:
  mov     x0, (60-20*print_token_udg_patch_06_screenthird-print_token_udg_patch_06_yoffset+1)
  mov     x1, #1
  ldr     x2, =print_token_udg_patch_06_dfaddr
  mov     x3, #0x9a                               // UDG K = 'k' (since [UDG] = address of 'a' in test)
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

print_token_udg_patch_06_effects:
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
  _strhbe 0b0000011000111100, print_token_udg_patch_06_dfaddr+20*216*0
  _strhbe 0b1000001010011111, print_token_udg_patch_06_dfaddr+20*216*1
  _strhbe 0b1111011111101110, print_token_udg_patch_06_dfaddr+20*216*2
  _strhbe 0b0011000000110100, print_token_udg_patch_06_dfaddr+20*216*3
  _strhbe 0b0000010011100100, print_token_udg_patch_06_dfaddr+20*216*4
  _strhbe 0b1100010111101011, print_token_udg_patch_06_dfaddr+20*216*5
  _strhbe 0b1010010111001000, print_token_udg_patch_06_dfaddr+20*216*6
  _strhbe 0b0000110000100110, print_token_udg_patch_06_dfaddr+20*216*7
  _strhbe 0b0011111101101101, print_token_udg_patch_06_dfaddr+20*216*8
  _strhbe 0b1011001101011110, print_token_udg_patch_06_dfaddr+20*216*9
  _strhbe 0b0000100100110001, print_token_udg_patch_06_dfaddr+20*216*10
  _strhbe 0b1111001111100000, print_token_udg_patch_06_dfaddr+20*216*11
  _strhbe 0b0101010101011100, print_token_udg_patch_06_dfaddr+20*216*12
  _strhbe 0b1011011001110000, print_token_udg_patch_06_dfaddr+20*216*13
  _strhbe 0b0010101110110110, print_token_udg_patch_06_dfaddr+20*216*14
  _strhbe 0b0011110011000000, print_token_udg_patch_06_dfaddr+20*216*15
  _strb   109, S_POSN_X
  _strb   (60-20*print_token_udg_patch_06_screenthird-print_token_udg_patch_06_yoffset), S_POSN_Y
  _str    print_token_udg_patch_06_dfaddr, DF_CC

  ldr     x0, =print_token_udg_patch_06_dfaddr
  bl      po_attr
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret

print_token_udg_patch_06_effects_regs:
  mov     x0, (60-20*print_token_udg_patch_06_screenthird-print_token_udg_patch_06_yoffset)
  mov     x1, (109-print_token_udg_patch_06_x)-1
  add     x2, x2, 1
  mov     x3, 0x0000000000000000
  mov     x4, print_token_udg_patch_06_yoffset
  mov     x5, 0x0000000000000000
  mov     x6, 0x0000000000000000
  mov     x7, 0x0000000000000000
  mov     x8, 0x0000000000000000
  ldr     x9, =mbreq
  mov     x10, 0x0000000000000000
  ldr     x11, =0x0000000000010159
  mov     x12, 0x000000000000006c
  mov     x13, 0x0000000000000000
  mov     x14, 0x00000000000000ff
  mov     x15, 0x000000000000ff00
  mov     x16, 0x000000000000021c
  mov     x17, 0x0000000000000044
  mov     x18, 0x0000000000000000
  nzcv    0b0110
  ret



# Same as print_token_udg_patch_03 but using upper screen instead of printer

.align 2
print_token_udg_patch_07_setup:
  _str    fake_channel_block, CURCHL              // [CURCHL] = fake_channel_block
  _resbit 0, FLAGS                                // leading space _not_ suppressed
  _resbit 1, FLAGS                                // print to screen (not printer)
  _resbit 0, TV_FLAG                              // print to upper screen
  _setbit 4, FLAGS                                // 128K mode - SPECTRUM keyword not UDG 'T'

.align 2
print_token_udg_patch_07_setup_regs:
  mov     w3, 0xa3
  ret

.align 2
print_token_udg_patch_07_effects:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  adr     x2, msg_print_token_udg_patch_07
  bl      print_string                            // Expect output " SPECTRUM "
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret

.align 2
print_token_udg_patch_07_effects_regs:
  ldrb    w0, [x28, S_POSN_Y-sysvars]
  ldrb    w1, [x28, S_POSN_X-sysvars]
  ldr     x2, [x28, DF_CC-sysvars]
  mov     x3, #0
  ldrb    w4, [x28, FLAGS-sysvars]                // w4 = [FLAGS]
  mov     x5, #4
  mov     x6, 'M'
  nzcv    0b0010
  ret

.align 0
msg_print_token_udg_patch_07: .asciz " SPECTRUM "
