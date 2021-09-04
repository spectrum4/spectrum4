.text
.align 2
po_char_2:                               // L0B6A
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  ldrb    w5, [x28, FLAGS-sysvars]                // w5 = [FLAGS]
  and     w5, w5, 0xfe                            // Clear bit 0 (=> allow leading space)
  cmp     w3, #0x20                               // Space character?
  b.ne    1f                                      // If not, jump forward to 1:.
  orr     w5, w5, 0x1                             // Set bit 0 (=> suppress leading space)
1:
  strb    w5, [x28, FLAGS-sysvars]                // Update [FLAGS] with bit 0 clear iff char is a space.
  add     x4, x4, x3, lsl #5                      // x4 = first byte of bit pattern of char
  bl      pr_all
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
