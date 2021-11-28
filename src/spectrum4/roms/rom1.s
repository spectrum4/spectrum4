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


.text
.align 2


.include "error_1.s"
.include "print_w0.s"
.include "tkn_table.s"

.align 2

.include "print_out.s"
.include "ctlchrtab.s"
.include "po_back.s"
.include "po_right.s"
.include "po_enter.s"
.include "po_comma.s"
.include "po_quest.s"

# --------------------------------
# Control characters with operands
# --------------------------------
# Certain control characters are followed by 1 or 2 operands.
# The entry points from control character table are po_1_oper and po_2_oper.
# The routines alter the output address of the current channel so that
# subsequent RST 10 instructions take the appropriate action
# before finally resetting the output address back to PRINT-OUT.

.include "po_tv_2.s"
.include "po_2_oper.s"
.include "po_1_oper.s"
.include "po_tv_1.s"
.include "po_change.s"
.include "po_cont.s"
.include "po_at_set.s"
.include "po_tab.s"
.include "to_report_bb.s"
.include "to_co_temp_5.s"
.include "to_end.s"
.include "po_fill.s"
.include "po_able.s"
.include "po_store.s"
.include "po_fetch.s"
.include "po_any.s"
.include "po_mosaic_half.s"
.include "po_t_udg.s"
.include "rejoin_po_t_udg.s"
.include "po_char.s"
.include "po_char_2.s"
.include "pr_all.s"
.include "po_attr.s"
.include "po_msg.s"
.include "po_tokens.s"
.include "po_table.s"
.include "po_table_1.s"

# Nothing needed, since on Spectrum 128, PO-SAVE just calls RST 10H (print_w0),
# but preserves DE, which would otherwise be corrupted. We have far more
# registers available in aarch64, so no wrapper needed.
# po_save:                         // L0C3B

.include "po_search.s"
.include "po_scr.s"

.align 3

.include "temps.s"
.include "cls.s"
.include "cls_lower.s"
.include "cl_chan.s"
.include "cl_all.s"
.include "cl_set.s"
.include "cl_line.s"
.include "cl_addr.s"
.include "copy_buff.s"
.include "add_char.s"
.include "add_ch_1.s"
.include "key_input.s"
.include "chan_open.s"
.include "chan_flag.s"
.include "chn_cd_lu.s"
.include "chan_k.s"
.include "chan_s.s"
.include "chan_p.s"
.include "one_space.s"
.include "make_room.s"
.include "indexer.s"
.include "report_j.s"
.include "report_bb.s"
.include "co_temp_5.s"
.include "print_token_udg_patch.s"

.include "new_tokens.s"
