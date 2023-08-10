'NORMAL BLOCK=24X24
'CSONIC DRAW***************************
SCREEN 7: CLS
SVEF = 0
TOTPP = 0
X = 0: Y = 0: C = 1: CURCC = 0
LX = 24: LY = 24
DIM PIC(LX, LY)
DIM gfx%(209)
LINE (-1, -1)-(LX + 1, LY + 1), 1, B
BC:
a$ = INKEY$
IF a$ = CHR$(0) + "H" GOTO UP
IF a$ = CHR$(0) + "P" GOTO DOWN
IF a$ = CHR$(0) + "K" GOTO LEFT
IF a$ = CHR$(0) + "M" GOTO RIGHT
IF a$ = "O" OR a$ = "o" THEN GOTO OPTIONS
IF a$ = " " GOTO DRAWCOL
IF a$ = "S" THEN GOTO SVE
IF a$ = "L" THEN GOTO LD
IF a$ = "Q" GOTO QUIT
IF a$ = "-" THEN GOTO DL
IF a$ = "T" THEN GOTO TLATE
IF a$ = "f" THEN GOTO FLIPI
GOTO BC

UP:
IF Y - 1 < 0 THEN GOTO BC
COLD = CURCC
CURCC = POINT(X, Y - 1)
Y = Y - 1
PSET (X, Y), 2
PSET (X, Y + 1), COLD
LOCATE 23, 1: PRINT X; " "; Y; " "
GOTO BC

DOWN:
IF Y + 1 > LY + 1 THEN GOTO BC
COLD = CURCC
CURCC = POINT(X, Y + 1)
Y = Y + 1
PSET (X, Y), 2
PSET (X, Y - 1), COLD
LOCATE 23, 1: PRINT X; " "; Y; " "
GOTO BC

LEFT:
IF X - 1 < 0 THEN GOTO BC
COLD = CURCC
CURCC = POINT(X - 1, Y)
X = X - 1
PSET (X, Y), 2
PSET (X + 1, Y), COLD
LOCATE 23, 1: PRINT X; " "; Y; " "
GOTO BC

RIGHT:
IF X + 1 > LX + 1 THEN GOTO BC
COLD = CURCC
CURCC = POINT(X + 1, Y)
X = X + 1
PSET (X, Y), 2
PSET (X - 1, Y), COLD
LOCATE 23, 1: PRINT X; " "; Y; " "
GOTO BC

OPTIONS:
COLOR 1

LOCATE 20, 1: INPUT "COLOR TO USE"; C
LOCATE 20, 1: PRINT "                   "
GOTO BC

DRAWCOL:
PSET (X, Y), C
CURCC = C
IF L = 1 THEN GOTO DL2
IF SVEF = 1 THEN GOTO SVE2
GOTO BC

SVE:
BEEP
SVEF = 1
STARTNUMX = 0: STARTNUMY = 0
GOTO BC

SVE2:
LOCATE 23, 1: INPUT "SAVE->FILENAME? "; FI$
LOCATE 23, 1: PRINT "                                  "
IF FI$ = "XX" THEN SVEF = 0: GOTO BC
ENDNUMX = LX: ENDNUMY = LY
LOCATE 23, 1: PRINT "PLEASE WAIT... SAVING...   "
MFI$ = "C:\CSONIC\GFX\" + FI$ + ".GFX"
GET (0, 0)-(24, 24), gfx%
DEF SEG = VARSEG(gfx%(0))
BSAVE MFI$, VARPTR(gfx%(0)), 418
DEF SEG
SVEF = 0
LOCATE 23, 1: PRINT "                           "
GOTO BC

LD:
LOCATE 23, 1: INPUT "LOAD->FILENAME? "; FL$
LOCATE 23, 1: PRINT "                      "
IF FL$ = "XX" THEN GOTO BC
CLS
TOTPP = 0
MFL$ = "C:\CSONIC\GFX\" + FL$ + ".GFX"
DEF SEG = VARSEG(gfx%(0))
BLOAD MFL$, VARPTR(gfx%(0))
DEF SEG
PUT (0, 0), gfx%, PSET
LINE (-1, -1)-(LX + 1, LY + 1), 1, B
GOTO BC

DL:
L = 1
LOCATE 23, 1: PRINT "LINE TO?"
X1 = X: Y1 = Y
GOTO BC

DL2:
L = 0
LOCATE 23, 1: PRINT "        "
X2 = X: Y2 = Y
LINE (X1, Y1)-(X2, Y2), C, BF
GOTO BC

TLATE:
LOCATE 23, 1: INPUT "Translate x,y", t1, t2
IF t1 = 0 AND t2 = 0 THEN LOCATE 23, 1: PRINT "              ": GOTO BC
FOR zy = 0 TO LY
FOR zx = 0 TO LX
IF POINT(zx, zy) = t1 THEN PSET (zx, zy), t2
NEXT
NEXT
LOCATE 23, 1: PRINT "              ": GOTO BC

FLIPI:
LOCATE 23, 1: INPUT "Flip y/n", t$: IF t$ = "y" THEN GOTO f2 ELSE LOCATE 23, 1: PRINT "            ": GOTO BC
f2:
LOCATE 23, 1: INPUT "H/V", t$: IF t$ = "H" THEN GOTO f3 ELSE GOTO f4
f3:
LOCATE 23, 1: PRINT "Please wait...        "
FOR zy = 0 TO LY
FOR zx = 0 TO LX
PIC(zx, zy) = POINT(zx, zy)
NEXT
NEXT
LINE (0, 0)-(LX, LY), 0, BF
FOR z = 0 TO LY
FOR z2 = 0 TO LX
PSET (LX - z2, z), PIC(z2, z)
NEXT
NEXT
LOCATE 23, 1: PRINT "                      "
GOTO BC:
f4:
LOCATE 23, 1: PRINT "Please wait...        "
FOR zy = 0 TO LY
FOR zx = 0 TO LX
PIC(zx, zy) = POINT(zx, zy)
NEXT
NEXT
LINE (0, 0)-(LX, LY), 0, BF
FOR z = 0 TO LY
FOR z2 = 0 TO LX
PSET (z2, LY - z), PIC(z2, z)
NEXT
NEXT
LOCATE 23, 1: PRINT "                      "
GOTO BC:

QUIT:




