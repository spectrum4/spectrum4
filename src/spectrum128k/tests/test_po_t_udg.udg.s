# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text



# This first test tests printing character 0x9a (154), which is UDG 'K'. [UDG]
# is set so that this maps to the standard 'k' character in char_set. The
# display file and attributes file are first prepared, and various system
# variables are updated that affect the printing, in order to test as many
# parameters as possible of the rendering process. Prints to upper screen.

.set po_t_udg_01_x, 11
.set po_t_udg_01_screenthird, 0
.set po_t_udg_01_yoffset, 5

.set po_t_udg_01_dfaddr, display_file + 32*8*8*po_t_udg_01_screenthird + po_t_udg_01_yoffset*32 + po_t_udg_01_x*1
.set po_t_udg_01_afaddr, attributes_file + 32*8*po_t_udg_01_screenthird + po_t_udg_01_yoffset*32 + po_t_udg_01_x

po_t_udg_01_setup:
  _strh   char_set+('a'-' ')*8, UDG
  _resbit 1, FLAGS                        ; print to screen (not printer)
  _resbit 0, TV_FLAG                      ; print to upper screen
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
  _strb   0b01010010, po_t_udg_01_dfaddr+8*32*0
  _strb   0b00110010, po_t_udg_01_dfaddr+8*32*1
  _strb   0b11000111, po_t_udg_01_dfaddr+8*32*2
  _strb   0b00110101, po_t_udg_01_dfaddr+8*32*3
  _strb   0b10110111, po_t_udg_01_dfaddr+8*32*4
  _strb   0b00100010, po_t_udg_01_dfaddr+8*32*5
  _strb   0b10011000, po_t_udg_01_dfaddr+8*32*6
  _strb   0b10100011, po_t_udg_01_dfaddr+8*32*7

  _strb   0b10101110, po_t_udg_01_afaddr  ; Attributes file
                                          ;   FLASH 1
                                          ;   PAPER 5
                                          ;   INK 6
  ret

po_t_udg_01_setup_regs:
  ld      a, 0x9a                         ; UDG K = 'k' (since [UDG] = address of 'a' in test)
                                          ;   0b00000000
                                          ;   0b00100000
                                          ;   0b00101000
                                          ;   0b00110000
                                          ;   0b00110000
                                          ;   0b00101000
                                          ;   0b00100100
                                          ;   0b00000000
  ld      b, 24-8*po_t_udg_01_screenthird-po_t_udg_01_yoffset
  ld      c, 33-po_t_udg_01_x
  ld      hl, po_t_udg_01_dfaddr
  ret

po_t_udg_01_effects:
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
  _strb   0b01010010, po_t_udg_01_dfaddr+8*32*0
  _strb   0b00010010, po_t_udg_01_dfaddr+8*32*1
  _strb   0b11101111, po_t_udg_01_dfaddr+8*32*2
  _strb   0b00000101, po_t_udg_01_dfaddr+8*32*3
  _strb   0b10000111, po_t_udg_01_dfaddr+8*32*4
  _strb   0b00001010, po_t_udg_01_dfaddr+8*32*5
  _strb   0b10111100, po_t_udg_01_dfaddr+8*32*6
  _strb   0b10100011, po_t_udg_01_dfaddr+8*32*7
                                          ; Attributes file
                                          ;   MASK_T=0b00110001
                                          ;   ATTR_T=0b01--010-
                                          ;   screen=0b--10---0
                                          ; =>       0b01100100
                                          ;   BRIGHT 1; PAPER 4; INK 4
                                          ; (temp) PAPER 9 => PAPER 0
  _strb   0b01000100, po_t_udg_01_afaddr  ; BRIGHT 1; PAPER 0; INK 4
  ret

po_t_udg_01_effects_regs:
  ld      a, 0b10100011                   ; A' = Last byte written to display file
  ldf     S_FLAG | X5_FLAG | PV_FLAG      ; why?
  ex      af, af'
  ld      a, 0b01000100                   ; A = Attribute file value
  ldf     N_FLAG                          ; why?
  ld      b, 24-8*po_t_udg_01_screenthird-po_t_udg_01_yoffset
  ld      c, (33-po_t_udg_01_x)-1         ; BC = New cursor position
  ld      d, 0b00110001                   ; D=[MASK_T]
  ld      e, 0b01100101                   ; E=[ATTR_T]
  ld      hl, po_t_udg_01_dfaddr+1        ; HL += 1
  ret






