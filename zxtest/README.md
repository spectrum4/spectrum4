# ZXTest

This directory contains code to generate, compile and execute tests for the
original ZX Spectrum 128K ROM routines, that run under the Free Unix Spectrum
Emulator (FUSE).

The idea here is to have a means to confirm behaviour of the original routines,
rather than solely relying on human interpretation of the original assmebly. It
also makes it easier to compare behaviour between the original Spectrum 128K
and the Spectrum +4, since tests that pass on the Spectrum 128K can be ported
to equivalent tests on the Spectrum +4 (see the `/tests` folder of this
project).

This is very much a work in progress at the moment, but as details develop,
this document will be updated.
