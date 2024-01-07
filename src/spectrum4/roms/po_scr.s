# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
.align 2
# ---------------
# Test for scroll
# ---------------
# This test routine is called when printing carriage return, when considering
# PRINT AT and from the general PRINT ALL characters routine to test if
# scrolling is required, prompting the user if necessary.
#
#
# If printer in use:
#   On entry:
#     Bit 1 of FLAGS set
#   On exit:
#     w4 = [FLAGS]
#
# If upper screen in use:
#   On entry:
#     Bit 1 of FLAGS clear
#     Bit 0 of [TV_FLAG] clear
#     [DF_SZ] set to number of lines for lower screen
#     w0 = 60 - actual screen row (60 = top line, 59 = second line, etc)
#     w1 = (109 - actual column) or 0x01 for past end of line but no carriage return
#   On exit:
#     If w0 > [DF_SZ]:
#       [S_POSN_Y] = x0
#       [S_POSN_X] = x1
#       [DF_CC] = display_file + 2*(109-x1) + ((60-x0)/20)*216*16*20 + 216*((60-x0)%20)
#       x2 = display_file + 2*(109-x1) + ((60-x0)/20)*216*16*20 + 216*((60-x0)%20)
#       w3 = [TV_FLAG]
#       w4 = (60-x0)%20
#       w5 = 216
#       w6 = 0x10e00
#       NZCV = 0b0010
#     If w0 == [DF_SZ]:
#       TODO (scrolling occurs)
#     If w0 < [DF_SZ]:
#       TODO (out of screen)
#
# If lower screen in use:
#   On entry:
#     Bit 1 of FLAGS clear
#     Bit 0 of [TV_FLAG] set
#     [DF_SZ] set to number of lines for lower screen
#     w0 = 120 - [DF_SZ] - actual screen row (60 = top line of lower screen, 59 = second line of lower screen, etc)
#     w1 = (109 - actual column) or 0x01 for past end of line but no carriage return
#   On exit:
#     If 1 > w0 > 60-[DF_SZ]:
#       [S_POSN_Y_L] = x0
#       [S_POSN_X_L] = x1
#       [ECHO_E_Y] = x0
#       [ECHO_E_X] = x1
#       [DF_CC_L] = display_file + 2*(109-x1) + ((120-x0-[DF_SZ])/20)*216*16*20 + 216*((120-x0-[DF_SZ])%20)
#       x2 = display_file + 2*(109-x1) + ((120-x0-[DF_SZ])/20)*216*16*20 + 216*((120-x0-[DF_SZ])%20)
#       w3 = [TV_FLAG]
#       w4 = (120-x0-[DF_SZ])%20
#       w5 = 216
#       w6 = 0x10e00
#       If w0 == 61-[DF_SZ]:
#         NZCV = 0b0110
#       Else:
#         NZCV = 0b0010
#     If w0 == 60-[DF_SZ]:
#       TODO (scrolling occurs)
#     If w0 < 2:
#       TODO (out of screen)
#     If w0 < 60-[DF_SZ]:
#       TODO (out of screen)
po_scr:                                  // L0C55
  ldrb    w4, [x28, FLAGS-sysvars]                // w4 = [FLAGS]
  tbnz    w4, #1, 9f                              // If printer in use, jump forward to 9:.
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  ldrb    w4, [x28, TV_FLAG-sysvars]              // w4 = [TV_FLAG]
  ldrb    w2, [x28, DF_SZ-sysvars]                // w2 = [DF_SZ].
  tbnz    w4, #0, po_scr_4                        // If lower screen in use, jump forward to po_scr_4.
  cmp     w0, w2                                  // 60 - line offset < DF_SZ?
  b.lo    report_5                                // w0 < [DF_SZ] => Out of screen (number of lines of upper screen < line offset).
  b.ne    8f                                      // No need to scroll - call cl_set and return.
// w0 == w2
  tbz     w1, #4, po_scr_2                        // Test TV_FLAG: if not an automatic listing, jump ahead to po_scr_2.
// TODO - test code below
// Automatic program listing
  ldrb    w7, [x28, BREG-sysvars]                 // w7 = [BREG] (scroll line count)
  subs    w7, w7, #1                              // Decrement scroll line count.
  b.eq    po_scr_3                                // If scroll count now 0, need to prompt user - so jump ahead to po_scr_3.
  mov     x0, #0                                  // Prepare stream number (0) (why not -3 like below?)
  bl      chan_open                               // Open stream 0 (Keyboard/Lower screen, unless modified).
  ldr     x8, [x28, LIST_SP-sysvars]              // x8 = LIST stack pointer (separate stack pointer for program listing)
  mov     sp, x8                                  // Update stack pointer.
  and     w1, w1, #~0x10                          // Signal automatic program listing complete (since end of screen reached).
  strb    w1, [x28, TV_FLAG-sysvars]              // [TV_FLAG] = w1
  b       8f                                      // Exit routine.
po_scr_2:                                // L0C88
// TODO - test code below
  ldrb    w9, [x28, SCR_CT-sysvars]               // w9 = [SCR_CT]
  subs    w9, w9, #1                              // Decrement SCR_CT.
  b.ne    po_scr_3                                // Jump forward to po_scr_3 to scroll display if result not zero.
// Now produce "scroll?" prompt
  mov     w9, #60
  sub     w9, w9, w0                              // w9 = line offset into section
  strb    w9, [x28, SCR_CT-sysvars]               // [SCR_CT] = w9
  ldrh    w9, [x28, ATTR_T-sysvars]               // w9[0-7] = [ATTR_T]
                                                  // w9[8-15] = [MASK_T]
  ldrb    w10, [x28, P_FLAG-sysvars]              // w10 = [P_FLAG]
  mov     x0, #-3                                 // Select system stream -3 (system channel K).
  bl      chan_open                               // Open it.
  adr     x4, scroll_message                      // Message table.
  mov     x3, #0                                  // First string in table.
  bl      po_msg                                  // Print it.
  ldrb    w9, [x28, TV_FLAG-sysvars]              // w9[0-7] = [TV_FLAG]
  orr     w9, w9, #0x20                           // Set bit 5 - signal clear lower screen.
  strb    w9, [x28, TV_FLAG-sysvars]              // [TV_FLAG] = w9[0-7]
  ldrb    w9, [x28, FLAGS-sysvars]                // w9[0-7] = [FLAGS]
  orr     w9, w9, #0x08                           // Set bit 3 - signal 'L' mode.
  and     w9, w9, #~0x20                          // Clear bit 5 - signal no new key.
  strb    w9, [x28, FLAGS-sysvars]                // [FLAGS] = w9[0-7]
// TODO
po_scr_3:                                // L0CD2
// TODO
po_scr_4:                                // L0D02
  cmp     w0, #0x02
  b.lo    report_5                                // w0 < 2 => Out of screen
  add     w4, w0, w2                              // w4 = w0 + [DF_SZ]
  subs    w4, w4, #61                             // w4 = w0 + [DF_SZ] - 61
  b.hs    8f                                      // w0 > 60 - [DF_SZ] => No need to scroll - call cl_set and return.
// TODO


8:
  bl      cl_set                                  // in Spectrum 128K, this was pushed on stack at start of po_scr
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
9:
  ret


report_5:                                // L0C86
// TODO


scroll_message:                          // L0CF8
  .asciz    "?"                                   // Step over marker
  .asciz    "scroll?"
