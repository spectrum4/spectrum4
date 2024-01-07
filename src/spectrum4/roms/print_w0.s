# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
.align 2
# Print character in lower 8 bits of w0 to current channel.
# Calls function pointer at [[CURCHL]].
#
# On entry:
#   w0 = char to print (lower 8 bits)
#   x28 = sysvars
#   [[CURCHL]] = print routine to call
#   ... any settings that routine at [[CURCHL]] requires ...
# On exit:
#   x1 = [[CURCHL]]
#   ... any changes that routine at [[CURCHL]] made ...
print_w0:                                // L0010
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  ldr     x1, [x28, CURCHL-sysvars]               // x1 = [CURCHL]
  ldr     x1, [x1]                                // x1 = [[CURCHL]]
  blr     x1                                      // bl [[CURCHL]]
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
