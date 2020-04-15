# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

.data

msg_colon0x:
.asciz ": 0x"

msg_title_sysvars:
.ascii "System Variables"
.byte 10,13
.ascii "================"
.byte 10,13,0

msg_copyright:
  .asciz "1982, 1986, 1987 Amstrad Plc."

msg_hex_header:
  .asciz "           00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f 10 11 12 13 14 15 16 17 18 19 1a 1b 1c 1d 1e 1f  "

.align 1
# -------------------------
# The 'Initial Stream Data'
# -------------------------
# Initially there are seven streams - 0xFD to 0x03.
# This table is identical to that in ROM 1 at 0x15C6.
# Used at 0x0226 (ROM 0).
initial_stream_data:
  .byte 0x01, 0x00                        // Stream -3 leads to channel 'K'.
  .byte 0x19, 0x00                        // Stream -2 leads to channel 'S'.
  .byte 0x31, 0x00                        // Stream -1 leads to channel 'R'.
  .byte 0x01, 0x00                        // Stream  0 leads to channel 'K'.
  .byte 0x01, 0x00                        // Stream  1 leads to channel 'K'.
  .byte 0x19, 0x00                        // Stream  2 leads to channel 'S'.
  .byte 0x49, 0x00                        // Stream  3 leads to channel 'P'.
initial_stream_data_END:

.align 3
# ---------------------------------
# The 'Initial Channel Information'
# ---------------------------------
# Initially there are four channels ('K', 'S', 'R', & 'P') for communicating
# with the 'keyboard', 'screen', 'work space' and 'printer'. For each channel
# the output routine address comes before the input routine address and the
# channel's code. This table is almost identical to that in ROM 1 at 0x15AF but
# with changes to the channel P routines to use the RS232 port instead of the
# ZX Printer.
# Used at 0x01DD (ROM 0).
initial_channel_info:
  .quad print_out                         // PRINT_OUT - K channel output routine.
  .quad key_input                         // KEY_INPUT - K channel input routine.
  .byte 'K',0,0,0,0,0,0,0                 // 0x4B      - Channel identifier 'K'.
  .quad print_out                         // PRINT_OUT - S channel output routine.
  .quad report_j                          // REPORT_J  - S channel input routine.
  .byte 'S',0,0,0,0,0,0,0                 // 0x53      - Channel identifier 'S'.
  .quad add_char                          // ADD_CHAR  - R channel output routine.
  .quad report_j                          // REPORT_J  - R channel input routine.
  .byte 'R',0,0,0,0,0,0,0                 // 0x52      - Channel identifier 'R'.
  .quad pout                              // POUT      - P Channel output routine.
  .quad pin                               // PIN       - P Channel input routine.
  .byte 'P',0,0,0,0,0,0,0x80              // 0x50      - Channel identifier 'P'.
initial_channel_info_END:

# --------------------------
# Channel code look-up table
# --------------------------
# This table is used to find one of the three flag setting routines. A zero
# end-marker is required as channel 'R' is not present.

#// chn-cd-lu
chn_cd_lu:
  .quad 0x0000000000000003                // 3 records
  .byte 'K',0,0,0,0,0,0,0                 // 0x4B      - Channel identifier 'K'.
  .quad chan_k
  .byte 'S',0,0,0,0,0,0,0                 // 0x53      - Channel identifier 'S'.
  .quad chan_s
  .byte 'P',0,0,0,0,0,0,0                 // 0x50      - Channel identifier 'P'.
  .quad chan_p

# Memory block for GPU mailbox call to allocate framebuffer
.align 4
mbreq:
  .word (mbreq_end-mbreq)                 // Buffer size
  .word 0                                 // Request/response code
  .word 0x00048003                        // Tag 0 - Set Screen Size
  .word 8                                 //   value buffer size
  .word 0                                 //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
  .word SCREEN_WIDTH                      //   request: width                response: width
  .word SCREEN_HEIGHT                     //   request: height               response: height
  .word 0x00048004                        // Tag 1 - Set Virtual Screen Size
  .word 8                                 //   value buffer size
  .word 0                                 //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
  .word SCREEN_WIDTH                      //   request: width                response: width
  .word SCREEN_HEIGHT                     //   request: height               response: height
  .word 0x00048009                        // Tag 2 - Set Virtual Offset
  .word 8                                 //   value buffer size
  .word 0                                 //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
  .word 0                                 //   request: x offset             response: x offset
  .word 0                                 //   request: y offset             response: y offset
  .word 0x00048005                        // Tag 3 - Set Colour Depth
  .word 4                                 //   value buffer size
  .word 0                                 //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
                                          //                   32 bits per pixel => 8 red, 8 green, 8 blue, 8 alpha
                                          //                   See https://en.wikipedia.org/wiki/RGBA_color_space
  .word 32                                //   request: bits per pixel       response: bits per pixel
  .word 0x00048006                        // Tag 4 - Set Pixel Order (really is "Colour Order", not "Pixel Order")
  .word 4                                 //   value buffer size
  .word 0                                 //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
  .word 0                                 //   request: 0 => BGR, 1 => RGB   response: 0 => BGR, 1 => RGB
  .word 0x00040001                        // Tag 5 - Get (Allocate) Buffer
  .word 8                                 //   value buffer size (response > request, so use response size)
  .word 0                                 //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
