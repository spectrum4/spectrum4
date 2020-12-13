# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

.text

.globl _start

_start:

  # Disable interrupts in case either the ROM interrupt routine depends on certain
  # registers having particular values, or corrupts registers that our routine
  # relies on, and to remove the unnecessary overhead of scanning keyboard during
  # testing.
  di

  # Preserve the initial values for registers HL' and IY and restore them on
  # return, since the calling ROM routine requires their values to be unaltered.
  # This eases troubleshooting if calling this routine interactively from BASIC.
  push    iy
  exx
  push    hl

  # System setup

  call    0x0daf                          ; Clear screen (CLS).
channel_assign:                           ; This label is translated to an
                                          ; address in all.sh, the value is
                                          ; incremented and passed to the go
                                          ; program that creates the BASIC
                                          ; loader program, in order to
                                          ; generate a POKE statement to
                                          ; allow an interactive user to
                                          ; modify the output channel to e.g.
                                          ; channel 2 (upper screen).
  ld      a, 0                            ; The value loaded into A here is
                                          ; irrelevant since it is overwritten
                                          ; by the BASIC loader program (see
                                          ; previous comment).
  call    0x1601                          ; open channel 3 (printer)
  ld      hl, all_tests
  xor     a                               ; A=0
  ld      b, (hl)
  cp      b                               ; [all_tests] == 0?
  jp      z, 10f                          ; no tests defined, so return
  inc     hl

  1:                                        ; Loop through all tests
    ld      de, msg_running_test_part_1
    call    print_msg_de                    ; Log "Running test "
    ld      e, (hl)
    inc     hl
    ld      d, (hl)                         ; DE = address of test definition
    inc     hl
    push    hl
    ex      de, hl                          ; HL = address of test definition
    ld      e, (hl)
    inc     hl
    ld      d, (hl)                         ; DE = address of test name
    inc     hl                              ; HL = address of register setup pointer in all_tests
    call    print_msg_de                    ; Log "<test case name>"
    ld      de, msg_running_test_part_2
    call    print_msg_de                    ; Log "...\r"

    # Set up registers

    push    bc
    push    hl

    exx                                     ; Preserve B, HL by switching to spare registers
    ld      hl, -0x28
    add     hl, sp
    ld      sp, hl
    ld      de, random_data
    ld      bc, 0x14
    ex      de, hl
    ldir                                    ; Copy 0x14 = 20 random bytes to stack
    ld      (stack), sp                     ; z80 has no `ld ix, sp` instruction so we have
    ld      ix, (stack)                     ; to write SP to a fixed memory address and read
                                            ; it back again.
    ld      (ix+2),0x3a                     ; Replace random value for IY with 0x5c3a since
    ld      (ix+3),0x5c                     ; ROM routines expect IY = 0x5c3a (ERRNO sysvar)
    exx                                     ; Restore data from spare register set:
                                            ;   B = remaining test count (unneeded)
                                            ;   HL = address of register setup section pointer
    ld      e, (hl)
    inc     hl
    ld      d, (hl)                         ; DE = address of register setup masks
    ld      h, d
    ld      l, e                            ; HL = start address of register setup masks
    inc     de
    inc     de
    inc     de                              ; DE = start address of register setup values
    ld      b, 0x14
                                            ;   0x00: IX (lsb)  0x01: IX (msb)
                                            ;   0x02: IY (lsb)  0x03: IY (msb)
                                            ;   0x04: F'        0x05: A'
                                            ;   0x06: C'        0x07: B'
                                            ;   0x08: E'        0x09: D'
                                            ;   0x0a: L'        0x0b: H'
                                            ;   0x0c: F         0x0d: A
                                            ;   0x0e: C         0x0f: B
                                            ;   0x10: E         0x11: D
                                            ;   0x12: L         0x13: H
    2:
      ld      a, 0x14
      sub     b
      and     0x07                            ; Mask contains 1 bit per increment of B, so
                                              ; one mask byte needs to be read for every 8
                                              ; decrements of B, i.e. when ((0x14-B) & 0x07) == 0.
      jr      nz, 3f
      ld      c, (hl)                         ; read next mask byte into C
      inc     hl                              ; prepare HL for next mask read
    3:
      bit     0, c                            ; is register byte defined?
      jr      z, 4f                           ; if not defined, skip forward to 4:
      # register defined, replace random value
      ld      a, (de)                         ; read value into A
      inc     de
      ld      (ix), a                         ; update entry in stack
    4:
      srl     c                               ; shift mask 1 bit to the right
      inc     ix
      djnz    2b

    # At this point all register values are prepared on the stack and IX is the
    # address above the registers, i.e. where HL was stacked with the address of
    # register setup pointer

    ld      (stack), ix                     ; z80 has no `ld de, ix` instruction so we have
    ld      de, (stack)                     ; to write IX to a fixed memory address and read
    ld      hl, -0x14
    add     hl, de
    ld      bc, 0x14
    ldir                                    ; Copy section again

    ld      e, (ix+0x14)
    ld      d, (ix+0x15)                    ; DE = address of register setup pointer
    inc     de
    inc     de                              ; DE = address of register effects pointer
    inc     de
    inc     de                              ; DE = address of exec pointer in all_tests
    ld      a, (de)
    ld      l, a
    inc     de
    ld      a, (de)                         ; HL = address of exec routine
    ld      h, a

    exx

    pop     ix
    pop     iy
    pop     af
    pop     bc
    pop     de
    pop     hl

    ex      af, af'
    exx

    pop     af
    pop     bc
    pop     de
    jp      (hl)

  test_exec_return:

    push    hl
    push    de
    push    bc
    push    af

    ex      af, af'
    exx

    push    hl
    push    de
    push    bc
    push    af
    push    iy
    push    ix

