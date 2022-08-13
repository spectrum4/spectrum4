.text
.align 2
# On entry:
#   w0 = first byte of 1 byte control code or second byte of 2 byte control code
po_cont:                                 // L0A87
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  adr     x4, print_out
  bl      po_change                               // Set current channel output routine to print_out.
  ldrh    w5, [x28, TVDATA-sysvars]               // w5[0-7] = control char
                                                  // w5[8-15] = first byte of 2 byte control code, if 2 byte
  lsr     w6, w5, #8                              // w6 = first byte of 2 byte control code, if 2 byte
  and     w5, w5, #0xff                           // w5 = control char
  cmp     w5, 0x16                                // control code INK to OVER (1 operand)?
  b.lo    3f                                      // If so, jump forward to 3:
  b.ne    5f                                      // If control char > 0x16 (=> 0x17 = TAB) jump forward to 5:
  // Control char = AT (0x16)
  mov     w1, #107                                // w1 = 107 (max allowed x coordinate)
  subs    w1, w1, w0                              // w1 = (107-column)

  b.lo    4f                                      // Jump forward to 4: if column > 107
  add     w1, w1, #2                              // w1 = (109-column)
  ldrb    w3, [x28, FLAGS-sysvars]                // w3 = [FLAGS]
  tbnz    w3, #1, 1f                              // If printer in use, jump forward to 1:
  mov     w0, #58
  subs    w0, w0, w6                              // w0 = (58-row)
  b.lo    4f                                      // Jump forward to 4: if row > 58
  add     w0, w0, #2                              // w0 = (60-row)
  ldrb    w3, [x28, TV_FLAG-sysvars]              // w3 = [TV_FLAG]
  tbnz    w3, #0, 7f                              // If lower screen in use, jump forward to 7:
  ldrb    w3, [x28, DF_SZ-sysvars]                // w3 = lower screen DF_SZ
  cmp     w3, w0
  b.hs    6f                                      // Jump forward to 6: if [DF_SZ] >= (60-row)
1:
  bl      cl_set
2:
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret
3:
  bl      co_temp_5
  b       2b
4:
  bl      report_bb
  b       2b
5:
  add     w4, w6, w0, lsl #8                      // w4 = TAB value (uint16)
  bl      po_fill
  b       2b
6:
  bl      report_5
  b       2b
7:
  bl      po_scr
  b       2b
