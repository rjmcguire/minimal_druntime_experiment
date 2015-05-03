module dmain;

version(D_LP64)
{
    extern __d_sys_exit(long code);
}
else
{
    extern __d_sys_exit(int code);
}

private alias extern(C) int function(char[][] args) MainFunc;
private extern (C) int _d_run_main(int argc, char** argv, MainFunc mainFunc)
{
    return mainFunc(null);
}

// DMD & LDC will insert it's own C main
version(DigitalMars)
{
    version = CompilerInsertsMain;
}
version(LDC)
{
    version = CompilerInsertsMain;
}
version (CompilerInsertsMain)
{
    extern(C) int main(int argc, char** argv);
}

// GDC expects C main to be supplied by the runtime
version (GNU)
{
    // This seems to be supplied by the compiler
    private extern(C) int _Dmain(char[][] args);
    
    private extern(C) int main(int argc, char** argv)
    {
        return _d_run_main(argc, argv, &_Dmain);
    }
}