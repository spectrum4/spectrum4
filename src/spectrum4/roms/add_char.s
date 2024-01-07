# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
.align 2
# ------------------------
# Add code to current line
# ------------------------
# this is the branch used to add normal non-control characters
# with ED-LOOP as the stacked return address.
# it is also the OUTPUT service routine for system channel 'R'.
add_char:                                // L0F81
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  ldrb    w9, [x28, MODE-sysvars]                 // w9 = [MODE].
  and     w9, w9, #~0x01                          // w9 = [MODE] with bit 0 clear.
  strb    w9, [x28, MODE-sysvars]                 // Update [MODE] to have bit 0 clear (Mode 'L').
  ldr     x5, [x28, K_CUR-sysvars]                // fetch address of keyboard cursor from K_CUR
  bl      one_space
  bl      add_ch_1
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
