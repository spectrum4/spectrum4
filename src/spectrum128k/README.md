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
that as routines as ported, similar unit tests will be created for the original
routines and the ported routines, to improve confidence that they have been
ported correctly.

To write one or more tests for ROM routine _ROM_routine_, create the test file:

`src/spectrum128k/test_<ROM_routine>[.<chunk>].s` where _ROM_routine_ is the
name of the routine defined in [src/spectrum128k/lib.s](../spectrum128k/lib.s).

If you are writing many tests, use `.<chunk>` to split them into chunks that
will fit into a single Spectrum 128K RAM page (which is 16KB).

For each test of the ROM routine, choose a unique name, and create _one or
more_ of the following assembly routines in the test file created:

* The `<test_name>_setup` routine should preconfigure RAM, prepare the stack,
  initialise hardware, etc, that is needed for the test.
* The `<test_name>_setup_regs` should prepare registers (including registers
  from the alternate register set if required) for the test.
* The `<test_name>_effects` routine should apply the same changes to RAM that
  the routine is expected to make.
* The `<test_name>_effects_regs` routine should update the registers in line
  with the changes the routine is expected to make.
* An unimplemented routine is equivalent to an empty one - any of the above
  routines can be skipped if not needed; only one routine is required in order
  for the test harness to include the test.

The test harness will call the _setup_ routines and then call the ROM routine
under test, and take a snapshot of the registers and RAM after the ROM routine
returns. It will also call the _setup_ routines followed by the _effects_
routines, and take another register/RAM snapshot. After this it will compare
the results, and report a test failure if there are any differences between the
two snapshots.

Note, each test file will be assembled into separate Spectrum 128K `.tzx` and
`.wav` files in order that test suites can easily be run independently of each
other, and also to avoid running out of memory on the Spectrum 128K to store
all of the unit tests.

The tests are executed by `all.sh`/`docker.sh` in the root directory. By
default, all tests are run, but this can be limited to a desired set. See
`all.sh -h` / `docker.sh -h` for more information.


## Generated tests

Sometimes it is useful to generate unit tests, for example, to iterate over
multiple inputs values. To generate tests, include a script in this directory
called `test_<something>.sh`. This should generate
`src/spectrum128k/test_<ROM_routine>[.<chunk>].s` files, with a warning comment
at the top of the file that the file is generated.


## Passing tests

When the porting of an assembly routine is finished, and its tests pass, the
tests can be disabled by moving them to the `passing_tests` subdirectory, in
order that they do not get run by default, in order to save time.

To reenable tests that are in the `passing_tests` subdirectory, simply move
them back into this directory.

Note, in the Github CI, all tests in the `passing_tests` subdirectory are
reinstated before calling `docker.sh`, in order to catch unwanted failures that
might otherwise go unnoticed.
