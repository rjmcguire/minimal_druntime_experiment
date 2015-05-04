#!/usr/bin/rdmd

import std.algorithm;
import std.array;
import std.file;
import std.path;
import std.process;
import std.stdio;

bool execute(string cmd)
{
    writeln(cmd);
    return system(cmd) == 0;
    //return r.status == 0;
}

void main(string[] args)
{
    // Ensure we have the right number of arguments
    if (args.length < 3)
    {
        writeln("Usage: rdmd build.d compiler portDir");
        return;
    }
    
    // enumerate the directory structure
    auto sourceDir = "source";
    auto ddir = buildPath(sourceDir, "d");
    auto runtimeDir = buildPath(ddir, "runtime");
    auto phobosDir = buildPath(ddir, "phobos");
    auto portsDir = buildPath(sourceDir, "ports");
    auto portDir = buildPath(portsDir, args[2]);
    
    if (!exists(portDir))
    {
        writeln("Directory '" ~ portDir ~ "' does not exist.");
        return;
    }
    
    auto objDir = "obj";
    auto outDir = "bin";

    //make sure intermediate and output directories exists
    if (!exists(objDir))
    {
        mkdir(objDir);
    }
    
    if (!exists(outDir))
    {
        mkdir(outDir);
    }
    
    // determine target
    enum targets
    {
        linux = "linux",
        cortexm = "cortexm",
        unknown = "unknown"
    }
    targets target = targets.unknown;
    if (!args[2].find("arm" ~ dirSeparator ~ "cortex-m").empty)
    {
        target = target.cortexm;
    }
    else if (!args[2].find("posix" ~ dirSeparator ~ "linux").empty)
    {
        target = targets.linux;
    }
    
    if (target == targets.unknown)
    {
        writeln("Could not determine target from '" ~ args[2] ~ "'.");
        return;
    }
    
    // determine compiler executable
    auto compilerExecutable = "";

    switch(args[1])
    {
        case "dmd":
            if (target != targets.linux)
            {
                writeln("DMD cannot build for target '" ~ cast(string)target ~ "`");
                return;
            }
            compilerExecutable = "dmd";
            break;
            
        case "gdc":
            switch(target)
            {
                case targets.linux:
                    compilerExecutable = "gdc";
                    break;
                    
                case targets.cortexm:
                    compilerExecutable = "arm-none-eabi-gdc";
                    break;
                    
                default:
                    writeln("Building with GDC for target '" ~ cast(string)target ~ "'is not yet supported");
                    return;
                    break;
            }
            break;
            
        case "ldc":
            if (target != targets.linux)
            {
                writeln("LDC cannot build for target '" ~ cast(string)target ~ "`");
                return;
            }
            else
            {
                writeln("LDC is currently not supported due to https://github.com/ldc-developers/ldc/issues/781");
                return;
            }
            compilerExecutable = "ldc2";
            break;
            
        default:
            writeln("Uknown compiler, '" ~ args[1] ~ "'");
            return;
            break;
    
    }

    // create compiler command
    auto cmd = "";
    switch(args[1])
    {
        case "dmd":
            cmd = compilerExecutable ~ " -c -defaultlib= -boundscheck=off";
            cmd ~= " -release";          // to get rid of module asserts
            cmd ~= " -betterC";          // no ModuleInfo
            cmd ~= " -I" ~ runtimeDir;
            cmd ~= " -I" ~ phobosDir;
            cmd ~= " -I" ~ buildPath(portDir, "runtime");
            cmd ~= " -I" ~ buildPath(portDir, "phobos");
            break;
            
        case "gdc":
            cmd = compilerExecutable ~ " -c -nophoboslib -nostdinc";
            cmd ~= " -fno-bounds-check -fno-in -fno-out -fno-invariants -fno-emit-moduleinfo";
            cmd ~= " -I " ~ runtimeDir;
            cmd ~= " -I " ~ phobosDir;
            cmd ~= " -I " ~ buildPath(portDir, "runtime");
            cmd ~= " -I " ~ buildPath(portDir, "phobos");
            break;
            
        case "ldc":
            cmd = compilerExecutable ~ " -c -singleobj -defaultlib= -boundscheck=off";
            cmd ~= " -I" ~ runtimeDir;
            cmd ~= " -I" ~ phobosDir;
            cmd ~= " -I" ~ buildPath(portDir, "runtime");
            cmd ~= " -I" ~ buildPath(portDir, "phobos");
            break;
            
        default:
            break;
    }
    
    // add user supplied arguments
    for(int i = 3; i < args.length; i++)
    {
        cmd ~= " " ~ args[i];
    }
    
    //rm all object files
    execute("rm -rf " ~ objDir ~ dirSeparator ~ "*.o");
    
    // collect source files to compile
    auto sourceFiles = runtimeDir.dirEntries("*.d", SpanMode.depth).array 
        ~ phobosDir.dirEntries("*.d", SpanMode.depth).array
        ~ portDir.dirEntries("*.d", SpanMode.depth).array
        ~ sourceDir.dirEntries("*.d", SpanMode.shallow).array;
        
    // for collecting object files to link later
    string[] objectFiles;
        
    // compile each source file to an object file
    foreach(sourceFile; sourceFiles)
    {        
        auto thisCmd = cmd ~ " " ~ sourceFile.name;
        auto objectFile = buildPath(objDir, sourceFile.name.replace(dirSeparator, "_") ~ ".o");
        objectFiles ~= objectFile;
        switch(args[1])
        {
            case "dmd":
                thisCmd ~= " -of" ~ objectFile;
                break;
                
            case "gdc":
                thisCmd ~= " -o " ~ objectFile;
                break;
                
            case "ldc":
                thisCmd ~= " -of=" ~ objectFile;
                break;
                
            default:
                break;
        }
        
        if (!execute(thisCmd))
        {
            return;
        }
    }
    
    // generate linker command
    auto linkerCmd = "";
    auto outputFile = buildPath(outDir, "main");
    switch(target)
    {
        case targets.linux:
            linkerCmd = "ld -o " ~ outputFile ~ " " ~ objectFiles.join(" ");
            break;
            
        case targets.cortexm:
            linkerCmd = "arm-none-eabi-ld -o " ~ outputFile ~ " " ~ objectFiles.join(" ");
            break;
            
        default:
            writeln("Can't determine which linker to use.");
            break;
    
    }
    
    //rm all object files
    execute("rm -rf " ~ outDir ~ dirSeparator ~ "*");
    
    // link
    execute(linkerCmd);
    
}