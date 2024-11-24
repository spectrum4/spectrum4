# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.bss
.align 12
pg_dir:
.space 0x7000
# PGD table (maps 1/512 * 512GB entries = 256TB range)
#   0x0000: [0x0000000000000000 - 0x0000007fffffffff] (512GB) -> PUD table at 0x1000
#   --- 511 missing entries ---
# PUD table (maps 1/512 (rpi3) or 5/512 (rpi4) * 1GB entries = 512GB range)
#   0x1000: [0x0000000000000000 - 0x000000003fffffff] (1GB) -> PMD table at 0x2000
#   0x1008: [0x0000000040000000 - 0x000000007fffffff] (1GB) -> PMD table at 0x3000   # rpi4 only
#   0x1010: [0x0000000080000000 - 0x00000000bfffffff] (1GB) -> PMD table at 0x4000   # rpi4 only
#   0x1018: [0x00000000c0000000 - 0x00000000ffffffff] (1GB) -> PMD table at 0x5000   # rpi4 only
#   --- 20 missing entries ---
#   0x10c0: [0x0000000600000000 - 0x0000000640000000] (1GB) -> PMD table at 0x6000   # rpi4 only
#   --- 487 missing entries ---
# PMD table (maps 512/512 * 2MB entries = 1GB range)
#   0x2000: [0x0000000000000000 - 0x00000000001fffff] (2MB)
#   0x2008: [0x0000000000200000 - 0x00000000003fffff] (2MB)
#   0x2010: [0x0000000000400000 - 0x00000000005fffff] (2MB)
#   ... 506 more entries ...
#   0x2fe8: [0x000000003fa00000 - 0x000000003fbfffff] (2MB)
#   0x2ff0: [0x000000003fc00000 - 0x000000003fdfffff] (2MB)
#   0x2ff8: [0x000000003fe00000 - 0x000000003fffffff] (2MB)
# PMD table (maps 512/512 * 2MB entries = 1GB range)
#   0x3000: [0x0000000040000000 - 0x00000000401fffff] (2MB)                          # rpi4 only
#   0x3008: [0x0000000040200000 - 0x00000000403fffff] (2MB)                          # rpi4 only
#   0x3010: [0x0000000040400000 - 0x00000000405fffff] (2MB)                          # rpi4 only
#   ... 506 more entries ...
#   0x3fe8: [0x000000007fa00000 - 0x000000007fbfffff] (2MB)                          # rpi4 only
#   0x3ff0: [0x000000007fc00000 - 0x000000007fdfffff] (2MB)                          # rpi4 only
#   0x3ff8: [0x000000007fe00000 - 0x000000007fffffff] (2MB)                          # rpi4 only
# PMD table (maps 512/512 * 2MB entries = 1GB range)
#   0x4000: [0x0000000080000000 - 0x00000000801fffff] (2MB)                          # rpi4 only
#   0x4008: [0x0000000080200000 - 0x00000000803fffff] (2MB)                          # rpi4 only
#   0x4010: [0x0000000080400000 - 0x00000000805fffff] (2MB)                          # rpi4 only
#   ... 506 more entries ...
#   0x4fe8: [0x00000000bfa00000 - 0x00000000bfbfffff] (2MB)                          # rpi4 only
#   0x4ff0: [0x00000000bfc00000 - 0x00000000bfdfffff] (2MB)                          # rpi4 only
#   0x4ff8: [0x00000000bfe00000 - 0x00000000bfffffff] (2MB)                          # rpi4 only
# PMD table (maps 512/512 * 2MB entries = 1GB range)
#   0x5000: [0x00000000c0000000 - 0x00000000c01fffff] (2MB)                          # rpi4 only
#   0x5008: [0x00000000c0200000 - 0x00000000c03fffff] (2MB)                          # rpi4 only
#   0x5010: [0x00000000c0400000 - 0x00000000c05fffff] (2MB)                          # rpi4 only
#   ... 506 more entries ...
#   0x5fe8: [0x00000000ffa00000 - 0x00000000ffbfffff] (2MB)                          # rpi4 only
#   0x5ff0: [0x00000000ffc00000 - 0x00000000ffdfffff] (2MB)                          # rpi4 only
#   0x5ff8: [0x00000000ffe00000 - 0x00000000ffffffff] (2MB)                          # rpi4 only
# PMD table (maps 32/512 * 2MB entries = 1GB range)                  # xHCI
#   0x6000: [0x0000000600000000 - 0x00000006001fffff] (2MB)                          # rpi4 only
#   0x6008: [0x0000000600200000 - 0x00000006003fffff] (2MB)                          # rpi4 only
#   0x6010: [0x0000000600400000 - 0x00000006005fffff] (2MB)                          # rpi4 only
#   ... ** 26 **  more entries ...                                                   # rpi4 only
#   0x60e8: [0x0000000603a00000 - 0x0000000603bfffff] (2MB)                          # rpi4 only
#   0x60f0: [0x0000000603c00000 - 0x0000000603dfffff] (2MB)                          # rpi4 only
#   0x60f8: [0x0000000603e00000 - 0x0000000603ffffff] (2MB)                          # rpi4 only
#   --- 480 missing entries ---
pg_dir_end:
