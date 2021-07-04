# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.



.text
.align 2


# poke_address_1 pokes an address above the attributes file
poke_address_1_setup_regs:
  adrp    x0, poke_address_test
  add     x0, x0, :lo12:poke_address_test
  mov     x1, #~0
  ret


poke_address_1_effects:
  _strb   0xff, poke_address_test
  ret


poke_address_1_effects_regs:
  adr     x9, display_file
  adr     x10, attributes_file_end
  movl    w11, (poke_address_test - attributes_file)
  nzcv    #0b0010
  ret


# poke_address_2 pokes an address in the display file
poke_address_2_setup:
  _strb   0x38, attributes_file + 16*108
  ret


poke_address_2_setup_regs:
  adr     x0, display_file + 16*216
  mov     x1, #34
  ret


poke_address_2_effects:
  _strb   #34, display_file + 16*216
  _pixel  0x00cccccc00cccccc, BORDER_LEFT + 16*0 + 0x0, BORDER_TOP + 16*(0*20 + 16) + 0x0
  _pixel  0x00cccccc00000000, BORDER_LEFT + 16*0 + 0x2, BORDER_TOP + 16*(0*20 + 16) + 0x0
  _pixel  0x00cccccc00cccccc, BORDER_LEFT + 16*0 + 0x4, BORDER_TOP + 16*(0*20 + 16) + 0x0
  _pixel  0x00cccccc00000000, BORDER_LEFT + 16*0 + 0x6, BORDER_TOP + 16*(0*20 + 16) + 0x0
  ret


poke_address_2_effects_regs:
  mov     w1, 0x2200
  movl    w3, 0x00cccccc
  mov     w5, 0xcc
  mov     x6, 0xcc
  movl    w7, 0x00cccccc
  mov     x8, 0x0
  adr     x9, mbreq
  mov     x10, 0x0
  mov     x11, 0xd80
  mov     x12, 0x6c
  mov     x13, 0x0
  mov     x14, 0x0
  mov     x15, 0x0
  mov     x16, 0x6c0
  mov     x17, 0x38
  mov     x18, 0x0
  nzcv    #0b0110
  ret


