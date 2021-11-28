# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.


.if ROMS_INCLUDE
.else
  .include "print_w0.s"
.endif


.text
.align 2


# This test calls po_attr passing the address of a pixel from the display file (section 1,
# line 5, column 4, pixel row 6). It first sets the current attribute of the character cell to
# 0b01010101, and ATTR_T, MASK_T, P_FLAG to other interesting values.


po_attr_cjs_setup:
  _strb   0b10010101, ATTR_T                      // See http://www.breakintoprogstack.co.uk/computers/zx-spectrum/screen-memory-layout
                                                  // temp colours: FLASH 1; BRIGHT 0; PAPER 2; INK 5
  # TODO - set screen attribute value to something more interesting than 0b01010101
  _strb   0b01010101, attributes_file + 1*108*20 + 5*108 + 4
                                                  // Current screen attributes are 0b01010101 => FLASH 0; BRIGHT 1; PAPER 2; INK 5
  _strb   0b01010110, MASK_T                      // Read attribute bits 1,2,4,6 from screen (0b01010101), and 0,3,5,7 from ATTR_T (0b10010101)
                                                  // => 0b11010101 => INK 5; PAPER 2; BRIGHT 1; FLASH 1
  _strb   0b10010111, P_FLAG                      // OVER 1; INVERSE 1; INK 9 (=> INK 7 since PAPER 2) => 0b11010111 = 0xd7
                                                  // => FLASH 1: BRIGHT 1: PAPER 2: INK 7
  # CJ's Elephant Antics brick sprite
  _strhbe 0b0000000000000000, display_file + 1*216*20*16 + 5*216 + 4*2 + 0x0*20*216
  _strhbe 0b0111111111111100, display_file + 1*216*20*16 + 5*216 + 4*2 + 0x1*20*216
  _strhbe 0b1101101010000110, display_file + 1*216*20*16 + 5*216 + 4*2 + 0x2*20*216
  _strhbe 0b1111111111101010, display_file + 1*216*20*16 + 5*216 + 4*2 + 0x3*20*216
  _strhbe 0b1011111111011000, display_file + 1*216*20*16 + 5*216 + 4*2 + 0x4*20*216
  _strhbe 0b1111011110111010, display_file + 1*216*20*16 + 5*216 + 4*2 + 0x5*20*216
  _strhbe 0b1010110111110000, display_file + 1*216*20*16 + 5*216 + 4*2 + 0x6*20*216
  _strhbe 0b1101111011101010, display_file + 1*216*20*16 + 5*216 + 4*2 + 0x7*20*216
  _strhbe 0b1011111111011000, display_file + 1*216*20*16 + 5*216 + 4*2 + 0x8*20*216
  _strhbe 0b1111101110110010, display_file + 1*216*20*16 + 5*216 + 4*2 + 0x9*20*216
  _strhbe 0b1011011100100000, display_file + 1*216*20*16 + 5*216 + 4*2 + 0xa*20*216
  _strhbe 0b1110111001001010, display_file + 1*216*20*16 + 5*216 + 4*2 + 0xb*20*216
  _strhbe 0b1001110010010000, display_file + 1*216*20*16 + 5*216 + 4*2 + 0xc*20*216
  _strhbe 0b1100000000000010, display_file + 1*216*20*16 + 5*216 + 4*2 + 0xd*20*216
  _strhbe 0b0101010101010100, display_file + 1*216*20*16 + 5*216 + 4*2 + 0xe*20*216
  _strhbe 0b0000000000000000, display_file + 1*216*20*16 + 5*216 + 4*2 + 0xf*20*216
  ret


po_attr_cjs_setup_regs:
  ldr     x0, = display_file + 1*216*20*16 + 5*216 + 4*2 + 6*20*216
                                                  // section 1, line 5, column 4, pixel row 6
  ret


po_attr_cjs_effects:
// Attributes file update
  _strb   0xd7, attributes_file + 1*108*20 + 5*108 + 4
