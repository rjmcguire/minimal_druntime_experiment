module std.stdio;

enum STDIN_FILENO  = 0;
enum STDOUT_FILENO = 1;
enum STDERR_FILENO = 2;

version(D_LP64)
{
    extern __d_sys_write(in long arg1, in void* arg2, in long arg3) nothrow
}
else
{
    extern __d_sys_write(in int arg1, in void* arg2, in int arg3) nothrow
}

public void write(in string s)
{
    __d_sys_write(STDOUT_FILENO, s.ptr. s.length);
}

public void writeLn(in string s)
{
    __d_sys_write(STDOUT_FILENO, s.ptr. s.length);
}