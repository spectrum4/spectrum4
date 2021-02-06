# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

.set MEMORY_DUMPS_BUFFER_SIZE, 0x01000000 // 16MB

.text
.align 2
run_tests:
  adr     x20, all_tests                  // x20 = address of test list
  ldr     x10, [x20], #8                  // x10 = number of tests
  cbz     x10, 11f                        // Return if no tests to run
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
// Stash framebuffer address, size and pitch on stack
# adr     x0, framebuffer
# ldp     w5, w6, [x0]
# stp     w5, w6, [sp, #-16]!
# ldr     w7, [x0, pitch-framebuffer]
# str     w7, [sp, #8]
// Replace framebuffer address, size and pitch with test framebuffer values
# adrp    x1, test_framebuffer
# add     x1, x1, :lo12:test_framebuffer
# mov     x2, #4*1920*1280
# stp     w1, w2, [x0]
# mov     w4, #4*1920
# str     w4, [x3]
// Create an initial snapshot for restoring state between tests
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
      ldp     x9, x17, [x23], #0x10           // x9 = setup address
                                              // x17 = setup_regs address
      adr     x0, msg_running_test_part_1
      bl      uart_puts                       // Log "Running test "
      add     x0, x23, #0x10                  // x0 = address of test case name
      bl      uart_puts                       // Log "<test case name>"
      adr     x0, msg_running_test_part_2
      bl      uart_puts                       // Log "...\r\n"

      mov     x0, #1
      adrp    x1, uart_disable
      add     x1, x1, :lo12:uart_disable
      strb    w0, [x1]                        // Disable UART output for test code

      cbz     x9, 3f                          // Skip RAM setup if there is none
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
      blr     x9                              // Setup RAM

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
      adr     x28, sysvars
      str     x28, [sp, #8 * 28]

      cbz     x30, 4f
      blr     x30                             // Call setup_regs routine
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
      mrs     x0, nzcv                        // Fetch flags (Negative, Zero, Carry, oVerflow)
      stp     x28, x0, [sp, #8 * 28]
      ldr     x0, [sp]

      ldr     x30, [sp, #0x130]               // x30 = address of routine to test
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
      mrs     x0, nzcv                        // Fetch flags (Negative, Zero, Carry, oVerflow)
      stp     x28, x0, [sp, #8 * 28]

      adrp    x1, uart_disable
      add     x1, x1, :lo12:uart_disable
      strb    wzr, [x1]                       // Enable UART output for test framework output

    // Restore stashed registers
      ldr     x2, [sp, #0x208]                // x2 = post-test snapshot location
      bl      snapshot_all_ram                // Snapshot post-test RAM
      ldr     x2, [sp, #0x200]                // x2 = pre-test snapshot location
      bl      restore_all_ram                 // Restore pre-test state
      ldr     x23, [sp, #0x228]               // x23 = pointer in test block
      ldp     x9, x17, [x23], #0x10           // x9 = effects address
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
      blr     x9                              // Setup RAM
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
      and     x1, x1, #0xF0000000            // Clear all bits of x1 except 28-31
      mrs     x0, nzcv                       // Get current flags
      and     x0, x0, #~0xF0000000           // Clear only bits 28-31 of x0
      orr     x0, x0, x1                     // Combine x0 and x1
      msr     nzcv, x0                       // Write result back to flags

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
      blr     x30                             // Set expected registers
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
      mrs     x0, nzcv                        // Fetch flags (Negative, Zero, Carry, oVerflow)
      stp     x28, x0, [sp, #8 * 28]

    // Restore stashed registers
      add     x24, sp, #0x300                 // x24 = address of this routine's stashed registers
      ldp     x21, x10, [x24, #16]            // Restore test block remaining test count, total remaining test count
      ldp     x19, x23, [x24, #32]            // Restore pointer in tests block, pointer in test block
      ldp     x22, x20, [x24, #48]            // Restore address of routine to test, pointer into all_tests

    // Compare registers
      mov     x8, sp
      mov     x9, #0                          // x9 = register index
      7:
        ldr     x12, [x8, #0x200]               // x12 = pre-test register value
        ldr     x13, [x8, #0x100]               // x13 = post-test register value
        ldr     x14, [x8], #0x08                // x14 = expected register value
        cmp     x13, x14
        b.eq    8f
        adr     x16, log_register               // x16 = function to log "Register x<index>"
        bl      test_fail
      8:
        add     x9, x9, #1
        cmp     x9, #29
        b.ne    7b

    // Compare flags
      adr     x6, flag_msg_offsets
      mov     w7, #0x80000000                 // Mask for bit 31
      ldr     w12, [x8, #0x200]               // w12 = pre-test NZCV
      ldr     w13, [x8, #0x100]               // w13 = post-test NZCV
      ldr     w14, [x8], #0x08                // w14 = expected NZCV
      eor     w9, w13, w14                    // w9 bits 28-31 hold 0 if expected == actual for counterpart NZCV flag, or 1 if not
      9:
        tst     w9, w7                          // Mask individual flag bit under test
        b.eq    10f                             // If flag was set correctly, jump ahead to 10:
      // Test fail - flag set incorrectly
        adr     x0, msg_fail
        bl      uart_puts                       // Log "FAIL: "
        add     x0, x23, #0x10                  // x0 = address of test case name
        bl      uart_puts                       // Log "<test case name>"
        mov     x0, ':'
        bl      uart_send                       // Log ":"
        mov     x0, ' '
        bl      uart_send                       // Log " "
        ldrb    w18, [x6]
        add     x0, x6, x18
        bl      uart_puts                       // Log "<flag description>"
        adr     x15, msg_should_be_set
        adr     x16, msg_should_not_be_set
        tst     w13, w7
        csel    x0, x15, x16, eq
        bl      uart_puts                       // Log " clear but should be set.\r\n" or "set but should be clear.\r\n"
      10:
        add     x6, x6, #1
        lsr     w7, w7, #1
        tbz     w7, #27, 9b

      ldp     x6, x7, [x24]                   // Restore pre-test snapshot location, post-test snapshot location
      mov     x8, #0                          // start address of region to snapshot
      adrp    x9, bss_debug_start
      add     x9, x9, :lo12:bss_debug_start   // first address not to snapshot
      bl      compare_snapshots
      adr     x8, framebuffer
      ldp     w8, w9, [x8]
      add     x9, x8, x9
      bl      compare_snapshots

    // Restore initial pristine snapshot
      adrp    x2, memory_dumps
      add     x2, x2, :lo12:memory_dumps      // x2 = target address for snapshot
      bl      restore_all_ram                 // Restore pre-test state

    // Restore stashed registers
      ldr     x6, [x24]                       // Restore pre-test snapshot location
      add     sp, sp, #0x330
      sub     x10, x10, #1                    // Decrement remaining test count
      subs    x21, x21, #1
      b.ne    2b                              // Loop if more tests to run

    add     sp, sp, #0x10
    cbnz    x10, 1b                         // Loop if more tests to run

  // Restore real framebuffer address, size, pitch
# adr     x0, framebuffer
# ldp     w5, w6, [sp]                    // Retrieve stacked framebuffer address and size
# stp     w5, w6, [x0]                    // Restore framebuffer address, size
# ldr     w7, [sp, #8]                    // Retrieve stacked pitch
# str     w7, [x0, pitch-framebuffer]     // Restore pitch
# add     sp, sp, #16                     // Keep stack pointer 16-byte aligned
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
11:
  ret


# On entry:
#   x8 = Memory location
log_ram:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  adr     x0, msg_fail_8
  bl      uart_puts                       // Log "Memory location [0x"
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
  bl      uart_puts                       // Log "System Variable "
  add     x0, x6, #9                      // x0 = address of system variable name
  bl      uart_puts                       // Log "<sysvar>"
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret


# On entry:
#   x9 = x register index (0-30)
log_register:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  adr     x0, msg_fail_0
  bl      uart_puts                       // Log "Register x"
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
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  adr     x0, msg_fail
  bl      uart_puts                       // Log "FAIL: "
  add     x0, x23, #0x10                  // x0 = address of test case name
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
# On exit:
#   x0 = address of msg_done
#   x1 = AUX_BASE
#   x2 = end address of used compressed data (exclusive) -> 8 byte aligned
#   x3 = [AUX_MU_LSR]
#   x4 = [x1 - 16]
#   x5 = [x1 - 8]
#   x26 = end address of used compressed data (exclusive) -> 8 byte aligned
#   x27 = 0x6a09e667bb67ae85
snapshot_all_ram:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  mov     x26, x2
# adr     x0, msg_snapshotting_ram
# bl      uart_puts
  mov     x0, #0                          // start address of region to snapshot
  adrp    x1, bss_debug_start
  add     x1, x1, :lo12:bss_debug_start   // first address not to snapshot
  mov     x2, x26
  mov     x3, MEMORY_DUMPS_BUFFER_SIZE
  add     x3, x1, x3                      // first address after end of compressed data region
  bl      snapshot_memory                 // x2 = first address after end of snapshot
# mov     x26, x2
# adr     x0, msg_done
# bl      uart_puts
# mov     x2, x26
  adr     x0, framebuffer
  ldp     w0, w1, [x0]
  add     x1, x0, x1
  bl      snapshot_memory                 // x2 = first address after end of snapshot
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
#  x7 = first address after random block
#  x8 = address in random block
#  x11 = rand_data
#  x26 = repeat count of last quad (excluding original entry, i.e. n-1 where n = length of repeated sequence)
#  x27 = 0x6a09e667bb67ae85 (reserved code to denote that a count and repeated value follow)
snapshot_memory:
  adrp    x7, rand_seq_length
  add     x7, x7, :lo12:rand_seq_length
  ldrb    w4, [x7]                        // w4 = random block length
  adrp    x11, rand_data
  add     x11, x11, :lo12:rand_data       // x11 = address of random data
  udiv    x8, x0, x4                      // x8 = int(start_address_decompressed/x4)
  umsubl  x8, w8, w4, x0                  // x8 = x0 - x4 * int(x0/x4) = start_address_decompressed % random_sequence_length
  add     x8, x8, x11                     // x8 = address inside random block that holds quad for masking start address
  add     x7, x4, x11                     // x7 = first address after random block
  mov     x26, #0                         // Set quad repeat counter to zero
  ldr     x27, =0x6a09e667bb67ae85
  ldr     x4, [x0], #8
  ldr     x12, [x8], #8
  cmp     x8, x7
  csel    x8, x8, x11, ne
  eor     x4, x4, x12
  1:
    ldr     x5, [x0], #8                    // Get next value.
    ldr     x12, [x8], #8
    cmp     x8, x7
    csel    x8, x8, x11, ne
    eor     x5, x5, x12
    cmp     x4, x5                          // Is new value different to previous one?
    b.ne    2f                              // If so, jump ahead to 2:.
  // new quad value matches previous quad value
    add     x26, x26, #1                    // Bump counter
    b       5f
  2:
  // new value found
    cbnz    x26, 3f                         // If reached end of repeating quad sequence, jump ahead to 3:.
  // previous value wasn't a repeating one
    cmp     x4, x27                         // Was the raw value (coincidentally) the reserved repeating value code?
    b.ne    4f                              // If not, jump ahead to store in raw form
  // escape the magic value as a "repeated 0 times" repeated quad value
  3:
  // recurring quad sequence completed
    add     x2, x2, #16
    cmp     x2, x3
    b.hs    6f
    stp     x27, x26, [x2, #-16]            // Store "repeated value magic value", number of repeats (excluding original)
    mov     x26, #0                         // Reset repeated entries counter
  4:
    add     x2, x2, #8
    cmp     x2, x3
    b.hs    6f
    stur    x4, [x2, #-8]                   // Store value
  5:
    mov     x4, x5
    cmp     x0, x1                          // Reached end of memory to snapshot?
    b.ne    1b                              // Repeat loop if end of region to compress not reached
  add     x2, x2, #24
  cmp     x2, x3
  b.hs    6f
  stp     x27, x26, [x2, #-24]            // Store "repeated value magic value", number of repeats (excluding original)
  str     x5, [x2, #-8]                   // Store value
  ret
6:
  adr     x0, msg_out_of_memory
  bl      uart_puts
  b       sleep


# On entry:
#   x2 = location of snapshot
restore_all_ram:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  mov     x0, #0                          // start address to restore snapshot to
  adrp    x1, bss_debug_start
  add     x1, x1, :lo12:bss_debug_start   // first address not to restore
  bl      restore_snapshot
  adr     x0, framebuffer
  ldp     w0, w1, [x0]
  add     x1, x0, x1
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
#   x27 = 0x6a09e667bb67ae85
#  TODO: update reg list
restore_snapshot:
  adrp    x7, rand_seq_length
  add     x7, x7, :lo12:rand_seq_length
  ldrb    w4, [x7]                        // w4 = random block length
  adrp    x11, rand_data
  add     x11, x11, :lo12:rand_data       // x11 = address of random data
  udiv    x8, x0, x4                      // x8 = int(start_address_decompressed/x4)
  umsubl  x8, w8, w4, x0                  // x8 = x0 - x4 * int(x0/x4) = start_address_decompressed % random_sequence_length
  add     x8, x8, x11                     // x8 = address inside random block that holds quad for masking start address
  add     x7, x4, x11                     // x7 = first address after random block
  ldr     x27, =0x6a09e667bb67ae85
  1:
    ldr     x4, [x2], #8
    cmp     x4, x27
    b.ne    3f
  // repeated value found
    ldp     x5, x4, [x2], #16               // x5 = repeat count (1 less than total entries), x4 = value
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
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  adrp    x26, rand_seq_length
  add     x26, x26, :lo12:rand_seq_length
  ldrb    w4, [x26]                        // w4 = random block length
  adrp    x11, rand_data
  add     x11, x11, :lo12:rand_data       // x11 = address of random data
  udiv    x25, x8, x4                     // x25 = int(start_address_decompressed/x4)
  umsubl  x25, w25, w4, x8                // x25 = x8 - x4 * int(x8/x4) = start_address_decompressed % random_sequence_length
  add     x25, x25, x11                   // x25 = address inside random block that holds quad for masking start address
  add     x26, x4, x11                     // x26 = first address after random block
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
    b       3f                              // x4 already set from previous iteration, so jump ahead
  2:
    ldr     x4, [x6], #8                   // Read a new value
    cmp     x4, x15                        // Is it the repeat marker?
    b.ne    3f                              // If not, it is a regular value, jump ahead to 3:
  // repeated value found
    ldp     x17, x4, [x6], #16             // x17 = repeat count (1 less than total entries), x4 = value
  3:
  // x17 and x4 correctly set now
    cbz     x18, 4f                         // If not still repeating previous pre-test value, jump ahead to 4:
    sub     x18, x18, #1                    // Decrement counter
    b       5f                              // x5 already set from previous iteration, so jump ahead
  4:
    ldr     x5, [x7], #8                   // Read a new value
    cmp     x5, x15                        // Is it the repeat marker?
    b.ne    5f                              // If not, it is a regular value, jump ahead to 5:
  // repeated value found
    ldp     x18, x5, [x7], #16             // x18 = repeat count (1 less than total entries), x5 = value
  5:
  // x18 and x5 correctly set now
    ldr     x14, [x8]
    ldr     x22, [x25]
    eor     x12, x22, x4
    eor     x13, x22, x5
    cmp     x13, x14
    b.eq    6f
    adr     x16, log_ram                    // x16 = function to log "Memory location [0x<address>]"
    bl      test_fail
  6:
    add     x8, x8, #8
    add     x25, x25, #8
    cmp     x25, x26
    csel    x25, x25, x11, ne
    cmp     x8, x9
    b.ne    1b
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret


# Fill with repeating sequence of random data, with random length one of
# 0x40/0x50/0x60/0x70/0x80/0x90/0xa0/0xb0.
fill_memory_with_junk:
  mov     x11, x30
  adr     x0, msg_filling_memory_with_junk
  bl      uart_puts
// Choose random sequence length
  bl      rand_x0                         // Fetch random bits in x0
  and     w1, w0, #0x00000070             // 0x00/0x10/0x20/0x30/0x40/0x50/0x60/0x70
  add     w1, w1, #0x00000040             // 0x40/0x50/0x60/0x70/0x80/0x90/0xa0/0xb0
  adrp    x7, rand_seq_length
  add     x7, x7, :lo12:rand_seq_length
  strb    w1, [x7]
// Generate random sequence
  adrp    x5, rand_data
  add     x5, x5, :lo12:rand_data
  mov     x0, x5
  mov     x4, x1                          // Preserve sequence byte length in x4
  bl      rand_block
// First random block: __bss_start -> bss_debug_start
  adr     x8, __bss_start
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
  udiv    x9, x8, x4                      // x9 = int(__bss_start/x4)
  umsubl  x10, w9, w4, x8                 // x10 = x8 - x4 * int(x8/x4) = __bss_start % (random sequence length)
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
  mov     w0, #0x00100000                 // "warmup count": the initial numbers generated are "less random" so will be discarded
  str     w0, [x1, #0x04]                 // [0x3f104004] = 0x00040000
  ldr     w0, [x1, #0x10]
  orr     w0, w0, #0x01
  str     w0, [x1, #0x10]                 // Set bit 0 of [0x3f104010]  (mask the interrupt)
  ldr     w0, [x1]
  orr     w0, w0, #0x01
  str     w0, [x1]                        // Set bit 0 of [0x3f104000]  (enable the hardware generator)
  adr     x0, msg_done
  bl      uart_puts
  mov     x30, x5
  ret


rand_x0:
  mov     x1, #0x4000
  movk    x1, #0x3f10, lsl #16            // x1 = 0x3f104000
  1:                                      // Wait until ([0x3f104004] >> 24) >= 2
    ldr     w0, [x1, #0x04]                 // Since bits 24-31 tell us how many words
    lsr     w0, w0, #25                     // are available, this must be at least one,
    cbz     w0, 1b                          // before we can safely read two words.
  ldr     w0, [x1, #0x08]                 // w0 = [0x3f104008] (random data)
  ldr     w2, [x1, #0x08]                 // w2 = [0x3f104008] (random data)
  bfi     x0, x2, #32, #32                // Copy bits from w2 into high bits of x0.
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
  movk    x2, #0x3f10, lsl #16            // x2 = 0x3f104000
  1:                                      // Loop until buffer filled
    2:                                      // Wait until ([0x3f104004] >> 24) >= 1
      ldr     w3, [x2, #0x04]                 // Since bits 24-31 tell us how many words
      lsr     w3, w3, #24                     // are available, this must be at least one.
      cbz     w3, 2b
    ldr     w3, [x2, #0x08]                 // w3 = [0x3f104008] (random data)
    str     w3, [x0], #0x04                 // Write to buffer.
    subs    x1, x1, #0x04
    cbnz    x1, 1b
  ret


display_sysvars:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  stp     x19, x23, [sp, #-16]!           // callee-saved registers used later on.
  stp     x20, x21, [sp, #-16]!           // callee-saved registers used later on.
  adr     x0, msg_title_sysvars
  bl      uart_puts
  adr     x19, sysvars_meta               // x0 = address of sysvars metadata table
  mov     w23, SYSVAR_COUNT               // x23 = number of system variables to log
  1:
    ldr     x20, [x19], #8                  // x20 = sysvar_meta entry
    bl      display_sysvar
    bl      uart_newline
    sub     w23, w23, #1
    cbnz    w23, 1b
  bl      uart_newline
  ldp     x20, x21, [sp], #16             // Pop callee-saved registers.
  ldp     x19, x23, [sp], #16             // Pop callee-saved registers.
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret


# On entry:
#   x20: address of sysvar metadata (sysvar_XXXXXX)
# On exit:
#   x0 =
#     1 byte sysvar: stack pointer - 61
#     2 byte sysvar: stack pointer - 59
#     4 byte sysvar: stack pointer - 55
#     8 byte sysvar: stack pointer - 47
#         otherwise: stack pointer - 60
#   x1 = AUX_BASE
#   x2 = 0
#   x3 = [AUX_MU_LSR] = 0x61
#   x4 =
#     1/2/4/8 byte sysvar: sysvar value
#               otherwise: unchanged
#   NZCV =
#     1/2/4/8 byte sysvar: 0b1000
#               otherwise: 0b0110
display_sysvar:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  stp     x21, x24, [sp, #-16]!           // callee-saved registers used later on.
  sub     sp, sp, #32                     // 32 bytes buffer for storing hex representation of sysvar (maximum is 16 chars + trailing 0, so 17 bytes)
  mov     x0, '['
  bl      uart_send                       // Print "["
  ldr     x0, [x20]                       // x0 = address offset of sys var
  add     x0, x0, x28
  bl      uart_x0                         // Print "<sys var address>"
  mov     x0, ']'
  bl      uart_send                       // Print "]"
  mov     x0, ' '
  bl      uart_send                       // Print " "
  add     x0, x20, #9
  bl      uart_puts                       // Print system variable name
  ldrb    w21, [x20, #8]                  // w21 = size of sysvar data in bytes
  ldr     x24, [x20]                      // x24 = address offset of sys var
  cmp     w21, #1
  b.eq    3f
  cmp     w21, #2
  b.eq    4f
  cmp     w21, #4
  b.eq    5f
  cmp     w21, #8
  b.eq    6f
  // not 2/4/8 bytes => print one byte at a time
  mov     x0, ':'
  bl      uart_send
  mov     x0, ' '
  bl      uart_send
  add     x24, x24, x28
  2:
    ldrb    w0, [x24], #1
    mov     x1, sp
    mov     x2, #8
    bl      hex_x0
    mov     w0, #0x0020
    strh    w0, [x1], #2                    // Add a space and trailing zero.
    mov     x0, sp
    bl      uart_puts
    subs    w21, w21, #1
    b.ne    2b
  b       8f
3:
  // 1 byte
  ldrb    w4, [x28, x24]
  b       7f
4:
  // 2 bytes
  ldrh    w4, [x28, x24]
  b       7f
5:
  // 4 bytes
  ldr     w4, [x28, x24]
  b       7f
6:
  // 8 bytes
  ldr     x4, [x28, x24]
7:
  adr     x0, msg_colon0x
  bl      uart_puts                       // Print ": 0x"
  mov     x0, x4
  mov     x1, sp
  mov     x2, x21, lsl #3                 // x2 = size of sysvar data in bits
  bl      hex_x0
  strb    wzr, [x1]                       // Add a trailing zero.
  mov     x0, sp
  bl      uart_puts
8:
  add     sp, sp, #32                     // Free buffer.
  ldp     x21, x24, [sp], #16             // Pop callee-saved registers.
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret


display_zx_screen:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  adr     x9, ZX_SCREEN
  adr     x0, display_file
1:
  ldrb    w1, [x9], #1
  stp     x0, x9, [sp, #-16]!
  bl      poke_address
  ldp     x0, x9, [sp], #16
  add     x0, x0, #1
  adr     x2, attributes_file_end
  cmp     x0, x2
  b.ne    1b
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret


# On entry:
#   x0 = start address
#   x1 = number of rows to print
#   x2 = screen line to start at
display_memory:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!           // Store old x19, x20 on the the stack.
  stp     x21, x22, [sp, #-16]!           // Store old x21, x22 on the the stack.
  stp     x23, x24, [sp, #-16]!           // Store old x23, x24 on the the stack.
  sub     sp, sp, #112                    // 112 bytes for screen line buffer
  mov     x19, x0                         // x19 = start address
  mov     x20, x1                         // x20 = number of rows to print
  mov     x21, x2                         // x21 = screen line to start at
  mov     w23, #0x2020                    // two spaces ('  ')
  adr     x0, msg_hex_header              // Pointer to string
  mov     w1, #0                          // x coordinate
  mov     w3, #0x00ffffff                 // white ink
  mov     w4, #0x000000cc                 // (dark) blue paper
  bl      paint_string                    // paint hex header line
  add     x21, x21, #1                    // x21 = first data line screen line
1:
  mov     x1, sp                          // address to write text string to
  strh    w23, [x1], #2                   // write '  ' to screen line buffer on stack
  mov     x0, x19                         // x0 = dump address
  mov     x2, #32
  bl      hex_x0                          // append to screen line buffer and update x1
  mov     x22, #0x20                      // 32 values to print
2:
  strb    w23, [x1], #1                   // write ' ' to screen line buffer
  ldrb    w0, [x19], #1                   // w0 = data at address, bump address x19
  mov     x2, #8
  bl      hex_x0
  subs    x22, x22, #1
  b.ne    2b
  strh    w23, [x1], #2                   // write '  ' to screen line buffer
  strb    wzr, [x1], #1                   // append 0 byte to terminate string
  mov     x0, sp
  mov     w1, #0                          // x = 0
  mov     x2, x21                         // y = line number
  mov     w3, #0x00ffffff                 // white ink
  mov     w4, #0x000000cc                 // (dark) blue paper
  bl      paint_string                    // paint string
  add     x21, x21, #1                    // increase line number
  subs    x20, x20, #1
  b.ne    1b                              // if not, process next line
  add     sp, sp, #112                    // Free screen line buffer
  ldp     x23, x24, [sp], #0x10           // Restore old x23, x24.
  ldp     x21, x22, [sp], #0x10           // Restore old x21, x22.
  ldp     x19, x20, [sp], #0x10           // Restore old x19, x20.
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret


# On entry:
#   x0 = hex value to convert to text
#   x1 = address to write text to (no trailing 0)
#   x2 = number of bits to print (multiple of 4)
# On exit:
#   x1 = address of next unused char (x1 += x2/4)
hex_x0:
  ror     x0, x0, x2
1:
  ror     x0, x0, #60
  and     w3, w0, #0x0f
  add     w3, w3, 0x30
  cmp     w3, 0x3a
  b.lo    2f
  add     w3, w3, 0x27
2:
  strb    w3, [x1], #1
  subs    w2, w2, #4
  b.ne    1b
  ret


demo:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  bl      paint_copyright                 // Paint the copyright text ((C) 1982 Amstrad....)
  mov     w0, 0x20000000
  bl      wait_cycles
  bl      display_zx_screen
  mov     w0, 0x10000000
  bl      wait_cycles
  mov     x0, #60
  bl      cls
  mov     x0, sp
  mov     x1, #1
  mov     x2, #0
  bl      display_memory
  adr     x0, mbreq
  mov     x1, #5
  mov     x2, #3
  bl      display_memory
  adr     x0, sysvars
  mov     x1, #10
  mov     x2, #10
  bl      display_memory
  adrp    x0, heap
  add     x0, x0, #:lo12:heap             // x0 = heap
  sub     x0, x0, #0x60
  mov     x1, #8
  mov     x2, #22
  bl      display_memory
  adr     x0, STRMS
  mov     x1, #2
  mov     x2, #32
  bl      display_memory
  ldr     x0, [x28, CHANS-sysvars]
  mov     x1, #2
  mov     x2, #36
  bl      display_memory
  bl      display_sysvars
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret


# ------------------------------------------------------------------------------
# Send '\r\n' over Mini UART
# ------------------------------------------------------------------------------
uart_newline:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  mov     x0, #13
  bl      uart_send
  mov     x0, #10
  bl      uart_send
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret


# ------------------------------------------------------------------------------
# Send a null terminated string over Mini UART.
# ------------------------------------------------------------------------------
#
# On entry:
#   x0 = address of null terminated string
# On exit:
#   x0 = address of null terminator
#   x1 = AUX_BASE
#   x2 = 0
#   x3 = [AUX_MU_LSR]
uart_puts:
  mov     x1, AUX_BASE & 0xffff0000
  movk    x1, AUX_BASE & 0x0000ffff       // x1 = 0x3f215000 = AUX_BASE
1:
  ldrb    w2, [x0], #1
  cbz     w2, 5f
  cmp     w2, #127
  b.ne    4f
  mov     w2, '('
2:
  ldr     w3, [x1, AUX_MU_LSR]            // w3 = [AUX_MU_LSR_REG]
  tbz     x3, #5, 2b                      // Repeat last statement until bit 5 is set.

/////////////////////
// This following section allows us to disable UART output during testing but
// setting the one byte test system variable 'uart_disable' to a non zero value
// without affecting any register values so to not impact tests.
.if       DEBUG_PROFILE
  adrp    x1, uart_disable
  add     x1, x1, :lo12:uart_disable
  ldrb    w1, [x1]
  cbnz    x1, uart_puts
  mov     x1, AUX_BASE & 0xffff0000
  movk    x1, AUX_BASE & 0x0000ffff       // x1 = 0x3f215000 = AUX_BASE
.endif
/////////////////////

  strb    w2, [x1, AUX_MU_IO_REG]         //   [AUX_MU_IO_REG] = w2
  mov     w2, 'c'
3:
  ldr     w3, [x1, AUX_MU_LSR]            // w3 = [AUX_MU_LSR_REG]
  tbz     x3, #5, 3b                      // Repeat last statement until bit 5 is set.
  strb    w2, [x1, AUX_MU_IO_REG]         //   [AUX_MU_IO_REG] = w2
  mov     w2, ')'
4:
  ldr     w3, [x1, AUX_MU_LSR]            // w3 = [AUX_MU_LSR_REG]
  tbz     x3, #5, 4b                      // Repeat last statement until bit 5 is set.

/////////////////////
// This following section allows us to disable UART output during testing but
// setting the one byte test system variable 'uart_disable' to a non zero value
// without affecting any register values so to not impact tests.
.if       DEBUG_PROFILE
  adrp    x1, uart_disable
  add     x1, x1, :lo12:uart_disable
  ldrb    w1, [x1]
  cbnz    x1, uart_puts
  mov     x1, AUX_BASE & 0xffff0000
  movk    x1, AUX_BASE & 0x0000ffff       // x1 = 0x3f215000 = AUX_BASE
.endif
/////////////////////

  strb    w2, [x1, AUX_MU_IO_REG]         //   [AUX_MU_IO_REG] = w2
  b       1b
5:
  ret


# ------------------------------------------------------------------------------
# Write the value of x0 as a hex string (0x0123456789abcdef) to Mini UART.
# ------------------------------------------------------------------------------
#
# On entry:
#   x0 = value to write as a hex string to Mini UART.
uart_x0:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!           // Backup x19, x20
  mov     x19, x0                         // Backup x0 in x19
  sub     sp, sp, #0x20                   // Allocate space on stack for hex string
  mov     w2, 0x7830
  mov     x1, sp
  mov     x1, sp
  strh    w2, [x1], #2                    // "0x"
  mov     x2, 64
  bl      hex_x0
  strb    wzr, [x1], #1
  mov     x0, sp
  bl      uart_puts
  add     sp, sp, #0x20
  mov     x0, x19                         // Restore x0
  ldp     x19, x20, [sp], #16             // Restore x19, x20
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret


# paint_string paints the zero byte delimited text string pointed to by x0 to the screen in the
# system font (16x16 pixels) at the screen print coordinates given by w1, w2. The ink colour is
# taken from w3 and paper colour from w4.
#
# On entry:
#   x0 = pointer to string
#   w1 = x
#   w2 = y
#   w3 = ink colour
#   w4 = paper colour
paint_string:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  stp     x0, x1, [sp, #-16]!
  stp     x2, x3, [sp, #-16]!
  str     x4, [sp, #-16]!
  bl      uart_puts
  bl      uart_newline
  ldr     x4, [sp], #0x10
  ldp     x2, x3, [sp], #0x10
  ldp     x0, x1, [sp], #0x10
  adr     x9, mbreq                       // x9 = address of mailbox request.
  ldr     w10, [x9, framebuffer-mbreq]    // w10 = address of framebuffer
  ldr     w9, [x9, pitch-mbreq]           // w9 = pitch
  adr     x11, chars-32*32                // x11 = theoretical start of character table for char 0
  1:
    ldrb    w12, [x0], 1                    // w12 = char from string, and update x0 to next char
    cbz     w12, 4f                         // if found end marker, jump to end of function and return
    add     x13, x11, x12, lsl #5           // x13 = address of character bitmap
    mov     w14, BORDER_TOP                 // w14 = BORDER_TOP
    add     w14, w14, w2, lsl #4            // w14 = BORDER_TOP + y * 16
    mov     w15, BORDER_LEFT                // w15 = BORDER_LEFT
    add     w15, w15, w1, lsl #4            // w15 = BORDER_LEFT + x * 16
    add     w15, w10, w15, lsl #2           // w15 = address of framebuffer + 4* (BORDER_LEFT + x * 16)
    umaddl  x14, w9, w14, x15               // w14 = pitch*(BORDER_TOP + y * 16) + address of framebuffer + 4 * (BORDER_LEFT + x*16)
    mov     w15, 16                         // w15 = y counter
    2:                                      // Paint char
      mov     w16, w14                        // w16 = leftmost pixel of current row address
      mov     w12, 1 << 15                    // w12 = mask for current pixel
      ldrh    w17, [x13], 2                   // w17 = bitmap for current row, and update x13 to next bitmap pattern
      3:                                      // Paint a horizontal row of pixels of character
        tst     w17, w12                        // apply pixel mask
        csel    w18, w3, w4, ne                 // if pixel set, colour w3 (ink colour) else colour w4 (paper colour)
        str     w18, [x14], 4                   // Colour current point, and update x14 to next point.
        lsr     w12, w12, 1                     // Shift bit mask to next pixel
        cbnz    w12, 3b
      add     w14, w16, w9                    // x14 = start of current line + pitch = start of new line.
      subs    w15, w15, 1                     // Decrease vertical pixel counter.
      b.ne    2b
    add     w1, w1, 1                       // Increment w1 (x print position) so that the next char starts to the right of the current char.
    b       1b                              // Repeat outer loop.
4:
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret


paint_copyright:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  adr     x0, msg_copyright               // x0 = location of system copyright message.
  mov     w1, 38                          // Print at x=38.
  mov     w2, 40                          // Print at y=40.
  movl    w3, INK_COLOUR                  // Ink colour is default system ink colour.
  movl    w4, PAPER_COLOUR                // Paper colour is default system paper colour.
  bl      paint_string                    // Paint the copyright string to screen.
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
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
  add     x0, x0, #0x14                   // x0 = address of last allocated byte
  strb    wzr, [x0]                       // Store 0 in last allocated byte
  mov     x3, #0xcccccccccccccccc
  add     x3, x3, #1                      // x3 = constant for divison by 10
  1:
    umulh   x4, x3, x2
    lsr     x4, x4, #3                      // x4 = x2 / 10
    add     x1, x4, x4, lsl #2              // x1 = 5 * x4
    sub     x2, x2, x1, lsl #1              // x2 = x2 % 10 = value of last digit
    add     x1, x2, #0x30                   // x1 = ASCII value of digit = x2 + 48
    strb    w1, [x0, #-1]!                  // store ASCII value on stack at correct offset
    mov     x2, x4                          // x2 = previous x2 / 10
    cbnz    x2, 1b                          // if x2 != 0 continue looping
3:
  ret


.data

.align 0
msg_colon0x:                   .asciz ": 0x"
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
msg_hex_header:                .asciz "           00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f 10 11 12 13 14 15 16 17 18 19 1a 1b 1c 1d 1e 1f  "
msg_init_rand:                 .asciz "Initialising random number generator unit... "
msg_out_of_memory:             .asciz "Out of memory!\r\n"
msg_rebooting:                 .asciz "Rebooting..."
msg_running_test_part_1:       .asciz "Running test "
msg_running_test_part_2:       .asciz "...\r\n"
msg_should_be_set:             .asciz " should be set.\r\n"
msg_should_not_be_set:         .asciz " should not be set.\r\n"
msg_snapshotting_ram:          .asciz "Snapshotting RAM... "
msg_title_sysvars:             .asciz "System Variables\r\n================\r\n"

flag_msg_offsets:
.byte msg_flag_n - .
.byte msg_flag_z - .
.byte msg_flag_c - .
.byte msg_flag_v - .
msg_flag_c:                    .asciz "Carry flag (C)"
msg_flag_n:                    .asciz "Negative flag (N)"
msg_flag_v:                    .asciz "Overflow flag (V)"
msg_flag_z:                    .asciz "Zero flag (Z)"



.include "tests.s"                      //  Include tests.s before "bss_debug_start"
.bss
# .align 12
# test_framebuffer: .space 4 * 1920 * 1280

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


# Include generated code...
.include "sysvars.s"
.include "screen.s"