// Framebuffer updates
  _pixel  0x00ff000000ff0000, BORDER_LEFT + 16*4 + 0x0, BORDER_TOP + 16*(1*20 + 5) + 0x0
  _pixel  0x00ff000000ff0000, BORDER_LEFT + 16*4 + 0x2, BORDER_TOP + 16*(1*20 + 5) + 0x0
  _pixel  0x00ff000000ff0000, BORDER_LEFT + 16*4 + 0x4, BORDER_TOP + 16*(1*20 + 5) + 0x0
  _pixel  0x00ff000000ff0000, BORDER_LEFT + 16*4 + 0x6, BORDER_TOP + 16*(1*20 + 5) + 0x0
  _pixel  0x00ff000000ff0000, BORDER_LEFT + 16*4 + 0x8, BORDER_TOP + 16*(1*20 + 5) + 0x0
  _pixel  0x00ff000000ff0000, BORDER_LEFT + 16*4 + 0xa, BORDER_TOP + 16*(1*20 + 5) + 0x0
  _pixel  0x00ff000000ff0000, BORDER_LEFT + 16*4 + 0xc, BORDER_TOP + 16*(1*20 + 5) + 0x0
  _pixel  0x00ff000000ff0000, BORDER_LEFT + 16*4 + 0xe, BORDER_TOP + 16*(1*20 + 5) + 0x0
  _pixel  0x00ffffff00ff0000, BORDER_LEFT + 16*4 + 0x0, BORDER_TOP + 16*(1*20 + 5) + 0x1
  _pixel  0x00ffffff00ffffff, BORDER_LEFT + 16*4 + 0x2, BORDER_TOP + 16*(1*20 + 5) + 0x1
  _pixel  0x00ffffff00ffffff, BORDER_LEFT + 16*4 + 0x4, BORDER_TOP + 16*(1*20 + 5) + 0x1
  _pixel  0x00ffffff00ffffff, BORDER_LEFT + 16*4 + 0x6, BORDER_TOP + 16*(1*20 + 5) + 0x1
  _pixel  0x00ffffff00ffffff, BORDER_LEFT + 16*4 + 0x8, BORDER_TOP + 16*(1*20 + 5) + 0x1
  _pixel  0x00ffffff00ffffff, BORDER_LEFT + 16*4 + 0xa, BORDER_TOP + 16*(1*20 + 5) + 0x1
  _pixel  0x00ffffff00ffffff, BORDER_LEFT + 16*4 + 0xc, BORDER_TOP + 16*(1*20 + 5) + 0x1
  _pixel  0x00ff000000ff0000, BORDER_LEFT + 16*4 + 0xe, BORDER_TOP + 16*(1*20 + 5) + 0x1
  _pixel  0x00ffffff00ffffff, BORDER_LEFT + 16*4 + 0x0, BORDER_TOP + 16*(1*20 + 5) + 0x2
  _pixel  0x00ffffff00ff0000, BORDER_LEFT + 16*4 + 0x2, BORDER_TOP + 16*(1*20 + 5) + 0x2
  _pixel  0x00ff000000ffffff, BORDER_LEFT + 16*4 + 0x4, BORDER_TOP + 16*(1*20 + 5) + 0x2
  _pixel  0x00ff000000ffffff, BORDER_LEFT + 16*4 + 0x6, BORDER_TOP + 16*(1*20 + 5) + 0x2
  _pixel  0x00ff000000ffffff, BORDER_LEFT + 16*4 + 0x8, BORDER_TOP + 16*(1*20 + 5) + 0x2
  _pixel  0x00ff000000ff0000, BORDER_LEFT + 16*4 + 0xa, BORDER_TOP + 16*(1*20 + 5) + 0x2
  _pixel  0x00ffffff00ff0000, BORDER_LEFT + 16*4 + 0xc, BORDER_TOP + 16*(1*20 + 5) + 0x2
  _pixel  0x00ff000000ffffff, BORDER_LEFT + 16*4 + 0xe, BORDER_TOP + 16*(1*20 + 5) + 0x2
  _pixel  0x00ffffff00ffffff, BORDER_LEFT + 16*4 + 0x0, BORDER_TOP + 16*(1*20 + 5) + 0x3
  _pixel  0x00ffffff00ffffff, BORDER_LEFT + 16*4 + 0x2, BORDER_TOP + 16*(1*20 + 5) + 0x3
  _pixel  0x00ffffff00ffffff, BORDER_LEFT + 16*4 + 0x4, BORDER_TOP + 16*(1*20 + 5) + 0x3
  _pixel  0x00ffffff00ffffff, BORDER_LEFT + 16*4 + 0x6, BORDER_TOP + 16*(1*20 + 5) + 0x3
  _pixel  0x00ffffff00ffffff, BORDER_LEFT + 16*4 + 0x8, BORDER_TOP + 16*(1*20 + 5) + 0x3
  _pixel  0x00ff000000ffffff, BORDER_LEFT + 16*4 + 0xa, BORDER_TOP + 16*(1*20 + 5) + 0x3
  _pixel  0x00ff000000ffffff, BORDER_LEFT + 16*4 + 0xc, BORDER_TOP + 16*(1*20 + 5) + 0x3
  _pixel  0x00ff000000ffffff, BORDER_LEFT + 16*4 + 0xe, BORDER_TOP + 16*(1*20 + 5) + 0x3
  _pixel  0x00ff000000ffffff, BORDER_LEFT + 16*4 + 0x0, BORDER_TOP + 16*(1*20 + 5) + 0x4
  _pixel  0x00ffffff00ffffff, BORDER_LEFT + 16*4 + 0x2, BORDER_TOP + 16*(1*20 + 5) + 0x4
  _pixel  0x00ffffff00ffffff, BORDER_LEFT + 16*4 + 0x4, BORDER_TOP + 16*(1*20 + 5) + 0x4
  _pixel  0x00ffffff00ffffff, BORDER_LEFT + 16*4 + 0x6, BORDER_TOP + 16*(1*20 + 5) + 0x4
  _pixel  0x00ffffff00ffffff, BORDER_LEFT + 16*4 + 0x8, BORDER_TOP + 16*(1*20 + 5) + 0x4
  _pixel  0x00ffffff00ff0000, BORDER_LEFT + 16*4 + 0xa, BORDER_TOP + 16*(1*20 + 5) + 0x4
  _pixel  0x00ff000000ffffff, BORDER_LEFT + 16*4 + 0xc, BORDER_TOP + 16*(1*20 + 5) + 0x4
  _pixel  0x00ff000000ff0000, BORDER_LEFT + 16*4 + 0xe, BORDER_TOP + 16*(1*20 + 5) + 0x4
  _pixel  0x00ffffff00ffffff, BORDER_LEFT + 16*4 + 0x0, BORDER_TOP + 16*(1*20 + 5) + 0x5
  _pixel  0x00ffffff00ffffff, BORDER_LEFT + 16*4 + 0x2, BORDER_TOP + 16*(1*20 + 5) + 0x5
  _pixel  0x00ffffff00ff0000, BORDER_LEFT + 16*4 + 0x4, BORDER_TOP + 16*(1*20 + 5) + 0x5
  _pixel  0x00ffffff00ffffff, BORDER_LEFT + 16*4 + 0x6, BORDER_TOP + 16*(1*20 + 5) + 0x5
  _pixel  0x00ff000000ffffff, BORDER_LEFT + 16*4 + 0x8, BORDER_TOP + 16*(1*20 + 5) + 0x5
  _pixel  0x00ffffff00ffffff, BORDER_LEFT + 16*4 + 0xa, BORDER_TOP + 16*(1*20 + 5) + 0x5
  _pixel  0x00ff000000ffffff, BORDER_LEFT + 16*4 + 0xc, BORDER_TOP + 16*(1*20 + 5) + 0x5
  _pixel  0x00ff000000ffffff, BORDER_LEFT + 16*4 + 0xe, BORDER_TOP + 16*(1*20 + 5) + 0x5
  _pixel  0x00ff000000ffffff, BORDER_LEFT + 16*4 + 0x0, BORDER_TOP + 16*(1*20 + 5) + 0x6
  _pixel  0x00ff000000ffffff, BORDER_LEFT + 16*4 + 0x2, BORDER_TOP + 16*(1*20 + 5) + 0x6
  _pixel  0x00ffffff00ffffff, BORDER_LEFT + 16*4 + 0x4, BORDER_TOP + 16*(1*20 + 5) + 0x6
  _pixel  0x00ffffff00ff0000, BORDER_LEFT + 16*4 + 0x6, BORDER_TOP + 16*(1*20 + 5) + 0x6
  _pixel  0x00ffffff00ffffff, BORDER_LEFT + 16*4 + 0x8, BORDER_TOP + 16*(1*20 + 5) + 0x6
  _pixel  0x00ffffff00ffffff, BORDER_LEFT + 16*4 + 0xa, BORDER_TOP + 16*(1*20 + 5) + 0x6
  _pixel  0x00ff000000ff0000, BORDER_LEFT + 16*4 + 0xc, BORDER_TOP + 16*(1*20 + 5) + 0x6
  _pixel  0x00ff000000ff0000, BORDER_LEFT + 16*4 + 0xe, BORDER_TOP + 16*(1*20 + 5) + 0x6
  _pixel  0x00ffffff00ffffff, BORDER_LEFT + 16*4 + 0x0, BORDER_TOP + 16*(1*20 + 5) + 0x7
  _pixel  0x00ffffff00ff0000, BORDER_LEFT + 16*4 + 0x2, BORDER_TOP + 16*(1*20 + 5) + 0x7
  _pixel  0x00ffffff00ffffff, BORDER_LEFT + 16*4 + 0x4, BORDER_TOP + 16*(1*20 + 5) + 0x7
  _pixel  0x00ff000000ffffff, BORDER_LEFT + 16*4 + 0x6, BORDER_TOP + 16*(1*20 + 5) + 0x7
  _pixel  0x00ffffff00ffffff, BORDER_LEFT + 16*4 + 0x8, BORDER_TOP + 16*(1*20 + 5) + 0x7
  _pixel  0x00ff000000ffffff, BORDER_LEFT + 16*4 + 0xa, BORDER_TOP + 16*(1*20 + 5) + 0x7
  _pixel  0x00ff000000ffffff, BORDER_LEFT + 16*4 + 0xc, BORDER_TOP + 16*(1*20 + 5) + 0x7
  _pixel  0x00ff000000ffffff, BORDER_LEFT + 16*4 + 0xe, BORDER_TOP + 16*(1*20 + 5) + 0x7
  _pixel  0x00ff000000ffffff, BORDER_LEFT + 16*4 + 0x0, BORDER_TOP + 16*(1*20 + 5) + 0x8
  _pixel  0x00ffffff00ffffff, BORDER_LEFT + 16*4 + 0x2, BORDER_TOP + 16*(1*20 + 5) + 0x8
  _pixel  0x00ffffff00ffffff, BORDER_LEFT + 16*4 + 0x4, BORDER_TOP + 16*(1*20 + 5) + 0x8
  _pixel  0x00ffffff00ffffff, BORDER_LEFT + 16*4 + 0x6, BORDER_TOP + 16*(1*20 + 5) + 0x8
  _pixel  0x00ffffff00ffffff, BORDER_LEFT + 16*4 + 0x8, BORDER_TOP + 16*(1*20 + 5) + 0x8
  _pixel  0x00ffffff00ff0000, BORDER_LEFT + 16*4 + 0xa, BORDER_TOP + 16*(1*20 + 5) + 0x8
  _pixel  0x00ff000000ffffff, BORDER_LEFT + 16*4 + 0xc, BORDER_TOP + 16*(1*20 + 5) + 0x8
  _pixel  0x00ff000000ff0000, BORDER_LEFT + 16*4 + 0xe, BORDER_TOP + 16*(1*20 + 5) + 0x8
  _pixel  0x00ffffff00ffffff, BORDER_LEFT + 16*4 + 0x0, BORDER_TOP + 16*(1*20 + 5) + 0x9
  _pixel  0x00ffffff00ffffff, BORDER_LEFT + 16*4 + 0x2, BORDER_TOP + 16*(1*20 + 5) + 0x9
  _pixel  0x00ff000000ffffff, BORDER_LEFT + 16*4 + 0x4, BORDER_TOP + 16*(1*20 + 5) + 0x9
  _pixel  0x00ffffff00ffffff, BORDER_LEFT + 16*4 + 0x6, BORDER_TOP + 16*(1*20 + 5) + 0x9
  _pixel  0x00ff000000ffffff, BORDER_LEFT + 16*4 + 0x8, BORDER_TOP + 16*(1*20 + 5) + 0x9
  _pixel  0x00ffffff00ffffff, BORDER_LEFT + 16*4 + 0xa, BORDER_TOP + 16*(1*20 + 5) + 0x9
  _pixel  0x00ff000000ff0000, BORDER_LEFT + 16*4 + 0xc, BORDER_TOP + 16*(1*20 + 5) + 0x9
  _pixel  0x00ff000000ffffff, BORDER_LEFT + 16*4 + 0xe, BORDER_TOP + 16*(1*20 + 5) + 0x9
  _pixel  0x00ff000000ffffff, BORDER_LEFT + 16*4 + 0x0, BORDER_TOP + 16*(1*20 + 5) + 0xa
  _pixel  0x00ffffff00ffffff, BORDER_LEFT + 16*4 + 0x2, BORDER_TOP + 16*(1*20 + 5) + 0xa
  _pixel  0x00ffffff00ff0000, BORDER_LEFT + 16*4 + 0x4, BORDER_TOP + 16*(1*20 + 5) + 0xa
  _pixel  0x00ffffff00ffffff, BORDER_LEFT + 16*4 + 0x6, BORDER_TOP + 16*(1*20 + 5) + 0xa
  _pixel  0x00ff000000ff0000, BORDER_LEFT + 16*4 + 0x8, BORDER_TOP + 16*(1*20 + 5) + 0xa
  _pixel  0x00ff000000ffffff, BORDER_LEFT + 16*4 + 0xa, BORDER_TOP + 16*(1*20 + 5) + 0xa
  _pixel  0x00ff000000ff0000, BORDER_LEFT + 16*4 + 0xc, BORDER_TOP + 16*(1*20 + 5) + 0xa
  _pixel  0x00ff000000ff0000, BORDER_LEFT + 16*4 + 0xe, BORDER_TOP + 16*(1*20 + 5) + 0xa
  _pixel  0x00ffffff00ffffff, BORDER_LEFT + 16*4 + 0x0, BORDER_TOP + 16*(1*20 + 5) + 0xb
  _pixel  0x00ff000000ffffff, BORDER_LEFT + 16*4 + 0x2, BORDER_TOP + 16*(1*20 + 5) + 0xb
  _pixel  0x00ffffff00ffffff, BORDER_LEFT + 16*4 + 0x4, BORDER_TOP + 16*(1*20 + 5) + 0xb
  _pixel  0x00ff000000ffffff, BORDER_LEFT + 16*4 + 0x6, BORDER_TOP + 16*(1*20 + 5) + 0xb
  _pixel  0x00ffffff00ff0000, BORDER_LEFT + 16*4 + 0x8, BORDER_TOP + 16*(1*20 + 5) + 0xb
  _pixel  0x00ff000000ff0000, BORDER_LEFT + 16*4 + 0xa, BORDER_TOP + 16*(1*20 + 5) + 0xb
  _pixel  0x00ff000000ffffff, BORDER_LEFT + 16*4 + 0xc, BORDER_TOP + 16*(1*20 + 5) + 0xb
  _pixel  0x00ff000000ffffff, BORDER_LEFT + 16*4 + 0xe, BORDER_TOP + 16*(1*20 + 5) + 0xb
  _pixel  0x00ff000000ffffff, BORDER_LEFT + 16*4 + 0x0, BORDER_TOP + 16*(1*20 + 5) + 0xc
  _pixel  0x00ffffff00ff0000, BORDER_LEFT + 16*4 + 0x2, BORDER_TOP + 16*(1*20 + 5) + 0xc
  _pixel  0x00ffffff00ffffff, BORDER_LEFT + 16*4 + 0x4, BORDER_TOP + 16*(1*20 + 5) + 0xc
  _pixel  0x00ff000000ff0000, BORDER_LEFT + 16*4 + 0x6, BORDER_TOP + 16*(1*20 + 5) + 0xc
  _pixel  0x00ff000000ffffff, BORDER_LEFT + 16*4 + 0x8, BORDER_TOP + 16*(1*20 + 5) + 0xc
  _pixel  0x00ffffff00ff0000, BORDER_LEFT + 16*4 + 0xa, BORDER_TOP + 16*(1*20 + 5) + 0xc
  _pixel  0x00ff000000ff0000, BORDER_LEFT + 16*4 + 0xc, BORDER_TOP + 16*(1*20 + 5) + 0xc
  _pixel  0x00ff000000ff0000, BORDER_LEFT + 16*4 + 0xe, BORDER_TOP + 16*(1*20 + 5) + 0xc
  _pixel  0x00ffffff00ffffff, BORDER_LEFT + 16*4 + 0x0, BORDER_TOP + 16*(1*20 + 5) + 0xd
  _pixel  0x00ff000000ff0000, BORDER_LEFT + 16*4 + 0x2, BORDER_TOP + 16*(1*20 + 5) + 0xd
  _pixel  0x00ff000000ff0000, BORDER_LEFT + 16*4 + 0x4, BORDER_TOP + 16*(1*20 + 5) + 0xd
  _pixel  0x00ff000000ff0000, BORDER_LEFT + 16*4 + 0x6, BORDER_TOP + 16*(1*20 + 5) + 0xd
  _pixel  0x00ff000000ff0000, BORDER_LEFT + 16*4 + 0x8, BORDER_TOP + 16*(1*20 + 5) + 0xd
  _pixel  0x00ff000000ff0000, BORDER_LEFT + 16*4 + 0xa, BORDER_TOP + 16*(1*20 + 5) + 0xd
  _pixel  0x00ff000000ff0000, BORDER_LEFT + 16*4 + 0xc, BORDER_TOP + 16*(1*20 + 5) + 0xd
  _pixel  0x00ff000000ffffff, BORDER_LEFT + 16*4 + 0xe, BORDER_TOP + 16*(1*20 + 5) + 0xd
  _pixel  0x00ffffff00ff0000, BORDER_LEFT + 16*4 + 0x0, BORDER_TOP + 16*(1*20 + 5) + 0xe
  _pixel  0x00ffffff00ff0000, BORDER_LEFT + 16*4 + 0x2, BORDER_TOP + 16*(1*20 + 5) + 0xe
  _pixel  0x00ffffff00ff0000, BORDER_LEFT + 16*4 + 0x4, BORDER_TOP + 16*(1*20 + 5) + 0xe
  _pixel  0x00ffffff00ff0000, BORDER_LEFT + 16*4 + 0x6, BORDER_TOP + 16*(1*20 + 5) + 0xe
  _pixel  0x00ffffff00ff0000, BORDER_LEFT + 16*4 + 0x8, BORDER_TOP + 16*(1*20 + 5) + 0xe
  _pixel  0x00ffffff00ff0000, BORDER_LEFT + 16*4 + 0xa, BORDER_TOP + 16*(1*20 + 5) + 0xe
  _pixel  0x00ffffff00ff0000, BORDER_LEFT + 16*4 + 0xc, BORDER_TOP + 16*(1*20 + 5) + 0xe
  _pixel  0x00ff000000ff0000, BORDER_LEFT + 16*4 + 0xe, BORDER_TOP + 16*(1*20 + 5) + 0xe
  _pixel  0x00ff000000ff0000, BORDER_LEFT + 16*4 + 0x0, BORDER_TOP + 16*(1*20 + 5) + 0xf
  _pixel  0x00ff000000ff0000, BORDER_LEFT + 16*4 + 0x2, BORDER_TOP + 16*(1*20 + 5) + 0xf
  _pixel  0x00ff000000ff0000, BORDER_LEFT + 16*4 + 0x4, BORDER_TOP + 16*(1*20 + 5) + 0xf
  _pixel  0x00ff000000ff0000, BORDER_LEFT + 16*4 + 0x6, BORDER_TOP + 16*(1*20 + 5) + 0xf
  _pixel  0x00ff000000ff0000, BORDER_LEFT + 16*4 + 0x8, BORDER_TOP + 16*(1*20 + 5) + 0xf
  _pixel  0x00ff000000ff0000, BORDER_LEFT + 16*4 + 0xa, BORDER_TOP + 16*(1*20 + 5) + 0xf
  _pixel  0x00ff000000ff0000, BORDER_LEFT + 16*4 + 0xc, BORDER_TOP + 16*(1*20 + 5) + 0xf
  _pixel  0x00ff000000ff0000, BORDER_LEFT + 16*4 + 0xe, BORDER_TOP + 16*(1*20 + 5) + 0xf
  ret


# TODO: comment all of this!!!
po_attr_cjs_effects_regs:
// section 1, line 5, character 4, plus 16 pixel row increments of 216*20
  adr     x0, display_file + 1*216*16*20 + 5*216 + 4*2 + 16*216*20
  mov     x1, #0
  mov     x3, #0
  mov     x5, #0xff
  mov     x6, #0
  mov     x7, #0xff0000
  mov     x8, #0
  adr     x9, mbreq
  mov     x10, #4
  movl    w11, 0x20f61
  mov     x12, #108
  mov     x13, #0xff
  mov     x14, #0xff
  mov     x15, #0xffffff
  mov     x16, #0xa90
  mov     x17, #0xd7
  mov     x18, #0x5
  adr     x24, attributes_file
  nzcv    #0b0110
  ret
