module runtimePort;

import c_types;

// can be found in druntime (rt/dmain2.d)
extern(C) int main(int argc, char** argv);

// can't make this nothrow due to https://github.com/ldc-developers/ldc/issues/925
extern(C) void __d_sys_exit(c_int arg1)
{
    version(D_LP64)
    {
        version(DigitalMars)
        {
            asm
            {
                mov RAX, 60;
                mov RDI, arg1;
                syscall;
            } 
        }
        else version(GNU)
        {
            asm 
            {
                "syscall"       // make the request to the OS 
                :               // no return
                : "a" 60,       // pass system call number in rax ("a")
                "D" arg1,       // pass arg1 in rdi ("D")
                : "memory", "cc", "rcx", "r11";  // announce to the compiler that the memory and condition codes 
                                                 // have been modified, kernel may clopper rcx and r11
            } 
        }
        else version(LDC)
        {
            import ldc.llvmasm;
            
            __asm
            (
                "syscall", 
                "{rax},
                {rdi},,
                ~{memory},~{cc},~{rcx},~{r11}", 
                60, arg1
            );
        }
    }
    else
    {
        static assert(false, "__d_sys_exit only supports 64-bit");
    }
}

// Call main and exit
private extern(C) void _start()
{
    int ret = main(0, null);
    __d_sys_exit(ret);
}

version(DigitalMars)
{
    version = NeedsDSORegistry;
}
else version(LDC)
{
    version = NeedsDSORegistry;
}

version(NeedsDSORegistry)
{
    // seems to be only used for linux, and only on 64-bit
    version(D_LP64)
    {
        extern(C) void _d_dso_registry(void* data)
        {

        }
    }
}