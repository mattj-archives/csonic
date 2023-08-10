DEFINT A-Z
DECLARE SUB ChangeGFX (p%())
DECLARE SUB ReDrawAround (tx, ty)
DECLARE FUNCTION OS (tx, ty)
DECLARE SUB ReDrawObj (tx, ty, ttx, tty, n)
DECLARE SUB DrawGfx (n)
DECLARE SUB enemy.mgr1 ()
'Cool Sonic ver 1.0 MODULE 2
' $DYNAMIC
TYPE badguy
x AS INTEGER
y AS INTEGER
x1 AS INTEGER
x2 AS INTEGER
y1 AS INTEGER
y2 AS INTEGER
t AS LONG
f1 AS INTEGER
f2 AS INTEGER
f3 AS INTEGER
state AS INTEGER
last AS INTEGER
num AS INTEGER
step AS INTEGER
END TYPE

COMMON SHARED bg11%(), bg12%(), bg13%(), bg14%()
COMMON SHARED bg21%(), bg22%(), bg23%(), bg24%()
COMMON SHARED bp%(), gfx%()
COMMON SHARED a(), x, y
COMMON SHARED p%(), bcnt()
COMMON SHARED bpot() AS badguy, mosqu() AS badguy, back%(), rm() AS badguy
COMMON SHARED stage, SonicDir
COMMON SHARED act, strx, stry

REM $STATIC
SUB enemy.mgr
SELECT CASE stage
CASE 1
enemy.mgr1
END SELECT

END SUB

SUB enemy.mgr1
tmve = 0
'get rid of that EXIT SUB for the next enemy
FOR z = 1 TO bcnt(3)
IF bpot(z).state = 1 THEN
 IF TIMER - bpot(z).t > .5 THEN
  IF bpot(z).f2 = 3 THEN
   IF bpot(z).f1 = 1 THEN bpot(z).f1 = 2 ELSE bpot(z).f1 = 1
   bpot(z).f2 = 0
   'EXIT SUB
  END IF
  
  IF bpot(z).f1 = 1 THEN
   bpot(z).y = bpot(z).y - 1
   a(bpot(z).x, bpot(z).y + 1) = 0
   a(bpot(z).x, bpot(z).y) = 72
   bpot(z).t = TIMER
   IF bpot(z).f2 = 3 THEN bpot(z).f2 = 0 ELSE bpot(z).f2 = bpot(z).f2 + 1
  temp1 = bpot(z).x: temp2 = bpot(z).y
  IF OS(temp1, temp2) = 1 THEN ReDrawObj temp1, temp2, temp1 - strx, temp2 - stry, 0
  ReDrawObj temp1, temp2 + 1, temp1 - strx, temp2 - stry + 1, 0
 
  END IF
  IF bpot(z).f1 = 2 THEN
   bpot(z).y = bpot(z).y + 1
   a(bpot(z).x, bpot(z).y - 1) = 0
   a(bpot(z).x, bpot(z).y) = 72
   bpot(z).t = TIMER
  IF bpot(z).f2 = 3 THEN bpot(z).f2 = 0 ELSE bpot(z).f2 = bpot(z).f2 + 1
  temp1 = bpot(z).x: temp2 = bpot(z).y
  IF OS(temp1, temp2) = 1 THEN ReDrawObj temp1, temp2, temp1 - strx, temp2 - stry, 0
  ReDrawObj temp1, temp2 - 1, temp1 - strx, temp2 - stry - 1, 0
 
  END IF
 END IF
END IF
NEXT
'******************************************************************
FOR z = 1 TO mosqu(1).last
 IF mosqu(z).state = 1 THEN
  IF TIMER - mosqu(z).t > .5 THEN
   IF mosqu(z).f1 = 1 THEN
    IF mosqu(z).step = 2 THEN
     IF mosqu(z).x - 1 < mosqu(z).x2 THEN mosqu(z).f1 = 2: mosqu(z).step = 1: GOTO 10
    ELSE
     IF mosqu(z).x - 1 < mosqu(z).x1 THEN mosqu(z).f1 = 2: mosqu(z).step = 2: GOTO 10
    END IF
    mosqu(z).x = mosqu(z).x - 1: tmve = 1
    a(mosqu(z).x, mosqu(z).y) = 71
    a(mosqu(z).x + 1, mosqu(z).y) = 0
   ELSE
    IF mosqu(z).step = 2 THEN
     IF mosqu(z).x + 1 > mosqu(z).x2 THEN mosqu(z).f1 = 1: mosqu(z).step = 1: GOTO 10
    ELSE
     IF mosqu(z).x + 1 > mosqu(z).x1 THEN mosqu(z).f1 = 1: mosqu(z).step = 2: GOTO 10
    END IF
    mosqu(z).x = mosqu(z).x + 1: tmve = 1
    a(mosqu(z).x, mosqu(z).y) = 71
    a(mosqu(z).x - 1, mosqu(z).y) = 0

   END IF
  mosqu(z).t = TIMER
