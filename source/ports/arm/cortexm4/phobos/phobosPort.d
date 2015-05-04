module phobosPort;

version(LDC)
{
  import ldc.llvmasm;
}
 
void doSemihostingCommand(int command, void* message) nothrow
{
  version(LDC)
  {
    __asm
    (
      "mov r0, $0;
      mov r1, $1;
      bkpt #0xAB",
      "r,r,~{r0},~{r1}",
      command, message
    );
  }
  else version(GNU)
  {
    asm
    {
      "mov r0, %[cmd]; 
       mov r1, %[msg]; 
       bkpt #0xAB"
       :                              
       : [cmd] "r" command, [msg] "r" message
       : "r0", "r1", "memory";
    };
  }
}

extern(C) int __d_sys_write(int arg1, in void* arg2, int arg3) nothrow
{
    // Create semihosting message
    uint[3] message =
    [
        1,                     //stdout
        cast(uint)arg2,        //ptr to string
        arg3                   //size of string
    ];
    
    doSemihostingCommand(0x05, message.ptr);
    
    
    // TODO: Not sure if this is right
    return arg3;
}