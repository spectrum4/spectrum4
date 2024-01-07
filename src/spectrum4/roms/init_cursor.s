# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
.align 2

# ---------------------
# ---------------------
#
# On entry:
# On exit:
init_cursor:                             // L3A7F
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  mov     x2, #0x000f000000000000
  add     x2, x2, #0x0000000000140000
  str     x2, [x28, FD6C-sysvars]
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
