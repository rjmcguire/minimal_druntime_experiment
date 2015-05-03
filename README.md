# minimal_druntime_experiment
An experiment to define the scope and feasibility of a minimal runtime for the D programming language.

The motivating goal is to make it possible to program resource-constrained microcontrollers in D, but that is likely on the only goal with this runtime.  

The source code currently only supports Linux 64-bit.  This should help make the development more convenient, allow broader participation for those without microcontroller hardware, and also remaining platform agnostic.  It is hoped that this repository will serve as a scratch pad for defining the inital scope and overall design.

## Porting
Porting is done by implementing the `__d_sys_` system calls.  At the moment only `__d_sys_write` and `__d_sys_exit` are defined.

It would be convenient to just use libc for this, but this effort is trying to make libc opt in rather than a prerequisite.

## Building
You must have DMD installed because the build script uses rdmd.

Simply run `rdmd build`.