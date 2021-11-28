.text
.align 2
# Print tokens and user defined graphics (chars 0x90-0xff).
#
# On entry:
#   w0 = 60 - line offset into section (60 = top line of S/K, 59 = second line, etc)
#   w1 = (109 - column), or 1 for end-of-line
#   x2 = address in display file / printer buffer(?)
#   w3 = char (144-255)
print_token_udg_patch:                   // L3B9F
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  cmp     w3, #0xa3                               // Is char 'SPECTRUM' (128K mode) / UDG T (48K mode)?
  b.eq    2f                                      // If so, jump forward to 2:.
  cmp     w3, #0xa4                               // Is char 'PLAY' (128K mode) / UDG U (48K mode)?
  b.eq    2f                                      // If so, jump forward to 2:.
1:
  subs    w3, w3, #0xa5                           // w3 = (char - 165)
  b.pl    3f                                      // If char is token (w3 >= 0) jump forward to 3:.
  // UDG character
  bl      rejoin_po_t_udg                         // Rejoin 48K BASIC routine.
  b       5f                                      // Exit routine.
2:
  // SPECTRUM/PLAY token (128K mode) or T/U UDG (48K mode)

  // TODO: See if we can find an alternative unused register for storing FLAGS
  // in, since we read it multiple times below.

  ldrb    w4, [x28, FLAGS-sysvars]                // w4 = [FLAGS]
  tbz     w4, #4, 1b                              // If in 48K mode, jump back to 1:.
  // SPECTRUM or PLAY token in 128K mode
  adr     x4, tkn_spectrum                        // x4 = address of "SPECTRUM" string
  adr     x5, tkn_play                            // x5 = address of "PLAY" string
  subs    w3, w3, #0xa3                           // w3 = 0 for "SPECTRUM" or 1 for "PLAY"
  csel    x4, x4, x5, eq                          // x4 = correct address for token string
  mov     w5, #0x04                               // Indicate trailing space required
  // TODO: check if any registers need to be preserved here
  bl      po_table_1                              // Print SPECTRUM or PLAY.
  // TODO: set carry flag??? Why???
  ldrb    w4, [x28, FLAGS-sysvars]                // w4 = [FLAGS]
  tbnz    w4, #1, 5f                              // If printer in use, jump forward to 5:.
  // Printer not in use
  b       4f
3:
  bl      po_tokens
4:
  bl      po_fetch
5:
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