framebuffer:
  .word 4096                              //   request: alignment in bytes   response: frame buffer base address
  .word 0                                 //   request: padding              response: frame buffer size in bytes
  .word 0x00040008                        // Tag 6 - Get Pitch (bytes per line)
  .word 4                                 //   value buffer size
  .word 0                                 //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
pitch:
  .word 0                                 //   request: padding              response: bytes per line
  .word 0x00010005                        // Tag 7 - Get ARM memory
  .word 8                                 //   value buffer size
  .word 0                                 //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
arm_base:
  .word 0                                 //   request: padding              response: base address in bytes
arm_size:
  .word 0                                 //   request: padding              response: size in bytes
  .word 0                                 // End Tags
mbreq_end:

.bss

sysvars:
.align 0
  COL:            .space 1                // Current column from 1 to WIDTH. Set to 0 by NEW command.
  WIDTH:          .space 1                // Paper column width. Default value of 80.
  TVPARS:         .space 1                // Number of inline parameters expected by RS232 (e.g. 2 for AT).
  RASP:           .space 1                // Length of warning buzz.
  PIP:            .space 1                // Length of keyboard click.
  FLAGS:          .space 1                // Flags to control the BASIC system:
                                          //   Bit 0: 1=Suppress leading space.
                                          //   Bit 1: 1=Using printer, 0=Using screen.
                                          //   Bit 2: 1=Print in L-Mode, 0=Print in K-Mode.
                                          //   Bit 3: 1=L-Mode, 0=K-Mode.
                                          //   Bit 4: 1=128K Mode, 0=48K Mode. [Always 0 on 48K Spectrum].
                                          //   Bit 5: 1=New key press code available in LAST_K.
                                          //   Bit 6: 1=Numeric variable, 0=String variable.
                                          //   Bit 7: 1=Line execution, 0=Syntax checking.
  FLAGS2:         .space 1                // Flags:
                                          //   Bit 0  : 1=Screen requires clearing.
                                          //   Bit 1  : 1=Printer buffer contains data.
                                          //   Bit 2  : 1=In quotes.
                                          //   Bit 3  : 1=CAPS LOCK on.
                                          //   Bit 4  : 1=Using channel 'K'.
                                          //   Bit 5-7: Not used (always 0).
  TV_FLAG:        .space 1                // Flags associated with the TV:
                                          //   Bit 0  : 1=Using lower editing area, 0=Using main screen.
                                          //   Bit 1-2: Not used (always 0).
                                          //   Bit 3  : 1=Mode might have changed.
                                          //   Bit 4  : 1=Automatic listing in main screen, 0=Ordinary listing in main screen.
                                          //   Bit 5  : 1=Lower screen requires clearing after a key press.
                                          //   Bit 6  : 1=Tape Loader option selected (set but never tested). [Always 0 on 48K Spectrum]
                                          //   Bit 7  : Not used (always 0).
  BORDCR:         .space 1                // Border colour multiplied by 8; also contains the attributes normally used for the lower half.
  ERR_NR:         .space 1                // 1 less than the report code. Starts off at 255 (for -1).
  DF_SZ:          .space 1                // The number of lines (including one blank line) in the lower part of the screen. (1-60)
  SCR_CT:         .space 1                // Counts scrolls - it is always 1 more than the number of scrolls that will be done before
                                          // stopping with 'scroll?'.
  P_POSN:         .space 1                // 109-column number of printer position.
  ECHO_E_COLUMN:  .space 1                // 109-column number (in lower half) of end of input buffer.
  ECHO_E_ROW:     .space 1                // 60-line number (in lower half) of end of input buffer.
  S_POSN_COLUMN:  .space 1                // 109-column number for PRINT position.
  S_POSN_ROW:     .space 1                // 60-line number for PRINT position.
  S_POSNL_COLUMN: .space 1                // Like S_POSN_COLUMN for lower part.
  S_POSNL_ROW:    .space 1                // Like S_POSN_ROW for lower part.
  P_FLAG:         .space 1                // Flags:
                                          //   Bit 0: Temporary 1=OVER 1, 0=OVER 0.
                                          //   Bit 1: Permanent 1=OVER 1, 0=OVER 0.
                                          //   Bit 2: Temporary 1=INVERSE 1, 0=INVERSE 0.
                                          //   Bit 3: Permanent 1=INVERSE 1, 0=INVERSE 0.
                                          //   Bit 4: Temporary 1=Using INK 9.
                                          //   Bit 5: Permanent 1=Using INK 9.
                                          //   Bit 6: Temporary 1=Using PAPER 9.
                                          //   Bit 7: Permanent 1=Using PAPER 9.

