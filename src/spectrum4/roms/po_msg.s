.text
.align 2
# ----------------
# Message printing
# ----------------
# This entry point is used to print tape, boot-up, scroll? and error messages.
# No leading and no trailing spaces used.
#
# On entry:
#   w3 = token table index (address of step over token)
#   x4 = address of message stored in RAM to print
po_msg:                                  // L0C0A
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  mov     w5, #0                                  // Index first entry in table.
  bl      po_table                                // Could just call po_table_1 here (and only need part of it).
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret
