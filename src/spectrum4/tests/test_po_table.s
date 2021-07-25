# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text


.if ROMS_INCLUDE
.else
  .include "po_search.s"
  .include "po_table_1.s"
  .include "print_w0.s"
.endif


# Since there is considerable test coverage of po_search, po_table and
# po_tokens, only minimal testing provided here.

.align 0
msg_po_table_test:
  .asciz "potato"
  .asciz "monkey"
  .asciz "robot"
msg_po_table_bakery0:
  .asciz "bakery0"
msg_po_table_door:
  .asciz "door"

.align 2
po_table_01_setup:
  _str    fake_channel_block, CURCHL
  ret

po_table_01_setup_regs:
  mov     x3, #0x2
  adr     x4, msg_po_table_test
  mov     x5, #0x50
  ret

po_table_01_effects:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  adr     x2, msg_po_table_bakery0
  bl      print_string                            // Expected output.
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret

po_table_01_effects_regs:
  mov     x0, #0x00
  adr     x1, fake_printout
  adr     x4, msg_po_table_door
  mov     x6, '0'
  nzcv    #0b1000
  ret