# This test tests printing character 0xa4 (164), which is UDG 'U'. [UDG] is set
# so that this maps to the standard 'k' character in char_set. The display file
# and attributes file are first prepared, and various system variables are
# updated that affect the printing, in order to test as many parameters as
# possible of the rendering process. Prints to upper screen.



# Choose an arbitrary location on screen to print to
.set po_t_udg_02_x, 11
.set po_t_udg_02_screenthird, 0
.set po_t_udg_02_yoffset, 5

# Calculate display file and attributes file addresses for the above character cell location
.set po_t_udg_02_dfaddr, display_file + 32*8*8*po_t_udg_02_screenthird + po_t_udg_02_yoffset*32 + po_t_udg_02_x*1
.set po_t_udg_02_afaddr, attributes_file + 32*8*po_t_udg_02_screenthird + po_t_udg_02_yoffset*32 + po_t_udg_02_x

po_t_udg_02_setup:
  _strh   char_set+('A'-'U'+'k'-' ')*8, UDG
                                          ; set [UDG] such that UDG 'U' uses the char_set 'k' bitmap
  _resbit 1, FLAGS                        ; print to screen (not printer)
  _resbit 4, FLAGS                        ; 128K mode (to ensure UDG 'U' and not PLAY keyword)
  _resbit 0, TV_FLAG                      ; print to upper screen
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
  _strb   0b01010010, po_t_udg_01_dfaddr+8*32*0
  _strb   0b00110010, po_t_udg_01_dfaddr+8*32*1
  _strb   0b11000111, po_t_udg_01_dfaddr+8*32*2
  _strb   0b00110101, po_t_udg_01_dfaddr+8*32*3
  _strb   0b10110111, po_t_udg_01_dfaddr+8*32*4
  _strb   0b00100010, po_t_udg_01_dfaddr+8*32*5
  _strb   0b10011000, po_t_udg_01_dfaddr+8*32*6
  _strb   0b10100011, po_t_udg_01_dfaddr+8*32*7

  _strb   0b10101110, po_t_udg_02_afaddr  ; Attributes file
                                          ;   FLASH 1
                                          ;   PAPER 5
                                          ;   INK 6
  ret

po_t_udg_02_setup_regs:
  ld      a, 0xa4
  ld      b, 24-8*po_t_udg_02_screenthird-po_t_udg_02_yoffset
  ld      c, 33-po_t_udg_02_x
  ld      hl, po_t_udg_02_dfaddr
  ret

po_t_udg_02_effects:
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
  _strb   0b01010010, po_t_udg_02_dfaddr+8*32*0
  _strb   0b00010010, po_t_udg_02_dfaddr+8*32*1
  _strb   0b11101111, po_t_udg_02_dfaddr+8*32*2
  _strb   0b00000101, po_t_udg_02_dfaddr+8*32*3
  _strb   0b10000111, po_t_udg_02_dfaddr+8*32*4
  _strb   0b00001010, po_t_udg_02_dfaddr+8*32*5
  _strb   0b10111100, po_t_udg_02_dfaddr+8*32*6
  _strb   0b10100011, po_t_udg_02_dfaddr+8*32*7
                                          ; Attributes file
                                          ;   MASK_T=0b00110001
                                          ;   ATTR_T=0b01--010-
                                          ;   screen=0b--10---0
                                          ; =>       0b01100100
                                          ;   BRIGHT 1; PAPER 4; INK 4
                                          ; (temp) PAPER 9 => PAPER 0
  _strb   0b01000100, po_t_udg_02_afaddr  ; BRIGHT 1; PAPER 0; INK 4
  ret

po_t_udg_02_effects_regs:
  ld      a, 0b10100011                   ; A' = Last byte written to display file
  ldf     0xa4
  ex      af, af'
  ld      a, 0b01000100                   ; A = Attribute file value
  ldf     N_FLAG                          ; why?
  ld      b, 24-8*po_t_udg_02_screenthird-po_t_udg_02_yoffset
  ld      c, (33-po_t_udg_02_x)-1         ; BC = New cursor position
  ld      d, 0b00110001                   ; D=[MASK_T]
  ld      e, 0b01100101                   ; E=[ATTR_T]
  ld      hl, po_t_udg_02_dfaddr+1        ; HL += 1
  ret