# poke_address_3 pokes an address in the attributes file
poke_address_3_setup:
  _strb   #93, attributes_file + 2*20*108 + 12*108 + 7
  _strb   #11, display_file + 2*216*16*20 + 12*216 + 7*2 + 0x0*216*20 + 0
  _strb   #12, display_file + 2*216*16*20 + 12*216 + 7*2 + 0x0*216*20 + 1
  _strb   #13, display_file + 2*216*16*20 + 12*216 + 7*2 + 0x1*216*20 + 0
  _strb   #14, display_file + 2*216*16*20 + 12*216 + 7*2 + 0x1*216*20 + 1
  _strb   #15, display_file + 2*216*16*20 + 12*216 + 7*2 + 0x2*216*20 + 0
  _strb   #16, display_file + 2*216*16*20 + 12*216 + 7*2 + 0x2*216*20 + 1
  _strb   #17, display_file + 2*216*16*20 + 12*216 + 7*2 + 0x3*216*20 + 0
  _strb   #18, display_file + 2*216*16*20 + 12*216 + 7*2 + 0x3*216*20 + 1
  _strb   #19, display_file + 2*216*16*20 + 12*216 + 7*2 + 0x4*216*20 + 0
  _strb   #20, display_file + 2*216*16*20 + 12*216 + 7*2 + 0x4*216*20 + 1
  _strb   #21, display_file + 2*216*16*20 + 12*216 + 7*2 + 0x5*216*20 + 0
  _strb   #22, display_file + 2*216*16*20 + 12*216 + 7*2 + 0x5*216*20 + 1
  _strb   #23, display_file + 2*216*16*20 + 12*216 + 7*2 + 0x6*216*20 + 0
  _strb   #24, display_file + 2*216*16*20 + 12*216 + 7*2 + 0x6*216*20 + 1
  _strb   #25, display_file + 2*216*16*20 + 12*216 + 7*2 + 0x7*216*20 + 0
  _strb   #26, display_file + 2*216*16*20 + 12*216 + 7*2 + 0x7*216*20 + 1
  _strb   #27, display_file + 2*216*16*20 + 12*216 + 7*2 + 0x8*216*20 + 0
  _strb   #28, display_file + 2*216*16*20 + 12*216 + 7*2 + 0x8*216*20 + 1
  _strb   #29, display_file + 2*216*16*20 + 12*216 + 7*2 + 0x9*216*20 + 0
  _strb   #30, display_file + 2*216*16*20 + 12*216 + 7*2 + 0x9*216*20 + 1
  _strb   #31, display_file + 2*216*16*20 + 12*216 + 7*2 + 0xa*216*20 + 0
  _strb   #32, display_file + 2*216*16*20 + 12*216 + 7*2 + 0xa*216*20 + 1
  _strb   #33, display_file + 2*216*16*20 + 12*216 + 7*2 + 0xb*216*20 + 0
  _strb   #34, display_file + 2*216*16*20 + 12*216 + 7*2 + 0xb*216*20 + 1
  _strb   #35, display_file + 2*216*16*20 + 12*216 + 7*2 + 0xc*216*20 + 0
  _strb   #36, display_file + 2*216*16*20 + 12*216 + 7*2 + 0xc*216*20 + 1
  _strb   #37, display_file + 2*216*16*20 + 12*216 + 7*2 + 0xd*216*20 + 0
  _strb   #38, display_file + 2*216*16*20 + 12*216 + 7*2 + 0xd*216*20 + 1
  _strb   #39, display_file + 2*216*16*20 + 12*216 + 7*2 + 0xe*216*20 + 0
  _strb   #40, display_file + 2*216*16*20 + 12*216 + 7*2 + 0xe*216*20 + 1
  _strb   #41, display_file + 2*216*16*20 + 12*216 + 7*2 + 0xf*216*20 + 0
  _strb   #42, display_file + 2*216*16*20 + 12*216 + 7*2 + 0xf*216*20 + 1
  ret


poke_address_3_setup_regs:
  adr     x0, attributes_file + 2*20*108 + 12*108 + 7
  mov     x1, #78
  ret


