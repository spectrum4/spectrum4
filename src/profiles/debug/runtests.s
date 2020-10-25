# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

.text
.align 2


check_sp_matches_x29:
  stp     x29, x30, [sp, #-16]!
  mov     x29, sp
// TODO
  ldp     x29, x30, [sp], #16
  ret


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
// TODO
  ldp     x29, x30, [sp], #16
  ret


test_equal:
  stp     x29, x30, [sp, #-16]!
  mov     x29, sp
// TODO
  ldp     x29, x30, [sp], #16
  ret


test_register_equals:
  stp     x29, x30, [sp, #-16]!
  mov     x29, sp
// TODO
  ldp     x29, x30, [sp], #16
  ret


test_registers_preserved:
  stp     x29, x30, [sp, #-16]!
  mov     x29, sp
// TODO
  ldp     x29, x30, [sp], #16
  ret


test_uncorrupted_sysvars:
  stp     x29, x30, [sp, #-16]!
  mov     x29, sp
// TODO
  ldp     x29, x30, [sp], #16
  ret
