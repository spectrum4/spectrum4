# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
.align 2
# -------------------
# THE 'ERROR' RESTART
# -------------------
#
# On entry:
#   w0 = error number (8 bits)
# On exit:
#   [X_PTR] = [CH_ADD]
#   [ERR_NO] = w0
#   stack pointer = [ERR_SP]
#   ....
#   x9 = [CH_ADD]
error_1:                                 // L0008
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  ldr     x9, [x28, CH_ADD-sysvars]               // x9 = character address from CH_ADD.
  str     x9, [x28, X_PTR-sysvars]                // Copy it to the error pointer X_PTR.
  strb    w0, [x28, ERR_NR-sysvars]               // Store error number in ERR_NR.
  ldr     x9, [x28, ERR_SP-sysvars]               // ERR_SP points to an error handler on the
  mov     sp, x9                                  // machine stack. There may be a hierarchy
                                                  // of routines.
                                                  // to MAIN-4 initially at base.
                                                  // or REPORT-G on line entry.
                                                  // or  ED-ERROR when editing.
                                                  // or   ED-FULL during ed-enter.
                                                  // or  IN-VAR-1 during runtime input etc.
  // TODO - a lot to implement here, skipping for now as I haven't understood
  // how the stack swapping works yet.
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret
