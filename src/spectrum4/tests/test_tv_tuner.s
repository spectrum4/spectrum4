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
  .include "cl_set.s"
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


tv_tuner_01_setup:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  _strh   0x01, (STRMS+0x0a)
  _str    tv_tuner_fake_chans, CHANS
  _strb   0x02, DF_SZ                             // lower screen is 2 lines
  strb    wzr, [x28, MASK_P-sysvars]
  strb    wzr, [x28, P_FLAG-sysvars]
  _str    char_set-32*32, CHARS
  adr     x0, display_file
  adr     x1, display_file_end
1:
  str     xzr, [x0], #0x08
  cmp     x0, x1
  b.ne    1b
  adr     x0, attributes_file
  adr     x2, attributes_file_end
2:
  mov     w1, #0x38
  stp     x0, x2, [sp, #-16]!
  bl      poke_address
  ldp     x0, x2, [sp], #16
  add     x0, x0, #0x01
  cmp     x0, x2
  b.ne    2b
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret

tv_tuner_01_effects:
  ret

tv_tuner_01_effects_regs:
  ret

.align 3
tv_tuner_fake_chans:
  .quad print_out                                 // PRINT_OUT - S channel output routine.
  .quad report_j                                  // REPORT_J  - S channel input routine.
  .byte 'S',0,0,0,0,0,0,0                         // 0x53      - Channel identifier 'S'.
