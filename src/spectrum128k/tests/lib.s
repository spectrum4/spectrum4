; This file is part of the Spectrum +4 Project.
; Licencing information can be found in the LICENCE file
; (C) 2021 Spectrum +4 Authors. All rights reserved.

.macro ldf val
  push    de
  ld      d, a
  ld      e, \val
  push    de
  pop     af
  pop     de
.endm

.macro _setbit bit, address
  ld      hl, \address
  set     \bit, (hl)
.endm

.macro _resbit bit, address
  ld      hl, \address
  res     \bit, (hl)
.endm

.macro _strb val, address
  ld      a, \val
  ld      (\address), a
.endm

.macro _strh val, address
  ld      hl, \val
  ld      (\address), hl
.endm

.macro f_clear_set clear, set
  push    de
  push    af
  pop     de                              ; D=A E=F
  ld      a, \set                         ; A has required bits set
  or      e                               ; plus flags already set in entry F
  ld      e, ~(\clear)
  and     e                               ; A now has required bits cleared
  ld      e, a                            ; D=original A, E=updated F
  push    de
  pop     af                              ; A restored, F updated
  pop     de                              ; DE restored
.endm



; Z80 flags
.set C_FLAG,    0b00000001
.set N_FLAG,    0b00000010
.set PV_FLAG,   0b00000100
.set X3_FLAG,   0b00001000
.set H_FLAG,    0b00010000
.set X5_FLAG,   0b00100000
.set Z_FLAG,    0b01000000
.set S_FLAG,    0b10000000
