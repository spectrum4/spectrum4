# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

.text
.align 2


# On entry:
#   x0 = address of test name
log_test_name:
  stp     x29, x30, [sp, #-16]!
  mov     x29, sp
  mov     x4, x0                          // Back up x0.
  adr     x0, msg_running_test_part_1
  bl      uart_puts
  mov     x0, x4                          // Restore x0.
  bl      uart_puts
  adr     x0, msg_running_test_part_2
  bl      uart_puts
  ldp     x29, x30, [sp], #16
  ret


msg_running_test_part_1: .asciz "Running test "
msg_running_test_part_2: .asciz "...\r\n"


.align 2
random_registers:
  stp     x29, x30, [sp, #-16]!
  mov     x29, sp
  sub     sp, sp, #0x100
  mov     x0, sp
  mov     x1, #0x100
  bl      rand_block
  pop_registers
  ldp     x29, x30, [sp], #16
  ret


random_sysvars:
  stp     x29, x30, [sp, #-16]!
  mov     x29, sp
  mov     x0, x28
  mov     x1, (sysvars_end - sysvars)
  bl      rand_block
  ldp     x29, x30, [sp], #16
  ret


test_register_equals:
  stp     x29, x30, [sp, #-16]!
  mov     x29, sp
// TODO
  ldp     x29, x30, [sp], #16
  ret


# On entry:
#   x0 = bit field for each register: 1 => register preserved / 0 => register should be updated
#        bit number matches register index
#   x8 = address of test case name
test_registers_preserved:
  stp     x29, x30, [sp, #-16]!
  mov     x29, sp
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
    bl      report_if_equal
    ldp     x2, x3, [sp], #16
    ldp     x0, x1, [sp], #16
    lsr     x0, x0, #1
    add     x1, x1, #1
    cmp     x1, #30
    b.ne    1b
  ldp     x29, x30, [sp], #16
  ret


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
report_if_equal:
  cmp     x4, x5
  csetm   x9, ne
  add     x6, x0, x9
  tst     x6, #1
  b.ne    3f
  // Test FAIL
  stp     x29, x30, [sp, #-16]!
  mov     x29, sp
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
  ldp     x29, x30, [sp], #16
3:
  ret


msg_fail: .asciz "FAIL: "
msg_reg1: .asciz ": register x"
msg_reg2: .asciz " value "
msg_reg3: .asciz " should have been modified\r\n"
msg_reg4: .asciz " value unexpectedly modified from "
msg_reg5: .asciz " to "


.align 2
test_unmodified_sysvars:
  stp     x29, x30, [sp, #-16]!
  mov     x29, sp
// TODO
  ldp     x29, x30, [sp], #16
  ret


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
  ldp     x19, x20, [sp], #0x10           // Restore x19, x20
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret
