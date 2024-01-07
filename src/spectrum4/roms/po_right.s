# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
.align 2
# --------------------
# Cursor right routine
# --------------------
# This implementation could probably be optimised, and it is questionable
# whether the attributes file should really be updated.
#
# On entry:
#   w0 = 60 - line offset into section (60 = top line of S/K, 59 = second line, etc)
#   w1 = (109 - column), or 1 for end-of-line
#   x2 = address in display file / printer buffer
#   w3 = 0x09 (chr 9)
po_right:                                // L0A3D
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!                   // Backup x19 / x20 on stack.
  ldrb    w19, [x28, P_FLAG-sysvars]              // Stash current [P_FLAG] in x19 so we can temporarily change it.
  mov     x4, #1                                  // w4 = 1 => 'OVER 1' in [P_FLAG]
  strb    w4, [x28, P_FLAG-sysvars]               // Temporarily set [P_FLAG] to 'OVER 1'
  mov     x0, ' '                                 // x0 = space character (' ')
  bl      po_able                                 // Print it, which updates cursor position and attributes file
                                                  // entry, without altering display file (unless space character
                                                  // has been modified).
  strb    w19, [x28, P_FLAG-sysvars]              // Restore stashed [P_FLAG].
  ldp     x19, x20, [sp], #0x10                   // Restore old x19, x20.
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
