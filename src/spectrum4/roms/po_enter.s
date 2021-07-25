.text
.align 2
# -----------------------
# Perform carriage return
# -----------------------
# A carriage return is 'printed' to screen or printer buffer.
#
# On entry:
#   w0 = 60 - line offset into section (60 = top line of S/K, 59 = second line, etc)
#   w1 = (109 - column), or 1 for end-of-line
#   x2 = address in display file / printer buffer
#   w3 = 0x0d (chr 13)
po_enter:                                // L0A4F
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!                   // Backup x19 / x20 on stack.
  stp     x21, x22, [sp, #-16]!                   // Backup x21 / x22 on stack.
  mov     w19, w0                                 // Stash argument w0.
  mov     w20, w1                                 // Stash argument w1.
  mov     w21, w2                                 // Stash argument w2.
  mov     w22, w3                                 // Stash argument w3.
  ldrb    w4, [x28, FLAGS-sysvars]                // w4 = [FLAGS]
  tbnz    w4, #1, 1f                              // If printer in use, jump forward to 1:.
  mov     w1, #109                                // The leftmost column position.
  // TODO preserve registers that following routine corrupts
  bl      po_scr                                  // Routine po_scr handles any scrolling required.
  sub     w0, w0, #1                              // Down one screen line.
  bl      cl_set                                  // Save new position in system variables.
  b       2f                                      // Exit routine.
1:
  // Flush printer buffer and reset print position.
  bl      copy_buff
2:
  // Exit routine.
  ldp     x21, x22, [sp], #0x10                   // Restore old x21, x22.
  ldp     x19, x20, [sp], #0x10                   // Restore old x19, x20.
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
