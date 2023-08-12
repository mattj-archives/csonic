@set MSQLB=c:\vbdos\lib\vbdosqlb.lib
@set MSLIB=c:\vbdos\lib\vbdos.lib
@del kbd.lib
@del kbd.qlb

c:\bp\bin\tasm kbd.asm

lib kbd.lib +kbd.obj -+%MSLIB%;

link /q kbd.lib,kbd.qlb,,%MSQLB%,,
rem @copy kbd.lib c:\escape\kbd.lib
rem @copy kbd.qlb c:\escape\kbd.qlb
:done