module std.stdio;

enum STDIN_FILENO  = 0;
enum STDOUT_FILENO = 1;
enum STDERR_FILENO = 2;

version(D_LP64)
{
    extern(C) extern long __d_sys_write(const long arg1, const void* arg2, const long arg3) nothrow;
}
else
{
    extern(C) extern int __d_sys_write(const int arg1, const void* arg2, const int arg3) nothrow;
}

public void write(const string s)
{
    __d_sys_write(STDOUT_FILENO, s.ptr, s.length);
}

public void writeln(const string s)
{
    write(s);
    write("\n");
}