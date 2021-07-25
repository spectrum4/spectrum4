# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text


# indexer_1 looks up a key that is not in the lookup table. The key happens
# to match the record count total, in case record count record is misused as a
# key, and also a record added past the end of the lookup table, to be sure
# scannings stops at the end of the table.

indexer_1_setup_regs:
  ld      c, 0x04
  ld      hl, indexer_test_table
  ret

indexer_1_effects_regs:
  ld      hl, indexer_test_table_end_marker
  ld      a, 0
  ldf     Z_FLAG | H_FLAG | PV_FLAG
  ret


# indexer_2 looks up a key that is in the lookup table twice.

indexer_2_setup_regs:
  ld      c, 0x07
  ld      hl, indexer_test_table
  ret

indexer_2_effects_regs:
  ld      hl, indexer_test_table_rec_0+1
  ld      a, 0x07
  ldf     C_FLAG | Z_FLAG
  ret


# indexer_3 looks up the last key in the lookup table, to make sure
# the complete table is scanned.

indexer_3_setup_regs:
  ld      c, 0x80
  ld      hl, indexer_test_table
  ret

indexer_3_effects_regs:
  ld      hl, indexer_test_table_rec_3+1
  ld      a, 0x80
  ldf     C_FLAG | Z_FLAG
  ret


indexer_test_table:
indexer_test_table_rec_0:
# record 0
  .byte 0x07
  .byte 0x76
indexer_test_table_rec_1:
# record 1
  .byte 0x07                              ; duplicate key from record 0
  .byte 0xff
indexer_test_table_rec_2:
# record 2
  .byte 0x03
  .byte 0x01
indexer_test_table_rec_3:
# record 3
  .byte 0x80
  .byte 0xef
indexer_test_table_end_marker:
  .byte 0x00
# padding
  .byte 0x00
indexer_test_table_rec_past_end:
# this record is past end of table!
  .byte 0x04
  .byte 0x01
