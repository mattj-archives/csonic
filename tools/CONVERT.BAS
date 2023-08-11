DECLARE SUB StartUp ()
StartUp

SCREEN 7

' Convert the EGA graphics into VGA 8-bpp raw files

DIM gfx(420) AS INTEGER
CLS
f$ = DIR$("GFX\*.GFX")
DO
   IF LEN(f$) = 0 THEN EXIT DO
   name$ = LEFT$(f$, INSTR(f$, ".GFX") - 1)


   infile$ = "GFX\" + f$
   outfile$ = "GFX2\" + name$ + ".2"
   LOCATE 24, 1: PRINT SPACE$(40);
   LOCATE 25, 1: PRINT SPACE$(40);

   LOCATE 24, 1: PRINT infile$;
   LOCATE 25, 1: PRINT outfile$;
   DEF SEG = VARSEG(gfx(0))
   BLOAD infile$, VARPTR(gfx(0))
   PUT (0, 0), gfx, PSET
   
   OPEN outfile$ FOR BINARY AS #1
        FOR y = 0 TO 24
         FOR x = 0 TO 24
          a% = POINT(x, y)
          PUT #1, (y * 25 + x + 1), a%
         NEXT
        NEXT
   CLOSE #1

   LOCATE 23, 1: PRINT gfx(0), gfx(1)
   f$ = DIR$

   SLEEP .5
LOOP

SCREEN 0: WIDTH 80: CLS

