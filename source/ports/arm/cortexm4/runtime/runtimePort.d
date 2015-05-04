module runtimePort;

//Must be stored as second 32-bit word in .text section
alias void function() ISR;
extern(C) immutable ISR ResetHandler = &OnReset;

// can be found in druntime (rt/dmain2.d)
extern(C) int main(int argc, char** argv);

extern(C) void __d_sys_exit(int arg1) nothrow
{
    // Nothing to return to in a bare-metal port
    while(true) { }
}

// Call main and exit
private extern(C) void _start()
{
    int ret = main(0, null);
    __d_sys_exit(ret);
}

void OnReset()
{
    // copy data segment out of ROM and into RAM
    memcpy(&__data_start__, &__text_end__, &__data_end__ - &__data_start__);

    // zero out variables initialized to void
    memset(&__bss_start__, 0, &__bss_end__ - &__bss_start__);
    
    //call main
    int ret = main(0, null);
    
    //return to caller
    __d_sys_exit(ret);
}

// defined in the linker
extern(C) extern __gshared ubyte __text_end__;
extern(C) extern __gshared ubyte __data_start__;
extern(C) extern __gshared ubyte __data_end__;
extern(C) extern __gshared ubyte __bss_start__;
extern(C) extern __gshared ubyte __bss_end__;

extern(C) void* memset(void* dest, int value, size_t num)
{
    // naive implementation for the moment.  Eventually,
    // this should be implemented in assembly
    
    byte* d = cast(byte*)dest;
    for(int i = 0; i < num; i++)
    {
        d[i] = cast(byte)value;
    }
    
    return dest;
} 

extern(C) void* memcpy(void* dest, void* src, size_t num)
{    
    // naive implementation for the moment.  Eventually,
    // this should be implemented in assembly
    
    ubyte* d = cast(ubyte*)dest;
    ubyte* s = cast(ubyte*)src;
    
    for(int i = 0; i < num; i++)
    {
        d[i] = s[i];
    }
    
    return dest;
} 