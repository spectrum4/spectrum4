## Channels and Streams

Introduction:

* https://faqwiki.zxnet.co.uk/wiki/Channels_and_streams

The system variable `STRMS` points to a Streams Data Table, which has (2-byte) offsets into Channel Information Table.
The `CURCHL` system variable points to an address inside the Channel Table. `CURCHL` is set by taking an absolute stream
number, and looking up the offset in the Channel Information Table, and then adding the base address of the Channel
Information Table.

The Channel Information Table has 24 bytes per channel:

0-7: Output Routine Address
8-15: Input Routine Address
16: Name (single ASCII char)
17-22: Reserved
23: 0x80 if last entry in table, otherwise 0x00
