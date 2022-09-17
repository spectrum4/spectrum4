# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.


.if ROMS_INCLUDE
.else
  .include "add_ch_1.s"
  .include "add_char.s"
  .include "chan_flag.s"
  .include "chan_k.s"
  .include "chan_open.s"
  .include "chan_p.s"
  .include "chan_s.s"
  .include "chn_cd_lu.s"
  .include "cl_addr.s"
  .include "cl_all.s"
  .include "cl_chan.s"
  .include "cl_line.s"
  .include "cl_set.s"
  .include "cls_lower.s"
  .include "co_temp_5.s"
  .include "copy_buff.s"
  .include "ctlchrtab.s"
  .include "indexer.s"
  .include "initial_channel_info.s"
  .include "initial_stream_data.s"
  .include "key_input.s"
  .include "make_room.s"
  .include "new_tokens.s"
  .include "one_space.s"
  .include "pin.s"
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
  .include "po_msg.s"
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
  .include "pout.s"
  .include "pr_all.s"
  .include "print_out.s"
  .include "print_token_udg_patch.s"
  .include "print_w0.s"
  .include "rejoin_po_t_udg.s"
  .include "report_bb.s"
  .include "report_j.s"
  .include "temps.s"
  .include "tkn_table.s"
.endif

.text
.align 2


cls_1_setup:
  _strb   0x02, DF_SZ
  _strb   0x38, ATTR_P
  _strb   0x38, BORDCR
  _str    heap, CHANS

  adrp    x5, heap
  add     x5, x5, :lo12:heap
  mov     x6, (initial_channel_info_END - initial_channel_info)/8
  adrp    x7, initial_channel_info
  add     x7, x7, :lo12:initial_channel_info
  // Loop to copy initial_channel_info block to [CHANS] = start of heap = heap
  3:
    ldr     x8, [x7], #8
    str     x8, [x5], #8
    subs    x6, x6, #1
    b.ne    3b
  add     x5, x28, STRMS - sysvars
  mov     x6, (initial_stream_data_END - initial_stream_data)/2
  adr     x7, initial_stream_data
  // Loop to copy initial_stream_data block to [STRMS]
  4:
    ldrh    w8, [x7], #2
    strh    w8, [x5], #2
    subs    x6, x6, #1
    b.ne    4b
  ret

cls_1_setup_regs:
  ret

cls_1_effects:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  adrp    x0, display_file
  add     x0, x0, :lo12:display_file
  adrp    x1, display_file_end
  add     x1, x1, :lo12:display_file_end
1:
  str     xzr, [x0], #0x08
  cmp     x0, x1
  b.ne    1b
  adrp    x0, attributes_file
  add     x0, x0, :lo12:attributes_file
  adrp    x2, attributes_file_end
  add     x2, x2, :lo12:attributes_file_end
2:
  mov     w1, #0x38
  stp     x0, x2, [sp, #-16]!
  bl      poke_address
  ldp     x0, x2, [sp], #16
  add     x0, x0, #0x01
  cmp     x0, x2
  b.ne    2b
  _resbit 1, FLAGS
  _resbit 5, FLAGS
  _resbit 0, FLAGS2                               // updated in cl_all
  _setbit 4, FLAGS2
  _resbit 5, TV_FLAG
  _setbit 0, TV_FLAG
  _resbit 0, P_FLAG
  _resbit 2, P_FLAG
  _resbit 4, P_FLAG
  _resbit 6, P_FLAG
  _strb   0x6d, S_POSN_X
  _strb   0x3c, S_POSN_Y
  _strb   0x6d, S_POSN_X_L
  _strb   0x3b, S_POSN_Y_L
  _strb   0x6d, ECHO_E_X
  _strb   0x3b, ECHO_E_Y
  _strb   0x01, SCR_CT                            // updated in cl_all
  _strb   0x38, ATTR_T
  _strb   0x00, MASK_T
  _strh   0x00, COORDS_X                          // updated in cl_all
  _strh   0x00, COORDS_Y                          // updated in cl_all
  _str    heap, CURCHL
  _str    display_file, DF_CC
  _str    display_file + 2*16*20*216 + 19*216, DF_CC_L
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret

cls_1_effects_regs:
  mov     x0, 0x000000000000003b
  mov     x1, 0x000000000000006d
  ldr     x2, =(display_file+2*216*16*20+216*19)
  ldrb    w3, [x28, TV_FLAG-sysvars]
  mov     x4, (61-2)%20
  mov     x5, 216
  ldr     x6, =0x0000000000010e00
  ldr     x7, =0x0000000000cccccc
  mov     x8, 0x0000000000000000
  mov     x9, 0x00000000000000de
  ldrb    w9, [x28, FLAGS2-sysvars]
  mov     x10, 'K'
  ldr     x11, =0x00000000000329ff
  mov     x12, 0x000000000000006c
  mov     x13, 0x0000000000000000
  mov     x14, 0x0000000000000000
  mov     x15, 0x0000000000000000
  mov     x16, 0x000000000000194f
  mov     x17, 0x0000000000000038
  mov     x18, 0x000000000000000a
  nzcv    0b0110
  ret
