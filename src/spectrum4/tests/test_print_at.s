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
  .include "pr_all.s"
  .include "print_out.s"
  .include "print_token_udg_patch.s"
  .include "print_w0.s"
  .include "rejoin_po_t_udg.s"
  .include "report_bb.s"
  .include "temps.s"
  .include "tkn_table.s"
.endif

.text


.align 2
print_at_01_setup:
  _str    heap, CHANS
  _str    heap, CURCHL
  _str    print_out, heap
  _strh   0x01, STRMS
  _strb   0x02, DF_SZ
  _resbit 0, TV_FLAG
  _resbit 1, FLAGS
  ret

print_at_01_setup_regs:
  mov     w7, #0x2b
  mov     w8, #0x3c
  ret

print_at_01_effects:
  _strb   0x3c-0x2b, S_POSN_Y                     // screen line 43
  _strb   0x6d-0x3c, S_POSN_X                     // screen column 60
  _strh   0x2b16, TVDATA
  _str    display_file + 2*216*20*16 + 3*216 + 60*2 + 0x0*20*216, DF_CC
  ret

print_at_01_effects_regs:
  mov     w0, #0x11
  mov     w1, #0x31
  adrp    x2, display_file + 2*216*20*16 + 3*216 + 60*2 + 0x0*20*216
  add     x2, x2, :lo12:(display_file + 2*216*20*16 + 3*216 + 60*2 + 0x0*20*216)
  ldrb    w3, [x28, TV_FLAG-sysvars]
  mov     w4, #0x03                               // third screen line into screen section (43 % 20)
  mov     w5, #0xd8                               // 216
  ldr     x6, =0x10e00                            // 216*20*16
  nzcv    0b1000
  ret
