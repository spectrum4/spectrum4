.text
.align 2
# On entry:
#   w0 = first byte of 1 byte control code or second byte of 2 byte control code
po_cont:                                 // L0A87
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  adr     x4, print_out
  bl      po_change                               // Set current channel output routine to print_out.
  ldrb    w5, [x28, TVDATA-sysvars]               // w5[0-7] = control char
                                                  // w5[8-15] = first byte of 2 byte control code, if 2 byte
  lsr     w6, w5, #8                              // w6 = first byte of 2 byte control code, if 2 byte
  and     w5, w5, #0xff                           // w5 = control char
  cmp     w5, 0x16                                // control code INK to OVER (1 operand)?
  b.lo    to_co_temp_5                            // If so, jump forward to ........
  b.ne    po_tab                                  // If control char > 0x16 (=> 0x17 = TAB) jump forward to ..........
  // Control char = AT (0x16)
  mov     w1, #107                                // w1 = 107 (max allowed x coordinate)
  subs    w1, w1, w0                              // w1 = (107-column)
  b.lo    to_report_bb                            // Jump forward to to_report_bb if column > 107
  add     w1, w1, #2                              // w1 = (109-column)
  ldrb    w3, [x28, FLAGS-sysvars]                // w3 = [FLAGS]
  tbnz    w3, #1, po_at_set                       // If printer in use, jump forward to ...........
  mov     w4, #58
  subs    w4, w4, w6                              // w4 =(58-row)
  b.lo    to_report_bb                            // Jump forward to .......... if row > 58
  // TODO?
