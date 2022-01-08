# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.


.text
.align 2
# Run all system tests.
#
# On entry:
#   <nothing>
# On exit:
#   God knows
run_tests:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  adr     x20, all_suites                         // x20 = address of test list
  ldr     x10, [x20], #8                          // x10 = number of tests
  cbz     x10, 11f                                // Return if no tests to run
// Create an initial snapshot for restoring state between tests
  adrp    x2, memory_dumps
  add     x2, x2, :lo12:memory_dumps              // x2 = target address for snapshot
  bl      snapshot_all_ram                        // Snapshot RAM so we can roll back between tests
  mov     x6, x2                                  // x6 = first free address after end of snapshot
  1:                                              // Loop executing tests
    ldr     x19, [x20], #0x08                     // x19 = address of test block
    ldp     x21, x22, [x19], #0x10                // x21 = number of tests for test block
                                                  // x22 = address of routine to test
    stp     x22, x20, [sp, #-16]!                 // Stash address of routine to test, pointer into all_suites
    2:
      ldr     x23, [x19], #0x08                   // x23 = address of test
      ldp     x9, x17, [x23], #0x10               // x9 = setup address
                                                  // x17 = setup_regs address
      adr     x0, msg_running_test_part_1
      bl      uart_puts                           // Log "Running test "
      add     x0, x23, #0x10                      // x0 = address of test case name
      bl      uart_puts                           // Log "<test case name>"
      adr     x0, msg_running_test_part_2
      bl      uart_puts                           // Log "...\r\n"

      mov     x0, #1
      adrp    x1, uart_disable
      add     x1, x1, :lo12:uart_disable
      strb    w0, [x1]                            // Disable UART output for test code

      cbz     x9, 3f                              // Skip RAM setup if there is none
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
      stp     x28, x29, [sp, #8 * 28]
      sub     sp, sp, #0x230                      // Stack pointer to match routine under test
      blr     x9                                  // Setup RAM
      add     sp, sp, #0x230

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
      ldp     x28, x29, [sp, #8 * 28]
      add     sp, sp, #0x100
    3:
      mov     x2, x6                              // x2 = Target address for pre-test snapshot, immediately after previous snapshot
      bl      snapshot_all_ram                    // Snapshot pre-test RAM
      stp     x19, x23, [sp, #-16]!               // Stash pointer in tests block, pointer in test block
      stp     x21, x10, [sp, #-16]!               // Stash test block remaining test count, total remaining test count
      stp     x6, x2, [sp, #-16]!                 // Stash pre-test snapshot location, post-test snapshot location
      sub     sp, sp, #0x100                      // Allocate space on stack for pre-test/post-test registers

    // Prepare pre-test registers with random values
      mov     x0, sp                              // x0 = start of pre-test register block
      mov     x1, #0x100                          // Register storage on stack takes up 0x100 bytes.
      bl      rand_block                          // Write random bytes to stack so registers are random when popped.

    // Set random values for NZCV flags
      ldr     x1, [sp, #8*29]
      mrs     x0, nzcv
      bfi     x0, x1, #28, #4
      msr     nzcv, x0

      mov     x30, x17
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
      adrp    x28, sysvars
      add     x28, x28, :lo12:sysvars
      str     x28, [sp, #8 * 28]

      cbz     x30, 4f
      sub     sp, sp, #0x200                      // Stack pointer to match routine under test
      blr     x30                                 // Call setup_regs routine
      add     sp, sp, #0x200
    4:

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
      mrs     x0, nzcv                            // Fetch flags (Negative, Zero, Carry, oVerflow)
      stp     x28, x0, [sp, #8 * 28]
      ldr     x0, [sp]

      ldr     x30, [sp, #0x130]                   // x30 = address of routine to test
      sub     sp, sp, #0x200                      // Stack pointer to match routine under test
      blr     x30                                 // Call routine under test
      add     sp, sp, #0x200

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
      mrs     x0, nzcv                            // Fetch flags (Negative, Zero, Carry, oVerflow)
      stp     x28, x0, [sp, #8 * 28]

      adrp    x1, uart_disable
      add     x1, x1, :lo12:uart_disable
      strb    wzr, [x1]                           // Enable UART output for test framework output

    // Restore stashed registers
      ldr     x2, [sp, #0x208]                    // x2 = post-test snapshot location
      bl      snapshot_all_ram                    // Snapshot post-test RAM
      ldr     x2, [sp, #0x200]                    // x2 = pre-test snapshot location
      bl      restore_all_ram                     // Restore pre-test state
      ldr     x23, [sp, #0x228]                   // x23 = pointer in test block
      ldp     x9, x17, [x23], #0x10               // x9 = effects address
                                                  // x17 = effects_regs address
      cbz     x9, 5f
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
      stp     x28, x29, [sp, #8 * 28]
      blr     x9                                  // Setup RAM
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
      ldp     x28, x29, [sp, #8 * 28]
      add     sp, sp, #0x100
    5:

    // Set NZCV flags
      ldp     x28, x1, [sp, #0x100 + 8 * 28]
      and     x1, x1, #0xf0000000                 // Clear all bits of x1 except 28-31
      mrs     x0, nzcv                            // Get current flags
      and     x0, x0, #~0xf0000000                // Clear only bits 28-31 of x0
      orr     x0, x0, x1                          // Combine x0 and x1
      msr     nzcv, x0                            // Write result back to flags

      mov     x30, x17
      ldp     x0, x1, [sp, #0x100 + 8 * 0]
      ldp     x2, x3, [sp, #0x100 + 8 * 2]
      ldp     x4, x5, [sp, #0x100 + 8 * 4]
      ldp     x6, x7, [sp, #0x100 + 8 * 6]
      ldp     x8, x9, [sp, #0x100 + 8 * 8]
      ldp     x10, x11, [sp, #0x100 + 8 * 10]
      ldp     x12, x13, [sp, #0x100 + 8 * 12]
      ldp     x14, x15, [sp, #0x100 + 8 * 14]
      ldp     x16, x17, [sp, #0x100 + 8 * 16]
      ldp     x18, x19, [sp, #0x100 + 8 * 18]
      ldp     x20, x21, [sp, #0x100 + 8 * 20]
      ldp     x22, x23, [sp, #0x100 + 8 * 22]
      ldp     x24, x25, [sp, #0x100 + 8 * 24]
      ldp     x26, x27, [sp, #0x100 + 8 * 26]
      cbz     x30, 6f
      sub     sp, sp, #0x100                      // Stack pointer to match routine under test
      blr     x30                                 // Set expected registers
      add     sp, sp, #0x100
    6:

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
      mrs     x0, nzcv                            // Fetch flags (Negative, Zero, Carry, oVerflow)
      stp     x28, x0, [sp, #8 * 28]

    // Restore stashed registers
      add     x24, sp, #0x300                     // x24 = address of this routine's stashed registers
      ldp     x21, x10, [x24, #16]                // Restore test block remaining test count, total remaining test count
      ldp     x19, x23, [x24, #32]                // Restore pointer in tests block, pointer in test block
      ldp     x22, x20, [x24, #48]                // Restore address of routine to test, pointer into all_suites

    // Compare registers
      mov     x8, sp
      mov     x9, #0                              // x9 = register index
      7:
        ldr     x12, [x8, #0x200]                 // x12 = pre-test register value
        ldr     x13, [x8, #0x100]                 // x13 = post-test register value
        ldr     x14, [x8], #0x08                  // x14 = expected register value
        cmp     x13, x14
        b.eq    8f
        adr     x16, log_register                 // x16 = function to log "Register x<index>"
        bl      test_fail
      8:
        add     x9, x9, #1
        cmp     x9, #29
        b.ne    7b

    // Compare flags
      adr     x6, flag_msg_offsets
      mov     w7, #0x80000000                     // Mask for bit 31
      ldr     w12, [x8, #0x200]                   // w12 = pre-test NZCV
      ldr     w13, [x8, #0x100]                   // w13 = post-test NZCV
      ldr     w14, [x8], #0x08                    // w14 = expected NZCV
      eor     w9, w13, w14                        // w9 bits 28-31 hold 0 if expected == actual for counterpart NZCV flag, or 1 if not
      9:
        tst     w9, w7                            // Mask individual flag bit under test
        b.eq    10f                               // If flag was set correctly, jump ahead to 10:
      // Test fail - flag set incorrectly
        adr     x0, msg_fail
        bl      uart_puts                         // Log "FAIL: "
        add     x0, x23, #0x10                    // x0 = address of test case name
        bl      uart_puts                         // Log "<test case name>"
        mov     x0, ':'
        bl      uart_send                         // Log ":"
        mov     x0, ' '
        bl      uart_send                         // Log " "
        ldrb    w18, [x6]
        add     x0, x6, x18
        bl      uart_puts                         // Log "<flag description>"
        adr     x15, msg_should_be_set
        adr     x16, msg_should_not_be_set
        tst     w13, w7
        csel    x0, x15, x16, eq
        bl      uart_puts                         // Log " clear but should be set.\r\n" or "set but should be clear.\r\n"
      10:
        add     x6, x6, #1
        lsr     w7, w7, #1
        tbz     w7, #27, 9b

      ldp     x6, x7, [x24]                       // Restore pre-test snapshot location, post-test snapshot location
      bl      compare_all_snapshots

    // Restore initial pristine snapshot
      adrp    x2, memory_dumps
      add     x2, x2, :lo12:memory_dumps          // x2 = target address for snapshot
      bl      restore_all_ram                     // Restore pre-test state

    // Restore stashed registers
      ldr     x6, [x24]                           // Restore pre-test snapshot location
      add     sp, sp, #0x330
      sub     x10, x10, #1                        // Decrement remaining test count
      subs    x21, x21, #1
      b.ne    2b                                  // Loop if more tests to run

    add     sp, sp, #0x10
    cbnz    x10, 1b                               // Loop if more tests to run

11:
  adr     x0, msg_all_tests_completed
  bl      uart_puts                               // Log "All tests completed.\r\n"
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret


# On entry:
#   x8 = Memory location
log_ram:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  adr     x0, msg_fail_8
  bl      uart_puts                               // Log "Memory location [0x"
  mov     x0, x8
  bl      uart_x0                                 // Log "<memory location in hex>"
  mov     x0, ']'                                 // Log "]"
  bl      uart_send
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret


log_sysvar:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  adr     x0, msg_fail_7
  bl      uart_puts                               // Log "System Variable "
  add     x0, x6, #9                              // x0 = address of system variable name
  bl      uart_puts                               // Log "<sysvar>"
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret


# On entry:
#   x9 = x register index (0-30)
log_register:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  adr     x0, msg_fail_0
  bl      uart_puts                               // Log "Register x"
  sub     sp, sp, 32
  mov     x0, sp
  mov     x2, x9
  bl      base10
  bl      uart_puts                               // Log "<register index>"
  add     sp, sp, #32
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
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
#   x8 = RAM test failure only: address that failed
#   x9 = Register failure only: x register index
#   x12 = pre-test value
#   x13 = post-test value
#   x14 = expected value
#   x16 = function to log entity that has incorrect value
#   x23 = address of test name minus 0x10
# On exit:
#   x0 / x1 / x2 / x3 corrupted (uart_puts / x16 / uart_x0 / hex_x0)
test_fail:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  adr     x0, msg_fail
  bl      uart_puts                               // Log "FAIL: "
  add     x0, x23, #0x10                          // x0 = address of test case name
  bl      uart_puts                               // Log "<test case name>"
  mov     x0, ':'
  bl      uart_send                               // Log ":"
  mov     x0, ' '
  bl      uart_send                               // Log " "
  blr     x16                                     // Log "<entity>"
  cmp     x12, x13
  b.eq    2f                                      // x12 == x13 => value unchanged but should have
// value changed
  adr     x0, msg_fail_1
  bl      uart_puts                               // Log " changed from "
  mov     x0, x12
  bl      uart_x0                                 // Log "<pre-test register value>"
  adr     x0, msg_fail_3
  bl      uart_puts                               // Log " to "
  mov     x0, x13
  bl      uart_x0                                 // Log "<post-test register value>"
  cmp     x12, x14
  b.eq    1f                                      // x12 == x14 => value shouldn't have changed but did
// value meant to change, but to a different value
  adr     x0, msg_fail_4
  bl      uart_puts                               // Log ", but should have changed to "
  mov     x0, x14
  bl      uart_x0                                 // Log "<expected register value>"
  adr     x0, msg_fail_6
  bl      uart_puts                               // Log ".\r\n"
  b       3f
1:
// value not meant to change, but did
  adr     x0, msg_fail_5
  bl      uart_puts                               // Log ", but should not have changed.\r\n"
  b       3f
2:
// value unchanged, but was meant to
  adr     x0, msg_fail_2
  bl      uart_puts                               // Log " unchanged from "
  mov     x0, x12
  bl      uart_x0                                 // Log "<pre-test register value>"
  adr     x0, msg_fail_4
  bl      uart_puts                               // Log ", but should have changed to "
  mov     x0, x14
  bl      uart_x0                                 // Log "<expected register value>"
  adr     x0, msg_fail_6
  bl      uart_puts                               // Log ".\r\n"
3:
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret


# On entry:
#   x2 = location to write compressed data to
# On exit:
#   x0 = start address of last continuous region
#   x1 = end address (exclusive) of last continuous region
#   x2 = end address of used compressed data (exclusive) -> 8 byte aligned
#   x3 = end address of compressed data (exclusive) -> 8 byte aligned
#   x4 = [x1 - 16]
#   x5 = [x1 - 8]
#   x7 = first address after random block
#   x8 = address in random block
#   x11 = rand_data
#   x26 = repeat count of last quad (excluding original entry, i.e. n-1 where n = length of repeated sequence)
#   x27 = 0x6a09e667bb67ae85 (reserved code to denote that a count and repeated value follow)
snapshot_all_ram:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  mov     x3, MEMORY_DUMPS_BUFFER_SIZE
  add     x3, x2, x3                              // first address after end of compressed data region
  mov     x0, #2                                  // Number of RAM regions to snapshot
  str     x0, [x2], #8                            // Store number of RAM regions to snapshot
  mov     x0, #0                                  // start address of region to snapshot
  adrp    x1, bss_debug_start
  add     x1, x1, :lo12:bss_debug_start           // first address not to snapshot
  bl      snapshot_memory                         // x2 = first address after end of snapshot
  adr     x0, framebuffer
  ldp     w0, w1, [x0]
  add     x1, x0, x1
  bl      snapshot_memory                         // x2 = first address after end of snapshot
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret


# On entry:
#   x0 = start address to compress (inclusive) -> 8 byte aligned
#   x1 = end address to compress (exclusive) -> 8 byte aligned, at least 16 more than x0
#   x2 = start address of compressed data buffer (inclusive) -> 8 byte aligned
#   x3 = end address of compressed data buffer (exclusive) -> 8 byte aligned
# On exit:
#   x0 = x1
#   x2 = end address of used compressed data (exclusive) -> 8 byte aligned
#   x4 = [x1 - 16]
#   x5 = [x1 - 8]
#   x7 = first address after random block
#   x8 = address in random block
#   x11 = rand_data
#   x26 = repeat count of last quad (excluding original entry, i.e. n-1 where n = length of repeated sequence)
#   x27 = 0x6a09e667bb67ae85 (reserved code to denote that a count and repeated value follow)
snapshot_memory:
  add     x2, x2, #16                             // Number of bytes required to store start and end addresses in buffer
  cmp     x2, x3                                  // Check buffer has enough space for storing start/end addresses
  b.hs    6f                                      // If not, throw buffer-overflow error
  stur    x0, [x2, #-16]                          // Store start address of data region to start of buffer
  stur    x1, [x2, #-8]                           // Store end address of data region to start of buffer
  adrp    x7, rand_seq_length
  add     x7, x7, :lo12:rand_seq_length
  ldrb    w4, [x7]                                // w4 = random block length
  adrp    x11, rand_data
  add     x11, x11, :lo12:rand_data               // x11 = address of random data
  udiv    x8, x0, x4                              // x8 = int(start_address_decompressed/x4)
  umsubl  x8, w8, w4, x0                          // x8 = x0 - x4 * int(x0/x4) = start_address_decompressed % random_sequence_length
  add     x8, x8, x11                             // x8 = address inside random block that holds quad for masking start address
  add     x7, x4, x11                             // x7 = first address after random block
  mov     x26, #0                                 // Set quad repeat counter to zero
  ldr     x27, =0x6a09e667bb67ae85
  ldr     x4, [x0], #8
  ldr     x12, [x8], #8
  cmp     x8, x7
  csel    x8, x8, x11, ne
  eor     x4, x4, x12
  1:
    ldr     x5, [x0], #8                          // Get next value.
    ldr     x12, [x8], #8
    cmp     x8, x7
    csel    x8, x8, x11, ne
    eor     x5, x5, x12
    cmp     x4, x5                                // Is new value different to previous one?
    b.ne    2f                                    // If so, jump ahead to 2:.
  // new quad value matches previous quad value
    add     x26, x26, #1                          // Bump counter
    b       5f
  2:
  // new value found
    cbnz    x26, 3f                               // If reached end of repeating quad sequence, jump ahead to 3:.
  // previous value wasn't a repeating one
    cmp     x4, x27                               // Was the raw value (coincidentally) the reserved repeating value code?
    b.ne    4f                                    // If not, jump ahead to store in raw form
  // escape the magic value as a "repeated 0 times" repeated quad value
  3:
  // recurring quad sequence completed
    add     x2, x2, #16
    cmp     x2, x3
    b.hs    6f
    stp     x27, x26, [x2, #-16]                  // Store "repeated value magic value", number of repeats (excluding original)
    mov     x26, #0                               // Reset repeated entries counter
  4:
    add     x2, x2, #8
    cmp     x2, x3
    b.hs    6f
    stur    x4, [x2, #-8]                         // Store value
  5:
    mov     x4, x5
    cmp     x0, x1                                // Reached end of memory to snapshot?
    b.ne    1b                                    // Repeat loop if end of region to compress not reached
  add     x2, x2, #24
  cmp     x2, x3
  b.hs    6f
  stp     x27, x26, [x2, #-24]                    // Store "repeated value magic value", number of repeats (excluding original)
  str     x5, [x2, #-8]                           // Store value
  ret
6:
  adr     x0, msg_out_of_memory
  bl      uart_puts
  b       sleep


# On entry:
#   x2 = location of snapshot
restore_all_ram:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  ldr     x6, [x2], #8                            // x6 = number of continuous regions to restore
  1:
    cbz     x6, 2f
    ldp     x0, x1, [x2], #16                     // x0 = start address to decompress to, x1 = end address (exclusive)
    bl      restore_snapshot
    sub     x6, x6, #1
    b       1b
2:
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
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
#   x27 = 0x6a09e667bb67ae85
#  TODO: update reg list
restore_snapshot:
  adrp    x7, rand_seq_length
  add     x7, x7, :lo12:rand_seq_length
  ldrb    w4, [x7]                                // w4 = random block length
  adrp    x11, rand_data
  add     x11, x11, :lo12:rand_data               // x11 = address of random data
  udiv    x8, x0, x4                              // x8 = int(start_address_decompressed/x4)
  umsubl  x8, w8, w4, x0                          // x8 = x0 - x4 * int(x0/x4) = start_address_decompressed % random_sequence_length
  add     x8, x8, x11                             // x8 = address inside random block that holds quad for masking start address
  add     x7, x4, x11                             // x7 = first address after random block
  ldr     x27, =0x6a09e667bb67ae85
  1:
    ldr     x4, [x2], #8
    cmp     x4, x27
    b.ne    3f
  // repeated value found
    ldp     x5, x4, [x2], #16                     // x5 = repeat count (1 less than total entries), x4 = value
    2:
      cbz     x5, 3f
      ldr     x12, [x8], #8
      cmp     x8, x7
      csel    x8, x8, x11, ne
      eor     x12, x4, x12
      str     x12, [x0], #8
      sub     x5, x5, #1
      b       2b
  3:
    ldr     x12, [x8], #8
    cmp     x8, x7
    csel    x8, x8, x11, ne
    eor     x12, x4, x12
    str     x12, [x0], #8
    cmp     x0, x1
    b.ne    1b
  ret


# On entry:
#   x6 = pre-test compressed snapshot address
#   x7 = post-test compressed snapshot address
# On exit:
#   x0
#   x1
#   x2
#   x3
#   x4
#   x5
#   x6
#   x7
#   x8
#   x9
#   x11
#   x12
#   x13
#   x14
#   x15
#   x16
#   x17
#   x18
#   x22
#   x25
#   x26
#   x27
compare_all_snapshots:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  ldr     x27, [x6], #8
  add     x7, x7, #8
  1:
    cbz     x27, 2f
    ldp     x8, x9, [x6], #16
    add     x7, x7, #16
    bl      compare_snapshots
    sub     x27, x27, #1
    b       1b
2:
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
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
#   x4
#   x5
#   x6
#   x7
#   x8
#   x11
#   x12
#   x13
#   x14
#   x15
#   x16
#   x17
#   x18
#   x22
#   x25
#   x26
# TODO: Custom output for system vars
compare_snapshots:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  adrp    x26, rand_seq_length
  add     x26, x26, :lo12:rand_seq_length
  ldrb    w4, [x26]                               // w4 = random block length
  adrp    x11, rand_data
  add     x11, x11, :lo12:rand_data               // x11 = address of random data
  udiv    x25, x8, x4                             // x25 = int(start_address_decompressed/x4)
  umsubl  x25, w25, w4, x8                        // x25 = x8 - x4 * int(x8/x4) = start_address_decompressed % random_sequence_length
  add     x25, x25, x11                           // x25 = address inside random block that holds quad for masking start address
  add     x26, x4, x11                            // x26 = first address after random block
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
    cbz     x17, 2f                               // If not still repeating previous pre-test value, jump ahead to 2:
    sub     x17, x17, #1                          // Decrement counter
    b       3f                                    // x4 already set from previous iteration, so jump ahead
  2:
    ldr     x4, [x6], #8                          // Read a new value
    cmp     x4, x15                               // Is it the repeat marker?
    b.ne    3f                                    // If not, it is a regular value, jump ahead to 3:
  // repeated value found
    ldp     x17, x4, [x6], #16                    // x17 = repeat count (1 less than total entries), x4 = value
  3:
  // x17 and x4 correctly set now
    cbz     x18, 4f                               // If not still repeating previous pre-test value, jump ahead to 4:
    sub     x18, x18, #1                          // Decrement counter
    b       5f                                    // x5 already set from previous iteration, so jump ahead
  4:
    ldr     x5, [x7], #8                          // Read a new value
    cmp     x5, x15                               // Is it the repeat marker?
    b.ne    5f                                    // If not, it is a regular value, jump ahead to 5:
  // repeated value found
    ldp     x18, x5, [x7], #16                    // x18 = repeat count (1 less than total entries), x5 = value
  5:
  // x18 and x5 correctly set now
    ldr     x14, [x8]
    ldr     x22, [x25]
    eor     x12, x22, x4
    eor     x13, x22, x5
    cmp     x13, x14
    b.eq    6f
    adr     x16, log_ram                          // x16 = function to log "Memory location [0x<address>]"
    bl      test_fail
  6:
    add     x8, x8, #8
    add     x25, x25, #8
    cmp     x25, x26
    csel    x25, x25, x11, ne
    cmp     x8, x9
    b.ne    1b
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret


# Fill with repeating sequence of random data, with random length one of
# 0x40/0x50/0x60/0x70/0x80/0x90/0xa0/0xb0.
fill_memory_with_junk:
  mov     x11, x30
  adr     x0, msg_filling_memory_with_junk
  bl      uart_puts
// Choose random sequence length
  bl      rand_x0                                 // Fetch random bits in x0
  and     w1, w0, #0x00000070                     // 0x00/0x10/0x20/0x30/0x40/0x50/0x60/0x70
  add     w1, w1, #0x00000040                     // 0x40/0x50/0x60/0x70/0x80/0x90/0xa0/0xb0
  adrp    x7, rand_seq_length
  add     x7, x7, :lo12:rand_seq_length
  strb    w1, [x7]
// Generate random sequence
  adrp    x5, rand_data
  add     x5, x5, :lo12:rand_data
  mov     x0, x5
  mov     x4, x1                                  // Preserve sequence byte length in x4
  bl      rand_block
// First random block: __bss_start -> bss_debug_start
  add     x8, x28, bss_start-sysvars
  adrp    x6, bss_debug_start
  add     x6, x6, :lo12:bss_debug_start
  bl      fill_region_with_junk
// Second random block: framebuffer
  adr     x0, framebuffer
  ldp     w8, w6, [x0]
  add     x6, x8, x6
  bl      fill_region_with_junk
// Log completed
  adr     x0, msg_done
  bl      uart_puts
  mov     x30, x11
  ret


fill_region_with_junk:
  mov     x0, x30
  udiv    x9, x8, x4                              // x9 = int(__bss_start/x4)
  umsubl  x10, w9, w4, x8                         // x10 = x8 - x4 * int(x8/x4) = __bss_start % (random sequence length)
  1:
    tst     x10, 0x0f
    b.eq    2f
    ldrb    w3, [x5, x10]
    strb    w3, [x8], #1
    add     x10, x10, #1
    b       1b
2:
  3:
    cmp     x10, x4
    csel    x10, xzr, x10, eq
    cmp     x8, x6
    b.hs    4f
    add     x7, x5, x10
    ldp     x9, x3, [x7]
    stp     x9, x3, [x8], #0x10
    add     x10, x10, #0x10
    b       3b
4:
  mov     x30, x0
  ret


# These hardware random number generator routines are inspired by:
#   https://github.com/torvalds/linux/blob/d4f6d923238dbdb69b8525e043fedef2670d4f2c/drivers/char/hw_random/bcm2835-rng.c
rand_init:
  mov     x5, x30
  adr     x0, msg_init_rand
  bl      uart_puts
  mov     x1, #0x4000
  movk    x1, #0x3f10, lsl #16
# mov     w0, #0x00040000                 // "warmup count": the initial numbers generated are "less random" so will be discarded
  mov     w0, #0x00100000                         // "warmup count": the initial numbers generated are "less random" so will be discarded
  str     w0, [x1, #0x04]                         // [0x3f104004] = 0x00040000
  ldr     w0, [x1, #0x10]
  orr     w0, w0, #0x01
  str     w0, [x1, #0x10]                         // Set bit 0 of [0x3f104010]  (mask the interrupt)
  ldr     w0, [x1]
  orr     w0, w0, #0x01
  str     w0, [x1]                                // Set bit 0 of [0x3f104000]  (enable the hardware generator)
  adr     x0, msg_done
  bl      uart_puts
  mov     x30, x5
  ret


rand_x0:
  mov     x1, #0x4000
  movk    x1, #0x3f10, lsl #16                    // x1 = 0x3f104000
  1:                                              // Wait until ([0x3f104004] >> 24) >= 2
    ldr     w0, [x1, #0x04]                       // Bits 24-31 tell us how many words
    lsr     w0, w0, RNG_BIT_SHIFT                 // are available, which needs to be at
    cbz     w0, 1b                                // least two, since we are going to
                                                  // read two words. However under qemu
                                                  // bits 24-31 are always 0b00000001 so
                                                  // we use a symbol for the the shift
                                                  // size; it is 25, unless building for
                                                  // QEMU, when it is 24.
  ldr     w0, [x1, #0x08]                         // w0 = [0x3f104008] (random data)
  ldr     w2, [x1, #0x08]                         // w2 = [0x3f104008] (random data)
  bfi     x0, x2, #32, #32                        // Copy bits from w2 into high bits of x0.
  ret


# Write random data to a buffer.
#
# On entry:
#   x0 = address of buffer (4 byte aligned)
#   x1 = size of buffer (multiple of 4 bytes)
# On exit:
#   x0 = first address after buffer
#   x1 = 0
#   x2 = 0x3f104000
#   x3 = last random word written to buffer
rand_block:
  and     x0, x0, #~0b11
  and     x1, x1, #~0b11
  mov     x2, #0x4000
  movk    x2, #0x3f10, lsl #16                    // x2 = 0x3f104000
  1:                                              // Loop until buffer filled
    2:                                            // Wait until ([0x3f104004] >> 24) >= 1
      ldr     w3, [x2, #0x04]                     // Since bits 24-31 tell us how many words
      lsr     w3, w3, #24                         // are available, this must be at least one.
      cbz     w3, 2b
    ldr     w3, [x2, #0x08]                       // w3 = [0x3f104008] (random data)
    str     w3, [x0], #0x04                       // Write to buffer.
    subs    x1, x1, #0x04
    cbnz    x1, 1b
  ret


print_string:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  1:
    ldrb    w0, [x2], #1
    cbz     w0, 2f
    bl      print_w0
    b       1b
2:
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


# Converts a uint64 value to ASCII decimal representation. The caller must
# provide a buffer of at least 21 bytes. The result will be written to the end of
# the buffer, including a trailing 0 byte. The start address will be returned.
#
# On entry:
#   x0 = address of 21 (or more) byte buffer to write to
#   x2 = value to convert to decimal
# On exit:
#   x0 = address of start of string within buffer
#   x1 = first byte of generated string
#   x2 = 0
#   x3 = 0xcccccccccccccccd
#   x4 = 0
base10:
  add     x0, x0, #0x14                           // x0 = address of last allocated byte
  strb    wzr, [x0]                               // Store 0 in last allocated byte
  mov     x3, #0xcccccccccccccccc
  add     x3, x3, #1                              // x3 = constant for divison by 10
  1:
    umulh   x4, x3, x2
    lsr     x4, x4, #3                            // x4 = x2 / 10
    add     x1, x4, x4, lsl #2                    // x1 = 5 * x4
    sub     x2, x2, x1, lsl #1                    // x2 = x2 % 10 = value of last digit
    add     x1, x2, #0x30                         // x1 = ASCII value of digit = x2 + 48
    strb    w1, [x0, #-1]!                        // store ASCII value on stack at correct offset
    mov     x2, x4                                // x2 = previous x2 / 10
    cbnz    x2, 1b                                // if x2 != 0 continue looping
3:
  ret



.align 3
fake_channel_block:
  .quad fake_printout


.align 3
fake_reg_update_channel_block:
  .quad fake_printout_touch_regs


.align 3
fake_printout:
  stp     x1, x2, [sp, #-16]!
  adr     x1, fake_print_buffer_location
  ldr     x2, [x1]
  strb    w0, [x2], #1
  str     x2, [x1]
  ldp     x1, x2, [sp], #0x10
  ret


fake_printout_touch_regs:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  bl      fake_printout
  mov     x0, #0x0a00
  mov     x1, #0x0a01
# mov     x2, #0x0a02                             // x2 must be preserved
# mov     x3, #0x0a03                             // x3 must be preserved
# mov     x4, #0x0a04                             // x4 must be preserved
# mov     x5, #0x0a05                             // x5 must be preserved
# mov     x6, #0x0a06                             // x6 must be preserved
  mov     x7, #0x0a07
  mov     x8, #0x0a08
  mov     x9, #0x0a09
  mov     x10, #0x0a0a
  mov     x11, #0x0a0b
  mov     x12, #0x0a0c
  mov     x13, #0x0a0d
  mov     x14, #0x0a0e
  mov     x15, #0x0a0f
  mov     x16, #0x0a10
  mov     x17, #0x0a11
  mov     x18, #0x0a12
  mov     x19, #0x0a13
  mov     x20, #0x0a14
  mov     x21, #0x0a15
  mov     x22, #0x0a16
  mov     x23, #0x0a17
  mov     x24, #0x0a18
  mov     x25, #0x0a19
  mov     x26, #0x0a1a
  mov     x27, #0x0a1b
# x28 must be preserved!!!
# mov     x28, #0x0a1c
  mov     x29, #0x0a1d
  mov     x30, #0x0a1e
  nzcv    #0b0101
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


.align 3
fake_print_buffer_location:
  .quad fake_print_buffer


##############################################################
#
# The following is intentionally in .text not .data so that
# adr instructions can be used rather than adrp/add to reduce
# code size. It may be that performance is better with a .data
# section in terms of cache utilisation due to the colocation
# of data, but I haven't tested. Could also be that it makes
# no difference if the caches are big enough
#
##############################################################

.align 0
msg_done:                      .asciz "DONE.\r\n"
msg_fail:                      .asciz "FAIL: "
msg_fail_0:                    .asciz "Register x"
msg_fail_1:                    .asciz " changed from "
msg_fail_2:                    .asciz " unchanged from "
msg_fail_3:                    .asciz " to "
msg_fail_4:                    .asciz ", but should have changed to "
# Intentionally .ascii not .asciz, in order to join with msg_fail_6.
msg_fail_5:                    .ascii ", but should not have changed"
msg_fail_6:                    .asciz ".\r\n"
msg_fail_7:                    .asciz "System Variable "
msg_fail_8:                    .asciz "Memory location ["
msg_filling_memory_with_junk:  .asciz "Filling memory with junk... "
msg_init_rand:                 .asciz "Initialising random number generator unit... "
msg_out_of_memory:             .asciz "Out of memory!\r\n"
# msg_rebooting:                 .asciz "Rebooting..."
msg_running_test_part_1:       .asciz "Running test "
msg_running_test_part_2:       .asciz "...\r\n"
msg_should_be_set:             .asciz " should be set.\r\n"
msg_should_not_be_set:         .asciz " should not be set.\r\n"
msg_all_tests_completed:       .asciz "All tests completed.\r\n"

flag_msg_offsets:
.byte msg_flag_n - .
.byte msg_flag_z - .
.byte msg_flag_c - .
.byte msg_flag_v - .
msg_flag_c:                    .asciz "Carry flag (C)"
msg_flag_n:                    .asciz "Negative flag (N)"
msg_flag_v:                    .asciz "Overflow flag (V)"
msg_flag_z:                    .asciz "Zero flag (Z)"

msg_nzcv:                      .asciz "NZCV: "


# Used by various unit tests....
test_message_table:
  .asciz "hello"
  .asciz "dog"
  .asciz "cat"
  .asciz "banana"
test_message_telephone:
  .asciz "telephone"
test_message_supper:
  .asciz "supper"


.bss

# Note, the start of this bss section is included in memory snapshots since
# snapshots are from 0 -> bss_debug_start, and bss_debug_start is declared
# further down in this file.

.align 0
fake_print_buffer:
  .space 1024

#########################################
# End of RAM snapshots
#########################################


.align 4
bss_debug_start:

.align 0
uart_disable: .space 1

.align 0
rand_seq_length: .space 1

.align 3
memory_dumps: .space MEMORY_DUMPS_BUFFER_SIZE

.align 4
rand_data: .space 0x100
