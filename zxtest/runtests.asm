# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

.text

.globl _start

_start:

  # Preserve state for safely returning from machine code back to BASIC.
  # Disable interrupts in case keyboard scanning routine depends on IY
  # being preserved (since it isn't). Stash HL' and IY which need
  # restoring before returning, due to assumptions in Spectrum ROM.

  di
  push iy
  exx
  push hl

  # System setup

  call    0x0daf                          ; cls
  ld      a, 3
  call    0x1601                          ; open channel 3 (printer)
  ld      hl, all_tests
  xor     a
  ld      b, (hl)
  cp      b
  ret     z
  inc     hl

1:                                        ; Loop through all tests
  ld      de, msg_running_test_part_1
  call    print_msg_de                    ; Log "Running test "
  ld      e, (hl)
  inc     hl
  ld      d, (hl)                         ; DE = address of test definition
  inc     hl
  ld      a, (de)
  ld      c, a
  inc     de
  ld      a, (de)
  ld      d, a
  ld      e, c                            ; DE = address of test name
  call    print_msg_de                    ; Log "<test case name>"
  ld      de, msg_running_test_part_2
  call    print_msg_de                    ; Log "...\r\n"

  # Set up registers

  push    bc                              ; Stash number of remaining tests (B)
  push    hl                              ; Stash current address inside all_tests
  ld      hl, -0x14
  add     hl, sp
  ld      sp, hl
  ld      de, random_data
  ld      bc, 0x14
  ex      de, hl
  ldir                                    ; Copy 0x14 = 20 random bytes to stack
  pop     de ;  pop     ix
  pop     de ;  pop     iy
  pop     de ;  pop     af
  pop     bc
  pop     de
  pop     hl
  ex      af, af'
  exx
  pop     de ;  pop     af
  pop     bc
  pop     de
  pop     hl

  pop     hl
  pop     bc
  djnz    1b

  # Test 1 setup
  ld      (iy+0x55), 0x95                 ; [ATTR_T] = 0b10010101
  ld      (iy+0x56), 0x56                 ; [MASK_T] = 0b01010110
  ld      (iy+0x57), 0x97                 ; [P_FLAG] = 0b10010111
  ld      hl, 0x59a4
  ld      (hl), 0x55
  ld      hl, 0x4ea4                      ; 16384 + 1*32*8*8 + 5*32 + 4*1 + 6*8*32
  call    0x0bdb                          ; call PO-ATTR
  ex      af, af'
  exx
  push    ix
  push    iy
  push    af
  push    bc
  push    de
  push    hl
  ex      af, af'
  exx
  push    af
  push    bc
  push    de
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
  pop     bc ; pop     af
  ex      af, af'
  exx
  pop     hl
  pop     de
  pop     bc
  pop     bc ; pop     af
  pop     iy
  pop     ix
  ld      b, 0
  ld      c, b
1:
  ld      e, c
  call    e_div_10
  ld      a, h
  add     a, 0x41
  rst     0x10
  inc     c
  djnz    1b
  call    print_newline
  ld      de, end_marker
  call    print_msg_de                    ; print 'spectrum4_tests_end_marker'
  call    print_newline

  # Restore state for safely returning back to BASIC. IY and HL' both need to
  # be restored, and BC holds return value, so set to 0 to indicate success.
  # Finally interrupts can be reenabled.

  pop hl
  pop iy
  exx
  ld bc, 0
  ei
  ret


print_msg_de:
1:
  ld      a,(de)
  cp      0
  ret     z
  rst     0x10
  inc     de
  jr      1b


# Final text to be written when unit tests have completed. When running in an
# emulator, signals that emulator can be terminated.
end_marker:
  .asciz "spectrum4_tests_end_marker"


# Divides 8 bit uint by 10.
#
# On entry:
#   E  = value to divide by 10
# On exit:
#   H  = E/10
#   L  = E*205 && 0xff
#   DE = E*41
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


msg_running_test_part_1: .asciz "Running test "
msg_running_test_part_2: .asciz "...\r\n"

msg_fail: .asciz "FAIL: "
msg_fail_0: .asciz ": Register x"
msg_fail_1: .asciz " changed from "
msg_fail_2: .asciz " unchanged from "
msg_fail_3: .asciz " to "
msg_fail_4: .asciz ", but should have changed to "
msg_fail_5: .ascii ", but should not have changed"
                                          ; Intentionally .ascii not .asciz, in order to join with msg_fail_6.
msg_fail_6: .asciz ".\r\n"
msg_fail_7: .asciz ": System Variable "
msg_fail_8: .asciz ": RAM entry "


.include "tests.asm"
.include "randomdata.asm"
