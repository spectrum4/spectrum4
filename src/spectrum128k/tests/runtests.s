# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text

.include "lib.s"

.global _start
.global fake0
.global fake1
.global fake_channel_block
.global fake_channel_init
.global fake_reg_update0
.global fake_reg_update1
.global fake_touch_registers_channel_block
.global print_msg_de
.global touch_all_registers

_start:

  # Preserve the initial values for registers HL' and IY and restore them on
  # return, since the calling ROM routine requires their values to be unaltered.
  # This eases troubleshooting if calling this routine interactively from BASIC.
  push    iy
  exx
  push    hl

  # System setup

  call    cl_all                          ; Clear screen (CLS).
channel_assign:                           ; This label is translated to an address
                                          ; in create-tzx.sh, the value is
                                          ; incremented and passed to the go
                                          ; program that creates the BASIC loader
                                          ; program, in order to generate a POKE
                                          ; statement to allow an interactive user
                                          ; to modify the output channel to e.g.
                                          ; channel 2 (upper screen).
  ld      a, 0                            ; The value loaded into A here is
                                          ; irrelevant since it is overwritten
                                          ; by the BASIC loader program (see
                                          ; previous comment).
  call    chan_open                       ; open channel
  di
  ld      ix, memory_dumps
  ld      de, snapshot_page
  call    all_pages_call
  ld      (pre_test_snapshot), ix
  ld      bc, (all_suites)                ; BC = total number of tests
  ld      a, b
  or      c                               ; [all_suites] == 0?
  ld      de, msg_no_tests
  jp      z, 10f                          ; no tests defined, so return
  ld      hl, all_suites+2                ; HL = address of first test suite
                                          ; pointer inside all_suites
  1:                                      ; Loop through all test suites
    ld      e, (hl)
    inc     hl
    ld      d, (hl)                       ; DE = address of test suite
    inc     hl
    ex      de, hl                        ; DE = address inside all_suites
                                          ; HL = address inside test suite
    push    de

    ld      d, b
    ld      e, c                          ; DE = number of remaining tests
    ld      c, (hl)
    inc     hl
    ld      b, (hl)                       ; BC = number of tests in this test suite
    inc     hl
    ex      de, hl                        ; DE = address inside test suite
                                          ; HL = number of remaining tests
    or      a                             ; Ensure carry is clear - not really needed as
                                          ; carry is coincidentally clear at this point, but
                                          ; this protects against future code changes
    sbc     hl, bc                        ; HL = number of tests remaining after test suite
    push    hl
    ex      de, hl                        ; DE = number of tests remaining after test suite
                                          ; HL = address inside test suite
    ld      e, (hl)
    inc     hl
    ld      d, (hl)                       ; DE = address of routine under test
    inc     hl
    ld      (call_routine+1), de
    2:                                    ; Loop through tests in test suite
      push    bc
      ld      de, msg_running_test_part_1
      ei
      call    print_msg_de                ; Log "Running test "
      ld      e, (hl)
      inc     hl
      ld      d, (hl)                     ; DE = address of test definition
      inc     hl
      push    hl

      ld      hl, setup_shim
      call    update_shim
      ld      hl, setup_regs_shim
      call    update_shim
      ld      hl, effects_shim
      call    update_shim
      ld      hl, effects_regs_shim
      call    update_shim

      ex      de, hl
      ld      (test_case_name), hl
      ex      de, hl
      call    print_msg_de                ; Log "<test case name>"
      ld      de, msg_running_test_part_2
      call    print_msg_de                ; Log "...\r"
      di

      ld      de, random_ram
      call    all_pages_call

    setup_shim:
      call    0x0000

      ld      ix, (pre_test_snapshot)
      ld      de, snapshot_page
      call    all_pages_call
      ld      (expected_snapshot), ix

      ld      hl, -0x12
      add     hl, sp                      ; HL = SP - 0x12
      ld      sp, hl                      ; SP -= 0x12
      ld      de, random_data
      ld      bc, 0x12                    ; BC = 0x12
      ex      de, hl                      ; DE = SP
                                          ; HL = random_data
      ldir                                ; Copy 0x12 = 18 random bytes to stack

      ld      iy, 0x5c3a                  ; ROM routines expect IY = 0x5c3a (ERRNO sysvar)
      pop     ix
      pop     af
      pop     bc
      pop     de
      pop     hl

      ex      af, af'
      exx

      pop     af
      pop     bc
      pop     de
      pop     hl

    setup_regs_shim:
      call    0x0000

      # Push pre-test register values on stack

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
      push    ix
      push    iy

      ex      af, af'
      exx

    effects_regs_shim:
      call    0x0000

      # Push expected register values on stack

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
      push    ix
      push    iy

    effects_shim:
      call    0x0000

      ld      ix, (expected_snapshot)
      ld      de, snapshot_page
      call    all_pages_call
      ld      (post_test_snapshot), ix

      # Restore pre-test memory

      ld      ix, (pre_test_snapshot)
      ld      de, restore_page
      call    all_pages_call

      # Restore pre-test registers from stack

      # Temporarily move SP to inside stack (since interuppts are disabled, this is ok)
      ld      (stack), sp                 ; Backup current stack pointer
      ld      hl, 0x14
      add     hl, sp                      ; HL = SP + 0x14
      ld      sp, hl                      ; SP += 0x14

      pop     iy
      pop     ix
      pop     af
      pop     bc
      pop     de
      pop     hl

      ex      af, af'
      exx

      pop     af
      pop     bc
      pop     de
      pop     hl

      # Restore former stack pointer
      ld      (hl_backup), hl
      ld      hl, (stack)
      ld      sp, hl
      ld      hl, (hl_backup)

    call_routine:
      call    0x0000

      # Push post-test register values on stack

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
      push    ix
      push    iy

      ld      ix, (post_test_snapshot)
      ld      de, snapshot_page
      call    all_pages_call

      ld      ix, memory_dumps
      ld      de, restore_page
      call    all_pages_call

      # Compare routine exit registers against expected values

      ld      (stack), sp                 ; z80 has no `ld ix, sp` instruction so we have
      ld      ix, (stack)                 ; to write SP to a fixed memory address and read
                                          ; it back again.
      ld      b, 0x14
      5:                                  ; loop through registers
        ld      d, (ix+0x14)              ; D = expected value
        ld      a, (ix)                   ; A = post-test value
        cp      d
        jr      z, 9f                     ; if post-test == expected, test passed; continue loop
        push    bc
        ld      hl, log_register
        ld      e, a                      ; E = post-test value
        ld      a, (ix+0x28)              ; A = pre-test value
        call    test_fail
        pop     bc
      9:
        inc     ix
        djnz    5b

      ld      (stack), sp
      ld      hl, (stack)
      ld      de, 0x14 + 0x14 + 0x14
      add     hl, de
      ld      sp, hl

      ld      ix, (pre_test_snapshot)
      ld      iy, (expected_snapshot)
      ld      de, compare_page
      exx
      ld      de, (post_test_snapshot)
      exx
      call    all_pages_call
      ld      iy, 0x5c3a                  ; restore IY (ROM routines expect IY = 0x5c3a (ERRNO sysvar))
      pop     hl
      pop     bc

      dec     bc
      ld      a, (test_failure)
      ld      d, a
      ld      a, b
      or      c
      and     d
      jp      nz, 2b
    pop     bc
    pop     hl

    ld      a, b
    or      c
    and     d
    jp      nz, 1b

  ei
  bit     0, d
  ld      de, msg_end_marker
  ld      bc, 0                           ; BASIC return value; 0 => success
  jr      nz, 10f
  ld      de, msg_test_failures
