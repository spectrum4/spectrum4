# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text


pr_all_upperscreen_paper9_over1_setup:
  _resbit 1, FLAGS
  _resbit 0, TV_FLAG
  _strb   0x04, DF_SZ                     ; lower screen is 4 lines
  _strb   0b01100011, P_FLAG              ; temp OVER 1
                                          ; perm OVER 1
                                          ; perm INK 9
                                          ; temp PAPER 9
  _strb   0b00110001, MASK_T
  _strb   0b01100101, ATTR_T              ;   BRIGHT 1
                                          ;   PAPER  4
                                          ;   INK 5

  _strb   0b01010010, 0x5067              ; Display file
  _strb   0b00110010, 0x5167
  _strb   0b11000111, 0x5267
  _strb   0b00110101, 0x5367
  _strb   0b10110111, 0x5467
  _strb   0b00100010, 0x5567
  _strb   0b10011000, 0x5667
  _strb   0b10100011, 0x5767

  _strb   0b10101110, 0x5a67              ; Attributes file
                                          ;   FLASH 1
                                          ;   PAPER 5
                                          ;   INK 6
  ret

pr_all_upperscreen_paper9_over1_setup_regs:
  ld      hl, 0x5067
  ld      de, 0x3f58                      ; char 'k'
                                          ;   0b00000000
                                          ;   0b00100000
                                          ;   0b00101000
                                          ;   0b00110000
                                          ;   0b00110000
                                          ;   0b00101000
                                          ;   0b00100100
                                          ;   0b00000000
  ld      bc, 0x051a
  ret

pr_all_upperscreen_paper9_over1_effects:
                                          ; Display file
  _strb   0b01010010, 0x5067              ;   0b01010010 xor 0b00000000
  _strb   0b00010010, 0x5167              ;   0b00110010 xor 0b00100000
  _strb   0b11101111, 0x5267              ;   0b11000111 xor 0b00101000
  _strb   0b00000101, 0x5367              ;   0b00110101 xor 0b00110000
  _strb   0b10000111, 0x5467              ;   0b10110111 xor 0b00110000
  _strb   0b00001010, 0x5567              ;   0b00100010 xor 0b00101000
  _strb   0b10111100, 0x5667              ;   0b10011000 xor 0b00100100
  _strb   0b10100011, 0x5767              ;   0b10100011 xor 0b00000000
                                          ; Attributes file
                                          ;   MASK_T=0b00110001
                                          ;   ATTR_T=0b01--010-
                                          ;   screen=0b--10---0
                                          ; =>       0b01100100
                                          ;   BRIGHT 1; PAPER 4; INK 4
                                          ; (temp) PAPER 9 => PAPER 0
  _strb   0b01000100, 0x5a67              ; BRIGHT 1; PAPER 0; INK 4
  ret

pr_all_upperscreen_paper9_over1_effects_regs:
  ld      a, 0xa3                         ; A' = Last byte written to display file
  ldf     S_FLAG | X5_FLAG | PV_FLAG      ; why?
  ex      af, af'
  ld      a, 0b01000100                   ; A = Attribute file value
  ldf     X3_FLAG | N_FLAG                ; why?
  ld      bc, 0x0519                      ; BC = New cursor position
  ld      d, 0b00110001                   ; D=[MASK_T]
  ld      e, 0b01100101                   ; E=[ATTR_T]
  ld      hl, 0x5068                      ; HL += 1
  ret


pr_all_lowerscreen_ink9_inverse1_setup:
  _resbit 1, FLAGS
  _setbit 0, TV_FLAG
  _strb   0x08, DF_SZ                     ; lower screen is 8 lines
  _strb   0b00010100, P_FLAG              ; (temp INVERSE 1)
                                          ; (temp INK 9)
  _strb   0b10010010, MASK_T
  _strb   0b00101010, ATTR_T

  _strb   0b01010010, 0x50ff              ; Display file
  _strb   0b00110010, 0x51ff
  _strb   0b11000111, 0x52ff
  _strb   0b00110101, 0x53ff
  _strb   0b10110111, 0x54ff
  _strb   0b00100010, 0x55ff
  _strb   0b10011000, 0x56ff
  _strb   0b10100011, 0x57ff

  _strb   0b00101011, 0x5aff              ; Attributes file
  ret