poke_address_3_effects:

  _strb   #78, attributes_file + 2*20*108 + 12*108 + 7

  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0x0, BORDER_TOP + 16*(2*20 + 12) + 0x0
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0x2, BORDER_TOP + 16*(2*20 + 12) + 0x0
  _pixel  0x000000ff00ffff00, BORDER_LEFT + 16*7 + 0x4, BORDER_TOP + 16*(2*20 + 12) + 0x0
  _pixel  0x00ffff0000ffff00, BORDER_LEFT + 16*7 + 0x6, BORDER_TOP + 16*(2*20 + 12) + 0x0
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0x8, BORDER_TOP + 16*(2*20 + 12) + 0x0
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0xa, BORDER_TOP + 16*(2*20 + 12) + 0x0
  _pixel  0x00ffff0000ffff00, BORDER_LEFT + 16*7 + 0xc, BORDER_TOP + 16*(2*20 + 12) + 0x0
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0xe, BORDER_TOP + 16*(2*20 + 12) + 0x0
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0x0, BORDER_TOP + 16*(2*20 + 12) + 0x1
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0x2, BORDER_TOP + 16*(2*20 + 12) + 0x1
  _pixel  0x00ffff0000ffff00, BORDER_LEFT + 16*7 + 0x4, BORDER_TOP + 16*(2*20 + 12) + 0x1
  _pixel  0x00ffff00000000ff, BORDER_LEFT + 16*7 + 0x6, BORDER_TOP + 16*(2*20 + 12) + 0x1
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0x8, BORDER_TOP + 16*(2*20 + 12) + 0x1
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0xa, BORDER_TOP + 16*(2*20 + 12) + 0x1
  _pixel  0x00ffff0000ffff00, BORDER_LEFT + 16*7 + 0xc, BORDER_TOP + 16*(2*20 + 12) + 0x1
  _pixel  0x000000ff00ffff00, BORDER_LEFT + 16*7 + 0xe, BORDER_TOP + 16*(2*20 + 12) + 0x1
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0x0, BORDER_TOP + 16*(2*20 + 12) + 0x2
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0x2, BORDER_TOP + 16*(2*20 + 12) + 0x2
  _pixel  0x00ffff0000ffff00, BORDER_LEFT + 16*7 + 0x4, BORDER_TOP + 16*(2*20 + 12) + 0x2
  _pixel  0x00ffff0000ffff00, BORDER_LEFT + 16*7 + 0x6, BORDER_TOP + 16*(2*20 + 12) + 0x2
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0x8, BORDER_TOP + 16*(2*20 + 12) + 0x2
  _pixel  0x00ffff00000000ff, BORDER_LEFT + 16*7 + 0xa, BORDER_TOP + 16*(2*20 + 12) + 0x2
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0xc, BORDER_TOP + 16*(2*20 + 12) + 0x2
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0xe, BORDER_TOP + 16*(2*20 + 12) + 0x2
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0x0, BORDER_TOP + 16*(2*20 + 12) + 0x3
  _pixel  0x00ffff00000000ff, BORDER_LEFT + 16*7 + 0x2, BORDER_TOP + 16*(2*20 + 12) + 0x3
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0x4, BORDER_TOP + 16*(2*20 + 12) + 0x3
  _pixel  0x00ffff00000000ff, BORDER_LEFT + 16*7 + 0x6, BORDER_TOP + 16*(2*20 + 12) + 0x3
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0x8, BORDER_TOP + 16*(2*20 + 12) + 0x3
  _pixel  0x00ffff00000000ff, BORDER_LEFT + 16*7 + 0xa, BORDER_TOP + 16*(2*20 + 12) + 0x3
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0xc, BORDER_TOP + 16*(2*20 + 12) + 0x3
  _pixel  0x000000ff00ffff00, BORDER_LEFT + 16*7 + 0xe, BORDER_TOP + 16*(2*20 + 12) + 0x3
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0x0, BORDER_TOP + 16*(2*20 + 12) + 0x4
  _pixel  0x00ffff00000000ff, BORDER_LEFT + 16*7 + 0x2, BORDER_TOP + 16*(2*20 + 12) + 0x4
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0x4, BORDER_TOP + 16*(2*20 + 12) + 0x4
  _pixel  0x00ffff0000ffff00, BORDER_LEFT + 16*7 + 0x6, BORDER_TOP + 16*(2*20 + 12) + 0x4
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0x8, BORDER_TOP + 16*(2*20 + 12) + 0x4
  _pixel  0x00ffff00000000ff, BORDER_LEFT + 16*7 + 0xa, BORDER_TOP + 16*(2*20 + 12) + 0x4
  _pixel  0x00ffff00000000ff, BORDER_LEFT + 16*7 + 0xc, BORDER_TOP + 16*(2*20 + 12) + 0x4
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0xe, BORDER_TOP + 16*(2*20 + 12) + 0x4
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0x0, BORDER_TOP + 16*(2*20 + 12) + 0x5
  _pixel  0x00ffff00000000ff, BORDER_LEFT + 16*7 + 0x2, BORDER_TOP + 16*(2*20 + 12) + 0x5
  _pixel  0x00ffff00000000ff, BORDER_LEFT + 16*7 + 0x4, BORDER_TOP + 16*(2*20 + 12) + 0x5
  _pixel  0x00ffff00000000ff, BORDER_LEFT + 16*7 + 0x6, BORDER_TOP + 16*(2*20 + 12) + 0x5
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0x8, BORDER_TOP + 16*(2*20 + 12) + 0x5
  _pixel  0x00ffff00000000ff, BORDER_LEFT + 16*7 + 0xa, BORDER_TOP + 16*(2*20 + 12) + 0x5
  _pixel  0x00ffff00000000ff, BORDER_LEFT + 16*7 + 0xc, BORDER_TOP + 16*(2*20 + 12) + 0x5
  _pixel  0x000000ff00ffff00, BORDER_LEFT + 16*7 + 0xe, BORDER_TOP + 16*(2*20 + 12) + 0x5
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0x0, BORDER_TOP + 16*(2*20 + 12) + 0x6
  _pixel  0x00ffff00000000ff, BORDER_LEFT + 16*7 + 0x2, BORDER_TOP + 16*(2*20 + 12) + 0x6
  _pixel  0x00ffff00000000ff, BORDER_LEFT + 16*7 + 0x4, BORDER_TOP + 16*(2*20 + 12) + 0x6
  _pixel  0x00ffff0000ffff00, BORDER_LEFT + 16*7 + 0x6, BORDER_TOP + 16*(2*20 + 12) + 0x6
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0x8, BORDER_TOP + 16*(2*20 + 12) + 0x6
  _pixel  0x00ffff00000000ff, BORDER_LEFT + 16*7 + 0xa, BORDER_TOP + 16*(2*20 + 12) + 0x6
  _pixel  0x000000ff00ffff00, BORDER_LEFT + 16*7 + 0xc, BORDER_TOP + 16*(2*20 + 12) + 0x6
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0xe, BORDER_TOP + 16*(2*20 + 12) + 0x6
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0x0, BORDER_TOP + 16*(2*20 + 12) + 0x7
  _pixel  0x00ffff00000000ff, BORDER_LEFT + 16*7 + 0x2, BORDER_TOP + 16*(2*20 + 12) + 0x7
  _pixel  0x000000ff00ffff00, BORDER_LEFT + 16*7 + 0x4, BORDER_TOP + 16*(2*20 + 12) + 0x7
  _pixel  0x00ffff00000000ff, BORDER_LEFT + 16*7 + 0x6, BORDER_TOP + 16*(2*20 + 12) + 0x7
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0x8, BORDER_TOP + 16*(2*20 + 12) + 0x7
  _pixel  0x00ffff00000000ff, BORDER_LEFT + 16*7 + 0xa, BORDER_TOP + 16*(2*20 + 12) + 0x7
  _pixel  0x000000ff00ffff00, BORDER_LEFT + 16*7 + 0xc, BORDER_TOP + 16*(2*20 + 12) + 0x7
  _pixel  0x000000ff00ffff00, BORDER_LEFT + 16*7 + 0xe, BORDER_TOP + 16*(2*20 + 12) + 0x7
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0x0, BORDER_TOP + 16*(2*20 + 12) + 0x8
  _pixel  0x00ffff00000000ff, BORDER_LEFT + 16*7 + 0x2, BORDER_TOP + 16*(2*20 + 12) + 0x8
  _pixel  0x000000ff00ffff00, BORDER_LEFT + 16*7 + 0x4, BORDER_TOP + 16*(2*20 + 12) + 0x8
  _pixel  0x00ffff0000ffff00, BORDER_LEFT + 16*7 + 0x6, BORDER_TOP + 16*(2*20 + 12) + 0x8
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0x8, BORDER_TOP + 16*(2*20 + 12) + 0x8
  _pixel  0x00ffff00000000ff, BORDER_LEFT + 16*7 + 0xa, BORDER_TOP + 16*(2*20 + 12) + 0x8
  _pixel  0x00ffff0000ffff00, BORDER_LEFT + 16*7 + 0xc, BORDER_TOP + 16*(2*20 + 12) + 0x8
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0xe, BORDER_TOP + 16*(2*20 + 12) + 0x8
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0x0, BORDER_TOP + 16*(2*20 + 12) + 0x9
  _pixel  0x00ffff00000000ff, BORDER_LEFT + 16*7 + 0x2, BORDER_TOP + 16*(2*20 + 12) + 0x9
  _pixel  0x00ffff0000ffff00, BORDER_LEFT + 16*7 + 0x4, BORDER_TOP + 16*(2*20 + 12) + 0x9
  _pixel  0x00ffff00000000ff, BORDER_LEFT + 16*7 + 0x6, BORDER_TOP + 16*(2*20 + 12) + 0x9
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0x8, BORDER_TOP + 16*(2*20 + 12) + 0x9
  _pixel  0x00ffff00000000ff, BORDER_LEFT + 16*7 + 0xa, BORDER_TOP + 16*(2*20 + 12) + 0x9
  _pixel  0x00ffff0000ffff00, BORDER_LEFT + 16*7 + 0xc, BORDER_TOP + 16*(2*20 + 12) + 0x9
  _pixel  0x000000ff00ffff00, BORDER_LEFT + 16*7 + 0xe, BORDER_TOP + 16*(2*20 + 12) + 0x9
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0x0, BORDER_TOP + 16*(2*20 + 12) + 0xa
  _pixel  0x00ffff00000000ff, BORDER_LEFT + 16*7 + 0x2, BORDER_TOP + 16*(2*20 + 12) + 0xa
  _pixel  0x00ffff0000ffff00, BORDER_LEFT + 16*7 + 0x4, BORDER_TOP + 16*(2*20 + 12) + 0xa
  _pixel  0x00ffff0000ffff00, BORDER_LEFT + 16*7 + 0x6, BORDER_TOP + 16*(2*20 + 12) + 0xa
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0x8, BORDER_TOP + 16*(2*20 + 12) + 0xa
  _pixel  0x000000ff00ffff00, BORDER_LEFT + 16*7 + 0xa, BORDER_TOP + 16*(2*20 + 12) + 0xa
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0xc, BORDER_TOP + 16*(2*20 + 12) + 0xa
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0xe, BORDER_TOP + 16*(2*20 + 12) + 0xa
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0x0, BORDER_TOP + 16*(2*20 + 12) + 0xb
  _pixel  0x000000ff00ffff00, BORDER_LEFT + 16*7 + 0x2, BORDER_TOP + 16*(2*20 + 12) + 0xb
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0x4, BORDER_TOP + 16*(2*20 + 12) + 0xb
  _pixel  0x00ffff00000000ff, BORDER_LEFT + 16*7 + 0x6, BORDER_TOP + 16*(2*20 + 12) + 0xb
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0x8, BORDER_TOP + 16*(2*20 + 12) + 0xb
  _pixel  0x000000ff00ffff00, BORDER_LEFT + 16*7 + 0xa, BORDER_TOP + 16*(2*20 + 12) + 0xb
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0xc, BORDER_TOP + 16*(2*20 + 12) + 0xb
  _pixel  0x000000ff00ffff00, BORDER_LEFT + 16*7 + 0xe, BORDER_TOP + 16*(2*20 + 12) + 0xb
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0x0, BORDER_TOP + 16*(2*20 + 12) + 0xc
  _pixel  0x000000ff00ffff00, BORDER_LEFT + 16*7 + 0x2, BORDER_TOP + 16*(2*20 + 12) + 0xc
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0x4, BORDER_TOP + 16*(2*20 + 12) + 0xc
  _pixel  0x00ffff0000ffff00, BORDER_LEFT + 16*7 + 0x6, BORDER_TOP + 16*(2*20 + 12) + 0xc
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0x8, BORDER_TOP + 16*(2*20 + 12) + 0xc
  _pixel  0x000000ff00ffff00, BORDER_LEFT + 16*7 + 0xa, BORDER_TOP + 16*(2*20 + 12) + 0xc
  _pixel  0x00ffff00000000ff, BORDER_LEFT + 16*7 + 0xc, BORDER_TOP + 16*(2*20 + 12) + 0xc
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0xe, BORDER_TOP + 16*(2*20 + 12) + 0xc
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0x0, BORDER_TOP + 16*(2*20 + 12) + 0xd
  _pixel  0x000000ff00ffff00, BORDER_LEFT + 16*7 + 0x2, BORDER_TOP + 16*(2*20 + 12) + 0xd
  _pixel  0x00ffff00000000ff, BORDER_LEFT + 16*7 + 0x4, BORDER_TOP + 16*(2*20 + 12) + 0xd
  _pixel  0x00ffff00000000ff, BORDER_LEFT + 16*7 + 0x6, BORDER_TOP + 16*(2*20 + 12) + 0xd
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0x8, BORDER_TOP + 16*(2*20 + 12) + 0xd
  _pixel  0x000000ff00ffff00, BORDER_LEFT + 16*7 + 0xa, BORDER_TOP + 16*(2*20 + 12) + 0xd
  _pixel  0x00ffff00000000ff, BORDER_LEFT + 16*7 + 0xc, BORDER_TOP + 16*(2*20 + 12) + 0xd
  _pixel  0x000000ff00ffff00, BORDER_LEFT + 16*7 + 0xe, BORDER_TOP + 16*(2*20 + 12) + 0xd
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0x0, BORDER_TOP + 16*(2*20 + 12) + 0xe
  _pixel  0x000000ff00ffff00, BORDER_LEFT + 16*7 + 0x2, BORDER_TOP + 16*(2*20 + 12) + 0xe
  _pixel  0x00ffff00000000ff, BORDER_LEFT + 16*7 + 0x4, BORDER_TOP + 16*(2*20 + 12) + 0xe
  _pixel  0x00ffff0000ffff00, BORDER_LEFT + 16*7 + 0x6, BORDER_TOP + 16*(2*20 + 12) + 0xe
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0x8, BORDER_TOP + 16*(2*20 + 12) + 0xe
  _pixel  0x000000ff00ffff00, BORDER_LEFT + 16*7 + 0xa, BORDER_TOP + 16*(2*20 + 12) + 0xe
  _pixel  0x000000ff00ffff00, BORDER_LEFT + 16*7 + 0xc, BORDER_TOP + 16*(2*20 + 12) + 0xe
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0xe, BORDER_TOP + 16*(2*20 + 12) + 0xe
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0x0, BORDER_TOP + 16*(2*20 + 12) + 0xf
  _pixel  0x000000ff00ffff00, BORDER_LEFT + 16*7 + 0x2, BORDER_TOP + 16*(2*20 + 12) + 0xf
  _pixel  0x000000ff00ffff00, BORDER_LEFT + 16*7 + 0x4, BORDER_TOP + 16*(2*20 + 12) + 0xf
  _pixel  0x00ffff00000000ff, BORDER_LEFT + 16*7 + 0x6, BORDER_TOP + 16*(2*20 + 12) + 0xf
  _pixel  0x000000ff000000ff, BORDER_LEFT + 16*7 + 0x8, BORDER_TOP + 16*(2*20 + 12) + 0xf
  _pixel  0x000000ff00ffff00, BORDER_LEFT + 16*7 + 0xa, BORDER_TOP + 16*(2*20 + 12) + 0xf
  _pixel  0x000000ff00ffff00, BORDER_LEFT + 16*7 + 0xc, BORDER_TOP + 16*(2*20 + 12) + 0xf
  _pixel  0x000000ff00ffff00, BORDER_LEFT + 16*7 + 0xe, BORDER_TOP + 16*(2*20 + 12) + 0xf
  ret


poke_address_3_effects_regs:
// section 2, line 12, character 7, plus 16 pixel row increments of 216*20
  adr     x0, display_file + 2*216*16*20 + 12*216 + 7*2 + 16*216*20
  mov     w1, #0x2a00
  mov     w3, #0x0
  mov     w5, #0x0
  mov     w6, #0x0
  mov     w7, #0xff
  mov     w8, #0x0
  adr     x9, mbreq
  mov     w10, #0x7
  movl    w11, 0x0003234f
  mov     w12, #0x6c
  mov     w13, #0xff
  mov     w14, #0xff
  mov     w15, #0x00ffff00
  mov     w16, #0x15f7
  mov     w17, #0x4e
  mov     w18, #0x0a
  nzcv    #0b0110
  ret


poke_address_4_setup_regs:
  adr     x0, COL
  mov     x1, #17
  ret


poke_address_4_effects:
  _strb   17, COL
  ret


poke_address_4_effects_regs:
  adr     x9, display_file
  movl    w11, (COL - attributes_file)
  sxtw    x11, w11
  nzcv    #0b1000
  ret


.bss
.align 0
poke_address_test: .space 1
