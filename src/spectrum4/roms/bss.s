# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.


.bss

bss_start:

.align 4                                          // Make sure sysvars at least start at a reasonable boundary (16 byte)
                                                  // to aid caching, simplify copying memory block, etc.

sysvars:
.align 0
COL:            .space 1                          // Current column from 1 to WIDTH. Set to 0 by NEW command.
WIDTH:          .space 1                          // Paper column width. Default value of 80.
TVPARS:         .space 1                          // Number of inline parameters expected by RS232 (e.g. 2 for AT).
RASP:           .space 1                          // Length of warning buzz.
PIP:            .space 1                          // Length of keyboard click.
FLAGS:          .space 1                          // Flags to control the BASIC system:
                                                  //   Bit 0: 1=Suppress leading space.
                                                  //   Bit 1: 1=Using printer, 0=Using screen.
                                                  //   Bit 2: 1=Print in L-Mode, 0=Print in K-Mode.
                                                  //   Bit 3: 1=L-Mode, 0=K-Mode.
                                                  //   Bit 4: 1=128K Mode, 0=48K Mode. [Always 0 on 48K Spectrum].
                                                  //   Bit 5: 1=New key press code available in LAST_K.
                                                  //   Bit 6: 1=Numeric variable, 0=String variable.
                                                  //   Bit 7: 1=Line execution, 0=Syntax checking.
FLAGS2:         .space 1                          // Flags:
                                                  //   Bit 0  : 1=Screen requires clearing.
                                                  //   Bit 1  : 1=Printer buffer contains data.
                                                  //   Bit 2  : 1=In quotes.
                                                  //   Bit 3  : 1=CAPS LOCK on.
                                                  //   Bit 4  : 1=Using channel 'K'.
                                                  //   Bit 5-7: Not used (always 0).
TV_FLAG:        .space 1                          // Flags associated with the TV:
                                                  //   Bit 0  : 1=Using lower editing area, 0=Using main screen.
                                                  //   Bit 1-2: Not used (always 0).
                                                  //   Bit 3  : 1=Mode might have changed.
                                                  //   Bit 4  : 1=Automatic listing in main screen, 0=Ordinary listing in main screen.
                                                  //   Bit 5  : 1=Lower screen requires clearing after a key press.
                                                  //   Bit 6  : 1=Tape Loader option selected (set but never tested). [Always 0 on 48K Spectrum]
                                                  //   Bit 7  : Not used (always 0).
BORDCR:         .space 1                          // Border colour multiplied by 8; also contains the attributes normally used for the lower half.
ERR_NR:         .space 1                          // 1 less than the report code. Starts off at 255 (for -1).
DF_SZ:          .space 1                          // The number of lines (including one blank line) in the lower part of the screen. (1-60)
SCR_CT:         .space 1                          // Counts scrolls - it is always 1 more than the number of scrolls that will be done before
                                                  // stopping with 'scroll?'.
P_POSN_X:       .space 1                          // 109-column number of printer position.
ECHO_E_X:       .space 1                          // 109-column number (in lower half) of end of input buffer.
ECHO_E_Y:       .space 1                          // 60-line number (in lower half) of end of input buffer.
S_POSN_X:       .space 1                          // 109-column number for PRINT position.
S_POSN_Y:       .space 1                          // 60-line number for PRINT position.
S_POSN_X_L:     .space 1                          // Like S_POSN_X for lower part.
S_POSN_Y_L:     .space 1                          // Like S_POSN_Y for lower part.
P_FLAG:         .space 1                          // Flags:
                                                  //   Bit 0: Temporary 1=OVER 1, 0=OVER 0.
                                                  //   Bit 1: Permanent 1=OVER 1, 0=OVER 0.
                                                  //   Bit 2: Temporary 1=INVERSE 1, 0=INVERSE 0.
                                                  //   Bit 3: Permanent 1=INVERSE 1, 0=INVERSE 0.
                                                  //   Bit 4: Temporary 1=Using INK 9.
                                                  //   Bit 5: Permanent 1=Using INK 9.
                                                  //   Bit 6: Temporary 1=Using PAPER 9.
                                                  //   Bit 7: Permanent 1=Using PAPER 9.
BREG:           .space 1                          // Calculator's B register.
ATTR_P:         .space 1                          // Permanent current colours, etc, as set up by colour statements.
MASK_P:         .space 1                          // Used for transparent colours, etc. Any bit that is 1 takes value from current attribute value, 0 from ATTR_P/T.
ATTR_T:         .space 1                          // Temporary current colours (as set up by colour items).
MASK_T:         .space 1                          // Like MASK_P, but temporary.
MODE:           .space 1                          // Specifies cursor type:
                                                  //   $00='L' or 'C'.
                                                  //   $01='E'.
                                                  //   $02='G'.
                                                  //   $04='K'.

