@echo off
call "H:\Simon\Applications\Visual studio\VS\VC\Auxiliary\Build\vcvarsall.bat" x86
nasm -f win32 -g -o %~dp0%1.obj %1.asm
link.exe /subsystem:console /entry:start /debug %~dp0%1.obj /out:%~dp0%1.exe Kernel32.lib
