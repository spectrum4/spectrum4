.text
.align 2
# ------------------------------------------------------
# Print message and possibly a leading/trailing space(s)
# ------------------------------------------------------
#
# Prints leading space if bit 0 of FLAGS clear and carry flag set.
# Prints trailing space if w5 >= 0x03 and (last char >= 'A' or last char == '$').
#
# On entry:
#   x4 = address of zero-terminated string to print
#   w5 = trailing space indicator:
#     w5 < 0x03 => no trailing space
#     w5 >= 0x03 => trailing space if last char >= 'A' or last char == '$'
#   x28 = sysvars
#   bit 0 of FLAGS clear and carry flag set if leading space required
#   [[CURCHL]] = print routine to call
#   ... any settings that routine at [[CURCHL]] requires ...
# On exit:
#   x0 =
#     if w5 >= 3 and (last char >= 'A' or last char == '$')
#       ' '
#     else:
#       0x0
#   x1 = [[CURCHL]]
#   x4 = first address after zero-terminated string
#   x6 = last char of keyword (not including the trailing zero byte)
#   NZCV =
#     if w5 > 3 and (last char >= 'A' or last char == '$'):
#       0b0010
#     for w5 == 0x03 and (last char >= 'A' or last char == '$'):
#       0b0110
#     else:
#       0b1000
po_table_1:                              // L0C17
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  b.lo    1f                                      // If carry is clear, jump forward to 1:.
  ldrb    w6, [x28, FLAGS-sysvars]                // w6 = [FLAGS]
  tbnz    w6, #0, 1f                              // If suppress space, jump forward to 1:.
  mov     w0, ' '                                 // x0 = space character (' ')
  bl      print_w0                                // Print it
  1:
    ldrb    w0, [x4], #1                          // Fetch ASCII char from token table entry into w0.
    cbz     w0, 2f                                // If 0, end of string; exit loop; jump forward to 2:.
    mov     w6, w0                                // Stash "previous" char in w6.
    bl      print_w0                              // Print it, preserving registers.
    b       1b                                    // Repeat loop
2:
  cmp     w6, '$'                                 // Was last character '$'?
  b.eq    3f                                      // If so, jump forward to 3: to consider trailing space.
  cmp     w6, 'A'                                 // Was it < 'A' i.e. '#', '>', '=' from tokens or ' ', '.'
                                                  // (from tape) or '?' from scroll?
  b.lo    4f                                      // No trailing space, so exit routine.
3:
  cmp     w5, #0x03                               // Test against RND, INKEY$ and PI which have no parameters
                                                  // and therefore no trailing space.
  b.lo    4f                                      // If one of them, no trailing space, so jump forward to 4:.
  mov     w0, ' '                                 // Otherwise print a trailing space (' ').
  bl      print_w0
4:
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret
