# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.bss
.align 12
pg_dir:
.space 0x6000

# Raspberry Pi 3 Paging Tables
# ============================
# PUD table (maps 1/512 (rpi3) or 5/512 (rpi4) * 1GB entries = 512GB range)
#   0x0000: [0x0000000000000000 - 0x000000003fffffff] (1GB) -> PMD table at 0x2000 || 0x3
#   --- 511 missing entries ---
# PMD table (maps 512/512 * 2MB entries = 1GB range)
#   0x1000: [0x0000000000000000 - 0x00000000001fffff] (2MB) -> 0x0000000000000401
#   0x1008: [0x0000000000200000 - 0x00000000003fffff] (2MB) -> 0x0000000000200401
#   0x1010: [0x0000000000400000 - 0x00000000005fffff] (2MB) -> 0x0000000000400401
#   ... 498 more entries ...
#   0x1fa8: [0x000000003ea00000 - 0x000000003ebfffff] (2MB) -> 0x000000003ea00401
#   0x1fb0: [0x000000003ec00000 - 0x000000003edfffff] (2MB) -> 0x000000003ec00401
#   0x1fb8: [0x000000003ee00000 - 0x000000003effffff] (2MB) -> 0x000000003ee00401
#   ---------------- Peripherals start here ----------------
#   0x1fc0: [0x000000003f000000 - 0x000000003f1fffff] (2MB) -> 0x000000003f000405
#   0x1fc8: [0x000000003f200000 - 0x000000003f3fffff] (2MB) -> 0x000000003f200405
#   0x1fd0: [0x000000003f400000 - 0x000000003f5fffff] (2MB) -> 0x000000003f400405
#   0x1fd8: [0x000000003f600000 - 0x000000003f7fffff] (2MB) -> 0x000000003f600405
#   0x1fe0: [0x000000003f800000 - 0x000000003f9fffff] (2MB) -> 0x000000003f800405
#   0x1fe8: [0x000000003fa00000 - 0x000000003fbfffff] (2MB) -> 0x000000003fa00405
#   0x1ff0: [0x000000003fc00000 - 0x000000003fdfffff] (2MB) -> 0x000000003fc00405
#   0x1ff8: [0x000000003fe00000 - 0x000000003fffffff] (2MB) -> 0x000000003fe00405