10:
  call    print_msg_de                    ; print 'All tests completed.' / 'Test failures!' / 'No tests to run'
  ld      bc, 1
11:
  exx
  # Prepare state for safely returning to BASIC. IY and HL' both need to be
  # restored and interrupts enabled. BC should already be set to an appropriate
  # return value by now, and all other register values are insignificant.
  pop     hl
  pop     iy
  exx
  ei
  ret


update_shim:
  ld      a, (de)
  ld      c, a
  inc     de
  ld      a, (de)
  ld      b, a
  inc     de
  or      c
  jr      z, 1f
  ld      (hl), 0xcd
  inc     hl
  ld      (hl), c
  inc     hl
  ld      (hl), b
  inc     hl
  ret
1:
  ld      (hl), 0
  inc     hl
  ld      (hl), 0
  inc     hl
  ld      (hl), 0
  inc     hl
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


log_ram_address:
  ld      de, msg_fail_8
  call    print_msg_de
  ld      a, (BANK_M)
  and     0x07
  or      0x30
  rst     0x10
  ld      de, msg_fail_9
  call    print_msg_de
  push    hl
  ld      h, b
  ld      l, c
  call    print_hl_as_hex
  pop     hl
  jp      test_fail_continue


# On entry:
#   A = pre-test value
#   D = expected value
#   E = post-test value
#   HL = function pointer for logging entity that failed test
test_fail:
  push    af
  ld      a, 0
  ld      (test_failure), a
  push    de
  ld      de, msg_fail
  call    print_msg_de                    ; Log "FAIL: "
  ex      de, hl
  ld      hl, (test_case_name)
  ex      de, hl
  call    print_msg_de
  jp      (hl)                            ; Log ": <entity>"
