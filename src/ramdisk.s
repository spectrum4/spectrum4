# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.
.global setup_ramdisk

.section .text
# ------------------------------------------------------------------------------
# Initialises the ram disk
# ------------------------------------------------------------------------------
setup_ramdisk:
  #         LD   IX,$EBEC     ; First free entry in RAM disk.
  #         LD   (SFNEXT),IX  ; $5B83.
  #         LD   (IX+$0A),$00 ;
  #         LD   (IX+$0B),$C0 ;
  #         LD   (IX+$0C),$00 ;
  #         LD   HL,$2BEC     ;
  #         LD   A,$01        ; AHL=Free space in RAM disk.
  #         LD   (SFSPACE),HL ; $5B85. Current address.
  #         LD   (SFSPACE+2),A ; $5B87. Current RAM bank.
  #
  #         LD   A,$05        ;
  #         CALL L1C64        ; Page in logical RAM bank 5 (physical RAM bank 0).
  #
  #         LD   HL,$FFFF     ; Load HL with known last working byte - 65535.
  #         LD   ($5CB4),HL   ; P_RAMT. Set physical RAM top to 65535.
  #
  #         LD   DE,CHAR_SET+$01AF ; $3EAF. Set DE to address of the last bitmap of 'U' in ROM 1.
  #         LD   BC,$00A8     ; There are 21 User Defined Graphics to copy.
  #         EX   DE,HL        ; Swap so destination is $FFFF.
  #         RST  28H          ;
  #         DEFW MAKE_ROOM+$000C ; Calling this address (LDDR/RET) in the main ROM
  #                           ; cleverly copies the 21 characters to the end of RAM.
  #
  #         EX   DE,HL        ; Transfer DE to HL.
  #         INC  HL           ; Increment to address first byte of UDG 'A'.
  #         LD   ($5C7B),HL   ; UDG. Update standard System Variable UDG.
  #
  #         DEC  HL           ;
  #         LD   BC,$0040     ; Set values 0 for PIP and 64 for RASP.
  #         LD   ($5C38),BC   ; RASP. Update standard System Variables RASP and PIP.
  #         LD   ($5CB2),HL   ; RAMTOP. Update standard System Variable RAMTOP - the last
  #                           ; byte of the BASIC system area. Any machine code and
  #                           ; graphics above this address are protected from NEW.
  ret
