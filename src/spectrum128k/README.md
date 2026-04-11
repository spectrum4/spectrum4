<!--
This file is part of the Spectrum +4 Project.
Licencing information can be found in the LICENCE file
(C) 2021-2026 Spectrum +4 Authors. All rights reserved.
-->

# Spectrum 128K routines

This directory contains:

  * The original ZX Spectrum 128K ROM routines
  * A test harness with unit tests for the original ROM routines

## Unit tests

The motivation for writing unit tests against the original ROM routines is to
have a means to validate the behaviour of the original ROM routines. This helps
to ensure that routines are ported correctly to the Spectrum +4 codebase, by
testing that the original routines behave as expected.

The [src/spectrum4](../spectrum4) directory has a similar test harness and unit
tests for testing the ported Spectrum +4 routines. In general it is anticipated
that as routines are ported, similar unit tests will be created for the original
routines and the ported routines, to improve confidence that they have been
ported correctly. See the [Spectrum +4 README](../spectrum4/README.md) for a
detailed explanation of how the test framework works (the random noise approach,
snapshot compression, and comparison logic).

## Adding a new test suite

To add tests for ROM routine `<routine>`, create the test file:

```
src/spectrum128k/tests/test_<routine>[.<chunk>].s
```

Where `<routine>` is the name of the routine as defined in
[src/spectrum128k/roms/rom1.s](roms/rom1.s), and `<chunk>` is an optional
short descriptive name for the test group.

If you are writing many tests, use `.<chunk>` to split them into chunks that
will fit into a single Spectrum 128K RAM page (which is 16KB).

**Only the `.s` file needs to be created.** The build system automatically
generates:

  * `test_<routine>.<chunk>.runner` - the test runner (via `tests.sh`)
  * `test_<routine>.<chunk>.tzx` / `.wav` - tape files for the Fuse emulator
  * The `.elf`, `.img`, `.o`, `.disassembly`, `.symbols` build artefacts

The routine to test is inferred from the filename: `test_po_scr.printer.s`
tests the routine `po_scr`. The test harness calls the routine automatically;
the test routines only need to declare the setup and expected effects.

## Writing test routines

For each test case, choose a unique name and create one or more of the
following assembly routines in the test file:

| Routine | Purpose |
|---------|---------|
| `<test>_setup` | Preconfigure RAM (system variables, channel blocks, etc.) |
| `<test>_setup_regs` | Set input register values and flags |
| `<test>_effects` | Apply the expected RAM changes the routine should make |
| `<test>_effects_regs` | Set the expected register values after the routine |

An unimplemented routine is equivalent to an empty one - any of the above
can be skipped if not needed; only one routine is required in order for the
test harness to include the test.

The test harness will:

1. Call the setup routines, then call the ROM routine under test
2. Call the setup routines, then call the effects routines
3. Compare the two snapshots and report any differences as failures

### Available macros

The following macros from `tests/lib.s` are available in test routines:

| Macro | Description |
|-------|-------------|
| `_strb val, SYSVAR` | Store byte `val` to system variable address |
| `_strh val, SYSVAR` | Store 16-bit `val` to system variable address |
| `_setbit bit, SYSVAR` | Set bit `bit` at system variable address |
| `_resbit bit, SYSVAR` | Clear bit `bit` at system variable address |
| `ldf val` | Load F register with `val` |
| `f_clear_set clear, set` | Clear and set specific flag bits |

Z80 flag constants are also defined: `C_FLAG`, `N_FLAG`, `PV_FLAG`, `X3_FLAG`,
`H_FLAG`, `X5_FLAG`, `Z_FLAG`, `S_FLAG`.

### Important notes

  * The effects routines should declare the expected state, not call the
    routine under test. Spell out every expected RAM and register change
    explicitly.
  * ROM symbols are only available if they are declared `.global` in
    `roms/rom1.s`. Internal ROM labels cannot be referenced from test code.
  * If an effects routine needs to replicate complex ROM behaviour (e.g.,
    scrolling), it is acceptable to call the routine under test from the
    effects routine - but take care not to call it from both effects and
    effects\_regs, as this would execute the routine twice and may produce
    different results (e.g., decrementing a counter twice).
  * Tests run inside the Fuse Spectrum 128K emulator. Routines that block
    waiting for user input (e.g., the "scroll?" prompt) will cause a timeout.

## Generated tests

Sometimes it is useful to generate unit tests, for example, to iterate over
multiple input values. To generate tests, include a script in this directory
called `test_<something>.sh`. This should generate
`src/spectrum128k/tests/test_<routine>[.<chunk>].gen-s` files. See
`test_po_scr.sh` for an example. Be sure to add a line to
`src/spectrum128k/tests/Tupfile` to include your script; it will not be
detected automatically.
