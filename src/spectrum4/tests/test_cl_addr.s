# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.


.if ROMS_INCLUDE
.else
  .include "print_w0.s"
.endif




.text
.align 2

# This test calls cl_addr to get the address of top left pixel of screen line 25.

cl_addr_1_setup_regs:
  mov     x0, 60 - 1*20 - 5                       // 60 - screen line 25
  ret


cl_addr_1_effects_regs:
  mov     x1, 1*20 + 5                            // screen line
  ldr     x2, = display_file + 1*20*16*216 + 5*216
                                                  // address of top left pixel of line to clear inside display file
  mov     x3, #1                                  // screen line / 20
  mov     x4, #5                                  // screen line % 20
  mov     x5, #216                                // 216
  ldr     x6, =69120                              // 69120 (0x10e00)
  ret
