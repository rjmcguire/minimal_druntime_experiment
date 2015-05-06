/**
 * Forms the symbols available to all D programs. Includes Object, which is
 * the root of the class object hierarchy.  This module is implicitly
 * imported.
 * Macros:
 *      WIKI = Object
 *
 * Copyright: Copyright Digital Mars 2000 - 2011.
 * License:   $(WEB www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors:   Walter Bright, Sean Kelly
 */

/*          Copyright Digital Mars 2000 - 2011.
 * Distributed under the Boost Software License, Version 1.0.
 *    (See accompanying file LICENSE or copy at
 *          http://www.boost.org/LICENSE_1_0.txt)
 */
module object;

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
    version(DigitalMars)
    {
        //DMD complains if this doesn't exist
        size_t getHash(in void* p) @trusted nothrow const { return cast(size_t)p; }
    }
}

class TypeInfo_Typedef
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
        // See https://github.com/ldc-developers/ldc/issues/781
        version(LDC)  
        {
            byte[]                init;
            string                name;
            void*[]               vtbl;
            void*[]               interfaces;
            TypeInfo_Class        base;
            void*                 destructor;
            void function(Object) classInvariant;
            uint                  m_flags;
            void*                 deallocator;
            void*[]               m_offTi;
            void function(Object) defaultConstructor;  
            immutable(void)*      m_RTInfo;           
        }
        else
        {
            ubyte[136] ignore;
        }
    }
    else
    {
        ubyte[68] ignore;
    }
}

version(DigitalMars)
{
    //DMD complains if this does not exist
    class TypeInfo_Array : TypeInfo
    {
        
    }
}

class TypeInfo_Enum : TypeInfo_Typedef
{

}

class TypeInfo_Invariant : TypeInfo_Const
{
    
}

version(DigitalMars)
{
    //DMD complains if this does not exist
    class TypeInfo_Pointer : TypeInfo
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

// Only LDC seems to require this
version(LDC)
{
    class TypeInfo_AssociativeArray : TypeInfo
    {
        //TypeInfo value;
        //TypeInfo key;
        version(D_LP64)
        {
            ubyte[16] ignore;
        }
        else
        {
            ubyte[8] ignore;
        }
    }
}

bool _xopEquals(in void*, in void*)
{
    // TODO: errror here.  Not supported
    return false;
}