.align 1
  REPDEL:         .space 1                // Place REPDEL in .align 1 section since REPDEL+REPPER is read/written together as a halfword.
                                          // Time (in 50ths of a second) that a key must be held down before it repeats. This starts off at 35.
  REPPER:         .space 1                // Delay (in 50ths of a second) between successive repeats of a key held down - initially 5.
  ATTR_P:         .space 1                // Permanent current colours, etc, as set up by colour statements.
  MASK_P:         .space 1                // Used for transparent colours, etc. Any bit that is 1 shows that the corresponding attribute.
  ATTR_T:         .space 1                // Temporary current colours (as set up by colour items).
  MASK_T:         .space 1                // Like MASK_P, but temporary.


  BAUD:           .space 2                // Baud rate timing constant for RS232 socket. Default value of 11. [Name clash with ZX Interface 1 system variable at 0x5CC3]
  SERFL:          .space 2                // Byte 0: Second character received flag:
                                          //           Bit 0   : 1=Character in buffer.
                                          //           Bits 1-7: Not used (always hold 0).
                                          // Byte 1: Received Character.
  RNFIRST:        .space 2                // Starting line number when renumbering. Default value of 10.
  RNSTEP:         .space 2                // Step size when renumbering. Default value of 10.
  STRMS:          .space 2*19             // Address offsets of 19 channels attached to streams.


.align 2
  COORDS:         .space 2                // X-coordinate of last point plotted.
  COORDS_Y:       .space 2                // Y-coordinate of last point plotted.

.align 3
  SFNEXT:         .space 8                // End of RAM disk catalogue marker. Pointer to first empty catalogue entry.
  SFSPACE:        .space 8                // Number of bytes free in RAM disk.
  CHARS:          .space 8                // 256 less than address of character set, which starts with ' ' and carries on to '©'.

# Pointers to inside the HEAP
  VARS:           .space 8                // Address of variables.
# DEST:           .space 8                // Address of variable in assignment.
  CHANS:          .space 8                // Address of channel data.
  CURCHL:         .space 8                // Address of information currently being used for input and output.
  PROG:           .space 8                // Address of BASIC program.
# NXTLIN:         .space 8                // Address of next line in program.
  DATADD:         .space 8                // Address of terminator of last DATA item.
  E_LINE:         .space 8                // Address of command being typed in.
# K_CUR:          .space 8                // Address of cursor.
  CH_ADD:         .space 8                // Address of the next character to be interpreted - the character after the argument of PEEK,
                                          // or the NEWLINE at the end of a POKE statement.
  X_PTR:          .space 8                // Address of the character after the '?' marker.
  WORKSP:         .space 8                // Address of temporary work space.
  STKBOT:         .space 8                // Address of bottom of calculator stack.
  STKEND:         .space 8                // Address of start of spare space.

# Other pointers
  RAMTOP:         .space 8                // Address of last byte of BASIC system area.
  P_RAMT:         .space 8                // Address of last byte of physical RAM.
  UDG:            .space 8                // Address of first user-defined graphic. Can be changed to save space by having fewer.
  ERR_SP:         .space 8                // Address of item on machine stack to be used as error return.

# Editor
  DF_CC:          .space 8                // Address in display file of PRINT position.
  DF_CCL:         .space 8                // Like DF CC for lower part of screen.
  PR_CC:          .space 8                // Full address of next position for LPRINT to print at (in ZX Printer buffer).
                                          // Legal values in printer_buffer range. [Not used in 128K mode]
sysvars_end:

  printer_buffer: .space 0x100            // Printer buffer used by 48K Basic but not by 128K Basic (apparently)

# Memory regions
  display_file:   .space (SCREEN_HEIGHT-BORDER_TOP-BORDER_BOTTOM)*(SCREEN_WIDTH-BORDER_LEFT-BORDER_RIGHT)/8
                                          // One pixel per bit => 8 pixels per byte
  display_file_end:
  attributes_file:.space (SCREEN_HEIGHT-BORDER_TOP-BORDER_BOTTOM)*(SCREEN_WIDTH-BORDER_LEFT-BORDER_RIGHT)/256
                                          // 16*16 pixels per attribute record => 256 pixles per byte
  attributes_file_end:
  ram_disk:       .space RAM_DISK_SIZE
  heap:           .space HEAP_SIZE