test_fail_continue:
  pop     hl                              ; H = expected value / L = post-test value
  pop     af
  ld      b, a                            ; B = pre-test value
  cp      l
  jr      z, 2f                           ; pre-test val == post-test val => value unchanged but should have
# value changed
  ld      de, msg_fail_1
  call    print_msg_de                    ; Log " changed from "
  ld      c, b
  call    print_c_as_hex                  ; Log "<pre-test register value>"
  ld      de, msg_fail_3
  call    print_msg_de                    ; Log " to "
  ld      c, l
  call    print_c_as_hex                  ; Log "<post-test register value>"
  ld      a, b
  cp      h
  jr      z, 1f                           ; pre-test val == expected val => value shouldn't have changed but did
# value meant to change, but to a different value
  ld      de, msg_fail_4
  call    print_msg_de                    ; Log ", but should have changed to "
  ld      c, h
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
  ld      c, b
  call    print_c_as_hex                  ; Log "<pre-test register value>"
  ld      de, msg_fail_4
  call    print_msg_de                    ; Log ", but should have changed to "
  ld      c, h
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
    push    de                            ; custom [[CURCHL]] routines may update DE
    rst     0x10
    pop     de
    inc     de
    jr      1b


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


random_ram:
  ld      hl, 0xc000
  ld      a, (random_data)
  ld      (hl), a
  ld      de, 0xc001
  ld      bc, 0x3fff
  ldir
  ret


# Snapshot and compress the contents of RAM paged in at 0xC000 to 0xFFFF.
# Write to buffer whose starting address is in IX and ends at 0xBFFF.
# Halt if out of memory, with error message.
#
# On entry:
#   IX = snapshot location
# On exit:
#   A = D (see DE below)
#   B = [0xffff]
#   HL = 0
#   DE = address of last used byte in snapshot
#   IX = first free address after snapshot
#   F = Z
#   A'
#   F'
snapshot_page:
  ld      hl, 0xc000
  ld      a, (hl)
  ld      b, a                            ; B = previous value
  inc     hl
  ld      de, 0                           ; DE = count of repeats
  1:
    ld      a, (hl)
    cp      b
    jr      nz, 5f
  ; repeated value
    inc     de
  2:
    inc     hl
    ld      b, a
    ld      a, h
    or      l
    jr      nz, 1b
  ld      (ix), 0x6a
  ld      (ix+1), e
  ld      (ix+2), d
  ld      (ix+3), b
  inc     ix
  inc     ix
  inc     ix
  inc     ix
3:                                        ; ensure ix <= 0xc000
  push    ix
  pop     de
  dec     de
  ld      a, d
  cp      0xc0
  ret     c
snapshot_out_of_memory:
  ex      de, hl
  ld      de, msg_snapshot_out_of_memory
  call    print_msg_de
4:
  jr      4b
  5:
  ; previous value != new value
    ex      af, af'                       ; backup A (new value)
    ld      a, b
    cp      0x6a                          ; previous value == 0x6a ?
    jr      z, 7f                         ; if so, store as a repeating sequence
  ; is count in de > 3 ?
    ld      a, e                          ; a = e
    srl     a                             ; a = e/2
    srl     a                             ; a = e/4
    or      d
    jr      nz, 7f                        ; if 4 or more repeats, store as a repeating sequence
  ; store unchanged
    ld      a, b                          ; a = old value
    ld      b, e                          ; b = number of repeats excluding original
    inc     b                             ; b = number of repeats including original
    6:
      ld      (ix), a
      inc     ix
      djnz    6b
    jr      8f
  7:
  ; previous value should be stored as repeating value
    ld      (ix), 0x6a
    ld      (ix+1), e
    ld      (ix+2), d
    ld      (ix+3), b
    inc     ix
    inc     ix
    inc     ix
    inc     ix
  8:
    call    3b
    ld      de, 0                         ; reset counter
    ex      af, af'                       ; restore A (new value)
    jr      2b


