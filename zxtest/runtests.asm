; This file is part of the Spectrum +4 Project.
; Licencing information can be found in the LICENCE file
; (C) 2019 Spectrum +4 Authors. All rights reserved.

.text

_start:
  call    0x0daf                          ; cls
  ld      a, 3
  call    0x1601                          ; open channel 0
  ld      (iy+0x55), 0x95                 ; [ATTR_T] = 0b10010101
  ld      (iy+0x56), 0x56                 ; [MASK_T] = 0b01010110
  ld      (iy+0x57), 0x97                 ; [P_FLAG] = 0b10010111
  ld      hl, 0x59a4
  ld      (hl), 0x55
  ld      hl, 0x4ea4                      ; 16384 + 1*32*8*8 + 5*32 + 4*1 + 6*8*32
  call    0x0bdb                          ; call PO-ATTR
  push    af
  push    bc
  push    de
  push    hl
  ld      b, h
  ld      c, l
  call    0x2d2b                          ; bc on calculator stack
  call    0x2de3                          ; print floating point number
  call    print_newline
  pop     hl
  push    hl
  ld      c, (hl)
  ld      b, 0
  call    0x2d2b                          ; bc on calculator stack
  call    0x2de3                          ; print floating point number
  call    print_newline
  pop     hl
  push    hl
  call    print_hl_as_hex
  call    print_newline
  pop     hl
  push    hl
  ld      c, (hl)
  call    print_c_as_hex
  call    print_newline
  pop     hl
  pop     de
  pop     bc
  pop     af
  ld      b, 0
  ld      c, b
l1:
  ld      e, c
  call    e_div_10
  ld      a, h
  add     a, 0x41
  rst     0x10
  inc     c
  djnz    l1
  call    print_newline
  ld      de, end_marker_start
  ld      bc, end_marker_end-end_marker_start
  call    0x203c                          ; print 'spectrum4_tests_end_marker'
  call    print_newline
  ret


; Final text to be written when unit tests have completed. When running in an
; emulator, signals that emulator can be terminated.
end_marker_start:
  db 'spectrum4_tests_end_marker'
end_marker_end:


; Divides 8 bit uint by 10.
;
; On entry:
;   E  = value to divide by 10
; On exit:
;   H  = E/10
;   L  = E*205 && 0xff
;   DE = E*41
e_div_10:
  ld      d, 0                            ; DE=E
  ld      h, d                            ; H=0
  ld      l, e                            ; HL=E
  add     hl, hl                          ; HL=E*2
  add     hl, hl                          ; HL=E*4
  add     hl, de                          ; HL=E*5
  add     hl, hl                          ; HL=E*10
  add     hl, hl                          ; HL=E*20
  add     hl, hl                          ; HL=E*40
  add     hl, de                          ; HL=E*41
  ld      d, h
  ld      e, l                            ; DE=E*41
  add     hl, hl                          ; HL=E*82
  add     hl, hl                          ; HL=E*164
  add     hl, de                          ; HL=E*205
  srl     h                               ; H = (E*205)/512
  srl     h                               ; H = (E*205)/1024
  srl     h                               ; H = (E*205)/2048 = E/10
  ret


print_hl_as_hex:
  ld      c,h
  call    print_c_as_hex
  ld      c,l
print_c_as_hex:
  ld      a,c
  rra
  rra
  rra
  rra
  call    conv
  ld      a,c
conv:
  and     0x0f
  add     a, 0x90
  daa
  adc     a, 0x40
  daa
  rst     0x10
  ret


print_newline:
  ld      a, 13
  rst     0x10
  ret


.include "tests.asm"
