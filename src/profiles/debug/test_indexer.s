# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

.text
.align 2


# indexer_1 looks up a key that is not in the lookup table. The key happens
# to match the record count total, in case record count record is misused as a
# key, and also a record added past the end of the lookup table, to be sure
# scannings stops at the end of the table.

indexer_1_setup_regs:
  mov x0, #4
  adr x1, indexer_test_table
  ret

indexer_1_effects_regs:
  mov x1, #0                              // 0 => record not found
  mov x9, #0                              // 0 => all records checks
  ldr x10, =0x1324354657687980            // value of last inspected key
  nzcv    #0b1000
  ret


# indexer_3 looks up a key that is in the lookup table twice.

indexer_2_setup_regs:
  mov x0, #0
  adr x1, indexer_test_table
  ret

indexer_2_effects_regs:
  adr x1, (indexer_test_table + 8 + 16*2) // address of record 2 key
  mov x2, #1                              // value of record 2 value
  mov x9, #1                              // number of unscanned entries
  mov x10, #0                             // value of last inspected key
  nzcv    #0b0110                         // 0b0110 => match found
  ret


# indexer_3 looks up a key that is in the lookup table.

indexer_3_setup_regs:
  ldr x0, =0x0001020304050607
  adr x1, indexer_test_table
  ret

indexer_3_effects_regs:
  adr x1, (indexer_test_table + 8 + 16*0) // address of record 0 key
  ldr x2, =0x1232343454565676             // value of record 2 value
  mov x9, #3                              // number of unscanned entries
  mov x10, x0                             // value of last inspected key
  nzcv    #0b0110                         // 0b0110 => match found
  ret


# indexer_4 looks up the last key in the lookup table, to make sure
# the complete table is scanned.

indexer_4_setup_regs:
  ldr x0, =0x1324354657687980
  adr x1, indexer_test_table
  ret

indexer_4_effects_regs:
  adr x1, (indexer_test_table + 8 + 16*3) // address of record 3 key
  ldr x2, =0x0123456789abcdef             // value of record 2 value
  mov x9, #0                              // number of unscanned entries
  mov x10, x0                             // value of last inspected key
  nzcv    #0b0110                         // 0b0110 => match found
  ret


.align 3
indexer_test_table:
# Record count
  .quad 0x0000000000000004
# record 0
  .quad 0x0001020304050607
  .quad 0x1232343454565676
# record 1
  .quad 0x0001020304050607                // duplicate key from record 0
  .quad 0xffffffffffffffff
# record 2
  .quad 0x0000000000000000
  .quad 0x0000000000000001
# record 3
  .quad 0x1324354657687980
  .quad 0x0123456789abcdef
# this record is past end of table!
  .quad 0x0000000000000004
  .quad 0x0101010101010101