# On entry:
#   IX = snapshot location
# On exit:
#   HL = 0
#   ...
restore_page:
  ld      hl, 0xc000
1:
  ld      b, (ix)
  inc     ix
  ld      a, b
  cp      0x6a
  jr      nz, 3f
; repeating
  ld      e, (ix)
  ld      d, (ix+1)
  ld      b, (ix+2)
  inc     ix
  inc     ix
  inc     ix
  2:
    ld      a, d
    or      e
    jr      z, 3f
    ld      (hl), b
    inc     hl
    dec     de
    jr 2b
3:
  ld      (hl), b
  inc     hl
  ld      a, h
  or      l
  jr      nz, 1b
  ret


# On entry:
#   DE = address of routine to call for each page
#
# Called routine must preserve HL', BC'
all_pages_call:
  ld      hl, all_pages_call_instruction+1
  ld      (hl), e
  inc     hl
  ld      (hl), d
  ld      a, (BANK_M)
  ld      h, a
  ld      bc, 0x7ffd
  ld      l, 16
  1:
    out     (c), l                        ; page in RAM bank 0/1/3/4/5/6/7 and 128K ROM
    ld      a, l
    ld      (BANK_M), a
    inc     l
    exx                                   ; preserve BC value
  all_pages_call_instruction:
    call    0x0000                        ; this value gets updated at start of routine
    exx
    ld      a, l
    cp      18
    jr      nz, 2f
    inc     l
  2:
    cp      24
    jr      nz, 1b
  ld      a, h
  out     (c), a                          ; page in original RAM bank
  ld      (BANK_M), a
  ret


# On entry:
#   IX = pre-test snapshot location
#   IY = expected snapshot location
#   DE = post-test snapshot location
compare_page:
; AF  BC  DE  HL
  ld      hl, 0xc000                      ; HL = address in RAM
  exx
; AF  BC' DE' HL'
  push    bc                              ; Backup BC'
  push    hl                              ; Backup HL'
  ld      bc, 0                           ; BC' = count for pre-test
  ld      de, 0                           ; DE' = count for expected
  ld      hl, 0                           ; HL' = count for post-test
  1:
; AF  BC' DE' HL'
    ld      a, b
    or      c                             ; A = B' | C'
    dec     bc                            ; BC' -= 1
    jr      nz, 2f                        ; if BC' != 0 jump to 2:
    inc     bc                            ; BC' = 0
    exx
; AF  BC  DE  HL
    ld      a, 0x6a                       ; A = 0x6a
    ld      c, (ix)                       ; C = [IX] (pre-test value)
    inc     ix
    cp      c
    exx
; AF  BC' DE' HL'
    jr      nz, 2f                        ; if pre-test value != 0x6a, jump to 2:
    ld      c, (ix)
    ld      b, (ix+1)                     ; BC' = updated pre-test count
    exx
; AF  BC  DE  HL
    ld      c, (ix+2)                     ; C = updated pre-test value
    exx
; AF  BC' DE' HL'
    inc     ix
    inc     ix
    inc     ix
  2:
; AF  BC' DE' HL'
    ld      a, d
    or      e                             ; A = D' | E'
    dec     de                            ; DE' -= 1
    jr      nz, 3f                        ; if DE' != 0 jump to 3:
    inc     de                            ; DE' = 0
    exx
; AF  BC  DE  HL
    ld      a, 0x6a                       ; A = 0x6a
    ld      b, (iy)                       ; B = [IY] (expected value)
    inc     iy
    cp      b
    exx
; AF  BC' DE' HL'
    jr      nz, 3f                        ; if expected value != 0x6a, jump to 3:
    ld      e, (iy)
    ld      d, (iy+1)                     ; DE' = updated expected count
    exx
; AF  BC  DE  HL
    ld      b, (iy+2)                     ; B = updated expected value
    exx
; AF  BC' DE' HL'
    inc     iy
    inc     iy
    inc     iy
  3:
; AF  BC' DE' HL'
    ld      a, h
    or      l                             ; A = H' | L'
    dec     hl                            ; HL' -= 1
    exx
; AF  BC  DE  HL
    jr      nz, 4f                        ; if HL' != 0 jump to 4:
    exx
; AF  BC' DE' HL'
    inc     hl
    exx
; AF  BC  DE  HL
    ex      af, af'
; AF' BC  DE  HL
    ld      a, (de)                       ; A' = [DE] (post-test value)
    inc     de
    cp      0x6a
    jr      nz, 5f                        ; if post-test value != 0x6a, jump to 5:
    ld      a, (de)
    inc     de
    exx
; AF' BC' DE' HL'
    ld      l, a
    exx
; AF' BC  DE  HL
    ld      a, (de)
    inc     de
    exx
; AF' BC' DE' HL'
    ld      h, a                          ; HL' = updated post-test count
    exx
; AF' BC  DE  HL
    ld      a, (de)                       ; A' = updated post-test value
    inc     de
    ex      af, af'
; AF  BC  DE  HL
  4:
; AF  BC  DE  HL
    ex      af, af'
  5:
; AF' BC  DE  HL
    cp      b                             ; compare A' and B
    jr      z, 6f                         ; if post-test == expected, jump to 8:
    exx
; AF' BC' DE' HL'
    push    af
    push    bc                            ; backup BC (expected / pre-test values)
    push    de                            ; backup DE (post-test snapshot address)
    push    hl
    exx
; AF' BC  DE  HL
    push    bc                            ; backup BC (expected / pre-test values)
    push    de                            ; backup DE (post-test address)
    push    hl                            ; backup HL (extraction memory address)

    ld      e, a
    ex      af, af'
; AF  BC  DE  HL
    push    af
    ld      d, b
    ld      a, h
    and     0x3f
    ld      b, a
    ld      a, c
    ld      c, l
    ld      hl, log_ram_address
    push    iy
    ld      iy, 0x5c3a                    ; ROM routines expect IY = 0x5c3a (ERRNO sysvar)
    ei
    call    test_fail
    di
    pop     iy
    pop     af
    ex      af, af'
; AF' BC  DE  HL
    pop     hl
    pop     de                            ; restore DE (post-test snapshot address)
    pop     bc                            ; restore BC
    exx
; AF' BC' DE' HL'
    pop     hl                            ; restore HL
    pop     de                            ; restore DE
    pop     bc                            ; restore BC
    pop     af
    exx
; AF' BC  DE  HL
  6:
; AF' BC  DE  HL
    inc     hl
    ex      af, af'
; AF  BC  DE  HL
    ld      a, h
    or      l
    exx
; AF  BC' DE' HL'
    jp      nz, 1b
  pop     hl
  pop     bc
  exx
  ret


# fake0 and fake1 are called from PO_TOKENS test setup methods to initialise RAM.
# In these tests, IY is set to 0x5000 in the _setup_regs routines. The PO_TOKENS
# ROM routine checks bit 0 of [IY+1] to determine if leading spaces should be
# suppressed or not when printing tokens.
#
# The difference between the two methods is:
#
#   * fake0 clears bit 0 of 0x5001 (to signal that leading spaces should _not_ be
#     suppressed)
#   * fake1 sets bit 0 of 0x5001 (to signal that leading spaces should be
#     suppressed)
#
# Afterwards a channel block is initialised with a custom print-out routine
# (fake_printout) that writes incoming bytes to the display file (0x4000) but
# _without_ disturbing any registers. See fake_printout description for more
# information.
fake0:
  _resbit 0, 0x5001
  ld      hl, fake_channel_block
  jp      fake_channel_init
fake1:
  _setbit 0, 0x5001
  ld      hl, fake_channel_block
  jp      fake_channel_init



