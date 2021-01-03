# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.


.set MEMORY_DUMP_BUFFER_SIZE, 0x01000000  // 16MB

.text
.align 2


run_tests:

# Register usage
# ==============
# x0-3 scratch registers
# x5   sysvars_meta
# x6   sysvar meta entry
# x7   sysvar setup mask / ram setup entry type
# x8   sysvar pointer mask
# x9   sysvar index / ram entry index
# x10  number of remaining tests
# x11  address of test definition
# x12  sysvar address
# x13  address of individual sysvar definition / address of RAM setup entry
# x14  sysvar value / ram setup value
# x15  number of RAM setup entries
# x16  function pointer for logging name of value being tested
# x17  sysvars/ram/registers setup/effects block
# x18  address on stack to set/test value
# x19  start of sysvar expected values after mask entries
# x20  address inside all_tests

# Stack organisation
# ==================
#
# RAM entries
#   sp:
#     post-test entries                     // (8 * RAM entries) bytes
#   sp+8*x15:
#     pre-test entries                      // (8 * RAM entries) bytes
#
# System variables
#   x29-512-2*(sysvars_end-sysvars) == sp+16*x15:
#     pre-test entries                      // (sysvars_end - sysvars) bytes
#   x29-512-(sysvars_end-sysvars) == sp+16*x15+(sysvars_end-sysvars):
#     post-test entries                     // (sysvars_end - sysvars) bytes
#
# Registers
#   x29-512:
#     pre-test entries                      // 256 bytes
#   x29-256:
#     post-test entries                     // 256 bytes
#
# x29:
#
#   Frame pointer                           // 8 bytes
#   Link Register                           // 8 bytes

  ldr     w0, arm_size
  and     sp, x0, #~0x0f                  // Set stack pointer at top of ARM memory
  adr     x20, all_tests                  // x20 = address of test list
  ldr     x10, [x20], #8                  // x10 = number of tests
  cbz     x10, 36f                        // Return if no tests to run
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.

