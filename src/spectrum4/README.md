# Spectrum +4 debug profile

The debug profile of Spectrum +4 contains the following features in addition to
the release profile:

  * Debug messages are logged to the UART interface
  * Some features of the Spectrum +4 are demoed on startup, to aid manual
    testing of audio and visual features

# Spectrum +4 tests profile

On start up:

  * The Spectrum +4 standard initialisation occurs
  * The test harness runs each test case in sequence
    * A message is written to UART logging the active test case
    * Random data is written to registers and RAM
    * The test case setup routines configure registers and RAM for the test
    * The registers and are copied to the stack, and the RAM is snapshotted (1)
    * The test case effects routines update registers and RAM
    * The registers and are copied to the stack, and the RAM is snapshotted (2)
    * The post-setup registers/RAM snapshots are reinstated (1)
    * The routine under test is called
    * The registers and are copied to the stack, and the RAM is snapshotted (3)
    * The snapshots (2) and (3) are compared, and differences are logged to UART
    as test failures with state recorded from snapshots (1), (2) and (3)
  * The Raspberry Pi performs a demonstration of audio and visual features
  * The Raspberry Pi continues running Spectrum +4 as normal

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
