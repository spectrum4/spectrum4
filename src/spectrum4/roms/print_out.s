.text
.align 2
# Default print routine for channels S/K, to print a single byte.
#
# On entry:
#   w0 = char (1 byte)
# On exit:
#   Depends on function in ctlchrtab
print_out:                               // L09F4
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!                   // Backup x19 / x20 on stack.
  mov     x19, x0                                 // Stash x0.
  bl      po_fetch                                // Fetch x0, x1, x2 (print coordinates and address)
  mov     x3, x19                                 // x3 = char to print
  cmp     x3, #0x20                               // Is character a space or higher (directly printable)?
  b.hs    1f                                      // If so, to 1: to print char.
  cmp     x3, #0x06                               // Is character in range 0 - 5?
  b.lo    2f                                      // If so, to 2: to print '?'.
  cmp     x3, #0x18                               // Is character in range 24 - 31?
  b.hs    2f                                      // If so, to 2: to print '?'.
  adr     x4, ctlchrtab-(6*8)                     // x4 = theorectical address of control character table char 0
  add     x4, x4, x3, lsl #3                      // x4 = address of control character routine for char passed in w0
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
  // Exit routine.
  ldp     x19, x20, [sp], #0x10                   // Restore old x19, x20.
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
