# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.


# Test the po_scr_2 code path: when the upper screen cursor reaches the
# scroll boundary (w0 == DF_SZ) and this is NOT an automatic program listing
# (TV_FLAG bit 4 = 0), po_scr should take the po_scr_2 path which decrements
# SCR_CT and eventually scrolls the display or shows the "scroll?" prompt.
#
# Conditions:
#   - Upper screen in use (FLAGS bit 1 = 0, TV_FLAG bit 0 = 0)
#   - Cursor at scroll boundary (w0 == DF_SZ = 0x1f)
#   - Not an automatic listing (TV_FLAG bit 4 = 0)
#   - SCR_CT = 2 (non-zero after decrement, so scrolls without prompting)
#
# The equivalent spectrum128k test is test_po_scr.tv_flag_bit4.s.


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
  .include "indexer.s"
  .include "po_msg.s"
  .include "po_search.s"
  .include "po_store.s"
  .include "po_table.s"
  .include "po_table_1.s"
  .include "print_w0.s"
  .include "temps.s"
.endif

.text
.align 2


po_scr_tv_flag_bit4_setup:
  _resbit 1, FLAGS                                // not printing
  _resbit 0, TV_FLAG                              // upper screen in use
  _resbit 4, TV_FLAG                              // not automatic listing (bit 4 = 0)
  _strb   0x1f, DF_SZ                             // DF_SZ = 31
  _strb   0x02, SCR_CT                            // SCR_CT = 2 (correct path decrements this)
  _strb   0x01, BREG                              // BREG = 1 (bug path would decrement this instead)
  ret


po_scr_tv_flag_bit4_setup_regs:
  mov     w0, #0x1f                               // w0 = 31 = DF_SZ (equality triggers bit 4 test)
  mov     w1, #0x10                               // w1 = 0x10 (bit 4 set - old bug would NOT branch to po_scr_2)
  ret


po_scr_tv_flag_bit4_effects:
  // po_scr_2 decrements SCR_CT in register w9 but does not store it back.
  // po_scr_4 -> cl_set -> cl_addr -> po_store writes cursor position to sysvars.
  // cl_addr: line = 60-0x1f = 29, section = 29/20 = 1, row = 29%20 = 9
  // DF_CC = display_file + 9*216 + 1*69120 + 218 - 2*0x10 = display_file + 71250
  _strb   0x1f, S_POSN_Y                          // po_store: [S_POSN_Y] = w0
  _strb   0x10, S_POSN_X                          // po_store: [S_POSN_X] = w1
  _str    display_file + 71250, DF_CC             // po_store: [DF_CC] = cursor address
  ret


po_scr_tv_flag_bit4_effects_regs:
  // Register state after po_scr with w0=0x1f, w1=0x10, upper screen, TV_FLAG bit 4 = 0:
  //   po_scr_2: w9 = [SCR_CT]-1 = 1
  //   po_scr_4: NZCV from subs (0x1f+0x1f-61 = 1) = 0b0010
  //   cl_addr:  line=29, section=1, row=9 => w4=9, w5=216, x6=69120
  //   cl_set:   x2 = display_file + 9*216 + 69120 + 218 - 2*0x10 = display_file + 71250
  //   po_store: w3 = [TV_FLAG]
  mov     w0, #0x1f
  mov     w1, #0x10
  adrp    x2, display_file + 71250
  add     x2, x2, :lo12:(display_file + 71250)
  ldrb    w3, [x28, TV_FLAG-sysvars]
  mov     w4, #9
  mov     w5, #216
  mov     x6, #0x00010000
  movk    x6, #0xe00
  mov     w9, #1
  nzcv    #0b0010
  ret