# Raspberry Pi 4 Paging Tables
# ============================
# PUD table (maps 1/512 (rpi3) or 5/512 (rpi4) * 1GB entries = 512GB range)
#   0x0000: [0x0000000000000000 - 0x000000003fffffff] (1GB) -> PMD table at 0x2000 || 0x3
#   0x0008: [0x0000000040000000 - 0x000000007fffffff] (1GB) -> PMD table at 0x3000 || 0x3
#   0x0010: [0x0000000080000000 - 0x00000000bfffffff] (1GB) -> PMD table at 0x4000 || 0x3
#   0x0018: [0x00000000c0000000 - 0x00000000ffffffff] (1GB) -> PMD table at 0x5000 || 0x3
#   --- 20 missing entries ---
#   0x00c0: [0x0000000600000000 - 0x0000000640000000] (1GB) -> PMD table at 0x6000 || 0x3
#   --- 487 missing entries ---
# PMD table (maps 512/512 * 2MB entries = 1GB range)
#   0x1000: [0x0000000000000000 - 0x00000000001fffff] (2MB) -> 0x0000000000000401
#   0x1008: [0x0000000000200000 - 0x00000000003fffff] (2MB) -> 0x0000000000200401
#   0x1010: [0x0000000000400000 - 0x00000000005fffff] (2MB) -> 0x0000000000400401
#   ... 506 more entries ...
#   0x1fe8: [0x000000003fa00000 - 0x000000003fbfffff] (2MB) -> 0x000000003fa00401
#   0x1ff0: [0x000000003fc00000 - 0x000000003fdfffff] (2MB) -> 0x000000003fc00401
#   0x1ff8: [0x000000003fe00000 - 0x000000003fffffff] (2MB) -> 0x000000003fe00401
# PMD table (maps 512/512 * 2MB entries = 1GB range)
#   0x2000: [0x0000000040000000 - 0x00000000401fffff] (2MB) -> 0x0000000040000401
#   0x2008: [0x0000000040200000 - 0x00000000403fffff] (2MB) -> 0x0000000040200401
#   0x2010: [0x0000000040400000 - 0x00000000405fffff] (2MB) -> 0x0000000040400401
#   ... 506 more entries ...
#   0x2fe8: [0x000000007fa00000 - 0x000000007fbfffff] (2MB) -> 0x000000007fa00401
#   0x2ff0: [0x000000007fc00000 - 0x000000007fdfffff] (2MB) -> 0x000000007fc00401
#   0x2ff8: [0x000000007fe00000 - 0x000000007fffffff] (2MB) -> 0x000000007fe00401
# PMD table (maps 512/512 * 2MB entries = 1GB range)
#   0x3000: [0x0000000080000000 - 0x00000000801fffff] (2MB) -> 0x0000000080000401
#   0x3008: [0x0000000080200000 - 0x00000000803fffff] (2MB) -> 0x0000000080200401
#   0x3010: [0x0000000080400000 - 0x00000000805fffff] (2MB) -> 0x0000000080400401
#   ... 506 more entries ...
#   0x3fe8: [0x00000000bfa00000 - 0x00000000bfbfffff] (2MB) -> 0x00000000bfa00401
#   0x3ff0: [0x00000000bfc00000 - 0x00000000bfdfffff] (2MB) -> 0x00000000bfc00401
#   0x3ff8: [0x00000000bfe00000 - 0x00000000bfffffff] (2MB) -> 0x00000000bfe00401
# PMD table (maps 512/512 * 2MB entries = 1GB range)
#   0x4000: [0x00000000c0000000 - 0x00000000c01fffff] (2MB) -> 0x00000000c0000401
#   0x4008: [0x00000000c0200000 - 0x00000000c03fffff] (2MB) -> 0x00000000c0200401
#   0x4010: [0x00000000c0400000 - 0x00000000c05fffff] (2MB) -> 0x00000000c0400401
#   ... 474 more entries ...
#   0x4ee8: [0x00000000fba00000 - 0x00000000fbbfffff] (2MB) -> 0x00000000fba00401
#   0x4ef0: [0x00000000fbc00000 - 0x00000000fbdfffff] (2MB) -> 0x00000000fbc00401
#   0x4ef8: [0x00000000fbe00000 - 0x00000000fbffffff] (2MB) -> 0x00000000fbe00401
#   ---------------- Peripherals start here ----------------
#   0x4f00: [0x00000000fc000000 - 0x00000000fc1fffff] (2MB) -> 0x00000000fc000405
#   0x4f08: [0x00000000fc200000 - 0x00000000fc3fffff] (2MB) -> 0x00000000fc200405
#   0x4f10: [0x00000000fc400000 - 0x00000000fc5fffff] (2MB) -> 0x00000000fc400405
#   ... 26 more entries ...
#   0x4fe8: [0x00000000ffa00000 - 0x00000000ffbfffff] (2MB) -> 0x00000000ffa00405
#   0x4ff0: [0x00000000ffc00000 - 0x00000000ffdfffff] (2MB) -> 0x00000000ffc00405
#   0x4ff8: [0x00000000ffe00000 - 0x00000000ffffffff] (2MB) -> 0x00000000ffe00405
# PMD table (maps 32/512 * 2MB entries = 1GB range)
#   ---------------- XHCI region starts here ----------------
#   0x5000: [0x0000000600000000 - 0x00000006001fffff] (2MB) -> 0x0000000600000409
#   0x5008: [0x0000000600200000 - 0x00000006003fffff] (2MB) -> 0x0000000600200409
#   0x5010: [0x0000000600400000 - 0x00000006005fffff] (2MB) -> 0x0000000600400409
#   ... ** 26 **  more entries ...
#   0x50e8: [0x0000000603a00000 - 0x0000000603bfffff] (2MB) -> 0x0000000603a00409
#   0x50f0: [0x0000000603c00000 - 0x0000000603dfffff] (2MB) -> 0x0000000603c00409
#   0x50f8: [0x0000000603e00000 - 0x0000000603ffffff] (2MB) -> 0x0000000603e00409
#   --- 480 missing entries ---
pg_dir_end:
