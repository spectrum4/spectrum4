# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.


# Test the po_scr_2 code path: when the upper screen cursor reaches the
# scroll boundary (B == DF_SZ) and this is NOT an automatic program listing
# (TV_FLAG bit 4 = 0), po_scr should take the po_scr_2 path which decrements
# SCR_CT and scrolls the display via po_scr_3.
#
# Conditions:
#   - Upper screen in use (FLAGS bit 1 = 0, TV_FLAG bit 0 = 0)
#   - Cursor at scroll boundary (B == DF_SZ = 7)
#   - Not an automatic listing (TV_FLAG bit 4 = 0)
#   - SCR_CT = 2 (non-zero after decrement, so scrolls without prompting)
#
# The effects routine calls po_scr directly to replicate the scroll, since
# cl_sc_all is an internal ROM label that cannot be called from test code.
# The effects_regs routine sets registers explicitly to avoid calling po_scr
# a second time (which would decrement SCR_CT to 0 and block at "scroll?").

.text


po_scr_tv_flag_bit4_setup:
  ld      hl, 0x4048
  inc     (hl)                            ; touch display file so we notice scrolling
  _resbit 1, FLAGS                        ; not printing
  _resbit 0, TV_FLAG                      ; upper screen in use
  _resbit 4, TV_FLAG                      ; not automatic listing (bit 4 = 0)
  _strb   0x07, DF_SZ                     ; DF_SZ = 7
  _strb   0x02, SCR_CT                    ; SCR_CT = 2 (po_scr_2 decrements this)
  ret


po_scr_tv_flag_bit4_setup_regs:
  ld      bc, 0x0710                      ; B = 7 = DF_SZ (equality triggers bit 4 test), C = 0x10 (bit 4 set)
  ret


po_scr_tv_flag_bit4_effects:
  ; Call po_scr to replicate all RAM effects (scroll + cursor update).
  ; po_scr_2 decrements SCR_CT (2->1, non-zero), jumps to po_scr_3 which
  ; scrolls the display and returns via cl_set.
  ld      bc, 0x0710
  call    po_scr
  ret


po_scr_tv_flag_bit4_effects_regs:
  ; Register state after po_scr with B=7, C=0x10, upper screen:
  ;   po_scr_3 returns via cl_set with B = DF_SZ+1 = 8, C = 0x21
  ;   cl_set calls cl_addr then po_store
  ;   cl_addr: line = 24-8 = 16, section = 16/8 = 2, row = 16%8 = 0
  ;     => HL = display_file + 2*8*8*32 = 0x5000
  ;   cl_set: HL += 33 - C = 33 - 0x21 = 0 => HL = display_file + 2*8*8*32
  ;   po_store: stores S_POSN_Y/X, DF_CC, loads A with TV_FLAG
  xor     a                               ; A = 0 (from cl_addr)
  ld      b, 0x08                         ; cl_set: B = DF_SZ+1
  ld      c, 0x21                         ; po_scr_3: C = 0x21
  ld      de, 0x0000                      ; DE zeroed by cl_addr within cl_set
  ld      hl, display_file + 2*8*8*32     ; cl_addr + cl_set: cursor address
  ldf     0x5c                            ; flags from cl_set/po_store path
  ret
