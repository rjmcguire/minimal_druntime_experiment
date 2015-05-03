module object;

version(D_LP64)
{ }
else
{
    static assert(false, "Currently only 64-bit is supported");
}

alias size_t    = typeof(int.sizeof);
alias ptrdiff_t = typeof(cast(void*)0 - cast(void*)0);
alias string    = immutable(char)[];

extern(C) __gshared void* _Dmodule_ref;

struct ModuleInfo
{ 
    uint _flags;
    uint _index;
}

class Object
{ 

}

class TypeInfo 
{ 
    
}

class TypeInfo_Struct : TypeInfo 
{
    version(D_LP64)
    {
        ubyte[120] ignore;
    }
    else
    {
        ubyte[52] ignore;
    }
}

class TypeInfo_Interface : TypeInfo 
{
    version(D_LP64)
    {
        ubyte[8] ignore;
    }
    else
    {
        ubyte[4] ignore;
    }
}

class TypeInfo_Class : TypeInfo 
{
    version(D_LP64)
    {
        ubyte[136] ignore;
    }
    else
    {
        ubyte[68] ignore;
    }
}


class TypeInfo_Enum : TypeInfo_Typedef
{

}

class TypeInfo_Delegate : TypeInfo
{
    version(D_LP64)
    {
        ubyte[24] ignore;
    }
    else
    {
        ubyte[12] ignore;
    }
}

class TypeInfo_Const : TypeInfo
{
    version(D_LP64)
    {
        ubyte[8] ignore;
    }
    else
    {
        ubyte[4] ignore;
    }
}

// This is needed by ModuleInfo, but only for 64-bit builds
// version(D_LP64)
// {
//     class TypeInfo_l : TypeInfo
//     {
// 
//     }
// }
