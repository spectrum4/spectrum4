.text
.align 2
# Print UDG (chars 0x90-0xa4).
#
# On entry:
#   w0 = 60 - line offset into section (60 = top line of S/K, 59 = second line, etc)
#   w1 = (109 - column), or 1 for end-of-line
#   x2 = address in display file / printer buffer(?)
#   w3 = (char-165) (-21 to -1)
rejoin_po_t_udg:                         // L0B56
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  add     w3, w3, #21                             // w3 now in range 0 to 20
  ldr     x4, [x28, UDG-sysvars]                  // x4 = [UDG]
  bl      po_char_2
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
