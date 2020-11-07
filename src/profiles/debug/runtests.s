# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

.text
.align 2


run_tests:
  ldr     w0, arm_size
  and     sp, x0, #~0x0f                  // Set stack pointer at top of ARM memory
  adr     x0, all_tests
  ldr     x10, [x0], #8                   // x10 = number of tests
  cbz     x10, end_run_tests              // Return if no tests to run
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  1:                                      // Loop executing tests
    ldr     x11, [x0], #8                 // x11 = address of test definition
    stp     x0, x10, [sp, #-16]!          // Push position in test list and remaining test count
    stp     x11, xzr, [sp, #-16]!         // Push address of test definition
    adr     x0, msg_running_test_part_1
    bl      uart_puts                     // Log "Running test "
    ldr     x0, [x11]                     // x0 = address of test name
    bl      uart_puts                     // Log "<test name>"
    adr     x0, msg_running_test_part_2
    bl      uart_puts                     // Log "...\r\n"
    mov     x0, x28
    mov     x1, (sysvars_end - sysvars)
    bl      rand_block                    // Set sysvars to random values
    ldr     x4, [x11, #16]                // x0 = sysvars setup block
    adr     x5, sysvarsizes
    adr     x6, sysvaraddresses
    mov     x9, #0                        // x9 = sysvar index
    add     x13, x4, SYSVAR_MASK_BYTES    // x13 = address of first sysvar definition
  loop_sysvar:
      tst     x9, #0x3f                   // lower 6 bits of x9 are 0 when we need to read next quad mask
      b.ne    test_loop1
      ldr     x7, [x4], #8                // x7 = sysvar setup mask
    test_loop1:
      tbz     x7, #0, prepare_loop_sysvar // if sysvar not defined, skip setting it and leave random value in place
    // sysvar defined, replace random value
      ldr     x14, [x13], #8              // x14 = value to set sysvar to
      ldr     x12, [x6, x9, lsl #3]       // x12 = sysvar address
      ldrb    w15, [x5, x9]               // x15 = sysvar size (in bytes)
      tbnz    w15, #0, x2f
      tbnz    w15, #1, x3f
      tbnz    w15, #2, x4f
      tbnz    w15, #3, x5f
      ret
    x2f:
      // 1 byte
      ldrb    w0, [x0]
      b       x6f
    x3f:
      // 2 bytes
      ldrh    w0, [x0]
      b       x6f
    x4f:
      // 4 bytes
      ldr     w0, [x0]
      b       x6f
    x5f:
      // 8 bytes
      ldr     x0, [x0]
    x6f:
      str     x0, [x28, CURCHL-sysvars]
    prepare_loop_sysvar:
      add     x9, x9, #1                  // Increment sysvar index
      lsr     x7, x7, #1                  // Shift mask bits right
      b       loop_sysvar

  setup_registers:
    sub     sp, sp, #0x100
    mov     x0, sp
    mov     x1, #0x100
    bl      rand_block
    pop_registers
    adr     x28, sysvars
    push_registers
    push_sysvars
    bl      po_change
    push_registers
    push_sysvars
    adr     x8, msg_po_change_case_1
    adr     x0, test_po_change_test_case_1_effects_registers
#   x0 = bit field for each register: 1 => register preserved / 0 => register should be updated
#        bit number matches register index
#   x8 = address of test case name
    add     x2, sp, (16 + sysvars_end - sysvars + 256 + sysvars_end - sysvars)
                                            // x2 = addres on stack of x0 before calling method
    add     x3, sp, (16 + sysvars_end - sysvars)
                                            // x3 = addres on stack of x0 after calling method
    mov     x1, #0                          // Index of the register to compare
  1:
  // test for equality
    ldr     x4, [x2, x1, lsl #3]
    ldr     x5, [x3, x1, lsl #3]
    stp     x0, x1, [sp, #-16]!
    stp     x2, x3, [sp, #-16]!
# Report a failure message to UART if values are equal but should not be, or
# are not equal but should be. Otherwise do nothing.
#
# Report lines as follows:
#
# FAIL: po_change test case 1: register x3 value 0x0000000000001a60 should have been modified
# FAIL: po_change test case 1: register x4 value unexpectedly modified from 0x8ceb064787d0b39b to 0x0000000000001a68
#
# On entry:
#   x0 = bit 0 set if values should be equal
#   x1 = index of x register to report on (e.g. 13 for 'x13')
#   x4 = register value before routine called
#   x5 = register value after routine called
#   x8 = address of test case name
  cmp     x4, x5
  csetm   x9, ne
  add     x6, x0, x9
  tst     x6, #1
  b.ne    3f
  // Test FAIL
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  stp     x0, x1, [sp, #-16]!
  stp     x4, x5, [sp, #-16]!
  adr     x0, msg_fail
  bl      uart_puts                       // Write "FAIL: "
  mov     x0, x8
  bl      uart_puts                       // Write "<test case name>"
  adr     x0, msg_reg1
  bl      uart_puts                       // Write ": register x"
  sub     sp, sp, #32
  mov     x0, sp
  ldr     x2, [sp, #56]
  bl      base10
  bl      uart_puts                       // Write "<register index>"
  add     sp, sp, #32
  cbnz    x9, 1f
// Value should have been modified
  adr     x0, msg_reg2
  bl      uart_puts                       // Write " value "
  ldr     x0, [sp]
  bl      uart_x0                         // Write "<original register value>"
  adr     x0, msg_reg3
  bl      uart_puts                       // Write " should have been modified\r\n"
  b       2f
1:
// Value unexpectedly modified
  adr     x0, msg_reg4
  bl      uart_puts                       // Write " value unexpectedly modified from "
  ldr     x0, [sp]
  bl      uart_x0                         // Write "<original register value>"
  adr     x0, msg_reg5
  bl      uart_puts                       // Write " to "
  ldr     x0, [sp, #8]
  bl      uart_x0                         // Write "<updated register value>"
  bl      uart_newline                    // Write "\r\n"
2:
  add     sp, sp, #32
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
3:
    ldp     x2, x3, [sp], #16
    ldp     x0, x1, [sp], #16
    lsr     x0, x0, #1
    add     x1, x1, #1
    cmp     x1, #30
    b.ne    1b
    adr     x0, test_po_change_test_case_1_modified_sysvars
    bl      test_sysvar_effects
    add     sp, sp, 2*(sysvars_end-sysvars+256)
                                          // Free captured register/sysvar data
    ldp     x0, x10, [sp], #16            // Pop position in test list and remaining test count
    sub     x10, x10, #1                  // Decrement remaining test count
    cbnz    x10, 1b                       // Loop if more tests to run
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
end_run_tests:
  ret


msg_running_test_part_1: .asciz "Running test "
msg_running_test_part_2: .asciz "...\r\n"

msg_fail: .asciz "FAIL: "
msg_reg1: .asciz ": register x"
msg_reg2: .asciz " value "
msg_reg3: .asciz " should have been modified\r\n"
msg_reg4: .asciz " value unexpectedly modified from "
msg_reg5: .asciz " to "


.align 2
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
