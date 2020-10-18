# Spectrum 4 tests

I've started working on a framework to enable testing of assembly routines.

The idea is that this directory will contain yaml files describing tests for
the Spectrum +4 assembly routines.

These will be compiled into assembly tests, which will be included in the debug
build of Spectrum +4, and run on start up. They will not be included in the
release builds of Spectrum +4.

Each test case will contain a setup section, and a validation section. The
tests are intended to run directly on the RPi 3B (or possibly under an emulator
such as QEMU, if possible).

* The Spectrum +4 standard initialisation will occur
* Each test case will be run in sequence
  - A log message will be written to UART to log the test case which is running
  - Random data will be written to registers and system variables
  - The test case setup will configure registers, system variables, and
    initialise memory used by the routine
  - The registers and system variables will copied to the stack
  - The routine will be called
  - The updated registers and updated system variables will be copied to the
    stack
  - The registers and system variables and initialised memory will be checked
    against the expected results defined in the test case
  - The test case result will be logged to UART with as much detail as possible
    in the case of a failure
* The RPi 3B will perform a demonstration of some features, such as playing
  music and displaying graphics.
* The RPi 3B will continue running Spectrum 4+ as normal.

## Test case format

This directory will contain yaml files, each containing logically grouped test
cases. Initially I intend to create a single file per routine under test, but
this is not a requirement.

Each test case will contain the following high level information:

* A memory initialisation section
* A register initialisation section
* A system variable initialisation section
* A memory validation section
* A registry validation section
* A system variable validation section

Further details of the exact format will follow soon, as the code and the tests
are implemented.