.align 1
REPDEL:         .space 1                          // Place REPDEL in .align 1 section since REPDEL+REPPER is read/written together as a halfword.
                                                  // Time (in 50ths of a second) that a key must be held down before it repeats. This starts off at 35.
REPPER:         .space 1                          // Delay (in 50ths of a second) between successive repeats of a key held down - initially 5.
BAUD:           .space 2                          // Baud rate timing constant for RS232 socket. Default value of 11. [Name clash with ZX Interface 1 system variable at 0x5CC3]
SERFL:          .space 2                          // Byte 0: Second character received flag:
                                                  //           Bit 0   : 1=Character in buffer.
                                                  //           Bits 1-7: Not used (always hold 0).
                                                  // Byte 1: Received Character.
RNFIRST:        .space 2                          // Starting line number when renumbering. Default value of 10.
RNSTEP:         .space 2                          // Step size when renumbering. Default value of 10.
STRMS:          .space 2*19                       // Address offsets of 19 channels attached to streams.
TVDATA:         .space 2                          // Stores bytes of colour, AT and TAB controls going to TV.

.align 2
COORDS:         .space 2                          // X-coordinate of last point plotted.
COORDS_Y:       .space 2                          // Y-coordinate of last point plotted.

.align 3
SFNEXT:         .space 8                          // End of RAM disk catalogue marker. Pointer to first empty catalogue entry.
SFSPACE:        .space 8                          // Number of bytes free in RAM disk.
CHARS:          .space 8                          // 256 less than address of character set, which starts with ' ' and carries on to '©'.
LIST_SP:        .space 8                          // Address of return address from automatic listing.

# Pointers to inside the HEAP
VARS:           .space 8                          // Address of variables.
# DEST:           .space 8                // Address of variable in assignment.
CHANS:          .space 8                          // Address of channel data.
CURCHL:         .space 8                          // Address of information currently being used for input and output.
PROG:           .space 8                          // Address of BASIC program.
# NXTLIN:         .space 8                // Address of next line in program.
DATADD:         .space 8                          // Address of terminator of last DATA item.
E_LINE:         .space 8                          // Address of command being typed in.
# K_CUR:          .space 8                // Address of cursor.
CH_ADD:         .space 8                          // Address of the next character to be interpreted - the character after the argument of PEEK,
                                                  // or the NEWLINE at the end of a POKE statement.
X_PTR:          .space 8                          // Address of the character after the '?' marker.
WORKSP:         .space 8                          // Address of temporary work space.
STKBOT:         .space 8                          // Address of bottom of calculator stack.
STKEND:         .space 8                          // Address of start of spare space.

# Other pointers
RAMTOP:         .space 8                          // Address of last byte of BASIC system area.
P_RAMT:         .space 8                          // Address of last byte of physical RAM.
UDG:            .space 8                          // Address of first user-defined graphic. Can be changed to save space by having fewer.
ERR_SP:         .space 8                          // Address of item on machine stack to be used as error return.

# Editor
DF_CC:          .space 8                          // Address in display file of PRINT position.
DF_CC_L:        .space 8                          // Like DF CC for lower part of screen.
PR_CC:          .space 8                          // Full address of next position for LPRINT to print at (in ZX Printer buffer).
K_CUR:          .space 8                          // Address of cursor.
                                                  // Legal values in printer_buffer range. [Not used in 128K mode]
MEMBOT:         .space 32                         // Calculator's memory area - used to store numbers that cannot conveniently be put on the
                                                  // calculator stack.

.align 4                                          // Ensure sysvars_end is at a 16 byte boundary.
sysvars_end:

printer_buffer: .space 0xd80                      // Printer buffer used by 48K Basic but not by 128K Basic (see docs/printer-buffer.md)
printer_buffer_end:

# Memory regions
display_file:   .space (SCREEN_HEIGHT-BORDER_TOP-BORDER_BOTTOM)*(SCREEN_WIDTH-BORDER_LEFT-BORDER_RIGHT)/8
                                                  // One pixel per bit => 8 pixels per byte
display_file_end:
attributes_file:.space (SCREEN_HEIGHT-BORDER_TOP-BORDER_BOTTOM)*(SCREEN_WIDTH-BORDER_LEFT-BORDER_RIGHT)/256
                                                  // 16*16 pixels per attribute record => 256 pixles per byte
attributes_file_end:
ram_disk:       .space RAM_DISK_SIZE
heap:           .space HEAP_SIZE
