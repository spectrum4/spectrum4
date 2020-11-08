# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

.text
.align 2


run_tests:

# Register usage
# ==============
# x0-3 scratch registers
# x4   address inside all_tests
# x5   sysvarsizes
# x6   sysvaraddresses
# x7   sysvar setup mask / ram setup entry type
# x8   sysvar pointer mask
# x9   sysvar index / ram entry index
# x10  number of remaining tests
# x11  address of test definition
# x12  sysvar address
# x13  address of individual sysvar definition / address of RAM setup entry
# x14  sysvar value / ram setup value
# x15  number of RAM setup entries
# x16  sysvar size in bytes (for literals)
# x17  sysvars/ram/registers setup/effects block
# x18  address on stack to set/test value

# Stack organisation
# ==================
#
# RAM entries
#   sp:
#     pre-test entries                      // (8 * RAM entries) bytes
#   sp+8*x15:
#     post-test entries                     // (8 * RAM entries) bytes
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
  adr     x4, all_tests                   // x4 = address of test list
  ldr     x10, [x4], #8                   // x10 = number of tests
  cbz     x10, end_run_tests              // Return if no tests to run
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  sub     sp, sp, (sysvars_end - sysvars)*2 + 256*2
                                          // Allocate space on stack for pre-test/post-test registers and system variables
  1:                                      // Loop executing tests
    adr     x5, sysvarsizes
    adr     x6, sysvaraddresses
    ldr     x11, [x4], #8                   // x11 = address of test definition

  // Log test running

    adr     x0, msg_running_test_part_1
    bl      uart_puts                       // Log "Running test "
    ldr     x0, [x11]                       // x0 = address of test name
    bl      uart_puts                       // Log "<test case name>"
    adr     x0, msg_running_test_part_2
    bl      uart_puts                       // Log "...\r\n"

  // RAM setup

    ldr     x17, [x11, #8]                  // x17 = ram setup block
    ldr     x15, [x17], #8                  // x15 = number of RAM setup entries
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

    mov     x0, x28
    mov     x1, (sysvars_end - sysvars)
    bl      rand_block                      // Set sysvars to random values
    ldr     x17, [x11, #16]                 // x17 = sysvars setup block
    mov     x9, #0                          // x9 = sysvar index
    add     x13, x17, SYSVAR_MASK_BYTES*2   // x13 = address of first sysvar definition
    4:
      tst     x9, #0x3f                       // lower 6 bits of x9 are 0 when we need to read next quad mask
      b.ne    5f
      ldr     x7, [x17], #8                   // x7 = sysvar setup mask
      ldr     x8, [x17, SYSVAR_MASK_BYTES - 8]
                                              // x8 = sysvar setup mask
    5:
      tbz     x7, #0, 10f                     // if sysvar not defined, skip setting it and leave random value in place
    // sysvar defined, replace random value
      ldr     x14, [x13], #8                  // x14 = value (pointer or literal value)
      ldr     x18, [x6, x9, lsl #3]           // x18 = sysvar address
      tbz     x8, #0, 6f
    // pointer
      add     x12, sp, x14, lsl #3            // x12 = pointer value
      str     x12, [x18]
      b       10f
    6:
      ldrb    w16, [x5, x9]                   // x16 = sysvar size (in bytes)
      tbnz    w16, #1, 7f
      tbnz    w16, #2, 8f
      tbnz    w16, #3, 9f
    // 1 byte
      strb    w14, [x18]
      b       10f
    7:
    // 2 bytes
      strh    w14, [x18]
      b       10f
    8:
    // 4 bytes
      str     w14, [x18]
      b       10f
    9:
    // 8 bytes
      str     x14, [x18]
    10:
      add     x9, x9, #1                      // Increment sysvar index
      lsr     x7, x7, #1                      // Shift sysvar mask bits right
      lsr     x8, x8, #1                      // Shift sysvar pointer bits right
      cmp     x9, SYSVAR_COUNT
      b.ne    4b

  // Copy sysvars to stack

    mov     x0, x28
    mov     x1, (sysvars_end - sysvars)
    add     x9, sp, x15, lsl #4
    11:
      ldp     x2, x3, [x0], #0x10
      stp     x2, x3, [x9], #0x10
      subs    x1, x1, #0x10
      b.ne    11b

  // Set up registers

    add     x0, x9, (sysvars_end - sysvars) // x0 = start of pre-test register block
    mov     x1, #0x100                      // Register storage on stack takes up 256 bytes.
    bl      rand_block                      // Log random bytes to stack so registers are random when popped.
    sub     x0, x0, #0x100                  // Restore x0 to start of pre-test register block
    str     x28, [x0, 28*8]                 // x28 is exceptional: has constant value; replace random value.
    ldr     x17, [x11, #24]                 // x17 = registers setup block
    mov     x9, #0                          // register index
    ldr     x7, [x17], #8                   // x7 = register setup mask: 2 bits per register
    12:
      tbz     x7, #0, 14f                     // Continue loop if register not defined.
    // register defined
      ldr     x14, [x17], #8                  // x14 = register value
      tbz     x7, #1, 13f
      add     x14, sp, x14, lsl #3            // Convert x14 from point value to absolute value.
    13:
    // x14 is absolute value
      str     x14, [x0, x9, lsl #3]
    14:
      add     x9, x9, #1
      lsr     x7, x7, #2
      cmp     x9, #29
      b.ne    12b

    ldr     x1, [x11, #56]                  // x1 = exec routine

  // Backup loop registers.

    stp     x4, x10, [sp, #-16]!
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
    ldp     x4, x10, [sp], #16

  // Test register values.
  //
  // Report a failure message to UART if values are equal but should not be, or
  // are not equal but should be. Otherwise do nothing.
  //
  // Report lines as follows:
  //
  // FAIL: po_change test case 1: Register x3 changed from 0x8ceb064787d0b39b to 0x0000000000001a68, but should not have changed.
  // FAIL: po_change test case 1: Register x4 changed from 0x0000000000001a60 to 0x000000000ed00100, but should have changed to 0x00000f00f00f00f0.
  // FAIL: po_change test case 1: Register x5 unchanged from 0xfe87f64783bc7a76 but should have changed to 0x00000f00f00f00f0.

    ldr     x17, [x11, #48]                 // x17 = registers effects block
    ldr     x7, [x17], #8                   // x7 = register effects mask: 2 bits per register
    mov     x9, #0                          // register index
    sub     x18, x29, #512                  // x18 = base address of pre-test registers
    15:
      add     x8, x18, x9, lsl #3             // x8 = address of pre-test register value on stack
      ldr     x12, [x8]                       // x12 = pre-test register value
      ldr     x13, [x8, #256]                 // x13 = post-test register value
      tbz     x7, #0, 16f                     // If register shouldn't change, jump forward to 16:.
    // Register should be modified
      ldr     x14, [x17], #8                  // x14 = register expected value as pointer or literal value
      tbz     x7, #1, 17f                     // Jump ahead to 17: if literal value.
      add     x14, sp, x14, lsl #3            // Convert x14 from point value to absolute value.
      b       17f
    16:
      mov     x14, x12                        // x14 = expected value (= pre-test value)
    17:
      cmp     x13, x14                        // Post-test register value (x13) == expected register value (x14)?
      b.eq    20f                             // If actual == expected, register test passed; continue loop.
    // Register test FAIL
      adr     x0, msg_fail
      bl      uart_puts                       // Log "FAIL: "
      ldr     x0, [x11]                       // x0 = address of test name
      bl      uart_puts                       // Log "<test case name>"
      adr     x0, msg_reg_fail_0
      bl      uart_puts                       // Log ": Register x"
      sub     sp, sp, #32
      mov     x0, sp
      mov     x2, x9
      bl      base10
      bl      uart_puts                       // Log "<register index>"
      add     sp, sp, #32
      cmp     x12, x13
      b.eq    19f                             // x12 == x13 => value unchanged but should have
    // register value changed
      adr     x0, msg_reg_fail_1
      bl      uart_puts                       // Log " changed from "
      mov     x0, x12
      bl      uart_x0                         // Log "<pre-test register value>"
      adr     x0, msg_reg_fail_3
      bl      uart_puts                       // Log " to "
      mov     x0, x13
      bl      uart_x0                         // Log "<post-test register value>"
      cmp     x12, x14
      b.eq    18f                             // x12 == x14 => value shouldn't have changed but did
    // register value meant to change, but to a different value
      adr     x0, msg_reg_fail_4
      bl      uart_puts                       // Log ", but should have changed to "
      mov     x0, x14
      bl      uart_x0                         // Log "<expected register value>"
      adr     x0, msg_reg_fail_6
      bl      uart_puts                       // Log ".\r\n"
      b       20f
    18:
    // register value not meant to change, but did
      adr     x0, msg_reg_fail_5
      bl      uart_puts                       // Log ", but should not have changed.\r\n"
      b       20f
    19:
    // register value unchanged, but was meant to
      adr     x0, msg_reg_fail_2
      bl      uart_puts                       // Log " unchanged from "
      mov     x0, x12
      bl      uart_x0                         // Log "<pre-test register value>"
      adr     x0, msg_reg_fail_4
      bl      uart_puts                       // Log ", but should have changed to "
      mov     x0, x14
      bl      uart_x0                         // Log "<expected register value>"
      adr     x0, msg_reg_fail_6
      bl      uart_puts                       // Log ".\r\n"
    20:
      add     x9, x9, #1
      lsr     x7, x7, #2
      cmp     x9, #29
      b.ne    15b

  // TODO: Test system variable values

  // TODO: Test RAM values

    add     sp, sp, x15, lsl #4             // Free RAM setup entries
    sub     x10, x10, #1                    // Decrement remaining test count
    cbnz    x10, 1b                         // Loop if more tests to run

  add     sp, sp, (sysvars_end - sysvars)*2 + 256*2
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
end_run_tests:
  ret


msg_running_test_part_1: .asciz "Running test "
msg_running_test_part_2: .asciz "...\r\n"

msg_fail: .asciz "FAIL: "
msg_reg_fail_0: .asciz ": Register x"
msg_reg_fail_1: .asciz " changed from "
msg_reg_fail_2: .asciz " unchanged from "
msg_reg_fail_3: .asciz " to "
msg_reg_fail_4: .asciz ", but should have changed to "
msg_reg_fail_5: .ascii ", but should not have changed"
                                          // Intentionally .ascii not .asciz, in order to join with msg_reg_fail_6.
msg_reg_fail_6: .asciz ".\r\n"
