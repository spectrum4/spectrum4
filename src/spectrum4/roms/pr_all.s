.text
.align 2
# -----------------------------------------
# Render character bitmap to screen/printer
# -----------------------------------------
# This entry point entered from above to paint ASCII and UDGs
# to screen/printer but also from earlier to paint mosaic characters.
#
# On entry:
#   w1 = (109 - column), or 1 for end-of-line
#   x2 = address in display file / printer buffer
#   x4 = address of 32 byte character bit pattern
#   [FLAGS] bit 1 (printer in use or not)
#   [P_FLAG] bit 0 and bit 2 (temp OVER, temp INVERSE)
#   if printer not in use:
#     w0 = 60 - line offset into section (60 = top line of S/K, 59 = second line, etc)
#     [P_FLAG] bit 4 and bit 6 (temp INK 9, temp PAPER 9)
#     [TV_FLAGS] bit 0 (lower screen in use or not)
#     [DF_SZ]
#     [ATTR_T]
#     [MASK_T]
# On exit:
#   If printer in use:
#     printer buffer updated (and potentially flushed)
#   Else:
#     display file and attributes file updated
#     x0 = 60 - new line offset into section
#     x1 = 109 - new column, or 1 for end-of-line
#     x2 += 2 (correct new cursor memory location, unless at first char of screen third)
#     Plus po_attr register changes (excluding x24):
#       x3
#       x5
#       x6
#       x7
#       x8
#       x9 = mbreq
#       x10
#       x11
#       x12
#       x13
#       x14
#       x15
#       x16
#       x17
#       x18
#       NZCV
#     If was at end-of-line before printing (entry x1 == 1):
#       cl_set register updates:
#         x4 = y offset into screen third of updated position (not entry position)
#       If lower screen:
#         [S_POSN_X_L] = 109 (start of line)
#         [S_POSN_Y_L] = x0-1 (line below)
#         [ECHO_E_X] = 109 (start of line)
#         [ECHO_E_Y] = x0-1 (line below)
#         [DF_CC_L] set to display file address for [S_POSN_{X,Y}_L]
#       If upper screen:
#         [S_POSN_X] = 109 (start of line)
#         [S_POSN_Y] = x0-1 (line below)
#         [DF_CC] set to display file address for [S_POSN_{X,Y}]
pr_all:                                  // L0B7F
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!                   // Backup x19 / x20 on stack.
  stp     x21, x22, [sp, #-16]!                   // Backup x21 / x22 on stack.
  stp     x23, x24, [sp, #-16]!                   // Backup x23 / x24 on stack.
  ldrb    w20, [x28, FLAGS-sysvars]               // w20 = [FLAGS]
  mov     x21, x2                                 // x21 = address in display file / printer buffer
  mov     x22, x4                                 // x22 = address of 32 byte character bit pattern
  cmp     w1, #1                                  // Trailing position at end of line?
  b.ne    1f                                      // If not trailing, jump ahead to 1:.
  // Trailing at end of line.
  sub     w0, w0, #1                              // Move down a line.
  mov     w1, #109                                // Move cursor to leftmost position.
  tbz     w20, #1, 1f                             // If printer not in use, jump ahead to 1:.
  // Printer in use.
  // TODO preserve registers that following routine corrupts
  bl      copy_buff                               // Flush printer buffer and reset print position.
1:
  cmp     w1, #109                                // Leftmost column?
  b.ne    2f                                      // If not, jump ahead to 2:.
  // Leftmost column.

  // updates x2
  // corrupts x3, x4, x5, x6
  bl      po_scr                                  // Consider scrolling
2:
  stp     x0, x1, [sp, #-16]!                     // Backup x0 / x1 on stack.
  str     x2, [sp, #-16]!                         // Backup x2 on stack.
  ldrb    w6, [x28, P_FLAG-sysvars]               // w6 = [P_FLAG]
  tst     w6, #1                                  // Test (temporary) OVER status (bit 0).
  csetm   w7, ne                                  // w7 = -1 if (temporary) OVER 1 in [P_FLAG]
                                                  //       0 if (temporary) OVER 0 in [P_FLAG]
  tst     w6, #4                                  // Test (temporary) INVERSE status (bit 2).
  csetm   w24, ne                                 // w24 = -1 if (temporary) INVERSE 1 in [P_FLAG]
                                                  //        0 if (temporary) INVERSE 0 in [P_FLAG]
  bfi     x24, x7, #32, #32                       // Move w7 (OVER mask) into upper 32 bits of x24
  mov     w19, #16                                // 16 pixel rows to update
  tbz     w20, #1, 3f                             // If printer not in use, jump ahead to 3:.
  ldrb    w10, [x28, FLAGS2-sysvars]              // w9 = [FLAGS2]
  orr     w10, w10, #0x2                          // w9 = [FLAGS2] with bit 1 set
  strb    w10, [x28, FLAGS2-sysvars]              // Update [FLAGS2] to have bit 1 set (signal printer buffer has been used).
  3:
    ldrh    w11, [x21]                            // w11 = current screen bit pattern
    and     x11, x11, x24, lsr #32                // Consider OVER.
    ldrh    w10, [x22], #2                        // w10 = character pixel line bit pattern at [x22]; bump x22
    eor     w11, w11, w10                         // Apply character bit pattern.
    eor     w23, w11, w24                         // Consider INVERSE.
    mov     x0, x21                               // Display file address to update for lefthandside byte
    bfxil   w1, w23, #0, #8                       // w23 has 16 bytes of bit pattern, left side is bits 0-7
  // disturbs x0, x3, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18
    bl      poke_address                          // Update LHS byte
    add     x0, x21, #1                           // RHS target address
    bfxil   w1, w23, #8, #8                       // Next 8 bits of pattern for RHS
  // disturbs x0, x3, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18
    bl      poke_address                          // Update RHS byte
    tbnz    w20, #1, 4f                           // If printer in use, jump ahead to 6:.
  // Printer not in use.
    add     x21, x21, 0x0870                      // 20*216 = 0x10e0 is too big to add in one step, so do it in two steps.
    add     x21, x21, 0x0870                      // Gives next pixel line down.
    b       5f
  // Printer in use
  4:
    add     x21, x21, #0xd8                       // x21 = current printer buffer location + 216

  //////////////////////////////////////////////////////////////////////////
  //
  // TODO: Probably this whole block is not needed, since buffer is probably
  // always flushed at start of new line.
  //
  //
    adrp    x11, printer_buffer_end
    add     x11, x11, :lo12:printer_buffer_end
    cmp     x21, x11                              // Is x21 now past end of printer buffer?
    b.lo    5f                                    // If not, jump ahead to 5:.
  // Overshot printer buffer
    sub     x21, x21, #0xd80                      // Correct printer buffer position
  //
  //
  //////////////////////////////////////////////////////////////////////////

  5:
    sub     w19, w19, #1                          // Decrement pixel row loop counter
    cbnz    w19, 3b                               // Repeat until all 16 pixel rows complete
  tbnz    w20, #1, 6f                             // If printer in use, jump ahead to 6:.
// Printer not in use
  ldr     x0, [sp]                                // x0 = original display file address
  bl      po_attr                                 // Call routine po_attr to update corresponding colour attribute.
6:
  ldr     x2, [sp], #0x10                         // Restore screen/printer position.
  ldp     x0, x1, [sp], #0x10                     // Restore line/column.
  sub     w1, w1, #1                              // Move column to the right.
  add     x2, x2, #2                              // Increase screen/printer position
                                                  // Note: at end of screen thirds this will be the wrong address,
                                                  // but cl_set presumably fixes it, before subsequent pr_all call.
                                                  // Instead of calling cl_set everywhere, probably the above
                                                  // could have been fixed to handle screen third endings.
  ldp     x23, x24, [sp], #0x10                   // Restore old x23, x24.
  ldp     x21, x22, [sp], #0x10                   // Restore old x21, x22.
  ldp     x19, x20, [sp], #0x10                   // Restore old x19, x20.
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
