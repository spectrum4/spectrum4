.text
.align 2
# This initial entry point deals with one operand INK to OVER.
#
# On entry:
#   w3 = control char (0x10/0x11/0x12/0x13/0x14/0x15)
#
# On exit:
#   [TVDATA] = w3[0-7]
#   [[CURCHL]] = po_cont
po_1_oper:                               // L0A7A
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  adr     x4, po_cont
  bl      po_tv_1                                 // Store control character in TVDATA low byte and set
                                                  // current channel output routine to po_cont.
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
