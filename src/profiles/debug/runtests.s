# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

.align 2
.text

run_tests:
  stp     x29, x30, [sp, #-16]!
  mov     x29, sp
  ldp     x29, x30, [sp], #16
  ret

random_registers:
// TODO
  ret

log_test_name:
// TODO
  ret

random_sysvars:
// TODO
  ret

test_allocated_is_address:
// TODO
  ret

test_allocated_is_preserved:
// TODO
  ret

test_register_is_address:
// TODO
  ret

test_register_preserved:
// TODO
  ret

test_sysvar_is_address:
// TODO
  ret

test_sysvar_preserved:
// TODO
  ret
