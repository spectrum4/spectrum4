# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text


cls_1_setup:
  _strb   0x02, DF_SZ
  _strb   0x00, MASK_P
  _strb   0x00, P_FLAG
  _strb   0x38, ATTR_P
  _strb   0x38, BORDCR
  _strh   char_set-32*32, CHARS
  _strh   sysvars_48k_end, CHANS

  ld      de, init_chan                   ; address: init-chan in ROM.
  ld      bc, 0x0015                      ; there are 21 bytes of initial data in ROM.
  ex      de, hl                          ; swap the pointers.
  ldir                                    ; copy the bytes to RAM.

  ld      hl, init_strm                   ; set source to ROM Address: init-strm
  ld      de, STRMS                       ; set destination to system variable STRM-FD
  ld      bc, 0x000e                      ; copy the 14 bytes of initial 7 streams data
  ldir                                    ; from ROM to RAM.



  ret

cls_1_setup_regs:
  ret

cls_1_effects:
  ld      hl, 16384
  ld      de, 16385
  ld      bc, 6143
  ld      (hl), 0
  ldir
  ld      hl, 22528
  ld      de, 22529
  ld      bc, 767
  ld      (hl), 0x38
  ldir
  _resbit 1, FLAGS
  _resbit 5, FLAGS
  _resbit 0, FLAGS2
  _setbit 4, FLAGS2
  _resbit 5, TV_FLAG
  _setbit 0, TV_FLAG
  _strb   0x21, S_POSN_X
  _strb   0x18, S_POSN_Y
  _strb   0x21, S_POSN_X_L
  _strb   0x17, S_POSN_Y_L
  _strb   0x21, ECHO_E_X
  _strb   0x17, ECHO_E_Y
  _strb   0x01, SCR_CT
  _strb   0x38, ATTR_T
  _strb   0x00, MASK_T
  _strb   0x00, COORDS_X
  _strb   0x00, COORDS_Y
  _strh   sysvars_48k_end, CURCHL
  _strh   display_file, DF_CC
  _strh   display_file + 2*8*8*32 + 7*32, DF_CC_L
  ret

cls_1_effects_regs:
  xor     a
  ld      b, 0x17
  ld      c, 0x21
  ld      d, 0x00
  ld      e, 0x00
  ld      hl, display_file+2*32*8*8+32*7
  ldf     0x18
  ret
