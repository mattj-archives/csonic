DEFINT A-Z
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

COMMON SHARED a(), p()
COMMON SHARED bcnt()
COMMON SHARED bpot() AS badguy, mosqu() AS badguy, rm() AS badguy
COMMON SHARED stage, SonicDir
COMMON SHARED act, strx, stry

REM $STATIC
SUB enemy.mgr ()
SELECT CASE stage
CASE 1
'enemy.mgr1
END SELECT

END SUB

SUB enemy.mgr1 ()
tmve = 0
'get rid of that EXIT SUB for the next enemy
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

