# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
.align 2

# ---------
# Make Room
# ---------
# This entry point is used to create BC spaces in various areas such as
# program area, variables area, workspace etc..
# The entire free RAM is available to each BASIC statement.
# On entry, HL addresses where the first location is to be created.
# Afterwards, HL will point to the location before this.
make_room:                               // L1655
  // TODO
  ret
