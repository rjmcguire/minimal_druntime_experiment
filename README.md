# minimal_druntime_experiment
An experiment to define the scope, feasibility, and architecural design details of a minimal runtime for the D programming language.

The motivating goal is to make it possible to program resource-constrained microcontrollers in D, but there may be uses outside of that domain.

This implementation discourages exposing platform bindings through the runtime as is currently done in the [official repository](https://github.com/D-Programming-Language/druntime/tree/master/src/core/sys).  Rather, if platform bindings are used, they should be maintained as a separate project and then privately imported and encapsulated in the platform's port.  The same applies to [`stdc`](https://github.com/D-Programming-Language/druntime/tree/master/src/core/stdc).

## Porting

```
d
??? phobos
??? ??? std
??? runtime
```

The implementation of the D language is in the [`d`](https://github.com/JinShil/minimal_druntime_experiment/tree/master/source/d) folder.  There one can find two subfolders [`d/phobos`](https://github.com/JinShil/minimal_druntime_experiment/tree/master/source/d/phobos) and [`d/runtime`](https://github.com/JinShil/minimal_druntime_experiment/tree/master/source/d/runtime) implementing the D standard library (Phobos), and the D runtime respectively.  However, those implementations have "system calls" (for lack of a better word) that must be implemented by the ports.  At the moment, for the sake of demonstration, only 2 system calls have been defined:
* `__d_sys_write` - Equivalent to C's `write` system call
* `__d_sys_exit` - Equivalent to C's `exit` system call

Each port, then implements those system calls as required by the underlying platform, and adds its source files to the [`ports`](https://github.com/JinShil/minimal_druntime_experiment/tree/master/source/ports) folder.  This is more or less how I wish [Issue 11666](https://issues.dlang.org/show_bug.cgi?id=11666) could be implemented:

```
ports
??? arm
??? ??? cortexm4
???     ??? phobos
???     ??? ??? phobosPort.d
???     ??? runtime
???         ??? runtimePort.d
??? posix
??? ??? linux
???     ??? phobos
???     ??? ??? phobosPort.d
???     ??? runtime
???         ??? c_types.d
???         ??? runtimePort.d
```

`phobosPort.d` provides the necessary system calls to for Phobos and `runtimePort.d` provides the necessary system calls for the D runtime.  

As new ports are added, the [`ports`](https://github.com/JinShil/minimal_druntime_experiment/tree/master/source/ports) folder becomes potentially larger and deeper.

## Building
You must have DMD installed because the build script uses rdmd.

The syntax of the build command is:
```
rdmd build.d compiler portDir
```
*compiler* can be `dmd`, `gdc`, or `ldc`
*portDir* is the folder containing the phobos/runtime port

Example.
`rdmd build gdc posix/linux` - build using the Linux port using the DMD compiler 
`rdmd build gdc posix/linux` - build using the Linux port using the GDC compiler
`rdmd build gdc arm/cortexm4` - build using the ARM Cortex-M4 port using the GDC compiler.

Currently, those are the only build commands implemented.  The `rdmd build gdc arm/cortexm4` build command will build for the [STM32F29I Discovery Board](http://www.st.com/web/catalog/tools/FM116/SC959/SS1532/PF259090)