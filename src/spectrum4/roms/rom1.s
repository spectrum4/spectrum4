# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

################################################################################################
# These routines are a translation of the original Z80 ROM 1 routines on the 128K Spectrum.
#
# The translation has been performed using Paul Farrow's 128K ROM 1 disassembly as principal reference:
#   * http://www.fruitcake.plus.com/Sinclair/Spectrum128/ROMDisassembly/Files/Disassemblies/Spectrum128_ROM1.zip
# which in turn is based on Geoff Wearmouth's 48K ROM disassembly (almost identical to 128K ROM 1):
#   * https://web.archive.org/web/20150618024638/http://www.wearmouth.demon.co.uk/zx82.htm
# together with Dr Ian Logan and Dr Frank O'Hara's original 48K ROM disassembly from January 1983:
#   * https://archive.org/details/CompleteSpectrumROMDisassemblyThe/mode/2up
# and Richard Dymond's additions:
#   * https://skoolkit.ca/disassemblies/rom/hex/maps/all.html
#
# In addition, using the fantastic Retro Virtual Machine v2.0 BETA-1 r7 from Juan Carlos Gonzalez Amestoy:
#   * http://www.retrovirtualmachine.org/en/downloads
# it has been possible to run the ROM routines through a debugger, to validate assumptions
# about the behaviour and fine-tine the descriptions.
#
# Note, the original routines have also been intentionally adapted to take advantage of the improved
# hardware of the Raspberry Pi 3B, such as more memory and higher screen resolution. Please see
# the top level README.md document for more information.
################################################################################################

.include "error_1.s"                     // L0008
.include "print_w0.s"                    // L0010
.include "tkn_table.s"                   // L0095
.include "print_out.s"                   // L09F4
.include "ctlchrtab.s"                   // L0A11
.include "po_back.s"                     // L0A23
.include "po_right.s"                    // L0A3D
.include "po_enter.s"                    // L0A4F
.include "po_comma.s"                    // L0A5F
.include "po_quest.s"                    // L0A69
.include "po_tv_2.s"                     // L0A6D
.include "po_2_oper.s"                   // L0A75
.include "po_1_oper.s"                   // L0A7A
.include "po_tv_1.s"                     // L0A7D
.include "po_change.s"                   // L0A80
.include "po_cont.s"                     // L0A87
.include "po_fill.s"                     // L0AC3
.include "po_able.s"                     // L0AD9
.include "po_store.s"                    // L0ADC
.include "po_fetch.s"                    // L0B03
.include "po_any.s"                      // L0B24
.include "po_mosaic_half.s"              // L0B3E
.include "po_t_udg.s"                    // L0B52
.include "rejoin_po_t_udg.s"             // L0B56
.include "po_char.s"                     // L0B65
.include "po_char_2.s"                   // L0B6A
.include "pr_all.s"                      // L0B7F
.include "po_attr.s"                     // L0BDB
.include "po_msg.s"                      // L0C0A
.include "po_tokens.s"                   // L0C10
.include "po_table.s"                    // L0C14
.include "po_table_1.s"                  // L0C17
.include "po_search.s"                   // L0C41
.include "po_scr.s"                      // L0C55
.include "temps.s"                       // L0D4D
.include "cls.s"                         // L0D6B
.include "cls_lower.s"                   // L0D6E
.include "cl_chan.s"                     // L0D94
.include "cl_all.s"                      // L0DAF
.include "cl_set.s"                      // L0DD9
.include "cl_line.s"                     // L0E44
.include "cl_addr.s"                     // L0E9B
.include "copy_buff.s"                   // L0ECD
.include "add_char.s"                    // L0F81
.include "add_ch_1.s"                    // L0F8B
.include "key_input.s"                   // L10A8
.include "report_j.s"                    // L15C4
.include "chan_open.s"                   // L1601
.include "chan_flag.s"                   // L1615
.include "chn_cd_lu.s"                   // L162D
.include "chan_k.s"                      // L1634
.include "chan_s.s"                      // L1642
.include "chan_p.s"                      // L164D
.include "one_space.s"                   // L1652
.include "make_room.s"                   // L1655
.include "indexer.s"                     // L16DC
.include "report_bb.s"                   // L1E9F
.include "co_temp_5.s"                   // L2211
.include "pixel_addr.s"                  // L22AA
.include "print_token_udg_patch.s"       // L3B9F
.include "new_tokens.s"                  // L3BD2
.include "tv_tuner.s"                    // L3C10
