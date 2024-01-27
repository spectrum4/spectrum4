# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.


.if ROMS_INCLUDE
.else
  .include "chan_flag.s"
  .include "chan_k.s"
  .include "chan_open.s"
  .include "chan_p.s"
  .include "chan_s.s"
  .include "chn_cd_lu.s"
  .include "cl_addr.s"
  .include "cl_set.s"
  .include "co_temp_5.s"
  .include "copy_buff.s"
  .include "ctlchrtab.s"
  .include "indexer.s"
  .include "new_tokens.s"
  .include "po_1_oper.s"
  .include "po_2_oper.s"
  .include "po_able.s"
  .include "po_any.s"
  .include "po_attr.s"
  .include "po_back.s"
  .include "po_change.s"
  .include "po_char.s"
  .include "po_char_2.s"
  .include "po_comma.s"
  .include "po_cont.s"
  .include "po_enter.s"
  .include "po_fetch.s"
  .include "po_fill.s"
  .include "po_mosaic_half.s"
  .include "po_quest.s"
  .include "po_right.s"
  .include "po_scr.s"
  .include "po_search.s"
  .include "po_store.s"
  .include "po_t_udg.s"
  .include "po_table.s"
  .include "po_table_1.s"
  .include "po_tokens.s"
  .include "po_tv_1.s"
  .include "po_tv_2.s"
  .include "pr_all.s"
  .include "print_message.s"
  .include "print_out.s"
  .include "print_token_udg_patch.s"
  .include "print_w0.s"
  .include "rejoin_po_t_udg.s"
  .include "report_bb.s"
  .include "temps.s"
  .include "tkn_table.s"
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
  bl      print_message                           // Expected output.
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
  bl      print_message                           // Expected output.
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
  bl      print_message                           // Expected output.
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


# This test checks that if we print a string which contains the control code
# sequence 0x10, 0x03, 0x11, 0x02, 0x11, 0x09, 0x10, 0x09 (INK 3, PAPER 2,
# PAPER 9, INK 9) that we end up with ATTR_T holding INK 0 and PAPER 7.
#
# Note this is different to what we get if we swap the order of the control
# codes from PAPER 9, INK 9 to INK 9, PAPER 9 which is demonstrated in the
# subsequent test.
.align 2
po_msg_paper_ink_9_1_setup:
  _str    heap, CHANS
  _str    heap, CURCHL                            // current stream is -3 (channel 'K')
  _str    print_out, heap
  _strh   0x01, STRMS
  ret

po_msg_paper_ink_9_1_setup_regs:
  mov     x3, xzr
  adr     x4, po_msg_paper_ink_9_1_text
  ret

po_msg_paper_ink_9_1_effects_regs:
  mov     x0, #0x00
  adr     x1, po_cont
  add     x4, x4, #0x0a
  mov     x5, #0x00
  mov     x6, #0x09
  nzcv    0b1000
  ret

po_msg_paper_ink_9_1_effects:
  _strb   0x10, TVDATA                            // last control code in string (INK)

  _resbit 0, ATTR_T
  _resbit 1, ATTR_T
  _resbit 2, ATTR_T                               // ink 0

  _setbit 3, ATTR_T
  _setbit 4, ATTR_T
  _setbit 5, ATTR_T                               // paper 7

  _setbit 0, MASK_T
  _setbit 1, MASK_T
  _setbit 2, MASK_T                               // ink colour to be taken from ATTR_T

  _setbit 3, MASK_T
  _setbit 4, MASK_T
  _setbit 5, MASK_T                               // paper colour to be taken from ATTR_T

  _setbit 4, P_FLAG                               // ink 9
  _setbit 6, P_FLAG                               // paper 9
  ret

po_msg_paper_ink_9_1_text:
  .byte   0x00                                    // initial marker
  .byte   0x10, 0x03                              // ink 3
  .byte   0x11, 0x02                              // paper 2
  .byte   0x11, 0x09                              // paper 9
  .byte   0x10, 0x09                              // ink 9
  .byte   0x00                                    // end marker


# This test checks that if we print a string which contains the control code
# sequence 0x10, 0x03, 0x11, 0x02, 0x10, 0x09, 0x11, 0x09 (INK 3, PAPER 2,
# INK 9, PAPER 9) that we end up with ATTR_T holding INK 7 and PAPER 0.
#
# Note this is different to what we get if we swap the order of the control
# codes from INK 9, PAPER 9 to PAPER 9, INK 9 which is demonstrated in the
# previous test.
.align 2
po_msg_paper_ink_9_2_setup:
  _str    heap, CHANS
  _str    heap, CURCHL                            // current stream is -3 (channel 'K')
  _str    print_out, heap
  _strh   0x01, STRMS
  ret

po_msg_paper_ink_9_2_setup_regs:
  mov     x3, xzr
  adr     x4, po_msg_paper_ink_9_2_text
  ret

po_msg_paper_ink_9_2_effects_regs:
  mov     x0, #0x00
  adr     x1, po_cont
  add     x4, x4, #0x0a
  mov     x5, #0x00
  mov     x6, #0x09
  nzcv    0b1000
  ret

po_msg_paper_ink_9_2_effects:
  _strb   0x11, TVDATA                            // last control code in string (PAPER)

  _setbit 0, ATTR_T
  _setbit 1, ATTR_T
  _setbit 2, ATTR_T                               // ink 7

  _resbit 3, ATTR_T
  _resbit 4, ATTR_T
  _resbit 5, ATTR_T                               // paper 0

  _setbit 0, MASK_T
  _setbit 1, MASK_T
  _setbit 2, MASK_T                               // ink colour to be taken from ATTR_T

  _setbit 3, MASK_T
  _setbit 4, MASK_T
  _setbit 5, MASK_T                               // paper colour to be taken from ATTR_T

  _setbit 4, P_FLAG                               // ink 9
  _setbit 6, P_FLAG                               // paper 9
  ret

po_msg_paper_ink_9_2_text:
  .byte   0x00                                    // initial marker
  .byte   0x10, 0x03                              // ink 3
  .byte   0x11, 0x02                              // paper 2
  .byte   0x10, 0x09                              // ink 9
  .byte   0x11, 0x09                              // paper 9
  .byte   0x00                                    // end marker
