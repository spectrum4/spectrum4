# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text


# Need a loooooong table here, since leading space requires >= 32 entries
# to occur.
msg_po_msg_test:
  .ascii "potat"
  .byte 'o'+0x80
  .ascii "monke"
  .byte 'y'+0x80
  .ascii "robo"
  .byte 't'+0x80
msg_po_msg_bakery0:
  .ascii "bakery"
  .byte '0'+0x80
msg_po_msg_door:
  .ascii "doo"
  .byte 'r'+0x80
  .ascii "msg"
  .byte '4'+0x80
  .ascii "msg"
  .byte '5'+0x80
  .ascii "msg"
  .byte '6'+0x80
  .ascii "msg"
  .byte '7'+0x80
  .ascii "msg"
  .byte '8'+0x80
  .ascii "msg"
  .byte '9'+0x80
  .ascii "msg1"
  .byte '0'+0x80
  .ascii "msg1"
  .byte '1'+0x80
  .ascii "msg1"
  .byte '2'+0x80
  .ascii "msg1"
  .byte '3'+0x80
  .ascii "msg1"
  .byte '4'+0x80
  .ascii "msg1"
  .byte '5'+0x80
  .ascii "msg1"
  .byte '6'+0x80
  .ascii "msg1"
  .byte '7'+0x80
  .ascii "msg1"
  .byte '8'+0x80
  .ascii "msg1"
  .byte '9'+0x80
  .ascii "msg2"
  .byte '0'+0x80
  .ascii "msg2"
  .byte '1'+0x80
  .ascii "msg2"
  .byte '2'+0x80
  .ascii "msg2"
  .byte '3'+0x80
  .ascii "msg2"
  .byte '4'+0x80
  .ascii "msg2"
  .byte '5'+0x80
  .ascii "msg2"
  .byte '6'+0x80
  .ascii "msg2"
  .byte '7'+0x80
  .ascii "msg2"
  .byte '8'+0x80
  .ascii "msg2"
  .byte '9'+0x80
  .ascii "msg3"
  .byte '0'+0x80
  .ascii "msg3"
  .byte '1'+0x80
msg_32:
  .ascii "msg3"
  .byte '2'+0x80
msg_33:
  .ascii "3"
  .byte '3'+0x80
msg_34:


# po_msg_01 just prints a regular message with no leading space

po_msg_01_setup:
  jp      fake0

po_msg_01_setup_regs:
  ld      iy, 0x5000
  ld      a, 0x2
  ld      de, msg_po_msg_test
  ret

po_msg_01_effects:
  ld      de, msg_po_msg_01_out
  call    print_msg_de                    ; Expected output.
  ret

po_msg_01_effects_regs:
  ld      a, 2*'0'
  ldf     0x97
  ld      de, 0x0007                      ; TODO - why?!?
  ret

msg_po_msg_01_out:
  .asciz "bakery0"

# po_msg_02 prints a message with leading space, since first char >= 'A', index >= 32 and FLAGS bit 0 is clear

po_msg_02_setup:
  jp      fake0

po_msg_02_setup_regs:
  ld      iy, 0x5000
  ld      a, 32
  ld      de, msg_po_msg_test
  ret

po_msg_02_effects:
  ld      de, msg_po_msg_02_out
  call    print_msg_de                    ; Expected output.
  ret

po_msg_02_effects_regs:
  ld      a, '2'*2
  ldf     0x87
  ld      de, 0x0007                      ; TODO - why?!?
  ret

# Output adds a leading space...
msg_po_msg_02_out:
  .asciz " msg32"


# po_msg_03 shouldn't print leading space, despite index >= 32 and FLAGS bit 0 being clear, since first char = '3' (i.e. not >= 'A')

po_msg_03_setup:
  jp      fake0

po_msg_03_setup_regs:
  ld      iy, 0x5000
  ld      a, 33
  ld      de, msg_po_msg_test
  ret

po_msg_03_effects:
  ld      de, msg_po_msg_03_out
  call    print_msg_de                    ; Expected output.
  ret

po_msg_03_effects_regs:
  ld      a, '3'*2
  ldf     0x87
  ld      de, 0x0007                      ; TODO - why?!?
  ret

msg_po_msg_03_out:
  .asciz "33"
