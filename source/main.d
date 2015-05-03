module main;

import std.stdio;

//To ensure structs compile
struct TestStruct
{
    immutable string testMemberVar = "struct member";
    
    void testMethod()
    {
        writeln(testMemberVar);
    }
}

//To ensure classes compile
//Only static right now, as we don't want to reqire dynamic memory allocation
//in this runtime.  It eventually should be added, but we still need to work out
//the details
class TestClass
{
    static immutable string testMemberVar = "class member";
    
    static void testMethod()
    [
        writeln(testMemberVar);
    }
}

void main()
{
    writeln("Hello World");

    TestStruct ts;
    ts.testMethod();
    
    TestClass.testMethod();
    
    //If it doesn't segfault after here, then __d_sys_exit works
}