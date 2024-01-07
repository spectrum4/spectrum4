# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
.align 2
# ------------------
# Handle CLS command
# ------------------
# clears the display.
# if it's difficult to write it should be difficult to read.
cls:                                     // L0D6B
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  bl      cl_all
  bl      cls_lower
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret
