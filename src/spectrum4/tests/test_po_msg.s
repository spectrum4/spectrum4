# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.


.if ROMS_INCLUDE
.else
  .include "po_search.s"
  .include "po_table.s"
  .include "po_table_1.s"
  .include "print_w0.s"
.endif

.text


# Need a loooooong table here, since leading space requires >= 32 entries
# to occur.
.align 0
msg_po_msg_test:
  .asciz "potato"
  .asciz "monkey"
  .asciz "robot"
msg_po_msg_bakery0:
  .asciz "bakery0"
msg_po_msg_door:
  .asciz "door"
  .asciz "msg4"
  .asciz "msg5"
  .asciz "msg6"
  .asciz "msg7"
  .asciz "msg8"
  .asciz "msg9"
  .asciz "msg10"
  .asciz "msg11"
  .asciz "msg12"
  .asciz "msg13"
  .asciz "msg14"
  .asciz "msg15"
  .asciz "msg16"
  .asciz "msg17"
  .asciz "msg18"
  .asciz "msg19"
  .asciz "msg20"
  .asciz "msg21"
  .asciz "msg22"
  .asciz "msg23"
  .asciz "msg24"
  .asciz "msg25"
  .asciz "msg26"
  .asciz "msg27"
  .asciz "msg28"
  .asciz "msg29"
  .asciz "msg30"
  .asciz "msg31"
msg_32:
  .asciz "msg32"
msg_33:
  .asciz "33"
msg_34:

# Output adds a leading space...
.align 0
msg_32_out:
  .asciz " msg32"


# po_msg_01 just prints a regular message with no leading space

.align 2
po_msg_01_setup:
  _str    fake_channel_block, CURCHL
  ret

po_msg_01_setup_regs:
  mov     x3, #0x2
  adr     x4, msg_po_msg_test
  ret

po_msg_01_effects:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  adr     x2, msg_po_msg_bakery0
  bl      print_string                            // Expected output.
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret

po_msg_01_effects_regs:
  mov     x0, #0x00
  adr     x1, fake_printout
  adr     x4, msg_po_msg_door
  mov     x5, #0
  mov     x6, '0'
  nzcv    #0b1000
  ret


# po_msg_02 prints a message with leading space, since first char >= 'A', index >= 32 and FLAGS bit 0 is clear

.align 2
po_msg_02_setup:
  _str    fake_channel_block, CURCHL
  _resbit 0, FLAGS
  ret

po_msg_02_setup_regs:
  mov     x3, #32
  adr     x4, msg_po_msg_test
  ret

po_msg_02_effects:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  adr     x2, msg_32_out
  bl      print_string                            // Expected output.
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret

po_msg_02_effects_regs:
  mov     x0, #0x00
  adr     x1, fake_printout
  adr     x4, msg_33
  mov     x5, #0
  mov     x6, '2'
  nzcv    #0b1000
  ret


# po_msg_03 shouldn't print leading space, despite index >= 32 and FLAGS bit 0 being clear, since first char = '3' (i.e. not >= 'A')

.align 2
po_msg_03_setup:
  _str    fake_channel_block, CURCHL
  _resbit 0, FLAGS
  ret

po_msg_03_setup_regs:
  mov     x3, #33
  adr     x4, msg_po_msg_test
  ret

po_msg_03_effects:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  adr     x2, msg_33
  bl      print_string                            // Expected output.
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret

po_msg_03_effects_regs:
  mov     x0, #0x00
  adr     x1, fake_printout
  adr     x4, msg_34
  mov     x5, #0
  mov     x6, '3'
  nzcv    #0b1000
  ret
