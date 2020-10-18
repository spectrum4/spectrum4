# Spectrum 4 tests

I've started working on a framework to enable testing of assembly routines.

The idea is that this directory will contain yaml files describing tests for the Spectrum +4 assembly routines.

The initial plan is that there will be a single yaml file per routine. The yaml file will contain structured data for setting up the test case:

* A heap initialisation section
* A register initialisation section
* A system variable initialisation section
* A heap validation section, for checking heap data after calling routine 
* A registry validation section for chekcing
