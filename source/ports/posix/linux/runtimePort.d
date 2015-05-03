module runtimePort;

import c_types;

// can be found in druntime (rt/dmain2.d)
extern(C) int main(int argc, char** argv);

void __d_sys_exit(c_int arg1) nothrow
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
        version(GNU)
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
        else
        {
            static assert(false, "__d_sys_exit only supports GDC");
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