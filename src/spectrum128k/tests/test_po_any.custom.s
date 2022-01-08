# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text


po_any_G_81_setup:
  _resbit 0, TV_FLAG                      ; lower screen not in use (used by po_fetch)
  _setbit 4, FLAGS                        ; 128K mode
  _strb   0b00001111, P_FLAG              ; OVER 1, INVERSE 1
  _resbit 1, FLAGS                        ; printer not in use
  _strb   0x05, DF_SZ                     ; lower screen is 5 lines
  _strb   0b01010011, MASK_T
  _strb   0b01100101, ATTR_T
  _strb   0b00111000, attributes_file + 32*8*0 + 7*32 + 9

  _strb   0b00000000, display_file + 32*8*8*0 + 7*32 + 9 + 0*32*8
  _strb   0b00111100, display_file + 32*8*8*0 + 7*32 + 9 + 1*32*8
  _strb   0b01000010, display_file + 32*8*8*0 + 7*32 + 9 + 2*32*8
  _strb   0b01000000, display_file + 32*8*8*0 + 7*32 + 9 + 3*32*8
  _strb   0b01001110, display_file + 32*8*8*0 + 7*32 + 9 + 4*32*8
  _strb   0b01000010, display_file + 32*8*8*0 + 7*32 + 9 + 5*32*8
  _strb   0b00111100, display_file + 32*8*8*0 + 7*32 + 9 + 6*32*8
  _strb   0b00000000, display_file + 32*8*8*0 + 7*32 + 9 + 7*32*8

  _strb   33-9, S_POSN_X
  _strb   24-7-0*8, S_POSN_Y
  _strh   display_file + 32*8*8*0 + 7*32 + 9, DF_CC

  ret

po_any_G_81_setup_regs:
  ld      a, 0x81
  ret

po_any_G_81_effects:

  _strb   0b00001111, MEMBOT + 0
  _strb   0b00001111, MEMBOT + 1
  _strb   0b00001111, MEMBOT + 2
  _strb   0b00001111, MEMBOT + 3
  _strb   0b00000000, MEMBOT + 4
  _strb   0b00000000, MEMBOT + 5
  _strb   0b00000000, MEMBOT + 6
  _strb   0b00000000, MEMBOT + 7

  _strb   0b11110000, display_file + 32*8*8*0 + 7*32 + 9 + 0*32*8
  _strb   0b11001100, display_file + 32*8*8*0 + 7*32 + 9 + 1*32*8
  _strb   0b10110010, display_file + 32*8*8*0 + 7*32 + 9 + 2*32*8
  _strb   0b10110000, display_file + 32*8*8*0 + 7*32 + 9 + 3*32*8
  _strb   0b10110001, display_file + 32*8*8*0 + 7*32 + 9 + 4*32*8
  _strb   0b10111101, display_file + 32*8*8*0 + 7*32 + 9 + 5*32*8
  _strb   0b11000011, display_file + 32*8*8*0 + 7*32 + 9 + 6*32*8
  _strb   0b11111111, display_file + 32*8*8*0 + 7*32 + 9 + 7*32*8

  _strb   0b00110100, attributes_file + 32*8*0 + 7*32 + 9

  ret

po_any_G_81_effects_regs:
  ld      a, 0xff
  ldf     0xac
  ex      af, af'
  ld      a, 0x34
  ldf     0x02
  ld      bc, 0x1117
  ld      de, 0x5365
  ld      hl, 0x40ea
  ret