#  x0 = start address to compress (inclusive) -> 8 byte aligned
#  x1 = end address to compress (exclusive) -> 8 byte aligned, at least 16 more than x0
#  x2 = start address of compressed data buffer (inclusive) -> 8 byte aligned
#  x3 = end address of compressed data buffer (inclusive) -> 8 byte aligned

  adrp    x0, pre_test_memory_dump
  add     x0, x0, :lo12:pre_test_memory_dump
  bl      uart_x0
  bl      uart_newline
  mov     x0, #0
  adrp    x1, pre_test_memory_dump
  add     x1, x1, :lo12:pre_test_memory_dump
  mov     x2, x1
  mov     x3, MEMORY_DUMP_BUFFER_SIZE
  add     x3, x2, x3
  bl      snapshot_memory
  mov     x0, x2
  bl      uart_x0
  bl      uart_newline

  sub     sp, sp, (sysvars_end - sysvars)*2 + 256*2
                                          // Allocate space on stack for pre-test/post-test registers and system variables
  1:                                      // Loop executing tests
    adr     x5, sysvars_meta
    ldr     x11, [x20], #8                  // x11 = address of test definition

  // Log test running

    adr     x0, msg_running_test_part_1
    bl      uart_puts                       // Log "Running test "
    ldr     x0, [x11]                       // x0 = address of test name
    bl      uart_puts                       // Log "<test case name>"
    adr     x0, msg_running_test_part_2
    bl      uart_puts                       // Log "...\r\n"

  // RAM setup

    ldr     x17, [x11, #8]                  // x17 = RAM setup block
    ldr     x15, [x17], #8                  // x15 = number of RAM setup entries
    cbz     x15, 4f
    sub     sp, sp, x15, lsl #4             // Allocate 16 bytes per RAM setup entry on stack
    mov     x9, #0                          // x9 = RAM setup index
    2:
      ldr     x13, [x17], #8                  // x13 = RAM entry setup block
      ldr     x7, [x13], #8                   // x7 = RAM entry type (1=byte, 2=halfword, 4=word, 8=quad, 16=pointer)
      ldr     x14, [x13], #8                  // x14 = RAM entry index value
      add     x18, sp, x9, lsl #3             // x18 = target address to be updated on stack
      tbz     w7, #4, 3f
      // pointer
      add     x14, sp, x14, lsl #3            // x14 = pointer value
    3:
      str     x14, [x18]                      // set RAM literal value
      str     x14, [x18, x15, lsl #3]         // set RAM literal value copy
      add     x9, x9, #1                      // increase RAM setup index counter
      cmp     x15, x9
      b.ne    2b

  // System variable setup

  4:
    mov     x0, x28
    mov     x1, (sysvars_end - sysvars)
    bl      rand_block                      // Set sysvars to random values
    ldr     x17, [x11, #16]                 // x17 = sysvars setup block
    mov     x9, #0                          // x9 = sysvar index
    add     x13, x17, SYSVAR_MASK_BYTES     // x13 = address of first sysvar definition
    5:
      tst     x9, #0x1f                       // lower 5 bits of x9 are 0 when we need to read next quad mask
      b.ne    6f
      ldr     x7, [x17], #8                   // x7 = sysvar setup mask
    6:
      tbz     x7, #0, 11f                     // if sysvar not defined, skip setting it and leave random value in place
    // sysvar defined, replace random value
      ldr     x14, [x13], #8                  // x14 = value (pointer or literal value)
      ldr     x6, [x5, x9, lsl #3]            // x6 = sysvar meta entry
      ldr     x18, [x6]                       // x18 = sysvar address offset
      tbz     x7, #1, 7f
    // pointer
      add     x12, sp, x14, lsl #3            // x12 = pointer value
      str     x12, [x28, x18]
      b       11f
    7:
      ldrb    w0, [x6, #8]                    // w0 = sysvar size (in bytes)
      tbnz    w0, #1, 8f
      tbnz    w0, #2, 9f
      tbnz    w0, #3, 10f
    // 1 byte
      strb    w14, [x28, x18]
      b       11f
    8:
    // 2 bytes
      strh    w14, [x28, x18]
      b       11f
    9:
    // 4 bytes
      str     w14, [x28, x18]
      b       11f
    10:
    // 8 bytes
      str     x14, [x28, x18]
    11:
      add     x9, x9, #1                      // Increment sysvar index
      lsr     x7, x7, #2                      // Shift sysvar mask 2 bits right
      cmp     x9, SYSVAR_COUNT
      b.ne    5b

  // Copy sysvars to stack

    mov     x0, x28
    mov     x1, (sysvars_end - sysvars)
    add     x9, sp, x15, lsl #4
    12:
      ldp     x2, x3, [x0], #0x10
      stp     x2, x3, [x9], #0x10
      subs    x1, x1, #0x10
      b.ne    12b

  // Set up registers

    add     x0, x9, (sysvars_end - sysvars) // x0 = start of pre-test register block
    mov     x1, #0x100                      // Register storage on stack takes up 256 bytes.
    bl      rand_block                      // Write random bytes to stack so registers are random when popped.
    sub     x0, x0, #0x100                  // rand_block just added 0x100 to x0, so subtract it again.
    str     x28, [x0, 28*8]                 // x28 is exceptional: has constant value; replace random value.
    ldr     x17, [x11, #24]                 // x17 = registers setup block
    mov     x9, #0                          // register index
    ldr     x7, [x17], #8                   // x7 = register setup mask: 2 bits per register
    13:
      tbz     x7, #0, 15f                     // Continue loop if register not defined.
    // register defined
      ldr     x14, [x17], #8                  // x14 = register value
      tbz     x7, #1, 14f
      add     x14, sp, x14, lsl #3            // Convert x14 from point value to absolute value.
    14:
    // x14 is absolute value
      str     x14, [x0, x9, lsl #3]
    15:
      add     x9, x9, #1
      lsr     x7, x7, #2
      cmp     x9, #29
      b.ne    13b

    ldr     x1, [x11, #56]                  // x1 = exec routine

  // Backup loop registers.

    stp     x20, x10, [sp, #-16]!
    stp     x11, x15, [sp, #-16]!

  // Replace registers with required values, except for x0 and x1 (which is done by shim)

    ldp     x2, x3, [x0, #8 * 2]
    ldp     x4, x5, [x0, #8 * 4]
    ldp     x6, x7, [x0, #8 * 6]
    ldp     x8, x9, [x0, #8 * 8]
    ldp     x10, x11, [x0, #8 * 10]
    ldp     x12, x13, [x0, #8 * 12]
    ldp     x14, x15, [x0, #8 * 14]
    ldp     x16, x17, [x0, #8 * 16]
    ldp     x18, x19, [x0, #8 * 18]
    ldp     x20, x21, [x0, #8 * 20]
    ldp     x22, x23, [x0, #8 * 22]
    ldp     x24, x25, [x0, #8 * 24]
    ldp     x26, x27, [x0, #8 * 26]
    ldr     x28, [x0, #8 * 28]

  // Call shim.

    blr     x1

  // Store post-test registers.

    stp     x0, x1, [x29, (8 * 0) - 256]
    stp     x2, x3, [x29, (8 * 2) - 256]
    stp     x4, x5, [x29, (8 * 4) - 256]
    stp     x6, x7, [x29, (8 * 6) - 256]
    stp     x8, x9, [x29, (8 * 8) - 256]
    stp     x10, x11, [x29, (8 * 10) - 256]
    stp     x12, x13, [x29, (8 * 12) - 256]
    stp     x14, x15, [x29, (8 * 14) - 256]
    stp     x16, x17, [x29, (8 * 16) - 256]
    stp     x18, x19, [x29, (8 * 18) - 256]
    stp     x20, x21, [x29, (8 * 20) - 256]
    stp     x22, x23, [x29, (8 * 22) - 256]
    stp     x24, x25, [x29, (8 * 24) - 256]
    stp     x26, x27, [x29, (8 * 26) - 256]
    str     x28, [x29, (8 * 28) - 256]

  // Restore loop registers.

    ldp     x11, x15, [sp], #16
    ldp     x20, x10, [sp], #16
    adr     x5, sysvars_meta

  // Store post-test system variables.

    mov     x0, x28
    mov     x1, (sysvars_end - sysvars)
    add     x9, sp, x15, lsl #4
    add     x9, x9, (sysvars_end-sysvars)
    16:
      ldp     x2, x3, [x0], #0x10
      stp     x2, x3, [x9], #0x10
      subs    x1, x1, #0x10
      b.ne    16b

  // Test register values

    ldr     x17, [x11, #48]                 // x17 = registers effects block
    ldr     x7, [x17], #8                   // x7 = register effects mask: 2 bits per register
    mov     x9, #0                          // register index
    sub     x18, x29, #512                  // x18 = base address of pre-test registers
    17:
      add     x8, x18, x9, lsl #3             // x8 = address of pre-test register value on stack
      ldr     x12, [x8]                       // x12 = pre-test register value
      ldr     x13, [x8, #256]                 // x13 = post-test register value
      tbz     x7, #0, 18f                     // If register shouldn't change, jump forward to 17:.
    // Register should be modified
      ldr     x14, [x17], #8                  // x14 = register expected value as pointer or literal value
      tbz     x7, #1, 19f                     // Jump ahead to 18: if literal value.
      add     x14, sp, x14, lsl #3            // Convert x14 from point value to absolute value.
      b       19f
    18:
      mov     x14, x12                        // x14 = expected value (= pre-test value)
    19:
      cmp     x13, x14                        // Post-test register value (x13) == expected register value (x14)?
      b.eq    20f                             // If actual == expected, register test passed; continue loop.
      mov     x16, log_register               // x16 = function to log ": Register x<index>"
      bl      test_fail                       // Otherwise, report failure.
    20:
      add     x9, x9, #1
      lsr     x7, x7, #2
      cmp     x9, #29
      b.ne    17b

  // Test system variable values

    ldr     x17, [x11, #40]                 // x17 = sysvars effects block
    add     x19, x17, SYSVAR_MASK_BYTES     // x19 = address of first sysvar definition
    mov     x9, #0                          // sysvar index
    add     x18, sp, x15, lsl #4            // x18 = base address of pre-test system variables
    21:
      tst     x9, #0x1f                       // lower 5 bits of x9 are 0 when we need to read next quad mask
      b.ne    22f
      ldr     x7, [x17], #8                   // x7 = sysvar setup mask
    22:
      ldr     x6, [x5, x9, lsl #3]            // x6 = sysvar meta entry
      ldr     x8, [x6]                        // x8 = address offset from x18 of pre-test sysvar
      add     x1, x8, (sysvars_end-sysvars)   // x1 = address offset from x18 of post-test sysvar
      ldrb    w0, [x6, #8]                    // w0 = sysvar size (in bytes)
      tbnz    w0, #1, 23f
      tbnz    w0, #2, 24f
      tbnz    w0, #3, 25f
    // 1 byte
      ldrb    w12, [x18, x8]                  // x12 = pre-test register value
      ldrb    w13, [x18, x1]                  // x13 = post-test register value
      b       26f
    23:
    // 2 bytes
      ldrh    w12, [x18, x8]                  // x12 = pre-test register value
      ldrh    w13, [x18, x1]                  // x13 = post-test register value
      b       26f
    24:
    // 4 bytes
      ldr     w12, [x18, x8]                  // x12 = pre-test register value
      ldr     w13, [x18, x1]                  // x13 = post-test register value
      b       26f
    25:
    // 8 bytes
      ldr     x12, [x18, x8]                  // x12 = pre-test register value
      ldr     x13, [x18, x1]                  // x13 = post-test register value
    26:
      tbz     x7, #0, 27f                     // If system variable shouldn't change, jump forward to 26.
    // Sysvar should be modified
      ldr     x14, [x19], #8                  // x14 = register expected value as pointer or literal value
      tbz     x7, #1, 28f                     // Jump ahead to 27: if literal value.
      add     x14, sp, x14, lsl #3            // Convert x14 from point value to absolute value.
      b       28f
    27:
      mov     x14, x12                        // x14 = expected value (= pre-test value)
    28:
      cmp     x13, x14                        // Post-test register value (x13) == expected register value (x14)?
      b.eq    29f                             // If actual == expected, register test passed; continue loop.
      mov     x16, log_sysvar                 // x16 = function to log ": System Variable <sysvar>"
      bl      test_fail                       // Otherwise, report failure.
    29:
      add     x9, x9, #1
      lsr     x7, x7, #2
      cmp     x9, SYSVAR_COUNT
      b.ne    21b

  // Test RAM values

    cbz     x15, 35f

    ldr     x17, [x11, #32]                 // x17 = RAM effects block
    add     x18, sp, x15, lsl #3            // x18 = address of RAM post-test entries
    add     x0, x15, #31                    // x0 = RAM entries + 31
    lsr     x0, x0, #5
    add     x19, x17, x0, lsl #3            // x19 = address of first RAM effects entry (x17 + (x15+31)/32)
    mov     x9, #0                          // RAM entry index
    30:
      tst     x9, #0x1f                       // lower 5 bits of x9 are 0 when we need to read next quad mask
      b.ne    31f
      ldr     x7, [x17], #8                   // x7 = RAM effects mask
    31:
      ldr     x12, [x18, x9, lsl #3]          // x12 = pre-test RAM value
      ldr     x13, [sp, x9, lsl #3]           // x13 = post-test RAM value
      tbz     x7, #0, 32f                     // If RAM entry shouldn't change, jump forward to 31:.
    // RAM entry should be modified
      ldr     x14, [x19], #8                  // x14 = RAM entry expected value as pointer or literal value
      tbz     x7, #1, 33f                     // Jump ahead to 31: if literal value.
      add     x14, sp, x14, lsl #3            // Convert x14 from point value to absolute value.
      b       33f
    32:
      mov     x14, x12                        // x14 = expected value (= pre-test value)
    33:
      cmp     x13, x14                        // Post-test RAM value (x13) == expected RAM value (x14)?
      b.eq    34f                             // If actual == expected, RAM test passed; continue loop.
      mov     x16, log_ram_entry              // x16 = function to log ": RAM entry <ram_entry>"
      bl      test_fail                       // Otherwise, report failure.
    34:
      add     x9, x9, #1
      lsr     x7, x7, #2
      cmp     x9, x15
      b.ne    30b

    add     sp, sp, x15, lsl #4             // Free RAM setup entries
  35:
    sub     x10, x10, #1                    // Decrement remaining test count
    cbnz    x10, 1b                         // Loop if more tests to run

  add     sp, sp, (sysvars_end - sysvars)*2 + 256*2
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
36:
  ret


log_ram_entry:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  adr     x0, msg_fail_8
  bl      uart_puts                       // Log ": RAM entry "
  ldr     x0, [x11, #8]                   // x0 = RAM setup block
  add     x0, x0, #8                      // Step over RAM entry count
  ldr     x0, [x0, x9, lsl #3]            // x0 = address of RAM entry definition block
  add     x0, x0, #16                     // x0 = address of RAM entry name
  bl      uart_puts                       // Log "<ram_entry>"
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
test_fail:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  adr     x0, msg_fail
  bl      uart_puts                       // Log "FAIL: "
  ldr     x0, [x11]                       // x0 = address of test name
  bl      uart_puts                       // Log "<test case name>"
  blr     x16                             // Log ": <entity>"
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
#  x0 = start address to decompress to (inclusive) -> 8 byte aligned
#  x1 = end address to decompress to (exclusive) -> 8 byte aligned, at least 16 more than x0
#  x2 = start address of compressed data buffer (inclusive) -> 8 byte aligned
# On exit:
#  x0 = x1
#  x2 = end address of used compressed data (exclusive) -> 8 byte aligned
#  x4 = [x1 - 8]
#  x5 = 0
#  x7 = 0x6a09e667bb67ae85
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


msg_running_test_part_1: .asciz "Running test "
msg_running_test_part_2: .asciz "...\r\n"

msg_fail: .asciz "FAIL: "
msg_fail_0: .asciz ": Register x"
msg_fail_1: .asciz " changed from "
msg_fail_2: .asciz " unchanged from "
msg_fail_3: .asciz " to "
msg_fail_4: .asciz ", but should have changed to "
msg_fail_5: .ascii ", but should not have changed"
                                          // Intentionally .ascii not .asciz, in order to join with msg_fail_6.
msg_fail_6: .asciz ".\r\n"
msg_fail_7: .asciz ": System Variable "
msg_fail_8: .asciz ": RAM entry "

msg_out_of_memory: .asciz "Out of memory!\r\n"


.bss

.align 3
pre_test_memory_dump: .space MEMORY_DUMP_BUFFER_SIZE
post_test_memory_dump: .space MEMORY_DUMP_BUFFER_SIZE
pre_test_framebuffer:
