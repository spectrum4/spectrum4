# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text



.set po_char1_x, 7
.set po_char1_screenthird, 2
.set po_char1_yoffset, 3

.set po_char1_dfaddr, display_file + 32*8*8*po_char1_screenthird + po_char1_yoffset*32 + po_char1_x*1
.set po_char1_afaddr, attributes_file + 32*8*po_char1_screenthird + po_char1_yoffset*32 + po_char1_x

po_char_1_setup:
  _strh   char_set-32*8, CHARS
  _resbit 1, FLAGS
  _resbit 0, TV_FLAG
  _strb   0x03, DF_SZ                     ; lower screen is 3 lines
  _strb   0b01100011, P_FLAG              ; temp OVER 1
                                          ; perm OVER 1
                                          ; perm INK 9
                                          ; temp PAPER 9
  _strb   0b00110001, MASK_T
  _strb   0b01100101, ATTR_T              ;   BRIGHT 1
                                          ;   PAPER  4
                                          ;   INK 5

                                          ; Display file
  _strb   0b01010010, po_char1_dfaddr+8*32*0
  _strb   0b00110010, po_char1_dfaddr+8*32*1
  _strb   0b11000111, po_char1_dfaddr+8*32*2
  _strb   0b00110101, po_char1_dfaddr+8*32*3
  _strb   0b10110111, po_char1_dfaddr+8*32*4
  _strb   0b00100010, po_char1_dfaddr+8*32*5
  _strb   0b10011000, po_char1_dfaddr+8*32*6
  _strb   0b10100011, po_char1_dfaddr+8*32*7

  _strb   0b10101110, po_char1_afaddr     ; Attributes file
                                          ;   FLASH 1
                                          ;   PAPER 5
                                          ;   INK 6
  ret

po_char_1_setup_regs:
  ld      a, 'k'
                                          ;   0b00000000
                                          ;   0b00100000
                                          ;   0b00101000
                                          ;   0b00110000
                                          ;   0b00110000
                                          ;   0b00101000
                                          ;   0b00100100
                                          ;   0b00000000
  ld      b, 24-8*po_char1_screenthird-po_char1_yoffset
  ld      c, 33-po_char1_x
  ld      hl, po_char1_dfaddr
  ret

po_char_1_effects:
  _resbit 0, FLAGS
                                          ; Display file
                                          ;   0b01010010 xor 0b00000000
                                          ;   0b00110010 xor 0b00100000
                                          ;   0b11000111 xor 0b00101000
                                          ;   0b00110101 xor 0b00110000
                                          ;   0b10110111 xor 0b00110000
                                          ;   0b00100010 xor 0b00101000
                                          ;   0b10011000 xor 0b00100100
                                          ;   0b10100011 xor 0b00000000
  _strb   0b01010010, po_char1_dfaddr+8*32*0
  _strb   0b00010010, po_char1_dfaddr+8*32*1
  _strb   0b11101111, po_char1_dfaddr+8*32*2
  _strb   0b00000101, po_char1_dfaddr+8*32*3
  _strb   0b10000111, po_char1_dfaddr+8*32*4
  _strb   0b00001010, po_char1_dfaddr+8*32*5
  _strb   0b10111100, po_char1_dfaddr+8*32*6
  _strb   0b10100011, po_char1_dfaddr+8*32*7
                                          ; Attributes file
                                          ;   MASK_T=0b00110001
                                          ;   ATTR_T=0b01--010-
                                          ;   screen=0b--10---0
                                          ; =>       0b01100100
                                          ;   BRIGHT 1; PAPER 4; INK 4
                                          ; (temp) PAPER 9 => PAPER 0
  _strb   0b01000100, po_char1_afaddr     ; BRIGHT 1; PAPER 0; INK 4
  ret

po_char_1_effects_regs:
  ld      a, 0b10100011                   ; A' = Last byte written to display file
  ldf     S_FLAG | X5_FLAG | PV_FLAG      ; why?
  ex      af, af'
  ld      a, 0b01000100                   ; A = Attribute file value
  ldf     X3_FLAG | N_FLAG                ; why?
  ld      b, 24-8*po_char1_screenthird-po_char1_yoffset
  ld      c, (33-po_char1_x)-1            ; BC = New cursor position
  ld      d, 0b00110001                   ; D=[MASK_T]
  ld      e, 0b01100101                   ; E=[ATTR_T]
  ld      hl, po_char1_dfaddr+1           ; HL += 1
  ret


.set po_char2_x, 32
.set po_char2_screenthird, 2
.set po_char2_yoffset, 3

.set po_char2_dfaddr, display_file + 32*8*8*po_char2_screenthird + po_char2_yoffset*32 + po_char2_x*1
.set po_char2_afaddr, attributes_file + 32*8*po_char2_screenthird + po_char2_yoffset*32 + po_char2_x

po_char_space_end_of_line_setup:
  _strh   char_set-32*8, CHARS
  _resbit 1, FLAGS
  _resbit 0, TV_FLAG
  _strb   0x03, DF_SZ                     ; lower screen is 3 lines
  _strb   0b01100011, P_FLAG              ; temp OVER 1
                                          ; perm OVER 1
                                          ; perm INK 9
                                          ; temp PAPER 9
  _strb   0b00110001, MASK_T
  _strb   0b01100101, ATTR_T              ;   BRIGHT 1
                                          ;   PAPER  4
                                          ;   INK 5

  _strb   0b10100011, po_char2_dfaddr+8*32*7
                                          ; Display file value for last pixel row, in order that F' is fixed

  _strb   0b10101110, po_char2_afaddr     ; Attributes file
                                          ;   FLASH 1
                                          ;   PAPER 5
                                          ;   INK 6
  ret

po_char_space_end_of_line_setup_regs:
  ld      a, ' '
  ld      b, 24-8*po_char2_screenthird-po_char2_yoffset
  ld      c, 33-po_char2_x
  ld      hl, po_char2_dfaddr
  ret

po_char_space_end_of_line_effects:
  _setbit 0, FLAGS
                                          ; Attributes file
                                          ;   MASK_T=0b00110001
                                          ;   ATTR_T=0b01--010-
                                          ;   screen=0b--10---0
                                          ; =>       0b01100100
                                          ;   BRIGHT 1; PAPER 4; INK 4
                                          ; (temp) PAPER 9 => PAPER 0
  _strb   0b01000100, po_char2_afaddr     ; BRIGHT 1; PAPER 0; INK 4
  _strb   (24-8*po_char2_screenthird-po_char2_yoffset)-1, S_POSN_Y
  _strb   33, S_POSN_X
  _strh   po_char2_dfaddr, DF_CC
  ret

po_char_space_end_of_line_effects_regs:
  ld      a, 0b10100011                   ; A' = Last byte written to display file
  ldf     0xa4
  ex      af, af'
  ld      a, 0b01000100                   ; A = Attribute file value
  ldf     0x22
  ld      b, 24-8*po_char2_screenthird-po_char2_yoffset-1
  ld      c, 32                           ; BC = New cursor position
  ld      d, 0b00110001                   ; D=[MASK_T]
  ld      e, 0b01100101                   ; E=[ATTR_T]
  ld      hl, po_char2_dfaddr+1           ; HL += 1
  ret
