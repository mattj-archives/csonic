@set MSQLB=c:\vbdos\lib\vbdosqlb.lib
@set MSLIB=c:\vbdos\lib\vbdos.lib
@set ASM=c:\bp\bin\tasm
@del kbd.lib
@del kbd.qlb

%ASM% main.asm
@if errorlevel 1 goto done

%ASM% gfx.asm
@if errorlevel 1 goto done

%ASM% kbd.asm
@if errorlevel 1 goto done

%ASM% put2.asm
@if errorlevel 1 goto done

lib kbd.lib +main.obj +kbd.obj +put2.obj +gfx.obj -+%MSLIB%;
@if errorlevel 1 goto done

link /q kbd.lib,kbd.qlb,,%MSQLB%,,
rem @copy kbd.lib c:\escape\kbd.lib
rem @copy kbd.qlb c:\escape\kbd.qlb
:done
