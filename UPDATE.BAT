@echo off
echo Now updating CSONIC...                                    1.0-- January 2, 2001
md gfx
md levels
echo .
echo If you get an Overwrite?[y,n,a] prompt, answer by pressing [a]
pause
move *.lev levels
echo If you get an Overwrite?[y,n,a] prompt, answer by pressing [a]
move *.lst gfx
echo If you get an Overwrite?[y,n,a] prompt, answer by pressing [a]
move *.gfx gfx
echo Done!
echo Use the QB PDS 7.1 to run CSONIC, or use the CSONIC.EXE file.
echo .
echo ------------------------------------------------------------------------------
echo CSONIC 1.0                            Updates:
echo ------------------------------------------------------------------------------
echo                                       All files
echo ------------------------------------------------------------------------------
echo .

