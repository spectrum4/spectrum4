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
  ld      l, 118
  ret

po_msg_01_effects:
  ld      de, msg_po_msg_01_out
  call    print_msg_de                    ; Expected output.
  ret

po_msg_01_effects_regs:
  ld      a, 2*'0'
  ldf     S_FLAG | H_FLAG | PV_FLAG | N_FLAG | C_FLAG
  ld      de, 118
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
  ld      l, 217
  ret

po_msg_02_effects:
  ld      de, msg_po_msg_02_out
  call    print_msg_de                    ; Expected output.
  ret

po_msg_02_effects_regs:
  ld      a, '2'*2
  ldf     S_FLAG | PV_FLAG | N_FLAG | C_FLAG
  ld      de, 217
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
  ld      l, 43
  ret

po_msg_03_effects:
  ld      de, msg_po_msg_03_out
  call    print_msg_de                    ; Expected output.
  ret

po_msg_03_effects_regs:
  ld      a, '3'*2
  ldf     S_FLAG | PV_FLAG | N_FLAG | C_FLAG
  ld      de, 43
  ret

msg_po_msg_03_out:
  .asciz "33"


# This test checks that if we print a string which contains the control code
# sequence 0x10, 0x03, 0x11, 0x02, 0x11, 0x09, 0x10, 0x09 (INK 3, PAPER 2,
# PAPER 9, INK 9) that we end up with ATTR_T holding INK 0 and PAPER 7.
#
# Note this is different to what we get if we swap the order of the control
# codes from PAPER 9, INK 9 to INK 9, PAPER 9 which is demonstrated in the
# subsequent test.
po_msg_paper_ink_9_1_setup:
  _strh   sysvars_48k_end, CHANS          ; channel information table stored after sysvars
  _strh   sysvars_48k_end, CURCHL         ; current stream is -3 (channel 'K')
  _strh   print_out, sysvars_48k_end
  _strh   0x01, STRMS
  ret

po_msg_paper_ink_9_1_setup_regs:
  xor     a
  ld      de, po_msg_paper_ink_9_1_text
  ld      l, 0x1b                         ; E holds value of entry L on exit, so give it a value so we can check E matches
  ret

po_msg_paper_ink_9_1_effects_regs:
  ldf     0x87
  ld      a, 0x12
  ld      bc, 0x1000
  ld      d, 0
  ld      e, 0x1b
  ret

po_msg_paper_ink_9_1_effects:
  _strb   0x10, TVDATA                    ; last control code in string (INK)

  _resbit 0, ATTR_T
  _resbit 1, ATTR_T
  _resbit 2, ATTR_T                       ; ink 0

  _setbit 3, ATTR_T
  _setbit 4, ATTR_T
  _setbit 5, ATTR_T                       ; paper 7

  _setbit 0, MASK_T
  _setbit 1, MASK_T
  _setbit 2, MASK_T                       ; ink colour to be taken from ATTR_T

  _setbit 3, MASK_T
  _setbit 4, MASK_T
  _setbit 5, MASK_T                       ; paper colour to be taken from ATTR_T

  _setbit 4, P_FLAG                       ; ink 9
  _setbit 6, P_FLAG                       ; paper 9
  ret

po_msg_paper_ink_9_1_text:
  # any byte value with bit 7 set here is fine
  .byte   0xab
  .byte   0x10, 0x03                      ; ink 3
  .byte   0x11, 0x02                      ; paper 2
  .byte   0x11, 0x09                      ; paper 9
  .byte   0x10, 0x09 | 0x80               ; ink 9 (bit 7 set => end marker)


# This test checks that if we print a string which contains the control code
# sequence 0x10, 0x03, 0x11, 0x02, 0x10, 0x09, 0x11, 0x09 (INK 3, PAPER 2,
# INK 9, PAPER 9) that we end up with ATTR_T holding INK 7 and PAPER 0.
#
# Note this is different to what we get if we swap the order of the control
# codes from INK 9, PAPER 9 to PAPER 9, INK 9 which is demonstrated in the
# previous test.
po_msg_paper_ink_9_2_setup:
  _strh   sysvars_48k_end, CHANS          ; channel information table stored after sysvars
  _strh   sysvars_48k_end, CURCHL         ; current stream is -3 (channel 'K')
  _strh   print_out, sysvars_48k_end
  _strh   0x01, STRMS
  ret

po_msg_paper_ink_9_2_setup_regs:
  xor     a
  ld      de, po_msg_paper_ink_9_2_text
  ld      l, 0x1c                         ; E holds value of entry L on exit, so give it a value so we can check E matches
  ret

po_msg_paper_ink_9_2_effects_regs:
  ldf     0x87
  ld      a, 0x12
  ld      bc, 0x4000
  ld      d, 0
  ld      e, 0x1c                         ; entry L
  ret

po_msg_paper_ink_9_2_effects:
  _strb   0x11, TVDATA                    ; last control code in string (PAPER)

  _setbit 0, ATTR_T
  _setbit 1, ATTR_T
  _setbit 2, ATTR_T                       ; ink 7

  _resbit 3, ATTR_T
  _resbit 4, ATTR_T
  _resbit 5, ATTR_T                       ; paper 0

  _setbit 0, MASK_T
  _setbit 1, MASK_T
  _setbit 2, MASK_T                       ; ink colour to be taken from ATTR_T

  _setbit 3, MASK_T
  _setbit 4, MASK_T
  _setbit 5, MASK_T                       ; paper colour to be taken from ATTR_T

  _setbit 4, P_FLAG                       ; ink 9
  _setbit 6, P_FLAG                       ; paper 9
  ret

po_msg_paper_ink_9_2_text:
  # any byte value with bit 7 set here is fine
  .byte   0xab
  .byte   0x10, 0x03                      ; ink 3
  .byte   0x11, 0x02                      ; paper 2
  .byte   0x10, 0x09                      ; ink 9
  .byte   0x11, 0x09 | 0x80               ; paper 9 (bit 7 set => end marker)