# Compare routine exit registers against expected values

    ld      (stack), sp
    ld      ix, (stack)
    ld      l, (ix+0x28)
    ld      h, (ix+0x29)                    ; HL = address of register setup pointer
    inc     hl
    inc     hl                              ; HL = address of register effects pointer
    ld      e, (hl)
    inc     hl
    ld      d, (hl)                         ; DE = register effects masks address
    ld      l, e
    ld      h, d                            ; HL = register effects masks address
    inc     de
    inc     de
    inc     de                              ; DE = register effects values address
    ld      b, 0x14                         ; B = loop counter for registers

    5:
      ld      a, 0x14
      sub     b
      and     0x07                            ; Mask contains 1 bit per increment of B, so
                                              ; one mask byte needs to be read for every 8
                                              ; decrements of B, i.e. when ((0x14-B) & 0x07) == 0.
      jr      nz, 6f
      ld      c, (hl)                         ; read next mask byte into C
      inc     hl                              ; prepare HL for next mask read
    6:
      bit     0, c                            ; is register byte defined?
      jr      z, 7f                           ; if not defined, skip forward to 7:
      # register defined, fetch expected value
      ld      a, (de)                         ; A = expected value = defined value
      inc     de
      jr      8f
    7:
      ld      a, (ix+0x14)                    ; A = expected value = pre-test value
    8:
      push    bc
      ld      c, a                            ; C = expected value
      ld      a, (ix)                         ; A = actual value
      cp      c
      jr      z, 9f                           ; if actual == expected, test passed; continue loop
      push    de
      push    hl
      ld      hl, log_register
      call    test_fail
      pop     hl
      pop     de
    9:
      pop     bc
      srl     c                               ; shift mask 1 bit to the right
      inc     ix
      djnz    5b

    # free stack and loop round for next test

    ld      (stack), sp
    ld      hl, (stack)
    ld      de, 0x14 + 0x14 + 0x02
    add     hl, de
    ld      sp, hl
    pop     bc
    pop     hl

    dec     b
    jp      nz, 1b

  ld      de, end_marker
  call    print_msg_de                    ; print 'All tests completed.'
  call    print_newline

10:
  ld      bc, 0                           ; BASIC return value; 0 => success
11:
  # Prepare state for safely returning to BASIC. IY and HL' both need to be
  # restored and interrupts enabled. BC should already be set to an appropriate
  # return value by now, and all other register values are insignificant.
  pop     hl
  pop     iy
  exx
  ei
  ret

# B = 0x14-(register index) (0x01-0x14)
log_register:
  ld      de, msg_fail_0
  call    print_msg_de
  ld      e, b
  ld      a, 0
  ld      bc, 0
  ld      hl, register_names
1:
  cpir
  dec     e
  jr      nz, 1b
  ex      de, hl
  call    print_msg_de
  jp      test_fail_continue

