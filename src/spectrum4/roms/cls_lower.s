.text
.align 2
// TODO: check this routine uses correct registers in subroutine calls and that subroutines don't corrupt needed registers
cls_lower:                               // L0D6E
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!                   // Backup x19 / x20 on stack.
  stp     x21, x22, [sp, #-16]!                   // Backup x21 / x22 on stack.
  ldrb    w9, [x28, TV_FLAG-sysvars]              // w9[0-7] = [TV_FLAG]
  and     w9, w9, #~0x20                          // Clear bit 5 - signal do not clear lower screen.
  orr     w9, w9, #0x01                           // Set bit 0 - signal lower screen in use.
  strb    w9, [x28, TV_FLAG-sysvars]              // [TV_FLAG] = w9[0-7]
  bl      temps                                   // Routine temps picks up temporary colours.
  ldrb    w0, [x28, DF_SZ-sysvars]                // Fetch lower screen DF_SZ.
  bl      cl_line                                 // Routine CL-LINE clears lower part and sets permanent attributes.
  adrp    x0, attributes_file_end                 // x0 = address of first byte after attributes file
  add     x0, x0, :lo12:attributes_file_end
  sub     x19, x0, 108*2                          // x19 = attribute address leftmost cell, second line up (first byte after last cell to clear)
  ldrb    w2, [x28, DF_SZ-sysvars]                // Fetch lower screen DF_SZ.
  mov     w3, #108
  umsubl  x20, w2, w3, x0                         // x20 = first attribute cell to clear
  ldrb    w21, [x28, ATTR_P-sysvars]              // Fetch permanent attribute from ATTR_P.
1:                                                // Set attributes file values to [ATTR_P] for lowest [DF_SZ] lines except bottom two lines.
  cmp     x19, x20
  b.ls    2f                                      // Exit loop if x19 <= x20 (unsigned)
  sub     x19, x19, #1
  mov     x0, x19
  mov     w1, w21
  bl      poke_address
  b       1b
2:
  mov     w5, 2
  strb    w5, [x28, DF_SZ-sysvars]                // Set the lower screen size to two rows.
  bl      cl_chan
  ldp     x21, x22, [sp], #0x10                   // Restore old x21, x22.
  ldp     x19, x20, [sp], #0x10                   // Restore old x19, x20.
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret
