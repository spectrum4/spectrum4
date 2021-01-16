# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.


.set MEMORY_DUMPS_BUFFER_SIZE, 0x01000000  // 16MB

.text
.align 2


run_tests:
  ldr     w0, arm_size
  and     sp, x0, #~0x0f                  // Set stack pointer at top of ARM memory
  adr     x20, all_tests                  // x20 = address of test list
  ldr     x10, [x20], #8                  // x10 = number of tests
  cbz     x10, 36f                        // Return if no tests to run
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  adrp    x2, memory_dumps
  add     x2, x2, :lo12:memory_dumps      // x2 = target address for snapshot
  bl      snapshot_all_ram                // Snapshot RAM so we can roll back between tests
  mov     x6, x2                          // x6 = first free address after end of snapshot
  1:                                      // Loop executing tests
    ldr     x19, [x20], #0x08               // x19 = address of test block
    ldp     x21, x22, [x19], #0x10          // x21 = number of tests for test block
                                            // x22 = address of routine to test
    stp     x22, x20, [sp, #-16]!           // Stash address of routine to test, pointer into all_tests
    2:
      ldr     x23, [x19], #0x08               // x23 = address of test
      ldp     x9, x30, [x23], #0x10           // x9 = setup address
                                              // x30 = setup_regs address
      adr     x0, msg_running_test_part_1
      bl      uart_puts                       // Log "Running test "
      add     x0, x23, #0x20                  // x0 = address of test case name
      bl      uart_puts                       // Log "<test case name>"
      adr     x0, msg_running_test_part_2
      bl      uart_puts                       // Log "...\r\n"
      blr     x9                              // Setup RAM
      mov     x2, x6                          // x2 = Target address for pre-test snapshot, immediately after previous snapshot
      bl      snapshot_all_ram                // Snapshot pre-test RAM
      stp     x19, x23, [sp, #-16]!           // Stash pointer in tests block, pointer in test block
      stp     x21, x10, [sp, #-16]!           // Stash test block remaining test count, total remaining test count
      stp     x6, x2, [sp, #-16]!             // Stash pre-test snapshot location, post-test snapshot location
      sub     sp, sp, #0x100                  // Allocate space on stack for pre-test/post-test registers

    // Prepare pre-test registers with random values

      mov     x0, sp                          // x0 = start of pre-test register block
      mov     x1, #0x100                      // Register storage on stack takes up 0x100 bytes.
      bl      rand_block                      // Write random bytes to stack so registers are random when popped.
      ldp     x0, x1, [sp]
      ldp     x2, x3, [sp, #8 * 2]
      ldp     x4, x5, [sp, #8 * 4]
      ldp     x6, x7, [sp, #8 * 6]
      ldp     x8, x9, [sp, #8 * 8]
      ldp     x10, x11, [sp, #8 * 10]
      ldp     x12, x13, [sp, #8 * 12]
      ldp     x14, x15, [sp, #8 * 14]
      ldp     x16, x17, [sp, #8 * 16]
      ldp     x18, x19, [sp, #8 * 18]
      ldp     x20, x21, [sp, #8 * 20]
      ldp     x22, x23, [sp, #8 * 22]
      ldp     x24, x25, [sp, #8 * 24]
      ldp     x26, x27, [sp, #8 * 26]
      ldr     x28, [sp, #8 * 28]
    // TODO: load flags

      blr     x30                             // Call setup_regs routine

    // Store pre-test registers
      stp     x0, x1, [sp]
      stp     x2, x3, [sp, #8 * 2]
      stp     x4, x5, [sp, #8 * 4]
      stp     x6, x7, [sp, #8 * 6]
      stp     x8, x9, [sp, #8 * 8]
      stp     x10, x11, [sp, #8 * 10]
      stp     x12, x13, [sp, #8 * 12]
      stp     x14, x15, [sp, #8 * 14]
      stp     x16, x17, [sp, #8 * 16]
      stp     x18, x19, [sp, #8 * 18]
      stp     x20, x21, [sp, #8 * 20]
      stp     x22, x23, [sp, #8 * 22]
      stp     x24, x25, [sp, #8 * 24]
      stp     x26, x27, [sp, #8 * 26]
      str     x28, [sp, #8 * 28]
    // TODO: store flags

      ldr     x30, [sp, #0x320]               // x30 = address of routine to test
      blr     x30                             // Call routine under test

    // Store post-test registers
      sub     sp, sp, #0x100
      stp     x0, x1, [sp]
      stp     x2, x3, [sp, #8 * 2]
      stp     x4, x5, [sp, #8 * 4]
      stp     x6, x7, [sp, #8 * 6]
      stp     x8, x9, [sp, #8 * 8]
      stp     x10, x11, [sp, #8 * 10]
      stp     x12, x13, [sp, #8 * 12]
      stp     x14, x15, [sp, #8 * 14]
      stp     x16, x17, [sp, #8 * 16]
      stp     x18, x19, [sp, #8 * 18]
      stp     x20, x21, [sp, #8 * 20]
      stp     x22, x23, [sp, #8 * 22]
      stp     x24, x25, [sp, #8 * 24]
      stp     x26, x27, [sp, #8 * 26]
      str     x28, [sp, #8 * 28]
    // TODO: store flags

    // Restore stashed registers
      ldr     x2, [sp, #0x308]                // x2 = post-test snapshot location
      bl      snapshot_all_ram                // Snapshot post-test RAM
      ldr     x2, [sp, #0x300]                // x2 = pointer in test block
      bl      restore_all_ram                 // Restore pre-test state
      ldr     x23, [sp, #0x328]               // x23 = pointer in test block
      ldp     x9, x30, [x23], #0x10           // x9 = effects address
                                              // x30 = effects_regs address
      blr     x9                              // Set expected RAM values
      blr     x30                             // Set expected registers

    // Store expected registers
      sub     sp, sp, #0x100
      stp     x0, x1, [sp]
      stp     x2, x3, [sp, #8 * 2]
      stp     x4, x5, [sp, #8 * 4]
      stp     x6, x7, [sp, #8 * 6]
      stp     x8, x9, [sp, #8 * 8]
      stp     x10, x11, [sp, #8 * 10]
      stp     x12, x13, [sp, #8 * 12]
      stp     x14, x15, [sp, #8 * 14]
      stp     x16, x17, [sp, #8 * 16]
      stp     x18, x19, [sp, #8 * 18]
      stp     x20, x21, [sp, #8 * 20]
      stp     x22, x23, [sp, #8 * 22]
      stp     x24, x25, [sp, #8 * 24]
      stp     x26, x27, [sp, #8 * 26]
      str     x28, [sp, #8 * 28]
    // TODO: store flags

    // Restore stashed registers
      add     x0, sp, #0x300                  // x0 = address of this routine's stashed registers
      ldp     x6, x7, [x0], #16               // Restore pre-test snapshot location, post-test snapshot location
      ldp     x21, x10, [x0], #16             // Restore test block remaining test count, total remaining test count
      ldp     x19, x23, [x0], #16             // Restore pointer in tests block, pointer in test block
      ldp     x22, x20, [x0], #16             // Restore address of routine to test, pointer into all_tests

    // TODO: Compare registers (should include flags)

    // TODO: the compare snapshots should also compare framebuffers
      mov     x8, #0                          // start address of region to snapshot
      adrp    x9, memory_dumps
      add     x9, x9, :lo12:memory_dumps      // first address not to snapshot
      bl      compare_snapshots

    // TODO: Restore initial pristine snapshot

      add     sp, sp, #0x330
      sub     x10, x10, #1                    // Decrement remaining test count
      subs    x21, x21, #1
      b.ne    2b                              // Loop if more tests to run

    add     sp, sp, #0x10
    cbnz    x10, 1b                         // Loop if more tests to run

  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
36:
  ret


log_ram:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  adr     x0, msg_fail_8
  bl      uart_puts                       // Log ": Memory location [0x"
  mov     x0, x8
  bl      uart_x0                         // Log "<memory location in hex>"
  mov     x0, ']'                         // Log "]"
  bl      uart_send
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret


log_sysvar:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  adr     x0, msg_fail_7
  bl      uart_puts                       // Log ": System Variable "
  add     x0, x6, #9                      // x0 = address of system variable name
  bl      uart_puts                       // Log "<sysvar>"
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret


log_register:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  adr     x0, msg_fail_0
  bl      uart_puts                       // Log ": Register x"
  sub     sp, sp, 32
  mov     x0, sp
  mov     x2, x9
  bl      base10
  bl      uart_puts                       // Log "<register index>"
  add     sp, sp, #32
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret


# Log test failure message
#
# Report a failure message to UART if values are equal but should not be, or
# are not equal but should be. Otherwise do nothing.
#
# Report lines as follows:
#
# FAIL: po_change test case 1: Register x3 changed from 0x8ceb064787d0b39b to 0x0000000000001a68, but should not have changed.
# FAIL: po_change test case 1: System Variable CURCHL changed from 0x0000000000001a60 to 0x000000000ed00100, but should have changed to 0x00000f00f00f00f0.
# FAIL: po_change test case 1: Register x5 unchanged from 0xfe87f64783bc7a76 but should have changed to 0x00000f00f00f00f0.
#
# On entry:
#   x11 = address of pointer to test name
#   x12 = pre-test value
#   x13 = post-test value
#   x14 = expected value
#   x16 = function to log entity that has incorrect value
# On exit:
#   x0 / x1 / x2 / x3 corrupted (uart_puts / x16 / uart_x0 / hex_x0)
test_fail:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  adr     x0, msg_fail
  bl      uart_puts                       // Log "FAIL: "
  ldr     x0, [x11]                       // x0 = address of test name
  bl      uart_puts                       // Log "<test case name>"
  mov     x0, ':'
  bl      uart_send                       // Log ":"
  mov     x0, ' '
  bl      uart_send                       // Log " "
  blr     x16                             // Log "<entity>"
  cmp     x12, x13
  b.eq    2f                              // x12 == x13 => value unchanged but should have
// value changed
  adr     x0, msg_fail_1
  bl      uart_puts                       // Log " changed from "
  mov     x0, x12
  bl      uart_x0                         // Log "<pre-test register value>"
  adr     x0, msg_fail_3
  bl      uart_puts                       // Log " to "
  mov     x0, x13
  bl      uart_x0                         // Log "<post-test register value>"
  cmp     x12, x14
  b.eq    1f                              // x12 == x14 => value shouldn't have changed but did
// value meant to change, but to a different value
  adr     x0, msg_fail_4
  bl      uart_puts                       // Log ", but should have changed to "
  mov     x0, x14
  bl      uart_x0                         // Log "<expected register value>"
  adr     x0, msg_fail_6
  bl      uart_puts                       // Log ".\r\n"
  b       3f
1:
// value not meant to change, but did
  adr     x0, msg_fail_5
  bl      uart_puts                       // Log ", but should not have changed.\r\n"
  b       3f
2:
// value unchanged, but was meant to
  adr     x0, msg_fail_2
  bl      uart_puts                       // Log " unchanged from "
  mov     x0, x12
  bl      uart_x0                         // Log "<pre-test register value>"
  adr     x0, msg_fail_4
  bl      uart_puts                       // Log ", but should have changed to "
  mov     x0, x14
  bl      uart_x0                         // Log "<expected register value>"
  adr     x0, msg_fail_6
  bl      uart_puts                       // Log ".\r\n"
3:
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret


# On entry:
#   x2 = location to write compressed data to
snapshot_all_ram:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  mov     x0, #0                          // start address of region to snapshot
  adrp    x1, memory_dumps
  add     x1, x1, :lo12:memory_dumps      // first address not to snapshot
  mov     x3, MEMORY_DUMPS_BUFFER_SIZE
  add     x3, x1, x3                      // first address after end of compressed data region
  bl      snapshot_memory                 // x2 = first address after end of snapshot
# TODO: snapshot framebuffer
# adr     x4, framebuffer
# ldr     w0, [x4]
# ldr     w1, [x4, #4]
# add     w1, w0, w1
# bl      snapshot_memory                 // x2 = first address after end of snapshot
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret


# On entry:
#  x0 = start address to compress (inclusive) -> 8 byte aligned
#  x1 = end address to compress (exclusive) -> 8 byte aligned, at least 16 more than x0
#  x2 = start address of compressed data buffer (inclusive) -> 8 byte aligned
#  x3 = end address of compressed data buffer (exclusive) -> 8 byte aligned
# On exit:
#  x0 = x1
#  x2 = end address of used compressed data (exclusive) -> 8 byte aligned
#  x4 = [x1 - 16]
#  x5 = [x1 - 8]
#  x6 = repeat count of last quad
#  x7 = 0x6a09e667bb67ae85
snapshot_memory:
  // x4 = quad at [address-8]
  // x5 = quad at [address]
  // x6 = repeat count of value (excluding original entry, i.e. n-1 where n = length of repeated sequence)
  // x7 = 0x6a09e667bb67ae85 (reserved code to denote that a count and repeated value follow)
  mov     x6, #0                          // Set quad repeat counter to zero
  ldr     x7, =0x6a09e667bb67ae85
  ldr     x4, [x0], #8
  1:
    ldr     x5, [x0], #8                    // Get next value.
    cmp     x4, x5                          // Is new value different to previous one?
    b.ne    2f                              // If so, jump ahead to 2:.
  // new quad value matches previous quad value
    add     x6, x6, #1                      // Bump counter
    b       5f
  2:
  // new value found
    cbnz    x6, 3f                          // If reached end of repeating quad sequence, jump ahead to 3:.
  // previous value wasn't a repeating one
    cmp     x4, x7                          // Was the raw value (coincidentally) the reserved repeating value code?
    b.ne    4f                              // If not, jump ahead to store in raw form
  // escape the magic value as a "repeated 0 times" repeated quad value
  3:
  // recurring quad sequence completed
    add     x2, x2, #16
    cmp     x2, x3
    b.hs    6f
    stp     x7, x6, [x2, #-16]              // Store "repeated value magic value", number of repeats (excluding original)
    mov     x6, #0                          // Reset repeated entries counter
  4:
    add     x2, x2, #8
    cmp     x2, x3
    b.hs    6f
    str     x4, [x2, #-8]                   // Store value
  5:
    mov     x4, x5
    cmp     x0, x1                          // Reached end of memory to snapshot?
    b.ne    1b                              // Repeat loop if end of region to compress not reached
  add     x2, x2, #24
  cmp     x2, x3
  b.hs    6f
  stp     x7, x6, [x2, #-24]              // Store "repeated value magic value", number of repeats (excluding original)
  str     x5, [x2, #-8]                   // Store value
  ret
6:
  adr     x0, msg_out_of_memory
  bl      uart_puts
  b       sleep


# On entry:
#   x2 = location of snapshot
# TODO: restore framebuffer
restore_all_ram:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  mov     x0, #0                          // start address to restore snapshot to
  adrp    x1, memory_dumps
  add     x1, x1, :lo12:memory_dumps      // first address not to restore
  bl      restore_snapshot
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret


# On entry:
#   x0 = start address to decompress to (inclusive) -> 8 byte aligned
#   x1 = end address to decompress to (exclusive) -> 8 byte aligned, at least 16 more than x0
#   x2 = start address of compressed data buffer (inclusive) -> 8 byte aligned
# On exit:
#   x0 = x1
#   x2 = end address of used compressed data (exclusive) -> 8 byte aligned
#   x4 = [x1 - 8]
#   x5 = 0
#   x7 = 0x6a09e667bb67ae85
restore_snapshot:
  ldr     x7, =0x6a09e667bb67ae85
  1:
    ldr     x4, [x2], #8
    cmp     x4, x7
    b.ne    3f
  // repeated value found
    ldp     x5, x4, [x2], #16               // x5 = repeat count (1 less than total entries), x4 = value
    2:
      cbz     x5, 3f
      str     x4, [x0], #8
      sub     x5, x5, #1
      b       2b
  3:
    str     x4, [x0], #8
    cmp     x0, x1
    b.ne    1b
  ret


# On entry:
#   x6 = pre-test compressed snapshot address
#   x7 = post-test compressed snapshot address
#   x8 = start memory address (inclusive) of expected data (uncompressed)
#   x9 = end memory address (exclusive) of expected data (uncompressed)
# On exit:
#   x0
#   x1
#   x2
#   x3
#   x6
#   x7
#   x8
#   x12
#   x13
#   x14
#   x15
#   x16
#   x17
#   x18
    // TODO: Custom output for system vars
compare_snapshots:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
// x8 will loop through quads until it reaches x9
// x12 = pre-test value of [x8] (from snapshot)
// x13 = post-test value of [x8] (from snapshot)
// x14 = expected value of [x8] (from current value in RAM)
// x17 = current repeat count for pre-test
// x18 = current repeat count for post-test
  ldr     x15, =0x6a09e667bb67ae85
  mov     x17, #0
  mov     x18, #0
  1:
    cbz     x17, 2f                         // If not still repeating previous pre-test value, jump ahead to 2:
    sub     x17, x17, #1                    // Decrement counter
    b       3f                              // x12 already set from previous iteration, so jump ahead
  2:
    ldr     x12, [x6], #8                   // Read a new value
    cmp     x12, x15                        // Is it the repeat marker?
    b.ne    3f                              // If not, it is a regular value, jump ahead to 3:
  // repeated value found
    ldp     x17, x12, [x6], #16             // x17 = repeat count (1 less than total entries), x12 = value
  3:
  // x17 and x12 correctly set now
    cbz     x18, 4f                         // If not still repeating previous pre-test value, jump ahead to 4:
    sub     x18, x18, #1                    // Decrement counter
    b       5f                              // x13 already set from previous iteration, so jump ahead
  4:
    ldr     x13, [x7], #8                   // Read a new value
    cmp     x13, x15                        // Is it the repeat marker?
    b.ne    5f                              // If not, it is a regular value, jump ahead to 5:
  // repeated value found
    ldp     x18, x13, [x7], #16             // x18 = repeat count (1 less than total entries), x13 = value
  5:
  // x18 and x13 correctly set now
    ldr     x14, [x8]
    cmp     x14, x13
    b.eq    6f
    adr     x16, log_ram                    // x16 = function to log ": Memory location [0x<address>]"
    bl      test_fail
  6:
    add     x8, x8, #8
    cmp     x8, x9
    b.ne    1b
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret


msg_running_test_part_1: .asciz "Running test "
msg_running_test_part_2: .asciz "...\r\n"

msg_fail: .asciz "FAIL: "
msg_fail_0: .asciz "Register x"
msg_fail_1: .asciz " changed from "
msg_fail_2: .asciz " unchanged from "
msg_fail_3: .asciz " to "
msg_fail_4: .asciz ", but should have changed to "
msg_fail_5: .ascii ", but should not have changed"
                                        // Intentionally .ascii not .asciz, in order to join with msg_fail_6.
msg_fail_6: .asciz ".\r\n"
msg_fail_7: .asciz "System Variable "

msg_fail_8: .asciz "Memory location [0x"

msg_out_of_memory: .asciz "Out of memory!\r\n"


.bss

.align 3
memory_dumps: .space MEMORY_DUMPS_BUFFER_SIZE
