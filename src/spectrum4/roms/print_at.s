# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text

# ----------------------------
# Print "AT w8, w9" characters
# ----------------------------
#
# On entry:
# On exit:
.align 2
print_at:                                // L372B
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  mov     w0, #0x16
  bl      print_w0
  mov     w0, w8
  bl      print_w0
  mov     w0, w9
  bl      print_w0
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
