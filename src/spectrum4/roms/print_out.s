.text
.align 2
# Default print routine for channels S/K, to print a single byte.
#
# On entry:
#   w0 = char (1 byte)
# On exit:
#   x1-x6 preserved + changes made by po_able / po_quest / function in ctlchrtab
print_out:                               // L09F4
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  stp     x1, x2, [sp, #-16]!                     // Preserve x1, x2
  stp     x3, x4, [sp, #-16]!                     // Preserve x3, x4
  stp     x5, x6, [sp, #-16]!                     // Preserve x5, x6
  mov     x3, x0                                  // x3 = char to print
  bl      po_fetch                                // Fetch x0, x1, x2 (print coordinates and address)
  cmp     x3, #0x20                               // Is character a space or higher (directly printable)?
  b.hs    1f                                      // If so, to 1: to print char.
  cmp     x3, #0x06                               // Is character in range 0 - 5?
  b.lo    2f                                      // If so, to 2: to print '?'.
  cmp     x3, #0x18                               // Is character in range 24 - 31?
  b.hs    2f                                      // If so, to 2: to print '?'.
  adr     x4, ctlchrtab-(6*8)                     // x4 = theorectical address of control character table char 0
  add     x4, x4, x3, lsl #3                      // x4 = address in table of control character routine pointer
  ldr     x4, [x4]                                // x4 = address of character routine
  blr     x4                                      // Call control character routine.
  b       3f                                      // Return from routine.
1:
  // Printable character.
  bl      po_able                                 // Print printable character.
  b       3f                                      // Return from routine.
2:
  // Unassigned control character.
  bl      po_quest                                // Print question mark.
3:
  // Restore registers and exit routine.
  ldp     x5, x6, [sp], #0x10                     // Restore old x5, x6.
  ldp     x3, x4, [sp], #0x10                     // Restore old x3, x4.
  ldp     x1, x2, [sp], #0x10                     // Restore old x1, x2.
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
