# 48K BASIC Printer Buffer

## Memory Layout in original Spectrum 128K

The original ZX Spectrum 128K ROM 1 (48K BASIC) used a printer buffer from
0x5b00 to 0x5bff. This printer buffer wasn't available in 128K mode, and
instead the same memory region stored 128K system variables.

It appears the 256 byte buffer stored a single character row of 32 characters,
as a pixel map, comprised of 8 pixel rows, one row at a time, from top to
bottom. The pixels inside each 32 byte row went ordered from left to right. In
other words, if the the offset into the printer buffer is stored in the a byte,
bits 0-4 would hold the horizontal position from 0-31, and bits 5-7 would hold
the vertical pixel row position from 0-7, where 0 is the top pixel row of the
32 characters, and 7 is the lowest row.

The screen was also 32 characters wide, so the printer buffer was essentially
designed to be able to buffer a single character row from the screen.

## New Memory Layout in Spectrum +4

In the Spectrum +4, the screen is 108 characters wide, and there isn't a
native printer interface planned, certainly not initially. Therefore I've
decided instead to write the printer output to one of the UART interfaces of
the RPi 3B, and plan to write a virtual printer emulator for macOS/Linux and
possibly Windows, so that the Spectrum +4 can still virtually print over a
serial interface to a virtual printer running on a different computer.
Perhaps it might even be possible for the virtual printer to write directly
to a PDF file.

The Spectrum +4 Printer Buffer will therefore be 16 pixel rows high, and 108
characters wide, stored in 216 bytes per row, therefore 3456 bytes in size
(exactly 13 times bigger than the original printer buffer).