10
  END IF
 END IF
 '**************************
 IF x = mosqu(z).x AND y - mosqu(z).y < 10 AND y - mosqu(z).y > 0 AND mosqu(z).state = 1 THEN
  mosqu(z).state = 2: mosqu(z).f1 = 1: mosqu(z).t = TIMER: tmve = 1: GOTO 20
 END IF
 IF mosqu(z).state = 2 THEN
  IF TIMER - mosqu(z).t > 1 THEN mosqu(z).state = 3: mosqu(z).f2 = 1: mosqu(z).t = TIMER: tmve = 1
  GOTO 20
 END IF
 '***************************
 IF mosqu(z).state = 3 THEN
  IF TIMER - mosqu(z).t > 1 THEN
   IF mosqu(z).f2 = 1 THEN
    mosqu(z).f2 = 2: mosqu(z).t = TIMER: tmve = 1: GOTO 20
   ELSE
    mosqu(z).state = 4: tmve = 1: GOTO 20
   END IF
  END IF
 END IF
 IF mosqu(z).state = 4 THEN
  IF TIMER - mosqu(z).t > .7 THEN
   IF a(mosqu(z).x, mosqu(z).y + 1) = 1 THEN mosqu(z).state = 5: tmve = 1: GOTO 20
   mosqu(z).y = mosqu(z).y + 1: tmve = 1
   mosqu(z).t = TIMER: mosqu(z).f2 = 2
   a(mosqu(z).x, mosqu(z).y) = 71
   a(mosqu(z).x, mosqu(z).y - 1) = 0

  END IF
 END IF
20
 IF tmve = 1 THEN
  temp1 = mosqu(z).x: temp2 = mosqu(z).y
  ReDrawAround temp1, temp2
  IF OS(temp1, temp2) = 1 THEN ReDrawObj temp1, temp2, temp1 - strx, temp2 - stry, z
 END IF
NEXT
tmve = 0
'*****************************************************
FOR z = 1 TO bcnt(2)
 IF rm(z).state = 1 THEN
  IF TIMER - rm(z).t > .5 THEN

   IF SonicDir = 3 THEN
    IF x < rm(z).x THEN           'move left
     IF a(rm(z).x - 1, rm(z).y + 1) = 1 THEN
      rm(z).x = rm(z).x - 1: rm(z).f1 = 1: rm(z).t = TIMER
      a(rm(z).x + 1, rm(z).y) = 0
      a(rm(z).x, rm(z).y) = 70: tmve = 1: GOTO 30
     END IF
    ELSE
     rm(z).state = 2: tmve = 1: GOTO 30
    END IF
    IF a(rm(z).x + 1, rm(z).y + 1) = 1 THEN
     rm(z).x = rm(z).x + 1: rm(z).f1 = 2: rm(z).t = TIMER
     a(rm(z).x - 1, rm(z).y) = 0
     a(rm(z).x, rm(z).y) = 70: tmve = 1: GOTO 30
    END IF
   END IF
   IF SonicDir = 4 THEN
    IF x < rm(z).x THEN           'move left
     rm(z).state = 2: tmve = 1: GOTO 30
    ELSE
    IF a(rm(z).x + 1, rm(z).y + 1) = 1 THEN
     rm(z).x = rm(z).x + 1: rm(z).f1 = 2: rm(z).t = TIMER
     a(rm(z).x - 1, rm(z).y) = 0
     a(rm(z).x, rm(z).y) = 70: tmve = 1: GOTO 30
    END IF
   END IF
   

    rm(z).state = 2: tmve = 1: GOTO 30
   END IF
  END IF
 END IF
 IF rm(z).state = 2 THEN
  IF x < rm(z).x THEN
   IF SonicDir = 3 THEN
    rm(z).state = 1: rm(z).t = TIMER: rm(z).f1 = 1: tmve = 1: GOTO 30
   END IF
  END IF
  IF x > rm(z).x THEN
   IF SonicDir = 4 THEN
    rm(z).state = 1: rm(z).t = TIMER: rm(z).f1 = 2: tmve = 1: GOTO 30
   END IF
  END IF
 END IF
30
IF rm(z).state <> 0 THEN
 IF tmve = 1 THEN
  temp1 = rm(z).x: temp2 = rm(z).y
  ReDrawAround temp1, temp2
  IF OS(temp1, temp2) = 1 THEN ReDrawObj temp1, temp2, temp1 - strx, temp2 - stry, z
 END IF
END IF
NEXT
tmve = 0

END SUB

SUB loadtoact
stage = 1
COLOR 2: PRINT "Loading graphics..."
DEF SEG = VARSEG(gfx%(0)): BLOAD "gfx\p1.gfx", VARPTR(gfx%(0)): ChangeGFX bp%()

SELECT CASE stage
CASE 1
'RMs
DEF SEG = VARSEG(gfx%(0)): BLOAD "gfx\rm1.gfx", VARPTR(gfx%(0)): ChangeGFX bg11%()
DEF SEG = VARSEG(gfx%(0)): BLOAD "gfx\rm2.gfx", VARPTR(gfx%(0)): ChangeGFX bg12%()
DEF SEG = VARSEG(gfx%(0)): BLOAD "gfx\rm3.gfx", VARPTR(gfx%(0)): ChangeGFX bg13%()
'Mosquitoes
DEF SEG = VARSEG(gfx%(0)): BLOAD "gfx\mosqu1.gfx", VARPTR(gfx%(0)): ChangeGFX bg21%()
DEF SEG = VARSEG(gfx%(0)): BLOAD "gfx\mosqu2.gfx", VARPTR(gfx%(0)): ChangeGFX bg22%()
DEF SEG = VARSEG(gfx%(0)): BLOAD "gfx\mosqu3.gfx", VARPTR(gfx%(0)): ChangeGFX bg23%()
DEF SEG = VARSEG(gfx%(0)): BLOAD "gfx\mosqu4.gfx", VARPTR(gfx%(0)): ChangeGFX bg24%()
END SELECT
CLS
END SUB