# This is the same as po_t_udg_01 but prints at end-of-line
# (entry C=1). This results in [S_POSN_X], [S_POSN_Y], [DF_CC] getting
# updated.

.set po_t_udg_03_x, 0
.set po_t_udg_03_screenthird, 0
.set po_t_udg_03_yoffset, 5

.set po_t_udg_03_dfaddr, display_file + 32*8*8*po_t_udg_03_screenthird + po_t_udg_03_yoffset*32 + po_t_udg_03_x*1
.set po_t_udg_03_afaddr, attributes_file + 32*8*po_t_udg_03_screenthird + po_t_udg_03_yoffset*32 + po_t_udg_03_x

po_t_udg_03_setup:
  _strh   char_set+('a'-' ')*8, UDG
  _resbit 1, FLAGS                        ; print to screen (not printer)
  _resbit 0, TV_FLAG                      ; print to upper screen
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
  _strb   0b01010010, po_t_udg_03_dfaddr+8*32*0
  _strb   0b00110010, po_t_udg_03_dfaddr+8*32*1
  _strb   0b11000111, po_t_udg_03_dfaddr+8*32*2
  _strb   0b00110101, po_t_udg_03_dfaddr+8*32*3
  _strb   0b10110111, po_t_udg_03_dfaddr+8*32*4
  _strb   0b00100010, po_t_udg_03_dfaddr+8*32*5
  _strb   0b10011000, po_t_udg_03_dfaddr+8*32*6
  _strb   0b10100011, po_t_udg_03_dfaddr+8*32*7

  _strb   0b10101110, po_t_udg_03_afaddr  ; Attributes file
                                          ;   FLASH 1
                                          ;   PAPER 5
                                          ;   INK 6
  ret

po_t_udg_03_setup_regs:
  ld      a, 0x9a                         ; UDG K = 'k' (since [UDG] = address of 'a' in test)
                                          ;   0b00000000
                                          ;   0b00100000
                                          ;   0b00101000
                                          ;   0b00110000
                                          ;   0b00110000
                                          ;   0b00101000
                                          ;   0b00100100
                                          ;   0b00000000
  ld      b, 24-8*po_t_udg_03_screenthird-po_t_udg_03_yoffset+1
  ld      c, 1
  ld      hl, po_t_udg_03_dfaddr
  ret

po_t_udg_03_effects:
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
  _strb   0b01010010, po_t_udg_03_dfaddr+8*32*0
  _strb   0b00010010, po_t_udg_03_dfaddr+8*32*1
  _strb   0b11101111, po_t_udg_03_dfaddr+8*32*2
  _strb   0b00000101, po_t_udg_03_dfaddr+8*32*3
  _strb   0b10000111, po_t_udg_03_dfaddr+8*32*4
  _strb   0b00001010, po_t_udg_03_dfaddr+8*32*5
  _strb   0b10111100, po_t_udg_03_dfaddr+8*32*6
  _strb   0b10100011, po_t_udg_03_dfaddr+8*32*7
                                          ; Attributes file
                                          ;   MASK_T=0b00110001
                                          ;   ATTR_T=0b01--010-
                                          ;   screen=0b--10---0
                                          ; =>       0b01100100
                                          ;   BRIGHT 1; PAPER 4; INK 4
                                          ; (temp) PAPER 9 => PAPER 0
  _strb   0b01000100, po_t_udg_03_afaddr  ; BRIGHT 1; PAPER 0; INK 4
  _strb   33, S_POSN_X
  _strb   24-8*po_t_udg_03_screenthird-po_t_udg_03_yoffset, S_POSN_Y
  _strh   po_t_udg_03_dfaddr, DF_CC
  ret

po_t_udg_03_effects_regs:
  ld      a, 0b10100011                   ; A' = Last byte written to display file
  ldf     S_FLAG | X5_FLAG | PV_FLAG      ; why?
  ex      af, af'
  ld      a, 0b01000100                   ; A = Attribute file value
  ldf     X5_FLAG | N_FLAG                ; why?
  ld      b, 24-8*po_t_udg_03_screenthird-po_t_udg_03_yoffset
  ld      c, (33-po_t_udg_03_x)-1         ; BC = New cursor position
  ld      d, 0b00110001                   ; D=[MASK_T]
  ld      e, 0b01100101                   ; E=[ATTR_T]
  ld      hl, po_t_udg_03_dfaddr+1        ; HL += 1
  ret
