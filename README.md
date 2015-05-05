# minimal_druntime_experiment
An experiment to define the scope, feasibility, and architecural design details of a minimal runtime for the D programming language.

## Overview
There was recently a discussion about how we could create a portable, pay-as-you-go, D runtime to help bring the promise of D to free-standing platforms and devices with tight resource constraints (e.g. microcontrollers).  Thread started here:  http://forum.dlang.org/post/mhrs4p$31id$1@digitalmars.com

To keep that momentum going, prove the concept, and provide a place to start and discuss ideas, I created the most minimal D runtime I could.  I've also included phobos, so we could still have `std.stdio.write` and `std.stdio.writeln` for console output, as every device needs a console for development.

```
d
├── phobos
│   └── std
└── runtime
    └── rt
        └── typeinfo

ports
├── arm
│   └── cortexm4
│       ├── phobosWe
│       │   └── phobosPort.d
│       └── runtime
│           └── runtimePort.d
├── posix
│   └── linux
│       ├── phobos
│       │   └── phobosPort.d
│       └── runtime
│           ├── c_types.d
│           └── runtimePort.d
```

There are two main folders: "d" and "ports".  "d" provides the patform-agnostic code, or code that is relevant to a large number of platforms.  The "ports" directory provides the platform-specific implementation.  Building simply requires importing "d/runtime", "d/phobos", and your platform's hierarchy in the "ports" folder.  At the moment, I've only implemented a Linux 64-bit port and an ARM Cortex-M4 port to illustrate the concept.  This is roughly how I wish the official runtime could be structured in the spirit of [Issue 11666](https://issues.dlang.org/show_bug.cgi?id=11666).

The official runtime includes platform-specific bindings in [`core.sys`](https://github.com/D-Programming-Language/druntime/tree/master/src/core/sys) and [`stdc`](https://github.com/D-Programming-Language/druntime/tree/master/src/core/stdc), but I think that is a design anomaly.  While a port may find it convenient to use those bindings, they should not be part of the D language's public API.  Rather, they should be deported to [Deimos](https://github.com/D-Programming-Deimos), and if needed, imported privately by a platform's port.  For the Linux port, I chose to write the platform's system calls in assembly to illustrate that it is not even necessary to use those bindings if one wants to do the due diligence in D.

## Porting to a New Platform
The platform-agnostic code in [d](https://github.com/JinShil/minimal_druntime_experiment/tree/master/source/d) delgates implementation details to the platform-specific code using `extern(C) extern _d_sys_name` "system calls" (for lack of a better term).  This is how the [newlib C library delegates platform-specific implementations](http://wiki.osdev.org/Porting_Newlib#newlib.2Flibc.2Fsys.2Fmyos.2Fsyscalls.c)

At the moment, for the sake of demonstration, only 2 system calls have been defined:

* `__d_sys_write` - Equivalent to C's `write` system call
* `__d_sys_exit` - Equivalent to C's `exit` system call

These two system calls allow us to create a simple Hello World.  "runtimePort.d" implements `__d_sys_exit` and "phobosPort.d" implements the `__d_sys_write`.

## Putting it all Together
Users are not expected to use this code directly.  Rather, I envision toolchain, silicon, and board vendors will use this code as a small, but essential part of, their platform's D programming package.  For example, a package for the ARM Cortex-M family of MCUs might contain the following:

* arm-none-eabi GDC cross-compiler
* a library containing compiled code for the "d" folder in this repository
* a library containing the compiled code for the "ports/arm/cortexm" folders in this repository
* cortex-m core startup files
* the newlib C library
* the C library bindings from Deimos
* multilibs from the GNU toolchain.

A silicon vendor like ST, may then take that package and add more platform-specific for their family of products:

* startup files with interrupt vectors for their peripherals
* linker scripts for each of their MCUs
* flash memory programmer
* library for on-dye peripherals
* etc..

A board vendor may choose to create yet another layer on top of the silicon vendor's package.
* library for peripherals external to the MCU (external RAM, IO expanders, gyroscope, LCD, etc...)

In short, this repository just provides just the foundation to "get D working", and delegates to toolchain, silicon, and board vendors to fill in the details for their products.

## Building
You must have DMD installed because the build script uses rdmd.

The syntax of the build command is:
```
rdmd build.d compiler portDir
```
* *compiler* can be `dmd`, `gdc`, or `ldc`
* *portDir* is the folder containing the phobos/runtime port

Example.
* `rdmd build gdc posix/linux` - build using the Linux port using the DMD compiler 
* `rdmd build gdc posix/linux` - build using the Linux port using the GDC compiler
* `rdmd build gdc arm/cortexm4` - build using the ARM Cortex-M4 port using the GDC compiler.

Currently, those are the only build commands implemented.  The `rdmd build gdc arm/cortexm4` build command will build for the [STM32F29I Discovery Board](http://www.st.com/web/catalog/tools/FM116/SC959/SS1532/PF259090)
