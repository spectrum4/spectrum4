# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
.align 2

# ------------------------
# Initialise Mode Settings
# ------------------------
# Called before Main menu displayed.
#
# On entry:
# On exit:
init_mode:                               // L2584
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  bl      reset_cursor
  strh    wzr, [x28, FC9A-sysvars]
  mov     w0, #0x82
  strb    w0, [x28, EC0D-sysvars]                 // Waiting for key press (bit 7), menu displayed (bit 1)
  strh    wzr, [x28, E_PPC-sysvars]
  bl      reset_indentation
  bl      mode_l
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
