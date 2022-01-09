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
  .include "copy_buff.s"
  .include "indexer.s"
  .include "po_attr.s"
  .include "po_char.s"
  .include "po_char_2.s"
  .include "po_mosaic_half.s"
  .include "po_msg.s"
  .include "po_scr.s"
  .include "po_search.s"
  .include "po_store.s"
  .include "po_t_udg.s"
  .include "po_table.s"
  .include "po_table_1.s"
  .include "pr_all.s"
  .include "print_w0.s"
  .include "temps.s"
  .include "rejoin_po_t_udg.s"
  .include "po_tokens.s"
  .include "po_fetch.s"
  .include "print_token_udg_patch.s"
  .include "new_tokens.s"
  .include "tkn_table.s"
.endif

.text


.align 2
po_any_G_81_setup:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  _resbit 0, TV_FLAG                              // lower screen not in use (used by po_fetch)
  _setbit 4, FLAGS                                // 128K mode
  _strb   0b00001111, P_FLAG                      // OVER 1, INVERSE 1
  _resbit 1, FLAGS                                // printer not in use
  _strb   0x1e, DF_SZ                             // lower screen is 30 lines
  _strb   0b01010011, MASK_T
  _strb   0b01100101, ATTR_T
  _strb   0b00111000, attributes_file + 108*20*0 + 11*108 + 9

  _strhbe 0b0000000000000000, display_file + 216*20*16*0 + 11*216 + 9*2 + 0*216*20
  _strhbe 0b0000000000000000, display_file + 216*20*16*0 + 11*216 + 9*2 + 1*216*20
  _strhbe 0b0000111111110000, display_file + 216*20*16*0 + 11*216 + 9*2 + 2*216*20
  _strhbe 0b0001111111111000, display_file + 216*20*16*0 + 11*216 + 9*2 + 3*216*20
  _strhbe 0b0011100000011100, display_file + 216*20*16*0 + 11*216 + 9*2 + 4*216*20
  _strhbe 0b0011000000001100, display_file + 216*20*16*0 + 11*216 + 9*2 + 5*216*20
  _strhbe 0b0011000000000000, display_file + 216*20*16*0 + 11*216 + 9*2 + 6*216*20
  _strhbe 0b0011000000000000, display_file + 216*20*16*0 + 11*216 + 9*2 + 7*216*20
  _strhbe 0b0011000011111100, display_file + 216*20*16*0 + 11*216 + 9*2 + 8*216*20
  _strhbe 0b0011000011111100, display_file + 216*20*16*0 + 11*216 + 9*2 + 9*216*20
  _strhbe 0b0011000000001100, display_file + 216*20*16*0 + 11*216 + 9*2 + 10*216*20
  _strhbe 0b0011100000011100, display_file + 216*20*16*0 + 11*216 + 9*2 + 11*216*20
  _strhbe 0b0001111111111000, display_file + 216*20*16*0 + 11*216 + 9*2 + 12*216*20
  _strhbe 0b0000111111110000, display_file + 216*20*16*0 + 11*216 + 9*2 + 13*216*20
  _strhbe 0b0000000000000000, display_file + 216*20*16*0 + 11*216 + 9*2 + 14*216*20
  _strhbe 0b0000000000000000, display_file + 216*20*16*0 + 11*216 + 9*2 + 15*216*20
  adr     x0, display_file + 216*20*16*0 + 11*216 + 9*2 + 0*216*20
  bl      po_attr
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret

.align 2
po_any_G_81_setup_regs:
  mov     w0, 60-11-0*20
  adr     x2, display_file + 216*20*16*0 + 11*216 + 9*2
  mov     w1, 109-9
  mov     w3, 0x81
  ret

.align 2
po_any_G_81_effects:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.

  _str    0xff00ff00ff00ff00, MEMBOT
  _str    0xff00ff00ff00ff00, MEMBOT+8
  _str    0x0000000000000000, MEMBOT+16
  _str    0x0000000000000000, MEMBOT+24

  _strhbe 0b1111111100000000, display_file + 216*20*16*0 + 11*216 + 9*2 + 0*216*20
  _strhbe 0b1111111100000000, display_file + 216*20*16*0 + 11*216 + 9*2 + 1*216*20
  _strhbe 0b1111000011110000, display_file + 216*20*16*0 + 11*216 + 9*2 + 2*216*20
  _strhbe 0b1110000011111000, display_file + 216*20*16*0 + 11*216 + 9*2 + 3*216*20
  _strhbe 0b1100011100011100, display_file + 216*20*16*0 + 11*216 + 9*2 + 4*216*20
  _strhbe 0b1100111100001100, display_file + 216*20*16*0 + 11*216 + 9*2 + 5*216*20
  _strhbe 0b1100111100000000, display_file + 216*20*16*0 + 11*216 + 9*2 + 6*216*20
  _strhbe 0b1100111100000000, display_file + 216*20*16*0 + 11*216 + 9*2 + 7*216*20
  _strhbe 0b1100111100000011, display_file + 216*20*16*0 + 11*216 + 9*2 + 8*216*20
  _strhbe 0b1100111100000011, display_file + 216*20*16*0 + 11*216 + 9*2 + 9*216*20
  _strhbe 0b1100111111110011, display_file + 216*20*16*0 + 11*216 + 9*2 + 10*216*20
  _strhbe 0b1100011111100011, display_file + 216*20*16*0 + 11*216 + 9*2 + 11*216*20
  _strhbe 0b1110000000000111, display_file + 216*20*16*0 + 11*216 + 9*2 + 12*216*20
  _strhbe 0b1111000000001111, display_file + 216*20*16*0 + 11*216 + 9*2 + 13*216*20
  _strhbe 0b1111111111111111, display_file + 216*20*16*0 + 11*216 + 9*2 + 14*216*20
  _strhbe 0b1111111111111111, display_file + 216*20*16*0 + 11*216 + 9*2 + 15*216*20

  adr     x0, display_file + 216*20*16*0 + 11*216 + 9*2 + 0*216*20
  bl      po_attr
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret

.align 2
po_any_G_81_effects_regs:
  sub     w1, w1, #1
  add     w2, w2, #2
  mov     w3, wzr
  adr     x4, MEMBOT
  mov     w5, #0xcc
  mov     w6, #0xcc
  ldr     w7, =0xcccc00
  mov     w8, wzr
  adr     x9, mbreq
  mov     w10, #9
  ldr     x11, =0x1067b
  mov     w12, #0x6c
  mov     w13, wzr
  mov     w14, #0xcc
  mov     w15, #0xcc00
  mov     w16, #0x04ad
  mov     w17, #0x34
  mov     w18, wzr
  nzcv    0b0110
  ret
