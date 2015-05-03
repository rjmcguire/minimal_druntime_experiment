#!/usr/bin/rdmd

import std.algorithm;
import std.array;
import std.file;
import std.path;
import std.process;
import std.stdio;

void main(string[] args)
{
    if (args.length < 2)
    {
        writeln("Usage: rdmd build.d {compiler} {compilerArgs}");
        return;
    }
    
    //TODO create object dir
    
    auto portsDir  = "ports";
    auto sourceDir = "source";
    auto binaryDir = "bin";
    auto appDir = "app";
    auto outputFile = buildPath(binaryDir, "test");
    
    string cmd = "rm -f outputFile";
    system(cmd);

    cmd = "";
    switch(args[1])
    {
        case "dmd":
            cmd = "dmd -defaultlib= -L-nodefaultlibs -L-nostdlib";
            break;
            
        case "gdc":
            // __entrypoint.di must exist or gdc won't compile
            cmd =  "touch include/__entrypoint.di";
            cmd ~= "; gdc -nophoboslib -nostdinc -nodefaultlibs -nostdlib -Iinclude";
            break;
            
        case "ldc":
            cmd = "ldc2 -c -singleobj -defaultlib= ";
            break;
            
        default:
            writeln("Uknown compiler: ", args[1]);
            return;
            break;
    }
    
    for(int i = 2; i < args.length; i++)
    {
        cmd ~= " " ~ args[i];
    }
    
    cmd ~= " " ~ sourceDir.dirEntries("*.d", SpanMode.depth).map!"a.name".join(" ");
    cmd ~= " " ~ portsDir.dirEntries("*.d", SpanMode.depth).map!"a.name".join(" ");
    cmd ~= " " ~ appDir.dirEntries("*.d", SpanMode.depth).map!"a.name".join(" ");
                  
    switch(args[1])
    {
        case "dmd":
            cmd ~= " -of" ~ outputFile;
            break;
            
        case "gdc":
            cmd ~= " -o " ~ outputFile;
            
            // remove __entrypoint.di since it what just needed for compilation
            cmd ~= "; rm include/__entrypoint.di";  
            break;
            
        case "ldc":
            cmd ~= " -of=" ~ outputFile;
            break;
            
        default:
            break;
            
    }
            
    writeln(cmd);
    system(cmd);
    
    //TODO create binary dir
}