pr_all_lowerscreen_ink9_inverse1_setup_regs:
  ld      hl, 0x50ff
  ld      de, 0x3f58                      ; char 'k'
                                          ;   0b00000000
                                          ;   0b00100000
                                          ;   0b00101000
                                          ;   0b00110000
                                          ;   0b00110000
                                          ;   0b00101000
                                          ;   0b00100100
                                          ;   0b00000000
  ld      bc, 0x1102
  ret

pr_all_lowerscreen_ink9_inverse1_effects:
                                          ; Display file
  _strb   0b11111111, 0x50ff
  _strb   0b11011111, 0x51ff
  _strb   0b11010111, 0x52ff
  _strb   0b11001111, 0x53ff
  _strb   0b11001111, 0x54ff
  _strb   0b11010111, 0x55ff
  _strb   0b11011011, 0x56ff
  _strb   0b11111111, 0x57ff
                                          ; Attributes file
                                          ;   MASK_T=0b10010010
                                          ;   ATTR_T=0b-01-10-0
                                          ;   screen=0b0--0--1-
                                          ; =>       0b00101010
                                          ;   PAPER 5
                                          ;   INK 2
                                          ; (temp) INK 9 => INK 0
  _strb   0b00101000, 0x5aff
  ret

pr_all_lowerscreen_ink9_inverse1_effects_regs:
  ld      a, 0xff                         ; A' = Last byte written to display file
  ldf     S_FLAG | X5_FLAG | X3_FLAG | PV_FLAG
                                          ; why?
  ex      af, af'
  ld      a, 0b00101000                   ; A = Attribute file value
  ldf     N_FLAG                          ; why?
  ld      bc, 0x1101                      ; BC = New cursor position
  ld      d, 0b10010010                   ; D=[MASK_T]
  ld      e, 0b00101010                   ; E=[ATTR_T]
  ld      hl, 0x5100                      ; HL += 1
  ret


pr_all_lowerscreen_inverse1_over1_endofline_setup:
  _resbit 1, FLAGS
  _setbit 0, TV_FLAG
  _strb   0x02, DF_SZ                     ; lower screen is 2 lines
  _strb   0b10100111, P_FLAG              ;   (temp OVER 1)
                                          ;   (perm OVER 1)
                                          ;   (temp INVERSE 1)
                                          ;   (perm INK 9)
                                          ;   (perm PAPER 9)
  _strb   0b00000000, MASK_T
  _strb   0b00100010, ATTR_T

  _strb   0b01010101, 0x50e0              ; Display file
  _strb   0b10101010, 0x51e0
  _strb   0b01010101, 0x52e0
  _strb   0b10101010, 0x53e0
  _strb   0b01010101, 0x54e0
  _strb   0b10101010, 0x55e0
  _strb   0b01010101, 0x56e0
  _strb   0b10101010, 0x57e0
  ret

pr_all_lowerscreen_inverse1_over1_endofline_setup_regs:
  ld      hl, 0x50e0
  ld      de, 0x3f58                      ; char 'k'
                                          ;   0b00000000
                                          ;   0b00100000
                                          ;   0b00101000
                                          ;   0b00110000
                                          ;   0b00110000
                                          ;   0b00101000
                                          ;   0b00100100
                                          ;   0b00000000
  ld      bc, 0x1801
  ret

pr_all_lowerscreen_inverse1_over1_endofline_effects:
                                          ; Display file
  _strb   0b10101010, 0x50e0
  _strb   0b01110101, 0x51e0
  _strb   0b10000010, 0x52e0
  _strb   0b01100101, 0x53e0
  _strb   0b10011010, 0x54e0
  _strb   0b01111101, 0x55e0
  _strb   0b10001110, 0x56e0
  _strb   0b01010101, 0x57e0

  _strb   0b00100010, 0x5ae0              ; Attributes file

  _strb   0x21, S_POSN_X_L
  _strb   0x17, S_POSN_Y_L
  _strb   0x21, ECHO_E_X
  _strb   0x17, ECHO_E_Y
  _strh   0x50e0, DF_CC_L
  ret

pr_all_lowerscreen_inverse1_over1_endofline_effects_regs:
  ld      a, 0x55                         ; A' = Last byte written to display file
  ldf     PV_FLAG                         ; why?
  ex      af, af'
  ld      a, 0x22                         ; A = Attribute file value
  ldf     X5_FLAG | N_FLAG                ; why?
  ld      bc, 0x1720                      ; BC = New cursor position
  ld      d, 0b00000000                   ; D=[MASK_T]
  ld      e, 0b00100010                   ; E=[ATTR_T]
  ld      hl, 0x50e1                      ; HL += 1
  ret