# fake0_reg_update0 and fake_reg_update1 are called from PO_TOKENS test setup
# methods to initialise RAM.  In these tests, IY is set to 0x5000 in the
# _setup_regs routines. The PO_TOKENS ROM routine checks bit 0 of [IY+1] to
# determine if leading spaces should be suppressed or not when printing tokens.
#
# The difference between the two methods is:
#
#   * fake_reg_update0 clears bit 0 of 0x5001 (to signal that leading spaces
#     should _not_ be suppressed)
#   * fake_reg_update1 sets bit 0 of 0x5001 (to signal that leading spaces should
#     be suppressed)
#
# Afterwards a channel block is initialised with a custom print-out routine
# (fake_printout_touch_registers) that writes incoming bytes to the display file
# (0x4000) and _disturbs_ all registers. See fake_printout_touch_registers
# description for more information.
fake_reg_update0:
  _resbit 0, 0x5001
  ld      hl, fake_touch_registers_channel_block
  jp      fake_channel_init
fake_reg_update1:
  _setbit 0, 0x5001
  ld      hl, fake_touch_registers_channel_block
  jp      fake_channel_init


fake_channel_init:
  ld      (CURCHL), hl
  ld      hl, 0x4002                      ; 0x4002 is start of buffer
  ld      (0x4000), hl                    ; 0x4000 holds address of next free byte in buffer
  ret


fake_channel_block:
  .hword fake_printout


fake_touch_registers_channel_block:
  .hword fake_printout_touch_registers


# This custom print out routine is used in tests in place of the standard ROM
# print-out routine at 0x09f4. It serves as a mock print routine in order to
# capture the text that is written during the execution of a unit test. It writes
# incoming bytes to a buffer at 0x4002, storing the buffer position at 0x4000.
# Since 0x4000 is the location of the default display file so the screen is
# termporarily corrupted - however, the screen is restored between tests, and
# using the display file provides some feedback to the user of what the test is
# doing.
#
# Note, the *_effects test routines can also use the same routine to print
# expected output, since the test framework already compares RAM snapshots
# created from the called test and from the *_effects routines. This makes the
# task of verifying printed text pretty simple, since the *_effects routine just
# needs to print the text that it expects the routine it is testing to print.
fake_printout:
# no need to preserve HL, since RST 10H does that for us
  ld      hl, (0x4000)                    ; 0x4000 stores the current location inside buffer
  ld      (hl), a                         ; Write char to buffer
  inc     hl                              ; Advance current location to next byte
  ld      (0x4000), hl                    ; Update buffer with new location
  ret


# This custom print out routine is the same as fake_printout, with the additional
# side effect of touching all registers in the register file before returning.
# This is useful for understanding how the ROM routines are affected by custom
# print out routines that disturb arbitrary registers.
fake_printout_touch_registers:
  call    fake_printout
  jr      touch_all_registers


# Simply touch all registers with unique values.
touch_all_registers:
  ld      de, 0x0102
  push    de
  pop     af
  ld      bc, 0x0304
  ld      de, 0x0506
  ld      hl, 0x0708
  ex      af, af'
  exx
  ld      de, 0x090a
  push    de
  pop     af
  ld      bc, 0x0b0c
  ld      de, 0x0d0e
  ld      hl, 0x0f10
  ex      af, af'
  exx
  ld      ix, 0x1112
# Not safe to update IY, since e.g. po_fetch relies on correct value of IY in
# order to fetch system variables FLAGS and TV_FLAG. If we modified IY here, on
# return from po_tokens, IY would have the modified value, and e.g. po_t_udg
# would break since it calls po_fetch immediately after po_tokens.
# ld      iy, 0x1314
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
msg_fail_8: .asciz ": RAM page "
msg_fail_9: .asciz " offset 0x"

msg_snapshot_out_of_memory:
  .asciz "FATAL: Out of space for RAM snapshot.\r"
msg_end_marker:
  .asciz "All tests completed.\r"
msg_no_tests:
  .asciz "No tests to run.\r"
msg_test_failures:
  .asciz "Test failures!\r"

test_failure: .byte 0xff

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
.asciz "IX (msb)"
.asciz "IX (lsb)"
.asciz "IY (msb)"
.asciz "IY (lsb)"


# See https://sourceware.org/bugzilla/show_bug.cgi?id=27047 - the `.bss`
# pseudo operation for z80-unknown-elf was added in binutils 2.36; earlier
# versions of binutils won't be able to assemble this line.
.bss

stack:                     .space 2
hl_backup:                 .space 2

pre_test_snapshot:         .space 2
expected_snapshot:         .space 2
post_test_snapshot:        .space 2
test_case_name:            .space 2

memory_dumps:              .space 0x3000  ; 12KB
