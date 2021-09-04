.text
.align 2
# On entry:
#   w0 = first byte of 2 byte control code
# On exit:
#   [TVDATA+1] = first byte of 2 byte control code
#   [[CURCHL]] = po_cont
#   x4 = po_cont
#   x5 = [CURCHL]
po_tv_2:                                 // L0A6D
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  adr     x4, po_cont                             // po_cont will be next output routine
  strb    w0, [x28, TVDATA+1-sysvars]             // store first operand in TVDATA high byte
  bl      po_change                               // Set current channel output routine to po_cont
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
