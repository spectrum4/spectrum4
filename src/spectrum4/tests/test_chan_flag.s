# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
.align 2

.if ROMS_INCLUDE
.else
  .include "add_ch_1.s"
  .include "add_char.s"
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
  .include "key_input.s"
  .include "new_tokens.s"
  .include "one_space.s"
  .include "pin.s"
  .include "po_1_oper.s"
  .include "po_2_oper.s"
  .include "po_able.s"
  .include "po_any.s"
  .include "po_at_set.s"
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
  .include "po_tab.s"
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
  .include "to_co_temp_5.s"
  .include "to_end.s"
  .include "to_report_bb.s"
.endif

# Copy default CHANS to heap
test_chan_flag_init:
  adrp    x5, heap
  add     x5, x5, #:lo12:heap                     // x5 = start of heap
  str     x5, [x28, CHANS-sysvars]                // [CHANS] = start of heap
  mov     x6, (initial_channel_info_END - initial_channel_info)/8
  adr     x7, initial_channel_info
  2:                                              // Loop to copy initial_channel_info block to [CHANS] = start of heap
    ldr     x8, [x7], #8
    str     x8, [x5], #8
    subs    x6, x6, #1
    b.ne    2b
  ret


chan_flag_01_setup:
  b       test_chan_flag_init

chan_flag_01_setup_regs:
  adr     x0, heap + 0x18*2
  ret

chan_flag_01_effects:
  _str    heap + 0x18*2, CURCHL                   //  Current channel is 'R'
  _resbit 4, FLAGS2                               //  K channel not in use
  ret

chan_flag_01_effects_regs:
  mov     x0, 'R'
  mov     x1, 0x00
  mov     x9, 0x00
  mov     x10, 0x50
  nzcv    #0b0010
  ret
