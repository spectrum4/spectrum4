.text
.align 2
# ---------------------------
# Set line and column numbers
# ---------------------------
# Calculate the character output address for screens or printer based on the
# line/column for screens for current K/S/P channel.
#
# On entry:
#
#   w0 = 60 - line offset into section (60 = top line of S/K, 59 = second line, etc)
#     for K: x0 = 120 - [DF_SZ] - actual screen row (x0 range: 1 -> 60)
#     for S: x0 = 60 - actual screen row (x0 range: 1 -> 60)
#     for P: x0 not used since printer buffer is a single line, so no Y coordinate
#   w1 = 109 - actual column
#     from 109 (leftmost column) to 2 (rightmost column) or 1 indicates entire
#     line printed, but no explicit carriage return (so lines needn't be
#     scrolled, and backspace still possible on printer).
#
# On exit:
#
#   If upper screen in use (bit 1 of FLAGS clear and bit 0 of TV_FLAG clear):
#     [S_POSN_Y] = x0
#     [S_POSN_X] = x1
#     [DF_CC] = display_file + 2*(109-x1) + ((60-x0)/20)*216*16*20 + 216*((60-x0)%20)
#     x2 = display_file + 2*(109-x1) + ((60-x0)/20)*216*16*20 + 216*((60-x0)%20)
#     w3 = [TV_FLAG]
#     w4 = (60-x0)%20
#     w5 = 216
#     w6 = 0x10e00
#
#   If lower screen in use (bit 1 of FLAGS clear and bit 0 of TV_FLAG set):
#     [S_POSN_Y_L] = x0
#     [S_POSN_X_L] = x1
#     [ECHO_E_Y] = x0
#     [ECHO_E_X] = x1
#     [DF_CC_L] = display_file + 2*(109-x1) + ((120-x0-[DF_SZ])/20)*216*16*20 + 216*((120-x0-[DF_SZ])%20)
#     x2 = display_file + 2*(109-x1) + ((120-x0-[DF_SZ])/20)*216*16*20 + 216*((120-x0-[DF_SZ])%20)
#     w3 = [TV_FLAG]
#     w4 = (120-x0-[DF_SZ])%20
#     w5 = 216
#     w6 = 0x10e00
#
#   If printer in use (bit 1 of FLAGS set):
#     [P_POSN_X] = x1
#     [PR_CC] = printer_buffer + 109 - x1
#     x2 = printer_buffer + 109 - x1
#     w3 = [FLAGS]
cl_set:                                  // L0DD9
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  ldrb    w3, [x28, FLAGS-sysvars]
  tbnz    w3, #1, 2f                              // If printer is in use, jump to 2:.
  stp     x19, x20, [sp, #-16]!                   // Backup x19 / x20 on stack.
  mov     x19, x0                                 // Stash x0
  mov     x20, x1                                 // Stash x1
  ldrb    w4, [x28, TV_FLAG-sysvars]
  tbz     w4, #0, 1f                              // If upper screen in use, jump to 1:.
                                                  // Lower screen in use.
  ldrb    w5, [x28, DF_SZ-sysvars]
  add     w0, w0, w5
  sub     w0, w0, #60                             // w0 = 60 - actual row number
1:
  bl      cl_addr                                 // x2 = address of top left pixel of row
  mov     x1, x20                                 // Restore stashed x1.
  mov     x0, x19                                 // Restore stashed x0.
  add     x2, x2, #218                            // x2 = address of top left pixel of row + 218
  sub     x2, x2, x1, lsl #1                      // x2 = address of top left pixel of row + 218 - 2 * (109 - screen column)
                                                  //    = address of top left pixel of char
  ldp     x19, x20, [sp], #16                     // Restore old x19, x20.
  b       3f
2:
  add     x2, x28, printer_buffer+109-sysvars
  sub     x2, x2, x1                              // x2 = address inside printer buffer to write char
3:
  bl      po_store
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret
