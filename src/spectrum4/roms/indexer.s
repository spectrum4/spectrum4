.text
.align 2
# --------------------------
# The Table INDEXING routine
# --------------------------
# Routine indexer searches an in-memory key/value store for x0.
#
# Keys and values are double words (64 bit values). Each record contains a single
# key and a single value. Keys and values may have unrestricted 64 bit values.
#
# The structure of the key/value store is:
#
#   uint64: number of records
#   [
#     uint64: key
#     uint64: value
#   ] * number of records
#
# Therefore the size of the store is [ 2*(number of records)+1 ] * 8 bytes (since
# 64 bits require 8 bytes of storage).
#
# * The key/value store must be 8 byte aligned in memory.
# * Records may be stored in an arbitrary order; however if a duplicate key exists,
#   the record with the lowest address in memory will take precendence.
# * Callers should check for non-zero x1 before using x2.
#
# On entry:
#   x0 = 64 bit key to search for
#   x1 = address of key/value store (8 byte aligned)
#
# On exit:
#   x0 unchanged
#   x1 = address of 64 bit key if found, otherwise 0
#   x2 = 64 bit value for key if found, otherwise unchanged
#   x9 = number of records after found key
#  x10 = x0 if found, otherwise value of last key in table
#  NZCV = result of `cmp x0, x10` (0b0110 if key found)
indexer:                                 // L16DC
  ldr     x9, [x1], #-8                           // x9 = number of records
                                                  // x1 = lookup table address - 8 = address of first record - 16
1:
  cbz     x9, 2f                                  // If all records have been exhausted, jump forward to 2:.
  ldr     x10, [x1, #16]!                         // Load key at x1+16 into x10, and proactively increase x1 by 16 for the next iteration.
  sub     x9, x9, 1                               // x9 = number of remaining records to check (which is now one less)
  cmp     x0, x10                                 // Check if key matches wanted key.
  b.ne    1b                                      // If not, loop back to 1:.
  ldr     x2, [x1, #8]                            // Key matches, set x2 to the value stored in x1 + 8, and leave x1 as it is.
  b       3f                                      // Jump forward to 3:.
2:
  mov     x1, 0                                   // Set x1 to zero to indicate value wasn't found.
3:
  ret
