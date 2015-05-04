module stdLibPort;

import c_types;

extern(C) c_int __d_sys_write(c_int arg1, in void* arg2, c_int arg3) nothrow
{
    ssize_t result;
    
    version(D_LP64)
    {
        version(DigitalMars)
        {
            asm nothrow
            {
                mov RAX, 1;
                mov RDI, arg1;
                mov RSI, arg2;
                mov RDX, arg3;
                syscall;
            }
        }
        else version(GNU)
        {
            asm
            {
                "syscall"       // make the request to the OS 
                : "=a" result   // return result in rax ("a")
                : "a" 1,        // pass system call number in rax ("a")
                "D" arg1,       // pass arg1 in rdi ("D")
                "S" arg2,       // pass arg2 in rsi ("S")
                "m" arg2,       // arg2 is a pointer to memory
                "d" arg3        // pass arg3 in rdx ("d")
                : "memory", "cc", "rcx", "r11";  // announce to the compiler that the memory and condition codes 
                                                 // have been modified, kernel may clopper rcx and r11
            } 
        }
        else
        {
            static assert(false, "__d_sys_write only supports DMD and GDC");
        }
    }
    else
    {
        static assert(false, "__d_sys_write only supports 64-bit");
    }
    
    
    // TODO: Not sure if this is right
    return result;
}