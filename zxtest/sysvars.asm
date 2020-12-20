# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

.text

sysvars:

.asciz "SWAP"                             ; 0x5b00
.byte 0x14

.asciz "YOUNGER"                          ; 0x5b14
.byte 0x9

.asciz "ONERR"                            ; 0x5b1d
.byte 0x12

.asciz "PIN"                              ; 0x5b2f
.byte 0x5

.asciz "POUT"                             ; 0x5b34
.byte 0x16

.asciz "POUT2"                            ; 0x5b4a
.byte 0xe

.asciz "TARGET"                           ; 0x5b58
.byte 0x2

.asciz "RETADDR"                          ; 0x5b5a
.byte 0x2

.asciz "BANK_M"                           ; 0x5b5c
.byte 0x1

.asciz "RAMRST"                           ; 0x5b5d
.byte 0x1

.asciz "RAMERR"                           ; 0x5b5e
.byte 0x1

.asciz "BAUD"                             ; 0x5b5f
.byte 0x2

.asciz "SERFL"                            ; 0x5b61
.byte 0x2

.asciz "COL"                              ; 0x5b63
.byte 0x1

.asciz "WIDTH"                            ; 0x5b64
.byte 0x1

.asciz "TVPARS"                           ; 0x5b65
.byte 0x1

.asciz "FLAGS3"                           ; 0x5b66
.byte 0x1

.asciz "N_STR1"                           ; 0x5b67
.byte 0xa

.asciz "HD_00"                            ; 0x5b71
.byte 0x1

.asciz "HD_0B"                            ; 0x5b72
.byte 0x2

.asciz "HD_0D"                            ; 0x5b74
.byte 0x2

.asciz "HD_0F"                            ; 0x5b76
.byte 0x2

.asciz "HD_11"                            ; 0x5b78
.byte 0x2

.asciz "SC_00"                            ; 0x5b7a
.byte 0x1

.asciz "SC_0B"                            ; 0x5b7b
.byte 0x2

.asciz "SC_0D"                            ; 0x5b7d
.byte 0x2

.asciz "SC_0F"                            ; 0x5b7f
.byte 0x2

.asciz "OLDSP"                            ; 0x5b81
.byte 0x2

.asciz "SFNEXT"                           ; 0x5b83
.byte 0x2

.asciz "SFSPACE"                          ; 0x5b85
.byte 0x3

.asciz "ROW01"                            ; 0x5b88
.byte 0x1

.asciz "ROW23"                            ; 0x5b89
.byte 0x1

.asciz "ROW45"                            ; 0x5b8a
.byte 0x1

.asciz "SYNRET"                           ; 0x5b8b
.byte 0x2

.asciz "LASTV"                            ; 0x5b8d
.byte 0x5

.asciz "RNLINE"                           ; 0x5b92
.byte 0x2

.asciz "RNFIRST"                          ; 0x5b94
.byte 0x2

.asciz "RNSTEP"                           ; 0x5b96
.byte 0x2

.asciz "STRIP1"                           ; 0x5b98
.byte 0x20

.asciz "TSTACK"                           ; 0x5bb8
.byte 0x48

.asciz "KSTATE"                           ; 0x5c00
.byte 0x8

.asciz "LASTK"                            ; 0x5c08
.byte 0x1

.asciz "REPDEL"                           ; 0x5c09
.byte 0x1

.asciz "REPPER"                           ; 0x5c0a
.byte 0x1

.asciz "DEFADD"                           ; 0x5c0b
.byte 0x2

.asciz "K_DATA"                           ; 0x5c0d
.byte 0x1

.asciz "TVDATA"                           ; 0x5c0e
.byte 0x2

.asciz "STRMS"                            ; 0x5c10
.byte 0x26

.asciz "CHARS"                            ; 0x5c36
.byte 0x2

.asciz "RASP"                             ; 0x5c38
.byte 0x1

.asciz "PIP"                              ; 0x5c39
.byte 0x1

.asciz "ERR_NR"                           ; 0x5c3a
.byte 0x1

.asciz "FLAGS"                            ; 0x5c3b
.byte 0x1

.asciz "TVFLAG"                           ; 0x5c3c
.byte 0x1

.asciz "ERR_SP"                           ; 0x5c3d
.byte 0x2

.asciz "LISTSP"                           ; 0x5c3f
.byte 0x2

.asciz "MODE"                             ; 0x5c41
.byte 0x1

.asciz "NEWPPC"                           ; 0x5c42
.byte 0x2

.asciz "NSPPC"                            ; 0x5c44
.byte 0x1

.asciz "PPC"                              ; 0x5c45
.byte 0x2

.asciz "SUBPPC"                           ; 0x5c47
.byte 0x1

.asciz "BORDCR"                           ; 0x5c48
.byte 0x1

.asciz "E_PPC"                            ; 0x5c49
.byte 0x2

.asciz "VARS"                             ; 0x5c4b
.byte 0x2

.asciz "DEST"                             ; 0x5c4d
.byte 0x2

.asciz "CHANS"                            ; 0x5c4f
.byte 0x2

.asciz "CURCHL"                           ; 0x5c51
.byte 0x2

.asciz "PROG"                             ; 0x5c53
.byte 0x2

.asciz "NXTLIN"                           ; 0x5c55
.byte 0x2

.asciz "DATADD"                           ; 0x5c57
.byte 0x2

.asciz "E_LINE"                           ; 0x5c59
.byte 0x2

.asciz "K_CUR"                            ; 0x5c5b
.byte 0x2

.asciz "CH_ADD"                           ; 0x5c5d
.byte 0x2

.asciz "X_PTR"                            ; 0x5c5f
.byte 0x2

.asciz "WORKSP"                           ; 0x5c61
.byte 0x2

.asciz "STKBOT"                           ; 0x5c63
.byte 0x2

.asciz "STKEND"                           ; 0x5c65
.byte 0x2

.asciz "BREG"                             ; 0x5c67
.byte 0x1

.asciz "MEM"                              ; 0x5c68
.byte 0x2

.asciz "FLAGS2"                           ; 0x5c6a
.byte 0x1

.asciz "DF_SZ"                            ; 0x5c6b
.byte 0x1

.asciz "S_TOP"                            ; 0x5c6c
.byte 0x2

.asciz "OLDPPC"                           ; 0x5c6e
.byte 0x2

.asciz "OSPPC"                            ; 0x5c70
.byte 0x1

.asciz "FLAGX"                            ; 0x5c71
.byte 0x1

.asciz "STRLEN"                           ; 0x5c72
.byte 0x2

.asciz "T_ADDR"                           ; 0x5c74
.byte 0x2

.asciz "SEED"                             ; 0x5c76
.byte 0x2

.asciz "FRAMES"                           ; 0x5c78
.byte 0x3

.asciz "UDG"                              ; 0x5c7b
.byte 0x2

.asciz "COORDS"                           ; 0x5c7d
.byte 0x2

.asciz "P_POSN"                           ; 0x5c7f
.byte 0x1

.asciz "PR_CC"                            ; 0x5c80
.byte 0x2

.asciz "ECHO_E"                           ; 0x5c82
.byte 0x2

.asciz "DF_CC"                            ; 0x5c84
.byte 0x2

.asciz "DF_CCL"                           ; 0x5c86
.byte 0x2

.asciz "S_POSN"                           ; 0x5c88
.byte 0x2

.asciz "SPOSNL"                           ; 0x5c8a
.byte 0x2

.asciz "SCR_CT"                           ; 0x5c8c
.byte 0x1

.asciz "ATTR_P"                           ; 0x5c8d
.byte 0x1

.asciz "MASK_P"                           ; 0x5c8e
.byte 0x1

.asciz "ATTR_T"                           ; 0x5c8f
.byte 0x1

.asciz "MASK_T"                           ; 0x5c90
.byte 0x1

.asciz "P_FLAG"                           ; 0x5c91
.byte 0x1

.asciz "MEMBOT"                           ; 0x5c92
.byte 0x20

.asciz "RAMTOP"                           ; 0x5cb2
.byte 0x2

.asciz "P_RAMT"                           ; 0x5cb4
.byte 0x2

sysvars_end:
