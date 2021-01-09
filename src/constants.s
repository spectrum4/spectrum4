# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

.set S_FRAME_SIZE,            0x0100

# .set SYNC_INVALID_EL1t,         0x00
# .set IRQ_INVALID_EL1t,          0x01
# .set FIQ_INVALID_EL1t,          0x02
# .set ERROR_INVALID_EL1t,        0x03

# .set SYNC_INVALID_EL1h,         0x04
# .set IRQ_INVALID_EL1h,          0x05
# .set FIQ_INVALID_EL1h,          0x06
# .set ERROR_INVALID_EL1h,        0x07

# .set SYNC_INVALID_EL0_64,       0x08
# .set IRQ_INVALID_EL0_64,        0x09
# .set FIQ_INVALID_EL0_64,        0x0a
# .set ERROR_INVALID_EL0_64,      0x0b

# .set SYNC_INVALID_EL0_32,       0x0c
# .set IRQ_INVALID_EL0_32,        0x0d
# .set FIQ_INVALID_EL0_32,        0x0e
# .set ERROR_INVALID_EL0_32,      0x0f

.set SCREEN_WIDTH,     1920
.set SCREEN_HEIGHT,    1200
.set BORDER_LEFT,      96
.set BORDER_RIGHT,     96
.set BORDER_TOP,       128
.set BORDER_BOTTOM,    112

.set MAILBOX_BASE,     0x3f00b880
.set MAILBOX_REQ_ADDR, 0x0
.set MAILBOX_WRITE,    0x20
.set MAILBOX_STATUS,   0x18
.set MAILBOX_EMPTY_BIT,30
.set MAILBOX_FULL_BIT, 31

.set FIRST_UDG_CHAR,   'A'
.set UDG_COUNT,        21               // Number of User Defined Graphics to copy (=> 'A'-'U').