# On entry:
#   (IX+0x14): pre-test value
#   A = (IX): post-test value
#   C: expected value
#   B: register/sysvar/RAM index (1-20)
#   HL: function pointer for logging entity that failed test
test_fail:
  push    hl
  ld      de, msg_fail
  call    print_msg_de                    ; Log "FAIL: "
  ld      (stack), sp
  ld      hl, (stack)                     ; HL = SP
  ld      d, 0
  ld      e, 0x32
  add     hl, de                          ; HL = SP + 0x32
                                          ; SP+0x00 -> function pointer for logging entity that failed
                                          ; SP+0x02 -> call return address from test_fail
                                          ; SP+0x04 -> register effects mask address
                                          ; SP+0x06 -> register effects values address
                                          ; SP+0x08 -> BC (C=bit mask / B=register index)
                                          ; SP+0x0a -> post-test registers
                                          ; SP+0x1e -> pre-test registers
                                          ; SP+0x32 -> address of register setup section pointer
  ld      e, (hl)
  inc     hl
  ld      d, (hl)                         ; DE = address of register setup section pointer
  dec     de
  dec     de                              ; DE = address of register test name pointer
  ex      de, hl
  ld      e, (hl)
  inc     hl
  ld      d, (hl)                         ; DE = address of register test name
  call    print_msg_de                    ; Log "<test case name>"
  pop     hl
  push    bc
  jp      (hl)                            ; Log ": <entity>"
test_fail_continue:
  pop     hl
  ld      a, (ix+0x14)
  cp      (ix)
  jr      z, 2f                           ; pre-test val == post-test val => value unchanged but should have
# value changed
  ld      de, msg_fail_1
  call    print_msg_de                    ; Log " changed from "
  ld      c, (ix+0x14)
  call    print_c_as_hex                  ; Log "<pre-test register value>"
  ld      de, msg_fail_3
  call    print_msg_de                    ; Log " to "
  ld      c, (ix)
  call    print_c_as_hex                  ; Log "<post-test register value>"
  ld      a, (ix+0x14)
  cp      l
  jr      z, 1f                           ; pre-test val == expected val => value shouldn't have changed but did
# value meant to change, but to a different value
  ld      de, msg_fail_4
  call    print_msg_de                    ; Log ", but should have changed to "
  ld      c, l
  call    print_c_as_hex                  ; "<expected register value>"
  ld      de, msg_fail_6
  call    print_msg_de                    ; Log ".\r"
  jr      3f
1:
# value not meant to change, but did
  ld      de, msg_fail_5
  call    print_msg_de                    ; Log ", but should not have changed.\r"
  jr      3f
2:
# value unchanged, but was meant to
  ld      de, msg_fail_2
  call    print_msg_de                    ; Log " unchanged from "
  ld      c, (ix)
  call    print_c_as_hex                  ; Log "<pre-test register value>"
  ld      de, msg_fail_4
  call    print_msg_de                    ; Log ", but should have changed to "
  ld      c, l
  call    print_c_as_hex                  ; Log "<expected register value>"
  ld      de, msg_fail_6
  call    print_msg_de                    ; Log ".\r"
3:
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
  .asciz "All tests completed."


# Divides E by 10 and returns in H.
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
msg_running_test_part_2: .asciz "...\r"

msg_fail: .asciz "FAIL: "
msg_fail_0: .asciz ": Register "
msg_fail_1: .asciz " changed from 0x"
msg_fail_2: .asciz " unchanged from 0x"
msg_fail_3: .asciz " to 0x"
msg_fail_4: .asciz ", but should have changed to 0x"
msg_fail_5: .ascii ", but should not have changed"
                                          ; Intentionally .ascii not .asciz, in order to join with msg_fail_6.
msg_fail_6: .asciz ".\r"
msg_fail_7: .asciz ": System Variable "
msg_fail_8: .asciz ": RAM entry "

register_names:
.byte 0
.asciz "H"
.asciz "L"
.asciz "D"
.asciz "E"
.asciz "B"
.asciz "C"
.asciz "A"
.asciz "F"
.asciz "H'"
.asciz "L'"
.asciz "D'"
.asciz "E'"
.asciz "B'"
.asciz "C'"
.asciz "A'"
.asciz "F'"
.asciz "IY (msb)"
.asciz "IY (lsb)"
.asciz "IX (msb)"
.asciz "IX (lsb)"


.include "tests.asm"
.include "randomdata.asm"

# See https://sourceware.org/bugzilla/show_bug.cgi?id=27047 - the `.bss`
# pseudo operation is not supported in binutils 2.35.1 under target
# z80-unknown-elf, so we need to use `.section .bss` instead.
.section .bss

stack: .space 2
