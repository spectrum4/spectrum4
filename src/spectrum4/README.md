<!--
This file is part of the Spectrum +4 Project.
Licencing information can be found in the LICENCE file
(C) 2021 Spectrum +4 Authors. All rights reserved.
-->

# Spectrum +4 debug profile

The debug profile of Spectrum +4 contains the following features in addition to
the release profile:

  * Debug messages are logged to the UART interface
  * Some features of the Spectrum +4 are demoed on startup, to aid manual
    testing of audio and visual features

# Spectrum +4 tests profile

## Motivation

The test framework exists to validate that Spectrum +4 routines (ported from the
original ZX Spectrum 128K Z80 assembly) produce identical side-effects to the
originals. Each routine, when called with a given set of register inputs and
specific memory values, should always produce the same register outputs and
memory writes. The framework makes this testable by:

1. Declaring the inputs (registers + memory) a routine depends on
2. Filling everything else with random noise to catch undeclared dependencies
3. Running the routine and capturing what changed
4. Comparing the actual side-effects against declared expectations

This same test format is used for both the original Spectrum 128K routines and
the ported Spectrum +4 routines, so tests can be directly ported between
platforms to validate equivalent behaviour.

## How it works

For each test case, the harness (`run_tests` in `tests/runtests.s`) performs the
following steps:

### 1. Prepare random noise

A random byte sequence of random length is generated and overlaid across
writable RAM (excluding the `.text` section). This ensures that any register or
memory location the routine under test does not explicitly depend on will hold
unpredictable values. If the routine accidentally reads from or writes to an
undeclared location, the random noise will (with high probability across
multiple test runs) cause the test to fail.

### 2. Take a pristine snapshot

The entire RAM state is compressed and stored. The compression works by XOR-ing
each 8-byte quad of memory against the corresponding position in the repeating
random sequence. Since most of memory is filled with the random sequence itself,
the XOR produces long runs of zeros, which compress efficiently using a simple
run-length encoding scheme: a magic value (`0x6a09e667bb67ae85`) followed by a
repeat count, followed by the repeated XOR'd value.

### 3. Run test setup

The test's `<test_name>_setup` routine configures specific memory locations
(e.g., system variables, channel blocks) that the routine under test depends on.
The test's `<test_name>_setup_regs` routine sets specific register values. All
other registers are left with the random values from step 1.

### 4. Snapshot pre-test state and call the routine

A pre-test snapshot captures the full register file and compressed RAM state.
The routine under test is then called. After it returns, a post-test snapshot
captures the resulting register file and compressed RAM.

### 5. Restore pre-test state and apply expected effects

RAM is restored to the pre-test state. The test's `<test_name>_effects` routine
is called to apply the **expected** memory changes, and
`<test_name>_effects_regs` applies the expected register changes. This produces
an "expected" snapshot.

### 6. Compare actual vs expected

The harness compares the post-test snapshot (what the routine actually did)
against the expected snapshot (what the test declares it should do). Any
differences — unexpected register changes, unexpected memory writes, or missing
expected changes — are reported as failures via UART, showing the pre-test
value, the actual post-test value, and the expected value.

### Why random noise catches bugs

If a routine writes to a memory location that isn't declared in the test's
effects, the write will be detected because the random noise at that address
will differ from the expected random noise. Even if by coincidence the written
value matches the random noise in one run, a subsequent run with a different
random sequence will catch it. Similarly, if a routine reads from an undeclared
memory location, the random value there will produce incorrect outputs that
the register/memory comparison will flag.

## Writing test cases

Each test case consists of up to four routines, all optional (at least one
required):

| Routine | Purpose |
|---------|---------|
| `<test>_setup` | Configure RAM that the routine depends on |
| `<test>_setup_regs` | Set input register values |
| `<test>_effects` | Apply expected memory changes |
| `<test>_effects_regs` | Apply expected register changes |

An unimplemented routine is equivalent to an empty one (no setup / no expected
changes).

### Example: `test_po_change.s`

```asm
# Test data: a fake channel block in memory, initialised with a known input
# routine address. We need this so that CURCHL can point to it (CURCHL holds
# the address of the current channel block, not the block itself).
.align 3
po_change_1_channel_block:
  .quad 0x0123456789abcdef

# Setup: set [CURCHL] to point to our test channel block
po_change_1_setup:
  _str    po_change_1_channel_block, CURCHL
  ret

# Setup registers: x4 = the new input routine address to write
po_change_1_setup_regs:
  ldr     x4, =0xfedbca9876543210
  ret

# Expected memory effect: channel block updated with new value
po_change_1_effects:
  _str    0xfedbca9876543210, po_change_1_channel_block
  ret

# Expected register effect: x5 = address of channel block
po_change_1_effects_regs:
  adr     x5, po_change_1_channel_block
  ret
```

## Cross-platform validation

The same test format is used for both Spectrum 128K and Spectrum +4:

- `src/spectrum128k/tests/` — tests against the original Z80 ROM routines
- `src/spectrum4/tests/` — tests against the ported AArch64 routines

When porting a routine, the workflow is:

1. Write tests against the original Spectrum 128K routine to validate your
   understanding of its behaviour
2. Port the routine to Spectrum +4 (AArch64)
3. Port the test cases to the Spectrum +4 test harness
4. Verify both test suites pass — confirming equivalent behaviour

## Unit tests

Unit tests are written for both the original Spectrum 128K ROMs and for the new
Spectrum +4 routines.

Ideally equivalent tests should exist for both platforms, so if you are adding
Spectrum +4 tests, you are encouraged to add equivalent Spectrum 128K tests
(and vice versa).

The Spectrum +4 test framework and the Spectrum 128K test framework use the
same format for defining test cases. See the [Spectrum 128K
README](../spectrum128k/README.md) for details on writing tests, generating
tests, and disabling passing tests.
