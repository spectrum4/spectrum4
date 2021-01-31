# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.



.text
.align 2


# poke_address_1 pokes an address above the attributes file
poke_address_1_setup:
  ret


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
  adr     x0, display_file
  adr     x1, attributes_file_end
  1:
    stp     xzr, xzr, [x0], #16
    cmp     x0, x1
    b.ne    1b
  adr     x0, framebuffer
  ldp     w0, w1, [x0]
  add     w1, w0, w1
  1:
    stp     xzr, xzr, [x0], #16
    cmp     x0, x1
    b.ne    1b
  ret


poke_address_2_setup_regs:
  adr     x0, display_file + 3456
  mov     x1, #34
  nzcv    #0b0110
  ret


poke_address_2_effects:
  _strb   #34, display_file + 3456
  ret


poke_address_2_effects_regs:
  mov     x1, 0x2200
  mov     x3, 0x0
  mov     x5, 0x0
  mov     x6, 0x0
  mov     x7, 0x0
  mov     x8, 0x0
  adr     x9, mbreq
  mov     x10, 0x0
  mov     x11, 0xd80
  mov     x12, 0x6c
  mov     x13, 0x0
  mov     x14, 0x0
  mov     x15, 0x0
  mov     x16, 0x6c0
  mov     x17, 0x0
  mov     x18, 0x0
  ret


# poke_address_3 pokes an address in the attributes file
poke_address_3_setup:
  adr     x0, display_file
  adr     x1, attributes_file_end
  1:
    stp     xzr, xzr, [x0], #16
    cmp     x0, x1
    b.ne    1b
  adr     x0, framebuffer
  ldp     w0, w1, [x0]
  add     w1, w0, w1
  1:
    stp     xzr, xzr, [x0], #16
    cmp     x0, x1
    b.ne    1b
  ret


poke_address_3_setup_regs:
  adr     x0, attributes_file + 2*20*108 + 12*108 + 7
  mov     x1, #78
  nzcv    #0b0110
  ret


poke_address_3_effects:
  ret


poke_address_3_effects_regs:
// section 2, line 12, character 7, plus 16 pixel row increments of 216*20
  adr     x0, display_file + 2*216*16*20 + 12*216 + 7*2 + 216*16*20
  mov     w1, #0x0
  mov     w3, #0x0
  mov     w5, #0x0
  mov     w6, #0x0
  mov     w7, #0xff
  mov     w8, #0x0
  adr     x9, mbreq
  mov     w10, #0x0
  movl    w11, 0x21541
  movl    w11, (poke_address_test - attributes_file)
  mov     w12, #0x6c
  mov     w13, #0xff
  mov     w14, #0xff
  mov     w15, #0xffff00
  mov     w16, #0xd80
  mov     w17, #0x4e
  mov     w18, #0x5
  ret


# poke_address_4 pokes an address below the display file
# Note: it corrupts address 3 - which is a byte of the
# first instruction under _start - but:
#   a) that instruction only runs once on startup
#   b) the test framework snapshots and restores RAM
#      so this corruption is automatically cleaned up
#      on test teardown
poke_address_4_setup:
  ret


poke_address_4_setup_regs:
  mov     x0, #3
  mov     x1, #17
  nzcv    #0b0110
  ret


poke_address_4_effects:
  _strb   17, (_start + 3)
  ret


poke_address_4_effects_regs:
  adr     x9, display_file
  movl    w11, (poke_address_test - attributes_file)
  nzcv    #0b1000
  ret


.bss
.align 0
poke_address_test: .space 1
