# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.if ROMS_INCLUDE
.else
  .include "add_ch_1.s"
  .include "add_char.s"
  .include "chan_flag.s"
  .include "chan_k.s"
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
  .include "new_tokens.s"
  .include "one_space.s"
  .include "make_room.s"
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

.text
.align 2

# Copy default STRMS and CHANS to heap
test_chan_open_init:
  adr     x5, STRMS
  mov     x6, (initial_stream_data_END - initial_stream_data)/2
                                                  // x6 = number of half words (2 bytes) in initial_stream_data block
  adr     x7, initial_stream_data
  1:                                              // Loop to copy initial_stream_data block to [STRMS]
    ldrh    w8, [x7], #2
    strh    w8, [x5], #2
    subs    x6, x6, #1
    b.ne    1b
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



chan_open_minus_01_setup:
  b       test_chan_open_init

chan_open_minus_01_setup_regs:
  mov     x0, #-1
  ret

chan_open_minus_01_effects:
  _str    heap + 0x18*2, CURCHL                   //  Current channel is 'R'
  _resbit 4, FLAGS2                               //  K channel not in use
  ret

chan_open_minus_01_effects_regs:
  mov     x0, 'R'
  mov     x1, 0x00
  mov     x9, 0x00
  mov     x10, 0x50
  nzcv    #0b0010
  ret



chan_open_00_setup:
  _strb   0x03, BORDCR
  _strb   0b10100110, P_FLAG
  b       test_chan_open_init

chan_open_00_setup_regs:
  mov     x0, #0x00
  ret

chan_open_00_effects:
  _str    heap, CURCHL                            // Current channel is keyboard
  _resbit 1, FLAGS                                // Printer not in use
  _resbit 5, FLAGS                                // No new key
  _setbit 4, FLAGS2                               // K channel in use
  _setbit 0, TV_FLAG                              // Lower screen in use
  _strb   0x03, ATTR_T                            // [BORDCR]
  _strb   0x00, MASK_T
  _strb   0b10100010, P_FLAG                      // even (temp) bits cleared
  ret

chan_open_00_effects_regs:
  mov     x0, 0b10100010                          // [P_FLAG]
  mov     x1, 0x03                                // [BORDCR]
  adr     x2, chan_k
  ldrb    w9, [x28, FLAGS2-sysvars]
  mov     x10, 'K'                                // Key for chn-cd-lu table
  nzcv    #0b0110
  ret



chan_open_01_setup:
  _strb   0x03, BORDCR
  _strb   0b10100110, P_FLAG
  b       test_chan_open_init

chan_open_01_setup_regs:
  mov     x0, #0x01
  ret

chan_open_01_effects:
  _str    heap, CURCHL                            // Current channel is keyboard
  _resbit 1, FLAGS                                // Printer not in use
  _resbit 5, FLAGS                                // No new key
  _setbit 4, FLAGS2                               // K channel in use
  _setbit 0, TV_FLAG                              // Lower screen in use
  _strb   0x03, ATTR_T                            // [BORDCR]
  _strb   0x00, MASK_T
  _strb   0b10100010, P_FLAG
  ret

chan_open_01_effects_regs:
  mov     x0, 0b10100010                          // [P_FLAG]
  mov     x1, 0x03                                // [BORDCR]
  adr     x2, chan_k
  ldrb    w9, [x28, FLAGS2-sysvars]
  mov     x10, 'K'                                // Key for chn-cd-lu table
  nzcv    #0b0110
  ret



chan_open_02_setup:
  _strb   0b10100010, P_FLAG
  _strb   0x57, ATTR_P
  _strb   0x23, MASK_P
  b       test_chan_open_init

chan_open_02_setup_regs:
  mov     x0, #0x02
  ret

chan_open_02_effects:
  _str    heap + 0x18*1, CURCHL                   // Current channel is screen
  _resbit 1, FLAGS                                // Printer not in use
  _resbit 4, FLAGS2                               // K channel not in use
  _resbit 0, TV_FLAG                              // Main screen in use
  _strb   0x57, ATTR_T                            // [ATTR_P]
  _strb   0x23, MASK_T                            // [MASK_P]
  _strb   0b11110011, P_FLAG                      // Perm bits copied to temp bits
  ret

chan_open_02_effects_regs:
  mov     x0, 0b11110011                          // [P_FLAG]
  mov     x1, 0x2357                              // ([MASK_P] << 8) | [ATTR_P]
  mov     x2, 0b01010001                          // [P_FLAG] with temp bits copied from perm bits; perm bits cleared
  mov     x9, 0x01
  mov     x10, 'S'                                // Key for chn-cd-lu table
  nzcv    #0b0110
  ret



chan_open_03_setup:
  b       test_chan_open_init

chan_open_03_setup_regs:
  mov     x0, #0x03
  ret

chan_open_03_effects:
  _str    heap + 0x18*3, CURCHL                   // Current channel is printer
  _setbit 1, FLAGS                                // Printer in use
  _resbit 4, FLAGS2                               // K channel not in use
  ret

chan_open_03_effects_regs:
  ldrb    w0, [x28, FLAGS-sysvars]
  mov     x1, chn_cd_lu + 0x08 + 2*0x10           // Third record in chn-cd-lu
  mov     x2, chan_p
  mov     w9, #0x00                               // No more records in chn-cd-lu
  mov     x10, 'P'                                // Key for chn-cd-lu table
  nzcv    #0b0110
  ret
